import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class TenantProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  String? _tenantId;
  Map<String, dynamic>? _tenantConfig;
  bool _isLoading = false;

  String? get tenantId => _tenantId;
  Map<String, dynamic>? get tenantConfig => _tenantConfig;
  bool get isLoading => _isLoading;

  TenantProvider() {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadTenant(user.uid);
      } else {
        _clearTenant();
      }
    });
  }

  // Main background loading
  Future<void> _loadTenant(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        _tenantId = userDoc.data()!['tenantId'] as String?;
        
        if (_tenantId != null) {
          final tenantDoc = await _firestore.collection('tenants').doc(_tenantId!).get();
          if (tenantDoc.exists) {
            _tenantConfig = tenantDoc.data();
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading tenant: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Registration Logic
  Future<void> registerAndInitialize({
    required String email,
    required String password,
    required String businessName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Create Auth User
      final credential = await _authService.register(email, password);
      if (credential?.user != null) {
        // 2. Initialize Firestore Data (Tenant + User profile)
        await _dbService.initializeNewTenant(
          uid: credential!.user!.uid,
          email: email,
          businessName: businessName,
        );
        // Note: authStateChanges listener will trigger _loadTenant
      }
    } catch (e) {
      debugPrint("Registration error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signIn(email, password);
    } catch (e) {
      debugPrint("Login error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  void _clearTenant() {
    _tenantId = null;
    _tenantConfig = null;
    _isLoading = false;
    notifyListeners();
  }
}
