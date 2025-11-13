// widgets/profile/profile_photo.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ProfilePhoto extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;

  const ProfilePhoto({super.key, this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
              border: Border.all(color: AppColors.secondary, width: 3),
              image: imagePath != null 
                ? (imagePath!.startsWith('http')
                    ? DecorationImage(
                        image: NetworkImage(imagePath!),
                        fit: BoxFit.cover,
                      )
                    : DecorationImage(
                        image: FileImage(File(imagePath!)),
                        fit: BoxFit.cover,
                      ))
                : null,
            ),
            child: imagePath == null 
              ? Icon(
                  Icons.business, 
                  size: 60, 
                  color: AppColors.textSecondary
                ) 
              : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                color: AppColors.secondary, 
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), 
                    blurRadius: 8
                  )
                ]
              ),
              child: Icon(
                Icons.camera_alt, 
                color: Colors.white, 
                size: 18
              ),
            ),
          ),
        ],
      ),
    );
  }
}