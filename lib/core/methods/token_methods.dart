import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class TokenUtils {
  // Add your utility methods here
  Future<String?> getBearerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveToken(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', accessToken);
  }

  Future<void> clearToken() async {}
}
