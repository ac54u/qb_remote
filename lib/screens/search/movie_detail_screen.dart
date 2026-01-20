import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../services/api_service.dart';
import '../../widgets/creative_copy_button.dart';

class MovieDetailScreen extends StatefulWidget {
  final dynamic item;
  const MovieDetailScreen({super.key, required this.item});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? _tmdbData;
  List<dynamic> _cast = [];

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final clean = Utils.cleanFileName(widget.item['title']);
    final data = await ApiService.searchTMDB(
      clean['title'],
      year: clean['year'],
    );
    if (data != null) {
      final credits = await ApiService.getTMDBCredits(data['id']);
      if (mounted) {
        setState(() {
          _tmdbData = data;
          _cast = credits;
          _loading = false;
        });
      }
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.value;
    final title = _tmdbData?['title'] ?? widget.item['title'];
    final overview = _tmdbData?['overview'] ?? "暂无简介";
    final poster = _tmdbData?['poster_path'];
    final backdrop = _tmdbData?['backdrop_path'];
    final rating = _tmdbData?['vote_average'];

    return CupertinoPageScaffold(
      backgroundColor: isDark ? kBgColorDark : Colors.white,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          "详情",
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        backgroundColor: isDark ? kBgColorDark : Colors.white,
        border: null,
      ),
      child: _loading
          ? const Center(child: CupertinoActivityIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                if (backdrop != null)
                  CachedNetworkImage(
                    imageUrl: "https://image.tmdb.org/t/p/w500$backdrop",
                    height: 200,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: widget.item['title'],
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: poster != null
                                  ? CachedNetworkImage(
                                      imageUrl:
                                          "https://image.tmdb.org/t/p/w200$poster",
                                      width: 100,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 100,
                                      height: 150,
                                      color: Colors.grey[200],
                                      child: const Icon(CupertinoIcons.film),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (rating != null)
                                  Row(
                                    children: [
                                      const Icon(
                                        CupertinoIcons.star_fill,
                                        size: 16,
                                        color: Color(0xFFFFCC00),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFFCC00),
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  "文件大小: ${Utils.formatBytes(widget.item['size'])}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  "来源: ${widget.item['indexer']}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "简介",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        overview,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: isDark ? Colors.grey[300] : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_cast.isNotEmpty) ...[
                        Text(
                          "演员",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _cast.length,
                            itemBuilder: (context, index) {
                              final c = _cast[index];
                              return Container(
                                width: 80,
                                margin: const EdgeInsets.only(right: 12),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage: c['profile_path'] != null
                                          ? NetworkImage(
                                              "https://image.tmdb.org/t/p/w200${c['profile_path']}",
                                            )
                                          : null,
                                      child: c['profile_path'] == null
                                          ? const Icon(CupertinoIcons.person)
                                          : null,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      c['name'],
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                      CreativeCopyButton(
                        magnet:
                            widget.item['magnetUrl'] ??
                            widget.item['downloadUrl'] ??
                            '',
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          color: isDark ? Colors.grey[800] : kBgColorLight,
                          onPressed: () async {
                            bool ok = await ApiService.addTorrent(
                              widget.item['magnetUrl'] ??
                                  widget.item['downloadUrl'],
                            );
                            Utils.showToast(ok ? "已添加下载" : "添加失败");
                          },
                          child: const Text(
                            "下载到服务器",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
