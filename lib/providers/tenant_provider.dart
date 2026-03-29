import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TenantProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadTenant(user.uid);
      } else {
        _clearTenant();
      }
    });
  }

  Future<void> _loadTenant(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch user doc to get their assigned tenantId
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        _tenantId = userDoc.data()!['tenantId'] as String?;
        
        if (_tenantId != null) {
          // 2. Fetch the tenant configuration
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

  void _clearTenant() {
    _tenantId = null;
    _tenantConfig = null;
    _isLoading = false;
    notifyListeners();
  }
}
