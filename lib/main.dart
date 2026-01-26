import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
// ✅ 新增：引入通知包
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/constants.dart';
import 'services/server_manager.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/main_tab_scaffold.dart';

// ✅ 新增：全局通知插件实例 (方便在其他文件直接调用)
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  
  final prefs = await SharedPreferences.getInstance();
  themeNotifier.value = prefs.getBool('is_dark_mode') ?? false;
  final hasServers = await ServerManager.hasServers();

  // ✅ 新增：初始化本地通知
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

// ✅ 新增：通知初始化逻辑分离
Future<void> _initNotifications() async {
  // Android 设置：使用默认的应用图标 (通常是 @mipmap/ic_launcher)
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS 设置：启动时直接请求权限 (角标、声音、弹窗)
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
    // 如果需要处理点击通知后的跳转，可以在这里加 onDidReceiveNotificationResponse
  );
}

class MyApp extends StatelessWidget {
  final bool startOnboarding;
  const MyApp({super.key, required this.startOnboarding});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, isDark, child) {
        return CupertinoApp(
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
          home: startOnboarding
              ? const OnboardingScreen()
              : const MainTabScaffold(),
        );
      },
    );
  }
}
