import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart'; // 1. 系统服务：剪贴板
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../services/api_service.dart';
import 'movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery; 
  final bool autoPaste;

  const SearchScreen({
    super.key, 
    this.initialQuery, 
    this.autoPaste = true
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<dynamic> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 4. 页面初始化逻辑：处理传参或剪贴板
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
        _searchCtrl.text = widget.initialQuery!;
        _doSearch();
      } else if (widget.autoPaste) {
        _checkClipboardAndSearch();
      }
    });
  }

  // 5. 核心方法：读取剪贴板并自动搜索
  Future<void> _checkClipboardAndSearch() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    
    if (data != null && data.text != null && data.text!.trim().isNotEmpty) {
      String content = data.text!.trim();
      
      if (content.length > 50) return; 

      setState(() {
        _searchCtrl.text = content;
      });

      Utils.showToast("已自动填入剪贴板内容");
      _doSearch();
    }
  }

  Future<void> _doSearch() async {
    if (_searchCtrl.text.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _results = [];
    });
    try {
      final prowlarrResults = await ApiService.searchProwlarr(_searchCtrl.text);

      final processed = prowlarrResults.map((item) {
        String raw = item['title'].toString().toUpperCase();
        List<String> tags = []; 
        if (raw.contains('4K') || raw.contains('2160P')) tags.add('4K');
        if (raw.contains('1080P')) tags.add('1080P');
        if (raw.contains('HDR')) tags.add('HDR');
        if (raw.contains('DV') || raw.contains('DOLBY')) tags.add('Dolby');

        return {...item, 'tags': tags};
      }).toList();

      // 排序：做种数从多到少
      processed.sort(
        (a, b) => (int.tryParse(b['seeders'].toString()) ?? 0).compareTo(int.tryParse(a['seeders'].toString()) ?? 0),
      );

      if (mounted) setState(() => _results = processed);
    } catch (e) {
      Utils.showToast("搜索失败: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.value; 
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          "资源搜索", 
          style: TextStyle(color: isDark ? Colors.white : Colors.black)
        ),
        previousPageTitle: "返回",
        // 适配导航栏背景
        backgroundColor: isDark ? kBgColorDark : Colors.white.withOpacity(0.5),
        border: null,
      ),
      backgroundColor: isDark ? kBgColorDark : kBgColorLight, // 使用全局动态背景
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoSearchTextField(
                controller: _searchCtrl,
                placeholder: "搜索电影、剧集 (Prowlarr)",
                placeholderStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                onSuffixTap: () {
                   _searchCtrl.clear();
                   setState(() => _results = []);
                },
                // ✅ 适配输入框背景：深色模式用深灰
                backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                onSubmitted: (_) => _doSearch(),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.search,
                            size: 64,
                            // ✅ 占位图标颜色调整
                            color: isDark ? Colors.white10 : Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "输入关键词开始搜刮",
                            style: TextStyle(color: isDark ? Colors.white24 : Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) =>
                          _buildResultItem(_results[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(dynamic item) {
    bool isDark = themeNotifier.value;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(builder: (_) => MovieDetailScreen(item: item)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // ✅ 使用动态卡片色
          color: isDark ? kCardColorDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          // ✅ 深色模式去掉投影
          boxShadow: isDark ? [] : kMinimalShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? "无标题",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      // ✅ 标题文字颜色
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4, 
                    children: (item['tags'] as List).map<Widget>((t) {
                      bool is4k = t == '4K';
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: is4k ? Colors.red : Colors.blue,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            fontSize: 10,
                            color: is4k ? Colors.red : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${item['indexer'] ?? 'Unknown'} • ${Utils.formatBytes(item['size'] ?? 0)}",
                    // ✅ 副标题文字颜色
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${item['seeders'] ?? 0}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF34C759), // 绿色数字保持
                  ),
                ),
                Text(
                  "做种",
                  style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}