import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'jwt_token';

  // store Token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  // read Token
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  // delete Token 
  static Future<void> clearToken() async {
    await _storage.delete(key: _keyToken);
  }
}