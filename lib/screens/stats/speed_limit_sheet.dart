import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../services/api_service.dart';

class SpeedLimitSheet extends StatefulWidget {
  final int initialDl; // in bytes
  final int initialUp; // in bytes
  const SpeedLimitSheet({
    super.key,
    required this.initialDl,
    required this.initialUp,
  });

  @override
  State<SpeedLimitSheet> createState() => _SpeedLimitSheetState();
}

class _SpeedLimitSheetState extends State<SpeedLimitSheet> {
  final _dlCtrl = TextEditingController();
  final _upCtrl = TextEditingController();
  // 0: KB/s, 1: MB/s
  int _dlUnit = 0;
  int _upUnit = 0;

  @override
  void initState() {
    super.initState();
    _initVals(widget.initialDl, _dlCtrl, (u) => _dlUnit = u);
    _initVals(widget.initialUp, _upCtrl, (u) => _upUnit = u);
  }

  void _initVals(int bytes, TextEditingController ctrl, Function(int) setUnit) {
    if (bytes == 0) {
      ctrl.text = "";
      return;
    }
    // > 1MB use MB
    if (bytes >= 1024 * 1024) {
      ctrl.text = (bytes / (1024 * 1024)).toStringAsFixed(1);
      setUnit(1);
    } else {
      ctrl.text = (bytes / 1024).toStringAsFixed(0);
      setUnit(0);
    }
  }

  int _calcBytes(String text, int unit) {
    if (text.isEmpty) return 0;
    double val = double.tryParse(text) ?? 0;
    if (unit == 1) return (val * 1024 * 1024).toInt();
    return (val * 1024).toInt();
  }

  Future<void> _save() async {
    int dl = _calcBytes(_dlCtrl.text, _dlUnit);
    int up = _calcBytes(_upCtrl.text, _upUnit);
    await ApiService.setTransferLimit(dlLimitBytes: dl, upLimitBytes: up);
    if (mounted) Navigator.pop(context);
    Utils.showToast("限速设置已更新");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeNotifier.value ? kBgColorDark : kBgColorLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Text(
            "全局速度限制",
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          _buildRow("下载限制", _dlCtrl, _dlUnit, (v) => setState(() => _dlUnit = v)),
          const SizedBox(height: 20),
          _buildRow("上传限制", _upCtrl, _upUnit, (v) => setState(() => _upUnit = v)),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              onPressed: _save,
              child: const Text("保存"),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    TextEditingController ctrl,
    int unit,
    Function(int) onUnitChange,
  ) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label)),
        Expanded(
          child: CupertinoTextField(
            controller: ctrl,
            placeholder: "0 (无限制)",
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ),
        const SizedBox(width: 10),
        CupertinoSlidingSegmentedControl<int>(
          children: const {0: Text("KB/s"), 1: Text("MB/s")},
          groupValue: unit,
          onValueChanged: (v) => onUnitChange(v!),
        ),
      ],
    );
  }
}
