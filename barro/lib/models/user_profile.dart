class UserProfile {
  String name;
  String studentId;
  String course;
  String section;
  int avatarColorIndex;
  String? avatarImagePath;

  UserProfile({
    this.name = 'Juan Dela Cruz',
    this.studentId = '2023-00123',
    this.course = 'BS Information Technology',
    this.section = '3-A',
    this.avatarColorIndex = 0,
    this.avatarImagePath,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'studentId': studentId,
        'course': course,
        'section': section,
        'avatarColorIndex': avatarColorIndex,
        'avatarImagePath': avatarImagePath,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String? ?? 'Juan Dela Cruz',
        studentId: json['studentId'] as String? ?? '2023-00123',
        course: json['course'] as String? ?? 'BS Information Technology',
        section: json['section'] as String? ?? '3-A',
        avatarColorIndex: json['avatarColorIndex'] as int? ?? 0,
        avatarImagePath: json['avatarImagePath'] as String?,
      );
}
