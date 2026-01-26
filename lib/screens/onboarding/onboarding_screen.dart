import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../server/server_form_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.arrow_down,
                  size: 40,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Orbix",
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "你的终极下载管家",
                style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 60),
              _featureItem(
                CupertinoIcons.add_circled_solid,
                "添加服务器",
                "连接 qBittorrent",
              ),
              _featureItem(
                CupertinoIcons.search,
                "超级搜刮",
                "Prowlarr + TMDB 聚合搜索",
              ),
              _featureItem(
                CupertinoIcons.shield_fill,
                "安全可靠",
                "支持 HTTPS 与 双重验证",
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(14),
                  child: const Text(
                    "开始配置",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => const ServerFormScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kPrimaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
