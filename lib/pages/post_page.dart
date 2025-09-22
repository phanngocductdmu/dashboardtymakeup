import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("posts");

  static const String imgbbApiKey = "7a0af2cd07f4eb139a69480020a697ab";
  static const String imgbbUploadUrl = "https://api.imgbb.com/1/upload";

  List<html.File> selectedFiles = [];
  List<String> previewUrls = [];

  /// Chọn ảnh từ máy
  void pickImages() {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.multiple = true;
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null) {
        selectedFiles = files.take(5).toList();
        previewUrls =
            selectedFiles.map((file) => html.Url.createObjectUrl(file)).toList();
        setState(() {});
      }
    });
  }

  /// Upload ảnh lên ImgBB và lưu URL vào Firebase
  Future<void> uploadImagesAndSavePost() async {
    if (selectedFiles.isEmpty) return;

    List<String> uploadedUrls = [];

    for (final file in selectedFiles) {
      final reader = html.FileReader();
      reader.readAsDataUrl(file); // chuyển file thành base64
      await reader.onLoad.first;

      final base64Image = (reader.result as String).split(',').last;

      final formData = html.FormData();
      formData.append('key', imgbbApiKey);
      formData.append('image', base64Image);
      formData.append('name', file.name.split('.').first);

      final request = html.HttpRequest();
      request.open('POST', imgbbUploadUrl);
      request.responseType = 'json';

      // gửi request trước
      request.send(formData);

      // chờ upload xong
      await request.onLoad.first;

      final res = request.response;
      if (res != null && res['success'] == true) {
        final url = res['data']['url'];
        if (url != null) {
          uploadedUrls.add(url);
          debugPrint("✅ Upload thành công: $url");
        }
      } else {
        debugPrint(
            '❌ Upload lỗi: ${request.status} - ${request.responseText}');
      }
    }

    if (uploadedUrls.isNotEmpty) {
      saveToFirebase(uploadedUrls);
    }
  }

  /// Lưu URL ảnh vào Firebase
  void saveToFirebase(List<String> urls) async {
    final newPostRef = ref.push();
    await newPostRef.set({'imageUrls': urls});
    debugPrint("✅ Lưu bài thành công với ${urls.length} ảnh");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🎉 Đăng bài thành công!"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
    selectedFiles.clear();
    previewUrls.clear();
    setState(() {});
  }

  /// Hiển thị dialog xem ảnh lớn
  void showImageDialog(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.black87,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder: (_, __) =>
                const CircularProgressIndicator(color: Colors.white),
                errorWidget: (_, __, ___) =>
                const Icon(Icons.broken_image, size: 60, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Đăng bài",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: pickImages,
                  style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: const Text("Chọn ảnh"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: uploadImagesAndSavePost,
                  style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: const Text("Đăng bài"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Preview ảnh với scroll theo hướng màn hình
            if (previewUrls.isNotEmpty)
              Expanded(
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    final isPortrait = orientation == Orientation.portrait;
                    return SingleChildScrollView(
                      scrollDirection:
                      isPortrait ? Axis.vertical : Axis.horizontal,
                      child: isPortrait
                          ? Column(
                        children: previewUrls.map((url) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GestureDetector(
                              onTap: () => showImageDialog(url),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  url,
                                  width: 250,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                          : Row(
                        children: previewUrls.map((url) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => showImageDialog(url),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  url,
                                  width: 250,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
