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

  Color _getLogColor(int type) {
    if (type == 8) return const Color(0xFFFF3B30); // Error
    if (type == 4) return const Color(0xFFFF9500); // Warning
    if (type == 2) return const Color(0xFF34C759); // Info
    return themeNotifier.value ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.value;
    return CupertinoPageScaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      navigationBar: CupertinoNavigationBar(
        middle: const Text("运行日志"),
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
                              color: _getLogColor(type),
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
  }
}
