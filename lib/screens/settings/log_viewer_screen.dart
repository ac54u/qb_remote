import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants.dart';
import '../../services/api_service.dart';

class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  List<dynamic> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fetchLogs();
    });
  }

  Future<void> _fetchLogs() async {
    final l = await ApiService.getServerLogs();
    if (mounted) {
      setState(() {
        _logs = l.reversed.toList();
        _loading = false;
      });
    }
  }

  // 修改点1：增加 isDark 参数，确保日志文字也能随主题变色
  Color _getLogColor(int type, bool isDark) {
    if (type == 8) return const Color(0xFFFF3B30); // Error
    if (type == 4) return const Color(0xFFFF9500); // Warning
    if (type == 2) return const Color(0xFF34C759); // Info
    return isDark ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    // 修改点2：使用 ValueListenableBuilder 包裹整个脚手架
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, isDark, child) {
        return CupertinoPageScaffold(
          // 动态背景色
          backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
          navigationBar: CupertinoNavigationBar(
            middle: Text(
              "运行日志",
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            // 动态导航栏背景
            backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _fetchLogs,
              child: const Icon(CupertinoIcons.refresh),
            ),
          ),
          child: SafeArea(
            child: _loading
                ? const Center(child: CupertinoActivityIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: _logs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      final msg = log['message'] ?? '';
                      final timestamp = log['timestamp'] ?? 0;
                      final type = log['type'] ?? 0;
                      
                      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp).toUtc().add(const Duration(hours: 8));
                      final timeStr = "${dateTime.month.toString().padLeft(2,'0')}-${dateTime.day.toString().padLeft(2,'0')} ${dateTime.hour.toString().padLeft(2,'0')}:${dateTime.minute.toString().padLeft(2,'0')}:${dateTime.second.toString().padLeft(2,'0')}";

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "[$timeStr]",
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                msg,
                                style: TextStyle(
                                  fontSize: 12,
                                  // 修改点3：传入当前的 isDark 状态
                                  color: _getLogColor(type, isDark),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}