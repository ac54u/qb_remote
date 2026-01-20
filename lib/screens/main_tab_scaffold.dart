import 'dart:async'; // 引入 Timer
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // 引入通知包
import '../main.dart'; // 引入 main.dart 以使用全局 notification 插件
import '../services/api_service.dart'; // 引入 API 服务
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
  // 记录每个任务的上一次状态 {hash: state}，用于判断状态变化
  final Map<String, String> _lastStates = {};

  @override
  void initState() {
    super.initState();
    // 启动通知轮询服务
    _startNotificationService();
  }

  @override
  void dispose() {
    // 销毁页面时停止计时器，防止内存泄漏
    _notificationTimer?.cancel();
    super.dispose();
  }

  // 🔔 核心逻辑：轮询检查下载状态
  void _startNotificationService() {
    // 每 5 秒检查一次
    _notificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      // 1. 获取最新种子列表
      final torrents = await ApiService.getTorrents();
      if (torrents == null) return;

      for (var t in torrents) {
        final hash = t['hash'];
        final name = t['name'];
        final state = t['state']; // 例如: downloading, up, completed, pausedDL
        
        // 2. 获取旧状态 (如果没有旧状态，说明是刚打开 App，跳过通知)
        final oldState = _lastStates[hash];

        // 3. 判断是否刚刚完成
        // 逻辑：如果旧状态是“下载中(downloading/forcedDL)”，且新状态变成了“做种(up/uploading)”或“完成”
        if (oldState != null && 
           (oldState == 'downloading' || oldState == 'forcedDL') && 
           (state == 'up' || state == 'uploading' || state == 'pausedUP' || state == 'stalledUP' || state == 'completed')) {
          
          _showCompletionNotification(name);
        }

        // 4. 更新记录，供下一次对比
        _lastStates[hash] = state;
      }
    });
  }

  // 🔔 发送本地通知
  Future<void> _showCompletionNotification(String fileName) async {
    // Android 通知详情
    const androidDetails = AndroidNotificationDetails(
      'download_channel', // 渠道 ID
      '下载通知', // 渠道名称
      channelDescription: '通知下载完成状态',
      importance: Importance.max,
      priority: Priority.high,
    );
    // iOS 通知详情
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    // 调用 main.dart 里初始化的插件发送通知
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // 使用时间戳作为唯一的 Notification ID
      '下载完成 🎉', // 标题
      fileName,   // 内容 (文件名)
      details,
    );
  }

  void _onTap(int index) {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 ValueListenableBuilder 监听主题变化 (如果你的 themeNotifier 在 constants.dart 中定义)
    // 如果没有使用 ValueListenableBuilder，直接取值也可以，但在切换主题时可能不会立即刷新 TabBar 颜色
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
