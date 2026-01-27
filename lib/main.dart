import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ✅ 新增：引入 QuickActions 包
import 'package:quick_actions/quick_actions.dart'; 

import 'core/constants.dart';
import 'services/server_manager.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/main_tab_scaffold.dart';
// ✅ 新增：确保引入你的搜索页 (请检查路径是否正确)
import 'screens/search/search_screen.dart'; 

// ✅ 全局通知插件实例
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ✅ 新增：全局导航 Key (用于在没有 Context 的地方跳转页面)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  
  final prefs = await SharedPreferences.getInstance();
  themeNotifier.value = prefs.getBool('is_dark_mode') ?? false;
  final hasServers = await ServerManager.hasServers();

  await _initNotifications();

  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://db35293e486355c70e7f20f377f9dc31@o4510735505358848.ingest.us.sentry.io/4510735511715840'; 
      options.tracesSampleRate = 1.0;
      options.debug = false;
    },
    appRunner: () => runApp(MyApp(startOnboarding: !hasServers)),
  );
}

Future<void> _initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}

// ⚠️ 修改：将 MyApp 改为 Stateful Widget 以便初始化 QuickActions
class MyApp extends StatefulWidget {
  final bool startOnboarding;
  const MyApp({super.key, required this.startOnboarding});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ✅ 1. 定义 QuickActions 实例
  final QuickActions quickActions = const QuickActions();

  @override
  void initState() {
    super.initState();
    // ✅ 2. 初始化 QuickActions
    _setupQuickActions();
  }

  void _setupQuickActions() {
    quickActions.initialize((String shortcutType) {
      // ✅ 3. 处理回调：当用户点击了快捷菜单
      if (shortcutType == 'action_search') {
        print('⚡️ 检测到长按快捷操作：进入搜索');
        
        // 使用全局 navigatorKey 进行跳转，因为这里可能没有 context
        navigatorKey.currentState?.push(
          CupertinoPageRoute(
            builder: (context) => const SearchScreen(
              autoPaste: true, // 👈 开启自动粘贴功能
            ),
          ),
        );
      }
    });

    // ✅ 4. 设置菜单项 (记得图片资源要放对位置)
    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'action_search',    // 唯一ID
        localizedTitle: '一键搜索', // 标题
        icon: 'ic_search',        // 原生图片名 (iOS: Assets.xcassets / Android: drawable)
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, isDark, child) {
        return CupertinoApp(
          // ✅ 5. 绑定全局 NavigatorKey
          navigatorKey: navigatorKey, 
          title: 'Orbix',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
             GlobalMaterialLocalizations.delegate,
             GlobalWidgetsLocalizations.delegate,
             GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'CN'),
            Locale('en', 'US'),
          ],
          theme: CupertinoThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            primaryColor: kPrimaryColor,
            scaffoldBackgroundColor: isDark ? kBgColorDark : kBgColorLight,
            barBackgroundColor: isDark
                ? const Color(0xFF1C1C1E)
                : const Color(0xCCF9F9F9),
            textTheme: CupertinoTextThemeData(
              textStyle: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black,
              ),
              navTitleTextStyle: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
              navLargeTitleTextStyle: GoogleFonts.outfit(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          // 注意：widget.startOnboarding (因为变成了 State 类)
          home: widget.startOnboarding
              ? const OnboardingScreen()
              : const MainTabScaffold(),
        );
      },
    );
  }
}