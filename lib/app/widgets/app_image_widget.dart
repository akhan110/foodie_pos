import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodiepos/app/theme/app_colors.dart';
import 'package:foodiepos/services/network/network.dart';

class AppImageWidget extends StatelessWidget {
  const AppImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.fallbackIcon = Icons.fastfood_rounded,
    this.fallbackIconColor = AppColors.primary,
    this.fallbackIconSize = 28,
  });

  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final Color fallbackIconColor;
  final double fallbackIconSize;

  @override
  Widget build(BuildContext context) {
    final path = imagePath?.trim() ?? '';

    Widget imageContent;

    if (path.isEmpty) {
      imageContent = _buildPlaceholder();
    } else if (path.startsWith('http://') || path.startsWith('https://')) {
      imageContent = Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: fallbackIconColor,
              ),
            ),
          );
        },
      );
    } else if (path.startsWith('/uploads/')) {
      final baseUrl = Network.instance.isInitialized
          ? Network.instance.dio.options.baseUrl
          : 'http://localhost:8000';
      final fullUrl = '$baseUrl$path';
      imageContent = Image.network(
        fullUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else if (path.endsWith('.svg')) {
      imageContent = SvgPicture.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else if (path.startsWith('assets/')) {
      imageContent = Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else if (File(path).existsSync()) {
      imageContent = Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } else {
      imageContent = _buildPlaceholder();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageContent,
      );
    }

    return imageContent;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: fallbackIconColor.withValues(alpha: 0.08),
      child: Icon(
        fallbackIcon,
        size: fallbackIconSize,
        color: fallbackIconColor,
      ),
    );
  }
}
