import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => PostsPageState();
}

class PostsPageState extends State<PostsPage> {
  static const String imgbbApiKey = "7a0af2cd07f4eb139a69480020a697ab";
  static const String imgbbUploadUrl = "https://api.imgbb.com/1/upload";

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("posts");
  final ImagePicker _picker = ImagePicker();

  /// Lấy albums -> Map<albumId, Map<key,url>>
  Future<Map<String, Map<String, String>>> fetchAlbums() async {
    final snapshot = await dbRef.get();
    Map<String, Map<String, String>> temp = {};

    if (snapshot.value != null && snapshot.value is Map) {
      final data = snapshot.value as Map;
      data.forEach((albumId, albumData) {
        if (albumData is Map && albumData['imageUrls'] != null) {
          final imgs = albumData['imageUrls'];

          if (imgs is Map) {
            temp[albumId] = Map<String, String>.from(imgs);
          } else if (imgs is List) {
            final mapImgs = <String, String>{};
            for (int i = 0; i < imgs.length; i++) {
              final val = imgs[i];
              if (val != null) mapImgs[i.toString()] = val.toString();
            }
            temp[albumId] = mapImgs;
          }
        }
      });
    }
    return temp;
  }

  /// Upload ảnh lên imgbb
  Future<String?> uploadToImgbb(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final uri = Uri.parse("$imgbbUploadUrl?key=$imgbbApiKey");

      final response = await http.post(uri, body: {"image": base64Image});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["data"]["url"];
      } else {
        debugPrint("Upload thất bại: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Lỗi upload Imgbb: $e");
      return null;
    }
  }

  /// Thêm ảnh
  Future<void> addImageToAlbum(String albumId) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String? url = await uploadToImgbb(pickedFile);
      if (url != null) {
        await dbRef.child(albumId).child("imageUrls").push().set(url);
        setState(() {});
      }
    }
  }

  /// Sửa ảnh
  Future<void> editImageInAlbum(String albumId, String keyImg, String oldUrl) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String? newUrl = await uploadToImgbb(pickedFile);
      if (newUrl != null) {
        await dbRef.child(albumId).child("imageUrls").child(keyImg).set(newUrl);
        setState(() {});
      }
    }
  }

  /// Xóa ảnh
  Future<void> deleteImageFromAlbum(String albumId, String keyImg) async {
    await dbRef.child(albumId).child("imageUrls").child(keyImg).remove();
    setState(() {});
  }

  /// Dialog xem ảnh lớn + edit/delete
  void showImageDialog(String albumId, String keyImg, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const CircularProgressIndicator(),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () {
                      Navigator.pop(context);
                      editImageInAlbum(albumId, keyImg, url);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                      deleteImageFromAlbum(albumId, keyImg);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xóa toàn bộ ảnh album
  Future<void> deleteAllImages(String albumId) async {
    await dbRef.child(albumId).child("imageUrls").set(null);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: FutureBuilder<Map<String, Map<String, String>>>(
        future: fetchAlbums(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple));
          } else if (snapshot.hasError) {
            return const Center(child: Text("Lỗi tải album"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Chưa có album"));
          }

          final albums = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: albums.keys.length,
            itemBuilder: (context, index) {
              final albumId = albums.keys.elementAt(index);
              final images = albums[albumId]!; // Map<key,url>
              final keys = images.keys.toList();

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row tiêu đề + thêm ảnh + xóa tất cả
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            albumId,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.green),
                                onPressed: () => addImageToAlbum(albumId),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_forever, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Xác nhận"),
                                      content: const Text(
                                          "Bạn có chắc muốn xóa toàn bộ ảnh trong album này?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text("Hủy"),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text("Xóa",
                                              style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await deleteAllImages(albumId);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: images.length,
                        itemBuilder: (context, i) {
                          final keyImg = keys[i];
                          final url = images[keyImg]!;

                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    showImageDialog(albumId, keyImg, url),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    placeholder: (_, __) => Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                          child: Icon(Icons.broken_image,
                                              size: 30)),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () =>
                                      deleteImageFromAlbum(albumId, keyImg),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.close,
                                        size: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
