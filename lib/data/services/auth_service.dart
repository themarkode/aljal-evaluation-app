import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication service - Simple approach:
/// 1. User logs in → store password hash locally
/// 2. Every 15 seconds → compare with Firebase password
/// 3. If different → logout
class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyPasswordHash = 'password_hash';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Hash a password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
  
  /// Get password from Firebase
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
  
  /// Get username from Firebase
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
  
  /// Check if user should be logged out (password changed in Firebase)
  Future<bool> shouldLogout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Not logged in? No need to check
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return false;
    
    // Get stored password hash
    final storedHash = prefs.getString(_keyPasswordHash);
    if (storedHash == null) return false;
    
    // Get current password from Firebase
    final firebasePassword = await _getFirebasePassword();
    if (firebasePassword == null) return false; // Can't reach Firebase, don't logout
    
    // Compare hashes
    final currentHash = _hashPassword(firebasePassword);
    if (storedHash != currentHash) {
      print('Password changed in Firebase! Logging out...');
      return true;
    }
    
    return false;
  }
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    
    if (!isLoggedIn) return false;
    
    // Check if password changed
    final shouldLogoutUser = await shouldLogout();
    if (shouldLogoutUser) {
      await logout();
      return false;
    }
    
    return true;
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
    
    print('Firebase username: "$firebaseUsername"');
    print('Input username: "${username.trim()}"');
    print('Firebase password: "$firebasePassword"');
    print('Input password: "$password"');
    
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
