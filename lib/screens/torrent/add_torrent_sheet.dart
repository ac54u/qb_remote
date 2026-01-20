import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../services/api_service.dart';

class AddTorrentSheet extends StatefulWidget {
  const AddTorrentSheet({super.key});

  @override
  State<AddTorrentSheet> createState() => _AddTorrentSheetState();
}

class _AddTorrentSheetState extends State<AddTorrentSheet> {
  int _segment = 0;
  final _magnetCtrl = TextEditingController();
  final _catCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _pathCtrl = TextEditingController(text: "/downloads/Movies");
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    // ⬇️ 修改：改为 FileType.any，解决 iOS 上 .torrent 文件变灰无法选中的问题
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, 
    );
    
    if (result != null) {
      final path = result.files.single.path;
      final name = result.files.single.name;
      
      // 简单检查后缀名
      if (name.toLowerCase().endsWith('.torrent')) {
        setState(() {
          _selectedFilePath = path;
          _selectedFileName = name;
        });
      } else {
        Utils.showToast("请选择 .torrent 格式的文件");
      }
    }
  }


  Future<void> _submit() async {
    setState(() => _isUploading = true);
    bool success = false;
    String? cat = _catCtrl.text.isNotEmpty ? _catCtrl.text : null;
    String? tags = _tagsCtrl.text.isNotEmpty ? _tagsCtrl.text : null;
    String? path = _pathCtrl.text.isNotEmpty ? _pathCtrl.text : null;

    if (_segment == 0) {
      if (_magnetCtrl.text.isEmpty) return;
      success = await ApiService.addTorrent(
        _magnetCtrl.text,
        category: cat,
        tags: tags,
        savePath: path,
      );
    } else {
      if (_selectedFilePath == null) return;
      success = await ApiService.addTorrentFile(
        _selectedFilePath!,
        category: cat,
        tags: tags,
        savePath: path,
      );
    }

    if (mounted) {
      setState(() => _isUploading = false);
      Navigator.pop(context);
      Utils.showToast(success ? "✅ 添加成功" : "❌ 添加失败");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: themeNotifier.value ? kBgColorDark : kBgColorLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: themeNotifier.value ? Colors.grey[900] : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Text("取消"),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  "添加种子",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _submit,
                  child: _isUploading
                      ? const CupertinoActivityIndicator()
                      : const Text(
                          "添加",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<int>(
                    groupValue: _segment,
                    children: const {
                      0: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("链接"),
                      ),
                      1: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("文件"),
                      ),
                    },
                    onValueChanged: (v) => setState(() => _segment = v!),
                  ),
                ),
                const SizedBox(height: 24),
                if (_segment == 0) ...[
                  const Text(
                    "种子链接",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _magnetCtrl,
                    placeholder: "磁力链接或种子 URL",
                    maxLines: 4,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeNotifier.value
                          ? Colors.grey[800]
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffix: CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: const Icon(
                        CupertinoIcons.doc_on_clipboard,
                        size: 20,
                      ),
                      onPressed: () async {
                        ClipboardData? data = await Clipboard.getData(
                          Clipboard.kTextPlain,
                        );
                        if (data != null) _magnetCtrl.text = data.text ?? "";
                      },
                    ),
                  ),
                ] else ...[
                  const Text(
                    "种子文件",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: themeNotifier.value
                            ? Colors.grey[800]
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: kPrimaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _selectedFileName != null
                                ? CupertinoIcons.doc_fill
                                : CupertinoIcons.doc_append,
                            size: 40,
                            color: kPrimaryColor,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _selectedFileName ?? "选择本地 .torrent 文件",
                            style: TextStyle(
                              color: _selectedFileName != null
                                  ? (themeNotifier.value
                                        ? Colors.white
                                        : Colors.black)
                                  : kPrimaryColor,
                              fontWeight: _selectedFileName != null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  "可选设置",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: themeNotifier.value
                        ? Colors.grey[800]
                        : Colors.white,
                    child: Column(
                      children: [
                        _buildOptionRow("分类", _catCtrl, "点击输入"),
                        const Divider(
                          height: 1,
                          indent: 16,
                          color: Color(0xFFE5E5EA),
                        ),
                        _buildOptionRow("标签", _tagsCtrl, "多个标签用逗号分隔"),
                        const Divider(
                          height: 1,
                          indent: 16,
                          color: Color(0xFFE5E5EA),
                        ),
                        _buildOptionRow("保存路径", _pathCtrl, "/downloads/Movies"),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow(
    String label,
    TextEditingController ctrl,
    String placeholder,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: CupertinoTextField(
              controller: ctrl,
              placeholder: placeholder,
              decoration: null,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15,
                color: themeNotifier.value ? Colors.white : Colors.black,
              ),
              placeholderStyle: const TextStyle(
                fontSize: 15,
                color: Color(0xFFC7C7CC),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
