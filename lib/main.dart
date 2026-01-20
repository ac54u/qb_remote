import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

// 引入我们刚才拆分的文件
import 'core/constants.dart';
import 'services/server_manager.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/main_tab_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  final prefs = await SharedPreferences.getInstance();
  themeNotifier.value = prefs.getBool('is_dark_mode') ?? false;
  final hasServers = await ServerManager.hasServers();

  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://db35293e486355c70e7f20f377f9dc31@o4510735505358848.ingest.us.sentry.io/4510735511715840'; 
      options.tracesSampleRate = 1.0;
      options.debug = false;
    },
    appRunner: () => runApp(MyApp(startOnboarding: !hasServers)),
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
          title: 'TrackLuxe',
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
