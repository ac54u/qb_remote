import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/api_service.dart';
import '../../core/utils.dart'; // 确保 utils.dart 里有 formatBytes 方法

class TorrentFilesSheet extends StatefulWidget {
  final String hash;
  const TorrentFilesSheet({super.key, required this.hash});

  @override
  State<TorrentFilesSheet> createState() => _TorrentFilesSheetState();
}

class _TorrentFilesSheetState extends State<TorrentFilesSheet> {
  List<dynamic> _files = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final files = await ApiService.getTorrentContent(widget.hash);
    if (mounted) {
      setState(() {
        _files = files;
        _loading = false;
      });
    }
  }

  // ✨ 升级版魔法函数：根据文件名生成彩色标签
  List<Widget> _buildTags(String fileName) {
    final name = fileName.toUpperCase();
    final List<String> tags = [];
    
    // 1. 识别关键词
    if (name.contains("2160P") || name.contains("4K")) tags.add("4K");
    else if (name.contains("1080P")) tags.add("1080P");
    
    if (name.contains("HDR") || name.contains("10BIT")) tags.add("HDR");
    if (name.contains("HEVC") || name.contains("X265") || name.contains("H265")) tags.add("HEVC");
    if (name.contains("DOLBY") || name.contains("ATMOS") || name.contains("TRUEHD")) tags.add("Dolby");
    if (name.contains("DTS") || name.contains("AAC")) tags.add("Audio");

    // 2. 渲染彩色标签
    return tags.map((tag) {
      Color color;
      switch (tag) {
        case "4K": color = Colors.purple; break;
        case "HDR": color = Colors.orange; break;
        case "HEVC": color = Colors.blue; break;
        case "Dolby": color = Colors.red; break;
        default: color = Colors.grey;
      }

      return Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.3), width: 0.5),
        ),
        child: Text(
          tag,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前的主题亮度，自动适配黑白模式
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // 占屏幕 75%
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // 顶部的小横条 (Handle)
          Container(
            width: 40, 
            height: 4, 
            decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
          ),
          
          // 标题栏
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("文件列表", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                if (!_loading) 
                  Text("${_files.length} 个文件", style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),

          // 列表内容
          Expanded(
            child: _loading
                ? const Center(child: CupertinoActivityIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 30),
                    itemCount: _files.length,
                    separatorBuilder: (c, i) => Divider(height: 1, indent: 60, color: Colors.grey.withOpacity(0.1)),
                    itemBuilder: (context, index) {
                      final file = _files[index];
                      final name = file['name'] as String;
                      // 如果 utils 报错，请确保你有 formatBytes 方法，或者暂时用 file['size'].toString() 代替
                      final size = Utils.formatBytes(file['size']); 
                      final progressVal = file['progress'] as double;
                      final progressStr = (progressVal * 100).toStringAsFixed(1);
                      final isCompleted = progressVal >= 1.0;
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 左侧图标：完成显示对勾，未完成显示文件
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                isCompleted ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.doc_fill,
                                color: isCompleted ? Colors.green : Colors.grey[400],
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // 右侧信息
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 文件名
                                  Text(
                                    name, 
                                    maxLines: 2, 
                                    overflow: TextOverflow.ellipsis, 
                                    style: TextStyle(fontWeight: FontWeight.w500, color: textColor, fontSize: 15)
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  // 标签行 (4K, HDR...)
                                  if (_buildTags(name).isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: _buildTags(name),
                                      ),
                                    ),
                                  
                                  // 底部大小和进度
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(size, style: TextStyle(color: subTextColor, fontSize: 12)),
                                      Text(
                                        "$progressStr%", 
                                        style: TextStyle(
                                          color: isCompleted ? Colors.green : CupertinoColors.systemBlue, 
                                          fontSize: 12, 
                                          fontWeight: FontWeight.bold
                                        )
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
