class Subject {
  final String id;
  String name;
  double units;
  double? midtermGrade;
  double? finalGrade;

  Subject({
    required this.id,
    required this.name,
    required this.units,
    this.midtermGrade,
    this.finalGrade,
  });

  double? get average {
    if (midtermGrade != null && finalGrade != null) {
      return (midtermGrade! + finalGrade!) / 2;
    } else if (midtermGrade != null) {
      return midtermGrade;
    } else if (finalGrade != null) {
      return finalGrade;
    }
    return null;
  }

  String get status {
    if (average == null) return 'Incomplete';
    return average! <= 3.0 ? 'Passed' : 'Failed';
  }

  String get remarks {
    if (average == null) return 'No grades yet';
    if (average! <= 1.25) return 'Excellent';
    if (average! <= 1.75) return 'Very Good';
    if (average! <= 2.25) return 'Good';
    if (average! <= 2.75) return 'Satisfactory';
    if (average! <= 3.0) return 'Passing';
    return 'Failed';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'units': units,
        'midtermGrade': midtermGrade,
        'finalGrade': finalGrade,
      };

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json['id'] as String,
        name: json['name'] as String,
        units: (json['units'] as num).toDouble(),
        midtermGrade: (json['midtermGrade'] as num?)?.toDouble(),
        finalGrade: (json['finalGrade'] as num?)?.toDouble(),
      );
}
