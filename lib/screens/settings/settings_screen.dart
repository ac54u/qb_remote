import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../services/server_manager.dart';
import '../../services/api_service.dart';

import '../server/server_list_screen.dart';
import 'log_viewer_screen.dart';
import 'feedback_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? _currentServer;
  String _qbtVersion = "v?.?.?";
  String _loginTime = "未知";
  int _refreshInterval = 3;
  bool _cellularWarn = true;
  
  final _pathCtrl = TextEditingController(); 
  final _prowlarrUrlCtrl = TextEditingController();
  final _prowlarrKeyCtrl = TextEditingController();
  final _tmdbKeyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pathCtrl.dispose();
    _prowlarrUrlCtrl.dispose();
    _prowlarrKeyCtrl.dispose();
    _tmdbKeyCtrl.dispose();
    super.dispose();
  }

  void _loadData() async {
    final s = await ServerManager.getCurrentServer();
    final v = await ApiService.getAppVersion();
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('login_time');

    setState(() {
      _currentServer = s;
      if (v != null) _qbtVersion = v;
      if (t != null) {
        final dt = DateTime.parse(t);
        _loginTime =
            "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      }
      _refreshInterval = prefs.getInt('refresh_rate') ?? 3;
      
      String path = prefs.getString('default_path') ?? "/downloads/Movies";
      _pathCtrl.text = path;

      _cellularWarn = prefs.getBool('cellular_warn') ?? true;

      String defaultUrl = s != null ? "http://${s['host']}:9696" : "";
      _prowlarrUrlCtrl.text = prefs.getString('prowlarr_url') ?? defaultUrl;
      _prowlarrKeyCtrl.text = prefs.getString('prowlarr_key') ?? '';
      _tmdbKeyCtrl.text = prefs.getString('tmdb_key') ?? '';
    });
  }

  Future<void> _saveDownloadPath() async {
    FocusScope.of(context).unfocus(); 
    if (_pathCtrl.text.isEmpty) {
      Utils.showToast("路径不能为空");
      return;
    }

    bool success = await ApiService.setPreferences(savePath: _pathCtrl.text);

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('default_path', _pathCtrl.text);
      Utils.showToast("✅ 默认路径已更新");
    } else {
      Utils.showToast("❌ 更新失败，请检查服务器连接或权限");
    }
  }

  void _saveExt() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('prowlarr_url', _prowlarrUrlCtrl.text);
    await p.setString('prowlarr_key', _prowlarrKeyCtrl.text);
    await p.setString('tmdb_key', _tmdbKeyCtrl.text);
    Utils.showToast("扩展配置已保存");
    Navigator.pop(context);
  }

  void _saveRefreshRate(double val) async {
    final p = await SharedPreferences.getInstance();
    int r = val.toInt();
    setState(() => _refreshInterval = r);
    await p.setInt('refresh_rate', r);
  }
  
  void _toggleCellular(bool v) async {
    final p = await SharedPreferences.getInstance();
    setState(() => _cellularWarn = v);
    await p.setBool('cellular_warn', v);
    if (v) Utils.showToast("流量警告已开启");
  }

  void _showExtSettings() {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          height: 500,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: themeNotifier.value ? kBgColorDark : kBgColorLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "扩展服务配置",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Prowlarr 地址",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                CupertinoTextField(
                  controller: _prowlarrUrlCtrl,
                  placeholder: "http://192.168.1.x:9696",
                ),
                const SizedBox(height: 12),
                const Text(
                  "Prowlarr API Key",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                CupertinoTextField(
                  controller: _prowlarrKeyCtrl,
                  placeholder: "在 Prowlarr 设置 -> 通用中获取",
                ),
                const SizedBox(height: 24),
                const Text(
                  "TMDB API Key (选填)",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                CupertinoTextField(
                  controller: _tmdbKeyCtrl,
                  placeholder: "留空则使用公共 Key",
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    onPressed: _saveExt,
                    child: const Text("保存"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🗑️ 已移除：_buildDonationCard 方法
  // 它的逻辑已经直接移到了 build 方法的列表里

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.value;
    return CupertinoPageScaffold(
      backgroundColor: isDark ? kBgColorDark : kBgColorLight,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          "设置",
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        backgroundColor: isDark ? kBgColorDark : kBgColorLight,
        border: null,
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 10),
                if (_currentServer != null)
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => const ServerListScreen(),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? kCardColorDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: kMinimalShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "当前服务器",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentServer!['host'],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.square_stack_3d_up,
                                size: 16,
                                color: kPrimaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "${_currentServer!['host']}:${_currentServer!['port']}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.info_circle,
                                size: 16,
                                color: kPrimaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "qBittorrent $_qbtVersion",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const Padding(
                  padding: EdgeInsets.only(left: 32, bottom: 8, top: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "下载设置",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ),
                CupertinoListSection.insetGrouped(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  backgroundColor: isDark ? kBgColorDark : kBgColorLight,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "默认保存路径",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: CupertinoTextField(
                                  controller: _pathCtrl,
                                  placeholder: "/downloads",
                                  style: TextStyle(
                                      color:
                                          isDark ? Colors.white : Colors.black),
                                  clearButtonMode:
                                      OverlayVisibilityMode.editing,
                                ),
                              ),
                              const SizedBox(width: 8),
                              CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 0),
                                color: CupertinoColors.activeBlue,
                                minSize: 32,
                                onPressed: _saveDownloadPath,
                                child: const Text(
                                  "保存",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "提示: 请务必填写服务器(或Docker容器)内部的真实路径",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.only(left: 32, bottom: 8, top: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "通用设置",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ),
                CupertinoListSection.insetGrouped(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  backgroundColor: isDark ? kBgColorDark : kBgColorLight,
                  children: [
                    CupertinoListTile(
                      title: Text(
                        "列表刷新频率",
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      subtitle: CupertinoSlider(
                        value: _refreshInterval.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        onChanged: (v) => _saveRefreshRate(v),
                      ),
                      trailing: Text(
                        "${_refreshInterval}s",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    CupertinoListTile(
                      title: Text(
                        "搜刮器配置",
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      subtitle: const Text("配置 Prowlarr & TMDB"),
                      leading: const Icon(
                        CupertinoIcons.search_circle_fill,
                        color: Colors.purple,
                      ),
                      trailing: const CupertinoListTileChevron(),
                      onTap: _showExtSettings,
                    ),
                    CupertinoListTile(
                      title: Text("运行日志", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                      leading: const Icon(CupertinoIcons.news, color: Colors.blueGrey),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const LogViewerScreen())),
                    ),
                    CupertinoListTile(
                      title: Text("流量预警", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                      subtitle: const Text("使用流量时弹出提示"),
                      leading: const Icon(CupertinoIcons.antenna_radiowaves_left_right, color: Colors.green),
                      trailing: CupertinoSwitch(
                        value: _cellularWarn, 
                        onChanged: _toggleCellular,
                      ),
                    ),
                    CupertinoListTile(
                      title: Text("意见反馈", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                      subtitle: const Text("提交建议或Bug"),
                      leading: const Icon(CupertinoIcons.chat_bubble_text_fill, color: kPrimaryColor),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => const FeedbackScreen(),
                          ),
                        );
                       },
                     ),
                     
                     // ✅ 新增：把“支持作者”直接合并到这里
                     Padding(
                       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                       child: Column(
                         children: [
                           Row(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               const Icon(CupertinoIcons.heart_fill, color: Colors.red),
                               const SizedBox(width: 8),
                               Text(
                                 "支持作者",
                                 style: TextStyle(
                                   fontSize: 18, 
                                   fontWeight: FontWeight.bold,
                                   color: isDark ? Colors.white : Colors.black,
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(height: 8),
                           const Text(
                             "如果觉得好用，可以请我喝杯咖啡 ~",
                             style: TextStyle(color: Colors.grey, fontSize: 14),
                           ),
                           const SizedBox(height: 16),
                           ClipRRect(
                             borderRadius: BorderRadius.circular(12),
                             child: CachedNetworkImage(
                               imageUrl: "https://i.postimg.cc/qkZ0Dy30/IMG-8639.jpg?dl=1",
                               fit: BoxFit.fitWidth, 
                               width: double.infinity,
                               placeholder: (context, url) => const SizedBox(
                                 height: 200, 
                                 child: Center(child: CupertinoActivityIndicator())
                               ),
                               errorWidget: (context, url, error) => Container(
                                 height: 200,
                                 color: Colors.grey[200],
                                 child: const Icon(Icons.broken_image, color: Colors.grey),
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                  ],
                ),
                
                // ⚠️ 删除了原来的 Donation Card，现在已经在 List Section 里了
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
