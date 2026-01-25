import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants.dart'; 

class UserAgreementScreen extends StatelessWidget {
  const UserAgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? kBgColorDark : kBgColorLight;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text("用户协议", style: TextStyle(color: textColor)),
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
                _buildHeader("TrackLuxe 用户协议", textColor),
                Text("最后更新：2026年1月25日", style: TextStyle(color: subTextColor, fontSize: 13)),
                const SizedBox(height: 24),

                _buildSectionTitle("1. 导言", textColor),
                _buildParagraph(
                  "欢迎使用 TrackLuxe（以下简称“本软件”）。本软件是一款开源的第三方 qBittorrent 远程管理工具。请您在开始使用前仔细阅读本协议。一旦您安装并使用本软件，即视为您已同意接受本协议的所有条款。",
                  textColor,
                ),

                _buildSectionTitle("2. 服务性质", textColor),
                _buildParagraph(
                  "本软件仅作为“客户端”工具，用于连接和控制用户自行搭建及管理的 qBittorrent 服务器。本软件本身不提供、不存储、不索引任何媒体内容或下载资源。",
                  textColor,
                ),

                _buildSectionTitle("3. 合法使用承诺", textColor),
                _buildParagraph(
                  "用户承诺仅将本软件用于合法目的。用户不得利用本软件下载、传播或存储违反当地法律法规的内容（包括但不限于侵犯版权的影视作品、非法软件等）。因用户使用不当导致的任何法律责任，均由用户自行承担。",
                  textColor,
                ),

                _buildSectionTitle("4. 免责声明 (重要)", textColor),
                _buildParagraph(
                  "4.1 本软件按“现状”提供，开发者不保证软件完全无 Bug 或绝对安全。\n"
                  "4.2 本软件包含对远程服务器文件的操作功能（如删除任务、删除文件）。**因用户误操作、网络故障或软件 Bug 导致的数据丢失、文件损坏或服务器异常，开发者不承担任何赔偿责任。**\n"
                  "4.3 本软件可能包含指向第三方网站（如 TMDB）的链接，开发者对第三方内容不负任何责任。",
                  textColor,
                ),

                _buildSectionTitle("5. 知识产权", textColor),
                _buildParagraph(
                  "本软件的代码及界面设计的知识产权归开发者所有。您可以基于开源协议（如有）合法使用，但不得在未经授权的情况下进行商业售卖或恶意破解。",
                  textColor,
                ),

                _buildSectionTitle("6. 协议修改", textColor),
                _buildParagraph(
                  "开发者保留在必要时修改本协议的权利。更新后的协议将在新版本中公布，恕不另行通知。",
                  textColor,
                ),
                
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    "TrackLuxe Team\nContact: zwthys@gmail.com",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subTextColor, fontSize: 12),
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

  Widget _buildParagraph(String text, Color color) {
    return Text(
      text,
      style: TextStyle(fontSize: 15, height: 1.6, color: color.withOpacity(0.8)),
    );
  }
}
