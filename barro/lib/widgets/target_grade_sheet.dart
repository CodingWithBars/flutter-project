import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/grade_provider.dart';

void showTargetGradeSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const TargetGradeSheet(),
  );
}

class TargetGradeSheet extends StatefulWidget {
  const TargetGradeSheet({super.key});

  @override
  State<TargetGradeSheet> createState() => _TargetGradeSheetState();
}

class _TargetGradeSheetState extends State<TargetGradeSheet> {
  final _targetController = TextEditingController(text: '90');
  String _selectedCategory = 'exam';

  final Map<String, String> _categoryNames = {
    'quiz': 'Quizzes',
    'project': 'Projects',
    'assignment': 'Assignments',
    'oral': 'Recitation',
    'exam': 'Exams',
  };

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Consumer<GradeProvider>(
        builder: (context, grades, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Icon(Icons.calculate_rounded, color: Colors.amber, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Target Grade Calculator',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Find out what score you need in a specific category to reach your target overall grade.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Inputs
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _targetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Target Overall (%)',
                          prefixIcon: Icon(Icons.flag_rounded),
                          suffixText: '%',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Target Category',
                          prefixIcon: Icon(Icons.category_rounded),
                        ),
                        items: _categoryNames.entries.map((e) {
                          return DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Result
                _buildResultCard(context, grades),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, GradeProvider grades) {
    double targetOverall = double.tryParse(_targetController.text) ?? 0.0;
    if (targetOverall <= 0) {
      return const SizedBox.shrink();
    }

    // Calculate required average in the selected category
    // Assuming all categories will be populated and total weight is 1.0 (100%)
    double otherCategoriesWeightedSum = 0;
    
    for (var entry in GradeProvider.categoryWeights.entries) {
      if (entry.key != _selectedCategory) {
        otherCategoriesWeightedSum += grades.categoryAverage(entry.key) * entry.value;
      }
    }

    double targetCategoryWeight = GradeProvider.categoryWeights[_selectedCategory] ?? 0.0;
    
    // Target = OtherSum + (RequiredAvg * Weight)
    // RequiredAvg = (Target - OtherSum) / Weight
    double requiredAvg = (targetOverall - otherCategoriesWeightedSum) / targetCategoryWeight;

    // Determine status
    Color statusColor;
    String statusMessage;
    IconData statusIcon;

    if (requiredAvg > 100) {
      statusColor = Colors.redAccent;
      statusMessage = 'Impossible! You would need >100%.';
      statusIcon = Icons.error_outline_rounded;
    } else if (requiredAvg <= 0) {
      statusColor = Colors.greenAccent;
      statusMessage = 'You already achieved this target!';
      statusIcon = Icons.check_circle_outline_rounded;
      requiredAvg = 0;
    } else {
      statusColor = Theme.of(context).colorScheme.primary;
      statusMessage = 'You can do it! Stay focused.';
      statusIcon = Icons.lightbulb_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Required ${_categoryNames[_selectedCategory]} Average:',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${requiredAvg.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, color: statusColor, size: 18),
              const SizedBox(width: 8),
              Text(
                statusMessage,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
