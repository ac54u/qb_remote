import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../services/api_service.dart';

class TorrentDetailScreen extends StatefulWidget {
  final dynamic torrent;
  const TorrentDetailScreen({super.key, required this.torrent});

  @override
  State<TorrentDetailScreen> createState() => _TorrentDetailScreenState();
}

class _TorrentDetailScreenState extends State<TorrentDetailScreen> {
  int _segIndex = 0;
  List<dynamic> _files = [];
  Map<String, dynamic> _peers = {};
  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refreshData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _refreshData() async {
    final hash = widget.torrent['hash'];
    if (_segIndex == 2) {
      final f = await ApiService.getTorrentFiles(hash);
      if (mounted && f != null) setState(() => _files = f);
    } else if (_segIndex == 1) {
      final p = await ApiService.getTorrentPeers(hash);
      if (mounted && p != null) setState(() => _peers = p['peers'] ?? {});
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.torrent;
    return CupertinoPageScaffold(
      backgroundColor: themeNotifier.value ? kBgColorDark : kBgColorLight,
      navigationBar: const CupertinoNavigationBar(
        middle: Text("详情"),
        previousPageTitle: "我的下载",
      ),
      child: Column(
        children: [
          const SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: CupertinoSegmentedControl<int>(
                children: const {
                  0: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("概览"),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("连接"),
                  ),
                  2: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("文件"),
                  ),
                },
                onValueChanged: (v) {
                  setState(() {
                    _segIndex = v;
                    _loading = true;
                  });
                  _refreshData();
                },
                groupValue: _segIndex,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: _buildContent(t)),
        ],
      ),
    );
  }

  Widget _buildContent(dynamic t) {
    if (_segIndex == 0) return _buildInfoView(t);
    if (_segIndex == 1) return _buildPeersView();
    return _buildFilesView();
  }

  Widget _buildInfoView(dynamic t) {
    final addedDate = DateTime.fromMillisecondsSinceEpoch(
      (t['added_on'] ?? 0) * 1000,
    );
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        CupertinoListSection.insetGrouped(
          backgroundColor: themeNotifier.value ? kBgColorDark : kBgColorLight,
          header: const Text("基本信息"),
          children: [
            _row("名称", t['name'] ?? '', bold: true),
            _row("大小", Utils.formatBytes(t['size'] ?? 0)),
            _row("进度", "${((t['progress'] ?? 0) * 100).toStringAsFixed(1)}%"),
            _row("状态", t['state'] ?? ''),
            _row(
              "添加时间",
              "${addedDate.year}-${addedDate.month}-${addedDate.day} ${addedDate.hour}:${addedDate.minute}",
            ),
            _row("保存路径", t['save_path'] ?? '', small: true),
            _row("分类", t['category'] ?? '无', small: true),
            _row("标签", t['tags'] ?? '', small: true),
          ],
        ),
        CupertinoListSection.insetGrouped(
          backgroundColor: themeNotifier.value ? kBgColorDark : kBgColorLight,
          header: const Text("传输数据"),
          children: [
            _row("下载速度", "${Utils.formatBytes(t['dlspeed'] ?? 0)}/s"),
            _row("上传速度", "${Utils.formatBytes(t['upspeed'] ?? 0)}/s"),
            _row("已下载", Utils.formatBytes(t['downloaded'] ?? 0)),
            _row("已上传", Utils.formatBytes(t['uploaded'] ?? 0)),
            _row("分享率", (t['ratio'] ?? 0).toStringAsFixed(2)),
          ],
        ),
      ],
    );
  }

  Widget _buildPeersView() {
    if (_peers.isEmpty) {
      return const Center(
        child: Text("暂无连接", style: TextStyle(color: Colors.grey)),
      );
    }

    final list = _peers.values.toList();
    return ListView.builder(
      padding: const EdgeInsets.only(top: 0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final p = list[index];
        final ip = p['ip'] ?? '?.?.?.?';
        return Container(
          color: themeNotifier.value ? kCardColorDark : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ip,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: themeNotifier.value ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    "${((p['progress'] ?? 0) * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilesView() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _files.length,
      itemBuilder: (context, index) {
        final f = _files[index];
        final progress = (f['progress'] ?? 0.0).toDouble();

        return Container(
          color: themeNotifier.value ? kCardColorDark : Colors.white,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                f['name'],
                style: TextStyle(
                  fontSize: 14,
                  color: themeNotifier.value ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                minHeight: 2,
                backgroundColor: const Color(0xFFF2F2F7),
                color: kPrimaryColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _row(
    String label,
    String value, {
    bool bold = false,
    bool small = false,
  }) {
    return CupertinoListTile(
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      trailing: SizedBox(
        width: 200,
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: themeNotifier.value ? Colors.white : Colors.black,
            fontSize: small ? 12 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
