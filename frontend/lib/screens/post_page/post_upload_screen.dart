import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path; // pathパッケージを追加
import 'package:async/async.dart'; // StreamGroupを使用するためにasyncパッケージを追加

class PostUploadScreen extends StatefulWidget {
  final String serverBaseUrl;
  const PostUploadScreen({Key? key, required this.serverBaseUrl})
    : super(key: key);

  @override
  State<PostUploadScreen> createState() => _PostUploadScreenState();
}

class _PostUploadScreenState extends State<PostUploadScreen> {
  XFile? _imageFile;
  final TextEditingController _locationNameController = TextEditingController();
  final TextEditingController _usernameController =
      TextEditingController(); // 仮のユーザー名入力

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _uploadPost() async {
    if (_imageFile == null ||
        _locationNameController.text.isEmpty ||
        _usernameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('写真、場所の名前、ユーザー名を入力してください。')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var uri = Uri.parse('${widget.serverBaseUrl}/api/posts');
      var request = http.MultipartRequest('POST', uri);

      // 画像ファイルをリクエストに追加
      // Stream.fromIterable([await _imageFile!.readAsBytes()]) を使用
      var stream = http.ByteStream(
        DelegatingStream.typed(_imageFile!.openRead()),
      );
      var length = await _imageFile!.length();
      var multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: path.basename(_imageFile!.path),
      );
      request.files.add(multipartFile);

      // 他のテキストデータをフィールドに追加
      request.fields['username'] = _usernameController.text;
      request.fields['locationName'] = _locationNameController.text;
      // 実際には、ユーザーアイコンのURLや位置情報なども追加

      var response = await request.send();

      if (response.statusCode == 200) {
        print('投稿成功！');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('投稿が完了しました！')));
        Navigator.pop(context); // タイムライン画面に戻る
      } else {
        final responseBody = await response.stream.bytesToString();
        print('投稿失敗: ${response.statusCode} - $responseBody');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('投稿失敗: ${response.statusCode}')));
      }
    } catch (e) {
      print('エラー発生: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('エラー発生: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新しい投稿')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _imageFile == null
                ? Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 50),
                      onPressed: _pickImage,
                    ),
                  ),
                )
                : Image.file(
                  File(_imageFile!.path),
                  height: 200,
                  fit: BoxFit.cover,
                ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationNameController,
              decoration: const InputDecoration(
                labelText: '場所の名前',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'ユーザー名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _uploadPost,
                  child: const Text('投稿する'),
                ),
          ],
        ),
      ),
    );
  }
}
