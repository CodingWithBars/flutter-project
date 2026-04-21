import 'package:flutter/foundation.dart';
import '../models/grade_item.dart';

class GradeProvider extends ChangeNotifier {
  List<GradeItem> _grades = [];
  bool _isLoaded = false;

  List<GradeItem> get allGrades => List.unmodifiable(_grades);
  bool get isLoaded => _isLoaded;

  // Category getters
  List<GradeItem> get quizzes =>
      _grades.where((g) => g.category == 'quiz').toList();
  List<GradeItem> get projects =>
      _grades.where((g) => g.category == 'project').toList();
  List<GradeItem> get assignments =>
      _grades.where((g) => g.category == 'assignment').toList();
  List<GradeItem> get oralRecitations =>
      _grades.where((g) => g.category == 'oral').toList();
  List<GradeItem> get exams =>
      _grades.where((g) => g.category == 'exam').toList();

  List<GradeItem> getByCategory(String category) {
    return _grades.where((g) => g.category == category).toList();
  }

  double categoryAverage(String category) {
    final items = getByCategory(category);
    if (items.isEmpty) return 0;
    return items.map((i) => i.percentage).reduce((a, b) => a + b) /
        items.length;
  }

  double categoryHighest(String category) {
    final items = getByCategory(category);
    if (items.isEmpty) return 0;
    return items.map((i) => i.percentage).reduce((a, b) => a > b ? a : b);
  }

  double categoryLowest(String category) {
    final items = getByCategory(category);
    if (items.isEmpty) return 0;
    return items.map((i) => i.percentage).reduce((a, b) => a < b ? a : b);
  }

  // Weighted overall grade
  static const Map<String, double> categoryWeights = {
    'quiz': 0.20,
    'project': 0.20,
    'assignment': 0.15,
    'oral': 0.15,
    'exam': 0.30,
  };

  double get overallGrade {
    double weighted = 0;
    double totalWeight = 0;

    for (final entry in categoryWeights.entries) {
      final items = getByCategory(entry.key);
      if (items.isNotEmpty) {
        final avg = categoryAverage(entry.key);
        weighted += avg * entry.value;
        totalWeight += entry.value;
      }
    }

    return totalWeight > 0 ? weighted / totalWeight : 0;
  }

