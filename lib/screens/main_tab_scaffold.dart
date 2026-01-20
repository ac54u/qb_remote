import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';

// 引入四个主页面 (稍后创建)
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
  void _onTap(int index) {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.value;
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
  }
}
