import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

class ImageCompressionService {
  /// Compress an image file to reduce size before upload
  /// 
  /// Parameters:
  /// - imageFile: The original image file
  /// - maxWidth: Maximum width in pixels (default 1920)
  /// - maxHeight: Maximum height in pixels (default 1920)
  /// - quality: JPEG quality 1-100 (default 85)
  /// 
  /// Returns: Compressed image file
  static Future<File> compressImage(
    File imageFile, {
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 85,
  }) async {
    try {
      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      
      // Decode image
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Calculate new dimensions maintaining aspect ratio
      int targetWidth = image.width;
      int targetHeight = image.height;

      if (targetWidth > maxWidth || targetHeight > maxHeight) {
        final aspectRatio = targetWidth / targetHeight;
        
        if (aspectRatio > 1) {
          // Landscape
          targetWidth = maxWidth;
          targetHeight = (maxWidth / aspectRatio).round();
        } else {
          // Portrait or square
          targetHeight = maxHeight;
          targetWidth = (maxHeight * aspectRatio).round();
        }
      }

      // Resize if needed
      if (targetWidth != image.width || targetHeight != image.height) {
        image = img.copyResize(
          image,
          width: targetWidth,
          height: targetHeight,
          interpolation: img.Interpolation.linear,
        );
      }

      // Compress to JPEG
      final compressedBytes = img.encodeJpg(image, quality: quality);

      // Create new file with compressed data
      final dir = path.dirname(imageFile.path);
      final filename = path.basenameWithoutExtension(imageFile.path);
      final extension = '.jpg'; // Always save as JPEG
      final compressedPath = path.join(dir, '${filename}_compressed$extension');
      
      final compressedFile = File(compressedPath);
      await compressedFile.writeAsBytes(compressedBytes);

      // Log compression results
      final originalSize = bytes.length / 1024 / 1024; // MB
      final compressedSize = compressedBytes.length / 1024 / 1024; // MB
      final reduction = ((1 - compressedSize / originalSize) * 100).toStringAsFixed(1);
      
      print('Image compressed:');
      print('  Original: ${originalSize.toStringAsFixed(2)} MB');
      print('  Compressed: ${compressedSize.toStringAsFixed(2)} MB');
      print('  Reduction: $reduction%');

      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      // Return original file if compression fails
      return imageFile;
    }
  }

  /// Compress multiple images in parallel
  static Future<List<File>> compressImages(
    List<File> imageFiles, {
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 85,
  }) async {
    final futures = imageFiles.map((file) => compressImage(
      file,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      quality: quality,
    ));
    
    return await Future.wait(futures);
  }

  /// Check if file is too large and needs compression
  static Future<bool> needsCompression(File imageFile, {int maxSizeMB = 2}) async {
    final bytes = await imageFile.length();
    final sizeMB = bytes / 1024 / 1024;
    return sizeMB > maxSizeMB;
  }
}
