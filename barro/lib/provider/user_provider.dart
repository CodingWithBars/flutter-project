import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  UserProfile _profile = UserProfile();
  bool _isLoaded = false;
  final ImagePicker _picker = ImagePicker();

  UserProfile get profile => _profile;
  bool get isLoaded => _isLoaded;

  static const List<Color> avatarColors = [
    Color(0xFF7C3AED),
    Color(0xFF06B6D4),
    Color(0xFF10B981),
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
  ];

  Color get avatarColor =>
      avatarColors[_profile.avatarColorIndex % avatarColors.length];

  bool get hasCustomAvatar {
    final p = _profile.avatarImagePath;
    return p != null && p.isNotEmpty && File(p).existsSync();
  }

  Future<void> loadProfile() async {
    if (_isLoaded) return;
    final data = await StorageService.loadUserProfile();
    if (data != null) {
      _profile = UserProfile.fromJson(data);
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? studentId,
    String? course,
    String? section,
  }) async {
    if (name != null) _profile.name = name;
    if (studentId != null) _profile.studentId = studentId;
    if (course != null) _profile.course = course;
    if (section != null) _profile.section = section;
    await _save();
    notifyListeners();
  }

  Future<void> setAvatarColor(int index) async {
    _profile.avatarColorIndex = index;
    await _save();
    notifyListeners();
  }

  Future<void> pickAvatar() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      final dir = await getApplicationDocumentsDirectory();
      final ext = image.path.split('.').last;
      final filename = 'avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final savedPath = '${dir.path}${Platform.pathSeparator}$filename';

      await File(image.path).copy(savedPath);

      // Delete old avatar
      if (_profile.avatarImagePath != null) {
        final oldFile = File(_profile.avatarImagePath!);
        if (oldFile.existsSync()) {
          try {
            await oldFile.delete();
          } catch (_) {}
        }
      }

      _profile.avatarImagePath = savedPath;
      await _save();
      notifyListeners();
    }
  }

  Future<void> removeAvatar() async {
    if (_profile.avatarImagePath != null) {
      final file = File(_profile.avatarImagePath!);
      if (file.existsSync()) {
        try {
          await file.delete();
        } catch (_) {}
      }
      _profile.avatarImagePath = null;
      await _save();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    await StorageService.saveUserProfile(_profile.toJson());
  }
}
