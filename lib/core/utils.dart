import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'constants.dart'; // 引用上面的 constants.dart

class Utils {
  static Map<String, dynamic> cleanFileName(String raw) {
    final yearReg = RegExp(r"(19|20)\d{2}");
    final yearMatch = yearReg.firstMatch(raw);
    String title = raw;
    String? year;

    if (yearMatch != null) {
      year = yearMatch.group(0);
      title = raw.substring(0, yearMatch.start);
    }

    title = title
        .replaceAll('.', ' ')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r"^\[.*?\]"), "")
        .trim();

    return {'title': title, 'year': year};
  }

  static String formatBytes(dynamic b) {
    if (b is! num || b <= 0) return "0 B";
    const s = ["B", "KB", "MB", "GB", "TB", "PB"];
    int i = (log(b) / log(1024)).floor();
    if (i >= s.length) i = s.length - 1;
    return "${(b / pow(1024, i)).toStringAsFixed(1)} ${s[i]}";
  }

  static bool isValidHash(String? h) {
    if (h == null) return false;
    return RegExp(r'^[a-fA-F0-9]{40}$').hasMatch(h);
  }

  static void showToast(String msg) {
    HapticFeedback.mediumImpact();
    Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }
}
