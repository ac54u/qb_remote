import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import '../core/constants.dart';

class CreativeCopyButton extends StatefulWidget {
  final String magnet;
  const CreativeCopyButton({super.key, required this.magnet});

  @override
  State<CreativeCopyButton> createState() => _CreativeCopyButtonState();
}

class _CreativeCopyButtonState extends State<CreativeCopyButton> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: widget.magnet));
        HapticFeedback.heavyImpact();
        setState(() => _copied = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _copied = false);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: _copied ? const Color(0xFF34C759) : kPrimaryColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (_copied ? const Color(0xFF34C759) : kPrimaryColor)
                  .withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _copied ? CupertinoIcons.checkmark_alt : CupertinoIcons.link,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              _copied ? "已复制磁力链接" : "复制磁力链接",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
