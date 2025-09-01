import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _basePath = 'evaluation_images';

  // Upload single image with compression
  Future<String> uploadImage({
    required File imageFile,
    required String evaluationId,
    required String imageType, // e.g., 'property', 'location', 'satellite'
  }) async {
    try {
      // Compress image before upload
      File compressedImage = await _compressImage(imageFile);

      // Generate unique filename
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$imageType.jpg';
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

  // Upload multiple images
  Future<List<String>> uploadMultipleImages({
    required List<File> imageFiles,
    required String evaluationId,
    required String imageType,
  }) async {
    try {
      List<String> downloadUrls = [];

      for (int i = 0; i < imageFiles.length; i++) {
        String url = await uploadImage(
          imageFile: imageFiles[i],
          evaluationId: evaluationId,
          imageType: '${imageType}_$i',
        );
        downloadUrls.add(url);
      }

      return downloadUrls;
    } catch (e) {
      throw Exception('Failed to upload multiple images: $e');
    }
  }

  // Delete image from Firebase Storage
  Future<void> deleteImage(String downloadURL) async {
    try {
      Reference ref = _storage.refFromURL(downloadURL);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Delete all images for an evaluation
  Future<void> deleteEvaluationImages(String evaluationId) async {
    try {
      Reference ref = _storage.ref().child('$_basePath/$evaluationId');
      ListResult result = await ref.listAll();

      // Delete all files in the folder
      for (Reference file in result.items) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete evaluation images: $e');
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
      String tempPath =
          '${imageFile.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      File compressedFile = File(tempPath);
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  // Get image file size in MB
  Future<double> getImageSizeInMB(File imageFile) async {
    int bytes = await imageFile.length();
    return bytes / (1024 * 1024); // Convert to MB
  }

  // Check if image is valid format
  bool isValidImageFormat(String filePath) {
    String extension = filePath.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'webp'].contains(extension);
  }
}
