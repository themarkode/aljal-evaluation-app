import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _basePath = 'evaluation_images';

  // Upload single image with compression
  Future<String> uploadImage({
    required File imageFile,
    required String evaluationId,
    required String imageType,
  }) async {
    try {
      // Compress image before upload
      File compressedImage = await _compressImage(imageFile);
      
      // Generate unique filename
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_$imageType.jpg';
      String fullPath = '$_basePath/$evaluationId/$fileName';

      // Upload to Firebase Storage
      Reference ref = _storage.ref().child(fullPath);
      UploadTask uploadTask = ref.putFile(compressedImage);
      
      // Wait for upload completion
      TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      String downloadURL = await snapshot.ref.getDownloadURL();
      
      // Clean up compressed file
      await compressedImage.delete();
      
      return downloadURL;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Compress image to reduce file size
  Future<File> _compressImage(File imageFile) async {
    try {
      // Read image
      Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) throw Exception('Could not decode image');
      
      // Resize if too large (max width/height: 1920px)
      if (image.width > 1920 || image.height > 1920) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? 1920 : null,
          height: image.height > image.width ? 1920 : null,
        );
      }
      
      // Compress as JPEG with 85% quality
      List<int> compressedBytes = img.encodeJpg(image, quality: 85);
      
      // Create temporary file
      String tempPath = '${imageFile.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      File compressedFile = File(tempPath);
      await compressedFile.writeAsBytes(compressedBytes);
      
      return compressedFile;
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }
}