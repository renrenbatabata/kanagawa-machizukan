import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class SaveImageButton extends StatelessWidget {
  final Uint8List? capturedImageBytes;

  const SaveImageButton({super.key, required this.capturedImageBytes});

  Future<void> _saveImage(BuildContext context) async {
    if (capturedImageBytes == null) return;

    final status = await Permission.storage.request();

    if (!context.mounted) return;

    if (status.isGranted) {
      final result = await ImageGallerySaver.saveImage(
        capturedImageBytes!,
        quality: 100,
        name: "saved_photo_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['isSuccess'] == true ? "保存しました" : "保存に失敗しました"),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("ストレージへのアクセスが許可されていません")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _saveImage(context),
      icon: const Icon(Icons.download),
      label: const Text("しゃしんをほぞんする"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
