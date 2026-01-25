import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart'; // 确保能获取到 themeNotifier 和颜色常量

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取当前主题状态
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? kBgColorDark : kBgColorLight;
    final cardColor = isDark ? kCardColorDark : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text("支持作者", style: TextStyle(color: textColor)),
        backgroundColor: bgColor,
        border: null, // 去掉导航栏底下的线，看起来更沉浸
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //以此构建一个漂亮的卡片
              Container(
                width: 300,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.heart_fill, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      "感谢您的支持",
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "如果这个 App 对您有帮助\n欢迎请我喝杯咖啡 ☕️",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14, 
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 二维码图片区域
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: "https://i.postimg.cc/qkZ0Dy30/IMG-8639.jpg?dl=1",
                          width: 220,
                          height: 220,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 220, 
                            height: 220, 
                            color: Colors.grey[200],
                            child: const CupertinoActivityIndicator(),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 220,
                            height: 220,
                            color: Colors.grey[200],
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, color: Colors.grey),
                                SizedBox(height: 8),
                                Text("图片加载失败", style: TextStyle(fontSize: 12, color: Colors.grey))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // 底部标语
              Text(
                "TrackLuxe v1.0.0",
                style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
