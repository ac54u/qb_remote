import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants.dart'; 

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? kBgColorDark : kBgColorLight;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text("隐私政策", style: TextStyle(color: textColor)),
        backgroundColor: bgColor,
        border: null,
      ),
      child: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader("Orbix 隐私政策", textColor),
                Text("生效日期：2026年1月25日", style: TextStyle(color: subTextColor, fontSize: 13)),
                const SizedBox(height: 24),

                _buildSectionTitle("1. 引言", textColor),
                _buildParagraph(
                  "Orbix（以下简称“本应用”）是一款配合 qBittorrent 使用的第三方管理工具。我们非常重视您的隐私。本应用的核心承诺是：我们不会将您的个人服务器信息、下载记录或文件内容上传至任何第三方服务器。您的数据完全由您掌控。",
                  textColor,
                ),

                _buildSectionTitle("2. 我们收集的信息", textColor),
                _buildSubTitle("2.1 本地存储的信息", textColor),
                _buildParagraph(
                  "为了让应用正常运行，以下信息会直接存储在您的设备本地：\n• 服务器配置信息（IP、账号、密码）\n• 应用偏好设置\n• API 密钥 (Prowlarr/TMDB)",
                  textColor,
                ),
                const SizedBox(height: 8),
                _buildSubTitle("2.2 崩溃报告与性能监控", textColor),
                _buildParagraph(
                  "为了修复 Bug，我们集成了 Sentry 服务。当应用崩溃时，会自动收集匿名的错误日志（含设备型号、堆栈追踪）。\n注意：日志绝不包含您的服务器密码或文件名。",
                  textColor,
                ),
                const SizedBox(height: 8),
                _buildSubTitle("2.3 外部服务交互", textColor),
                _buildParagraph(
                  "搜索功能可能会与 TMDB 或您的 Prowlarr 服务器交互，仅用于获取媒体元数据。",
                  textColor,
                ),

                _buildSectionTitle("3. 权限使用说明", textColor),
                _buildParagraph(
                  "• 网络权限：连接您的服务器及外部 API。\n• 本地网络：用于发现局域网设备。\n• 通知权限：仅用于发送本地下载状态通知。",
                  textColor,
                ),

                _buildSectionTitle("4. 数据安全", textColor),
                _buildParagraph(
                  "您的服务器登录凭据仅保存在本地。开发者无法访问您的任何服务器数据。",
                  textColor,
                ),

                _buildSectionTitle("5. 联系我们", textColor),
                _buildParagraph(
                  "如有疑问或需申请删除崩溃日志数据，请联系：",
                  textColor,
                ),
                SelectableText(
                  "zwthys@gmail.com",
                  style: TextStyle(
                    color: kPrimaryColor, 
                    fontSize: 16, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildSectionTitle(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildSubTitle(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildParagraph(String text, Color color) {
    return Text(
      text,
      style: TextStyle(fontSize: 15, height: 1.6, color: color.withOpacity(0.8)),
    );
  }
}
