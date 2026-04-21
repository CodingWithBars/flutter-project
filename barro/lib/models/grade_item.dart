class GradeItem {
  final String id;
  final String title;
  final String category; // 'quiz', 'project', 'assignment', 'oral', 'exam'
  final double score;
  final double totalPoints;
  final DateTime date;
  final String description;
  final String? examType; // 'prelim', 'midterm', 'final'

  GradeItem({
    required this.id,
    required this.title,
    required this.category,
    required this.score,
    required this.totalPoints,
    required this.date,
    this.description = '',
    this.examType,
  });

  double get percentage => totalPoints > 0 ? (score / totalPoints) * 100 : 0;

  String get letterGrade {
    final pct = percentage;
    if (pct >= 97) return '1.00';
    if (pct >= 94) return '1.25';
    if (pct >= 91) return '1.50';
    if (pct >= 88) return '1.75';
    if (pct >= 85) return '2.00';
    if (pct >= 82) return '2.25';
    if (pct >= 79) return '2.50';
    if (pct >= 76) return '2.75';
    if (pct >= 75) return '3.00';
    return '5.00';
  }

  String get status => percentage >= 75 ? 'Passed' : 'Failed';
}
