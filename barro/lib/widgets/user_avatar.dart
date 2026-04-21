import 'dart:io';
import 'package:flutter/material.dart';
import '../provider/user_provider.dart';

class UserAvatar extends StatelessWidget {
  final UserProvider user;
  final double radius;
  final bool showEditBadge;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 24,
    this.showEditBadge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar;

    if (user.hasCustomAvatar) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(user.profile.avatarImagePath!)),
        backgroundColor: user.avatarColor,
      );
    } else {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: user.avatarColor,
        child: Text(
          user.profile.initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.6,
          ),
        ),
      );
    }

    if (showEditBadge) {
      avatar = Stack(
        children: [
          avatar,
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2.5,
                ),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: radius * 0.3,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }
}
