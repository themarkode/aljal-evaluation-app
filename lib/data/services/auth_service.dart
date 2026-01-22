import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication service - Real-time approach:
/// 1. User logs in → store password hash locally
/// 2. Listen to Firebase password changes in real-time (no polling!)
/// 3. If password changes → trigger logout callback
class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyPasswordHash = 'password_hash';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream subscription for real-time password changes
  StreamSubscription<DocumentSnapshot>? _credentialsSubscription;

  /// Callback to execute when password changes (logout user)
  void Function()? _onPasswordChanged;

  /// Hash a password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Start listening to credential changes in real-time
  /// This replaces the 15-second polling with instant detection
  Future<void> startListeningToCredentialChanges(
      void Function() onPasswordChanged) async {
    _onPasswordChanged = onPasswordChanged;

    // Cancel any existing subscription
    await _credentialsSubscription?.cancel();

    // Get current stored hash for comparison
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

    if (!isLoggedIn) return; // Not logged in, no need to listen

    final storedHash = prefs.getString(_keyPasswordHash);
    if (storedHash == null) return;

    // Listen to real-time changes on the credentials document
    _credentialsSubscription = _firestore
        .collection('app_settings')
        .doc('credentials')
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return;

      final firebasePassword = snapshot.data()!['password'] as String?;
      if (firebasePassword == null) return;

      final currentHash = _hashPassword(firebasePassword);

      // If hash is different, password was changed - trigger logout
      if (storedHash != currentHash) {
        print('🔒 Password changed in Firebase! Triggering logout...');
        _onPasswordChanged?.call();
      }
    }, onError: (error) {
      print('Error listening to credentials: $error');
    });

    print('✅ Started real-time listener for credential changes');
  }

  /// Stop listening to credential changes
  Future<void> stopListeningToCredentialChanges() async {
    await _credentialsSubscription?.cancel();
    _credentialsSubscription = null;
    _onPasswordChanged = null;
    print('🛑 Stopped real-time listener for credential changes');
  }

  /// Get password from Firebase (one-time fetch for login)
  Future<String?> _getFirebasePassword() async {
    try {
      final doc = await _firestore
          .collection('app_settings')
          .doc('credentials')
          .get()
          .timeout(const Duration(seconds: 5));

      if (doc.exists && doc.data() != null) {
        return doc.data()!['password'] as String?;
      }
      return null;
    } catch (e) {
      print('Failed to get Firebase password: $e');
      return null;
    }
  }

  /// Get username from Firebase (one-time fetch for login)
  Future<String?> _getFirebaseUsername() async {
    try {
      final doc = await _firestore
          .collection('app_settings')
          .doc('credentials')
          .get()
          .timeout(const Duration(seconds: 5));

      if (doc.exists && doc.data() != null) {
        return doc.data()!['username'] as String?;
      }
      return null;
    } catch (e) {
      print('Failed to get Firebase username: $e');
      return null;
    }
  }

  /// Check if user is authenticated (simple check, no Firebase call)
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Login with username and password
  /// Returns: 'success', 'network_error', or 'invalid_credentials'
  Future<String> loginWithResult(String username, String password) async {
    // Get credentials from Firebase
    final firebaseUsername = await _getFirebaseUsername();
    final firebasePassword = await _getFirebasePassword();

    if (firebaseUsername == null || firebasePassword == null) {
      print('Could not fetch credentials from Firebase');
      return 'network_error';
    }

    // Validate credentials
    if (username.trim() != firebaseUsername || password != firebasePassword) {
      print('Credentials do not match!');
      return 'invalid_credentials';
    }

    // Save session with password hash
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyPasswordHash, _hashPassword(password));

    return 'success';
  }

  /// Simple login (for backward compatibility)
  Future<bool> login(String username, String password) async {
    final result = await loginWithResult(username, password);
    return result == 'success';
  }

  /// Logout
  Future<void> logout() async {
    // Stop listening to changes
    await stopListeningToCredentialChanges();

    // Clear local session
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyPasswordHash);
  }

  /// Get error message in Arabic
  static String getErrorMessage(String error) {
    switch (error) {
      case 'invalid_credentials':
        return 'اسم المستخدم أو كلمة المرور غير صحيحة';
      case 'network_error':
        return 'لا يمكن الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت';
      case 'password_changed':
        return 'تم تغيير كلمة المرور، يرجى تسجيل الدخول مرة أخرى';
      default:
        return 'حدث خطأ، يرجى المحاولة مرة أخرى';
    }
  }
}