  String get overallLetterGrade {
    final pct = overallGrade;
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

  String get overallRemark {
    final pct = overallGrade;
    if (pct >= 97) return 'Excellent';
    if (pct >= 94) return 'Very Good';
    if (pct >= 88) return 'Good';
    if (pct >= 82) return 'Satisfactory';
    if (pct >= 75) return 'Passing';
    if (pct == 0) return 'No grades yet';
    return 'Needs Improvement';
  }

  void loadDummyData() {
    if (_isLoaded) return;
    _grades = _getDummyGrades();
    _isLoaded = true;
    notifyListeners();
  }

  static List<GradeItem> _getDummyGrades() {
    return [
      // ── Quizzes ──
      GradeItem(
        id: 'q1',
        title: 'Quiz 1',
        category: 'quiz',
        score: 85,
        totalPoints: 100,
        date: DateTime(2025, 8, 20),
        description: 'Introduction to Computing',
      ),
      GradeItem(
        id: 'q2',
        title: 'Quiz 2',
        category: 'quiz',
        score: 92,
        totalPoints: 100,
        date: DateTime(2025, 9, 3),
        description: 'Data Types & Variables',
      ),
      GradeItem(
        id: 'q3',
        title: 'Quiz 3',
        category: 'quiz',
        score: 78,
        totalPoints: 100,
        date: DateTime(2025, 9, 17),
        description: 'Control Structures',
      ),
      GradeItem(
        id: 'q4',
        title: 'Quiz 4',
        category: 'quiz',
        score: 95,
        totalPoints: 100,
        date: DateTime(2025, 10, 1),
        description: 'Functions & Methods',
      ),
      GradeItem(
        id: 'q5',
        title: 'Quiz 5',
        category: 'quiz',
        score: 88,
        totalPoints: 100,
        date: DateTime(2025, 10, 15),
        description: 'Object-Oriented Programming',
      ),

      // ── Projects ──
      GradeItem(
        id: 'p1',
        title: 'Research Paper',
        category: 'project',
        score: 90,
        totalPoints: 100,
        date: DateTime(2025, 9, 10),
        description: 'History of Computing',
      ),
      GradeItem(
        id: 'p2',
        title: 'Group Presentation',
        category: 'project',
        score: 88,
        totalPoints: 100,
        date: DateTime(2025, 10, 20),
        description: 'Software Development Life Cycle',
      ),
      GradeItem(
        id: 'p3',
        title: 'Final Project',
        category: 'project',
        score: 95,
        totalPoints: 100,
        date: DateTime(2025, 11, 25),
        description: 'Student Management System',
      ),

      // ── Assignments ──
      GradeItem(
        id: 'a1',
        title: 'Assignment 1',
        category: 'assignment',
        score: 45,
        totalPoints: 50,
        date: DateTime(2025, 8, 25),
        description: 'Flowchart & Pseudocode',
      ),
      GradeItem(
        id: 'a2',
        title: 'Assignment 2',
        category: 'assignment',
        score: 48,
        totalPoints: 50,
        date: DateTime(2025, 9, 8),
        description: 'Variable Declaration Exercises',
      ),
      GradeItem(
        id: 'a3',
        title: 'Assignment 3',
        category: 'assignment',
        score: 40,
        totalPoints: 50,
        date: DateTime(2025, 9, 22),
        description: 'Loop Practice Problems',
      ),
      GradeItem(
        id: 'a4',
        title: 'Assignment 4',
        category: 'assignment',
        score: 47,
        totalPoints: 50,
        date: DateTime(2025, 10, 6),
        description: 'Array Manipulation',
      ),
      GradeItem(
        id: 'a5',
        title: 'Assignment 5',
        category: 'assignment',
        score: 44,
        totalPoints: 50,
        date: DateTime(2025, 10, 20),
        description: 'File Handling',
      ),
      GradeItem(
        id: 'a6',
        title: 'Assignment 6',
        category: 'assignment',
        score: 50,
        totalPoints: 50,
        date: DateTime(2025, 11, 3),
        description: 'Database Basics',
      ),

      // ── Oral Recitation / Participation ──
      GradeItem(
        id: 'o1',
        title: 'Recitation — Week 3',
        category: 'oral',
        score: 18,
        totalPoints: 20,
        date: DateTime(2025, 9, 1),
        description: 'Class discussion on algorithms',
      ),
      GradeItem(
        id: 'o2',
        title: 'Recitation — Week 6',
        category: 'oral',
        score: 17,
        totalPoints: 20,
        date: DateTime(2025, 9, 22),
        description: 'Board work — sorting',
      ),
      GradeItem(
        id: 'o3',
        title: 'Recitation — Week 9',
        category: 'oral',
        score: 20,
        totalPoints: 20,
        date: DateTime(2025, 10, 13),
        description: 'Q&A on OOP concepts',
      ),
      GradeItem(
        id: 'o4',
        title: 'Recitation — Week 12',
        category: 'oral',
        score: 19,
        totalPoints: 20,
        date: DateTime(2025, 11, 3),
        description: 'Case study presentation',
      ),

      // ── Exams ──
      GradeItem(
        id: 'e1',
        title: 'Prelim Exam',
        category: 'exam',
        score: 82,
        totalPoints: 100,
        date: DateTime(2025, 9, 15),
        description: 'Covers Chapters 1–4',
        examType: 'prelim',
      ),
      GradeItem(
        id: 'e2',
        title: 'Midterm Exam',
        category: 'exam',
        score: 88,
        totalPoints: 100,
        date: DateTime(2025, 10, 27),
        description: 'Covers Chapters 5–8',
        examType: 'midterm',
      ),
      GradeItem(
        id: 'e3',
        title: 'Final Exam',
        category: 'exam',
        score: 91,
        totalPoints: 100,
        date: DateTime(2025, 12, 5),
        description: 'Comprehensive Exam',
        examType: 'final',
      ),
    ];
  }
}
