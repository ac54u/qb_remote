import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart'; // 引入 main.dart 以使用全局 notification 插件
import '../services/api_service.dart';
import '../core/constants.dart';

// 引入四个主页面
import 'torrent/torrent_list_screen.dart';
import 'stats/statistics_screen.dart';
import 'search/search_screen.dart';
import 'settings/settings_screen.dart';

class MainTabScaffold extends StatefulWidget {
  const MainTabScaffold({super.key});

  @override
  State<MainTabScaffold> createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<MainTabScaffold> {
  Timer? _notificationTimer;
  // 记录每个任务的上一次状态 {hash: state}
  final Map<String, String> _lastStates = {};

  @override
  void initState() {
    super.initState();
    _startNotificationService();
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  // 🔔 核心逻辑：轮询检查下载状态 (支持 完成 + 报错)
  void _startNotificationService() {
    // 每 5 秒检查一次
    _notificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      // 1. 获取最新种子列表
      final torrents = await ApiService.getTorrents();
      if (torrents == null) return;

      for (var t in torrents) {
        final hash = t['hash'];
        final name = t['name'];
        final state = t['state']; 
        
        // 2. 获取旧状态
        final oldState = _lastStates[hash];

        // --- 情况一：刚刚下载完成 ---
        // 旧状态是“下载中”，新状态是“做种”或“完成”
        if (oldState != null && 
           (oldState == 'downloading' || oldState == 'forcedDL') && 
           (state == 'up' || state == 'uploading' || state == 'pausedUP' || state == 'stalledUP' || state == 'completed')) {
          
          _showNotification("下载完成 🎉", name);
        }

        // --- 情况二：任务出错了 (硬盘满、读写错误、文件丢失) ---
        // 只有当旧状态“不是错误”，而新状态“是错误”时才通知 (防止一直弹窗)
        if (oldState != null && 
           oldState != 'error' && oldState != 'missingFiles' &&
           (state == 'error' || state == 'missingFiles')) {
          
          _showNotification("⚠️ 下载出错", "$name (请检查硬盘或文件)");
        }

        // 3. 更新记录
        _lastStates[hash] = state;
      }
    });
  }

  // 🔔 通用的通知发送方法 (支持自定义标题和内容)
  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'download_channel',
      '下载通知',
      channelDescription: '通知下载完成状态',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // ID
      title, 
      body, 
      details,
    );
  }

  void _onTap(int index) {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, isDark, child) {
        return CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            onTap: _onTap,
            backgroundColor: isDark
                ? const Color(0xCC1C1C1E)
                : const Color(0xCCFFFFFF),
            activeColor: kPrimaryColor,
            inactiveColor: Colors.grey,
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white10 : const Color(0x1A000000),
                width: 0.0,
              ),
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.arrow_down_circle_fill),
                label: "下载",
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.graph_square_fill),
                label: "统计",
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.search),
                label: "搜索",
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.gear_solid),
                label: "设置",
              ),
            ],
          ),
          tabBuilder: (context, index) {
            switch (index) {
              case 0:
                return const TorrentListScreen();
              case 1:
                return const StatisticsScreen();
              case 2:
                return const SearchScreen();
              case 3:
                return const SettingsScreen();
              default:
                return const TorrentListScreen();
            }
          },
        );
      },
    );
  }
}
