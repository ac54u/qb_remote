import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ServerManager {
  static const String key = 'servers_v2';
  static const String idxKey = 'current_server_idx';

  static Future<List<Map<String, dynamic>>> getServers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(key);
    if (jsonStr == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(jsonStr));
  }

  static Future<bool> hasServers() async {
    final list = await getServers();
    return list.isNotEmpty;
  }

  static Future<void> addServer(Map<String, dynamic> server) async {
    final list = await getServers();
    list.add(server);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(list));
    if (list.length == 1) await setCurrentIndex(0);
  }

  static Future<void> updateServer(
    int index,
    Map<String, dynamic> server,
  ) async {
    final list = await getServers();
    list[index] = server;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(list));
  }

  static Future<void> removeServer(int index) async {
    final list = await getServers();
    list.removeAt(index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(list));
    await setCurrentIndex(0);
  }

  static Future<int> getCurrentIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(idxKey) ?? 0;
  }

  static Future<void> setCurrentIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(idxKey, index);
  }

  static Future<Map<String, dynamic>?> getCurrentServer() async {
    final list = await getServers();
    final idx = await getCurrentIndex();
    if (list.isEmpty || idx >= list.length) return null;
    return list[idx];
  }
}
