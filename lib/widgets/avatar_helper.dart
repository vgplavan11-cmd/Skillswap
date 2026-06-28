import 'dart:io';
import 'package:flutter/material.dart';

Widget buildSafeAvatar({
  required String imagePath,
  double radius = 24.0,
  IconData fallbackIcon = Icons.person,
  double? fallbackIconSize,
}) {
  final double iconSize = fallbackIconSize ?? radius;

  if (imagePath.isEmpty) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: Icon(fallbackIcon, size: iconSize, color: Colors.grey[600]),
    );
  }

  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(imagePath),
      backgroundColor: Colors.grey[300],
      onBackgroundImageError: (exception, stackTrace) {
        // Fallback silently if URL fails to load
      },
    );
  }

  // Handle local files (e.g. cached files from ImagePicker during registration)
  if (imagePath.startsWith('/') || imagePath.contains(':\\') || imagePath.contains(':/')) {
    try {
      final file = File(imagePath);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: FileImage(file),
          backgroundColor: Colors.grey[300],
        );
      }
    } catch (_) {
      // Ignore filesystem access exceptions
    }
  }

  // Default fallback icon
  return CircleAvatar(
    radius: radius,
    backgroundColor: Colors.grey[300],
    child: Icon(fallbackIcon, size: iconSize, color: Colors.grey[600]),
  );
}
