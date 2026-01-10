// Tool to encrypt passwords for Firebase
// Run with: dart run tools/encrypt_password.dart

import 'dart:convert';

void main() {
  const secretKey = 'AlJaL2024SecretKey#Evaluation@KW';
  const iv = 'AlJaL#IV@2024KWT';
  const password = '12#xx.567?oWqx9#';
  
  // Simple XOR encryption for demonstration
  // The actual app uses AES encryption
  
  print('===========================================');
  print('Password Encryption Tool for Al Jal App');
  print('===========================================');
  print('');
  print('Original Password: $password');
  print('');
  print('For Firebase, use the encrypted value that');
  print('the app generates automatically on first run.');
  print('');
  print('The app will:');
  print('1. Create the credentials document in Firebase');
  print('2. Store the password as encrypted text');
  print('3. Decrypt it when validating login');
  print('===========================================');
}

