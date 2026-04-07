import 'dart:async';
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
  String? _errorMessage;

  String? get tenantId => _tenantId;
  Map<String, dynamic>? get tenantConfig => _tenantConfig;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TenantProvider() {
    _init();
  }

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  StreamSubscription<DocumentSnapshot>? _tenantSubscription;

  void _init() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadTenant(user.uid);
      } else {
        _clearTenant();
      }
    });
  }

  // Main background loading and listening
  void _loadTenant(String uid) {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _userSubscription?.cancel();
    _userSubscription = _firestore.collection('users').doc(uid).snapshots().listen((userDoc) {
      if (userDoc.exists && userDoc.data() != null) {
        final newTenantId = userDoc.data()!['tenantId'] as String?;
        if (newTenantId != null && newTenantId.isNotEmpty) {
          if (newTenantId != _tenantId) {
            _tenantId = newTenantId;
            _setupTenantSubscription(_tenantId!);
          }
        } else {
          _errorMessage = "User profile has no assigned tenant.";
          _isLoading = false;
          notifyListeners();
        }
      } else {
        // Doc doesn't exist yet - this is expected during registration for a moment
        // We stay in loading state
        debugPrint("User profile doc not found yet for uid: $uid");
      }
    }, onError: (e) {
      _errorMessage = "Error loading user profile: $e";
      _isLoading = false;
      notifyListeners();
    });
  }

  void _setupTenantSubscription(String tId) {
    _tenantSubscription?.cancel();
    _tenantSubscription = _firestore.collection('tenants').doc(tId).snapshots().listen((tenantDoc) {
      if (tenantDoc.exists) {
        _tenantConfig = tenantDoc.data();
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = "Business configuration not found.";
        _clearTenant();
      }
    }, onError: (e) {
      _errorMessage = "Error listening to business info: $e";
      _clearTenant();
    });
  }

  // Registration Logic
  Future<void> registerAndInitialize({
    required String email,
    required String password,
    required String businessName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
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
        // authStateChanges listener handles the UI transition via _loadTenant
      }
    } catch (e) {
      debugPrint("Registration error: $e");
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.signIn(email, password);
    } catch (e) {
      debugPrint("Login error: $e");
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
    // We don't set _isLoading = false here; _loadTenant will do it.
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  void _clearTenant() {
    _userSubscription?.cancel();
    _tenantSubscription?.cancel();
    _tenantId = null;
    _tenantConfig = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateBusinessSettings(Map<String, dynamic> data) async {
    if (_tenantId == null) return;
    try {
      await _dbService.updateTenantConfig(_tenantId!, data);
    } catch (e) {
      debugPrint("Error updating business settings: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userSubscription?.cancel();
    _tenantSubscription?.cancel();
    super.dispose();
  }
}
