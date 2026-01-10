import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _basePath = 'evaluation_images';
  
  // Maximum file size (10MB)
  static const int _maxFileSize = 10 * 1024 * 1024;
  
  // Allowed image types
  static const List<String> _allowedExtensions = [
    '.jpg', '.jpeg', '.png', '.gif', '.webp'
  ];

  // Upload single image with compression
  Future<String> uploadImage({
    required File imageFile,
    required String evaluationId,
    required String imageType,
    Function(double)? onProgress,
  }) async {
    try {
      // Validate image
      await _validateImage(imageFile);
      
      // Compress image before upload
      File compressedImage = await _compressImage(imageFile);
      
      // Generate unique filename
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_$imageType.jpg';
      String fullPath = '$_basePath/$evaluationId/$fileName';

      // Upload to Firebase Storage with progress tracking
      Reference ref = _storage.ref().child(fullPath);
      UploadTask uploadTask = ref.putFile(compressedImage);
      
      // Track upload progress if callback provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }
      
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
    Function(int, double)? onProgress, // (index, progress)
  }) async {
    List<String> downloadURLs = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        String url = await uploadImage(
          imageFile: imageFiles[i],
          evaluationId: evaluationId,
          imageType: '${imageType}_${i + 1}',
          onProgress: onProgress != null 
            ? (progress) => onProgress(i, progress)
            : null,
        );
        downloadURLs.add(url);
      } catch (e) {
        // Skip failed image and continue with others
        // Error: Failed to upload image ${i + 1}: $e
        continue;
      }
    }
    
    return downloadURLs;
  }

  // Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Get reference from URL
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Delete all images for an evaluation
  Future<void> deleteEvaluationImages(String evaluationId) async {
    try {
      // List all files in the evaluation folder
      String folderPath = '$_basePath/$evaluationId';
      ListResult result = await _storage.ref(folderPath).listAll();
      
      // Delete each file
      for (Reference ref in result.items) {
        await ref.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete evaluation images: $e');
    }
  }

  // Replace an existing image
  Future<String> replaceImage({
    required String oldImageUrl,
    required File newImageFile,
    required String evaluationId,
    required String imageType,
  }) async {
    try {
      // Delete old image
      await deleteImage(oldImageUrl);
      
      // Upload new image
      return await uploadImage(
        imageFile: newImageFile,
        evaluationId: evaluationId,
        imageType: imageType,
      );
    } catch (e) {
      throw Exception('Failed to replace image: $e');
    }
  }

  // Get all image URLs for an evaluation
  Future<List<String>> getEvaluationImageUrls(String evaluationId) async {
    try {
      String folderPath = '$_basePath/$evaluationId';
      ListResult result = await _storage.ref(folderPath).listAll();
      
      List<String> urls = [];
      for (Reference ref in result.items) {
        String url = await ref.getDownloadURL();
        urls.add(url);
      }
      
      return urls;
    } catch (e) {
      throw Exception('Failed to get evaluation images: $e');
    }
  }

  // Validate image before upload
  Future<void> _validateImage(File imageFile) async {
    // Check if file exists
    if (!await imageFile.exists()) {
      throw Exception('Image file does not exist');
    }
    
    // Check file size
    int fileSize = await imageFile.length();
    if (fileSize > _maxFileSize) {
      throw Exception('Image size exceeds 10MB limit');
    }
    
    // Check file extension
    String extension = path.extension(imageFile.path).toLowerCase();
    if (!_allowedExtensions.contains(extension)) {
      throw Exception('Invalid image format. Allowed: ${_allowedExtensions.join(", ")}');
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
      
      // Get proper temporary directory
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      File compressedFile = File(tempPath);
      await compressedFile.writeAsBytes(compressedBytes);
      
      return compressedFile;
    } catch (e) {
      throw Exception('Failed to compress image: $e');
    }
  }

  // Upload image from bytes (useful for camera/gallery picker)
  Future<String> uploadImageFromBytes({
    required Uint8List imageBytes,
    required String evaluationId,
    required String imageType,
    Function(double)? onProgress,
  }) async {
    try {
      // Create temporary file from bytes
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg';
      File tempFile = File(tempPath);
      await tempFile.writeAsBytes(imageBytes);
      
      // Upload using regular method
      String url = await uploadImage(
        imageFile: tempFile,
        evaluationId: evaluationId,
        imageType: imageType,
        onProgress: onProgress,
      );
      
      // Clean up temp file
      await tempFile.delete();
      
      return url;
    } catch (e) {
      throw Exception('Failed to upload image from bytes: $e');
    }
  }

  // Get image metadata
  Future<FullMetadata?> getImageMetadata(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      return await ref.getMetadata();
    } catch (e) {
      // Return null if metadata fetch fails
      return null;
    }
  }

  // Check if image exists
  Future<bool> imageExists(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }
}