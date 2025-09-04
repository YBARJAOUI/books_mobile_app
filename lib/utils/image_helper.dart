import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageHelper {
  /// Construit un Widget Image à partir d'une chaîne base64
  static Widget buildImageFromBase64(
    String? imageData, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    if (imageData == null || imageData.isEmpty) {
      return placeholder ?? _defaultPlaceholder();
    }

    try {
      Uint8List bytes;

      // Cas 1: Data URI complète (data:image/jpeg;base64,...)
      if (imageData.startsWith('data:')) {
        final uri = Uri.parse(imageData);
        if (uri.data != null) {
          bytes = uri.data!.contentAsBytes();
        } else {
          return errorWidget ?? _defaultErrorWidget();
        }
      }
      // Cas 2: Chaîne base64 pure (sans préfixe)
      else {
        try {
          bytes = base64Decode(imageData);
        } catch (e) {
          print('Erreur décodage base64: $e');
          return errorWidget ?? _defaultErrorWidget();
        }
      }

      return Image.memory(
        bytes,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          print('Erreur affichage image: $error');
          return errorWidget ?? _defaultErrorWidget();
        },
      );
    } catch (e) {
      print('Erreur traitement image: $e');
      return errorWidget ?? _defaultErrorWidget();
    }
  }

  /// Vérifie si une chaîne est une image base64 valide
  static bool isValidBase64Image(String? imageData) {
    if (imageData == null || imageData.isEmpty) {
      return false;
    }

    try {
      if (imageData.startsWith('data:')) {
        final uri = Uri.parse(imageData);
        return uri.data != null;
      } else {
        base64Decode(imageData);
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  /// Convertit une image base64 pure en Data URI
  static String toDataUri(
    String base64String, {
    String mimeType = 'image/jpeg',
  }) {
    if (base64String.startsWith('data:')) {
      return base64String;
    }
    return 'data:$mimeType;base64,$base64String';
  }

  /// Extrait la partie base64 d'une Data URI
  static String extractBase64(String imageData) {
    if (imageData.startsWith('data:')) {
      final commaIndex = imageData.indexOf(',');
      if (commaIndex != -1) {
        return imageData.substring(commaIndex + 1);
      }
    }
    return imageData;
  }

  static Widget _defaultPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.book, color: Colors.grey[400], size: 48),
    );
  }

  static Widget _defaultErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.broken_image, color: Colors.grey[400], size: 48),
    );
  }
}
