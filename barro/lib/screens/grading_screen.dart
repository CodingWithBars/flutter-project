import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/grade_provider.dart';
import '../widgets/grade_item_tile.dart';
import '../widgets/grade_summary_card.dart';

class GradingScreen extends StatelessWidget {
  const GradingScreen({super.key});

  static const _categories = [
    ('quiz', 'Quizzes', Icons.quiz_rounded, Color(0xFF7C3AED)),
    ('project', 'Projects', Icons.folder_rounded, Color(0xFF06B6D4)),
    ('assignment', 'Assignments', Icons.assignment_rounded, Color(0xFF10B981)),
    ('oral', 'Recitation', Icons.record_voice_over_rounded, Color(0xFFF59E0B)),
    ('exam', 'Exams', Icons.school_rounded, Color(0xFFEC4899)),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _categories.length,
      child: SafeArea(
        child: Consumer<GradeProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Grades',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Overall: ',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 14),
                          ),
                          Text(
                            '${provider.overallGrade.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${provider.overallLetterGrade})',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '· ${provider.overallRemark}',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Tab bar
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.white.withValues(alpha: 0.05),
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.white38,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(fontSize: 14),
                  indicatorWeight: 3,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  tabs: _categories
                      .map((c) => Tab(
                            child: Row(
                              children: [
                                Icon(c.$3, size: 18),
                                const SizedBox(width: 6),
                                Text(c.$2),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                // Tab views
                Expanded(
                  child: TabBarView(
                    children: _categories.map((c) {
                      return _buildCategoryView(
                          context, provider, c.$1, c.$2, c.$3, c.$4);
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryView(
    BuildContext context,
    GradeProvider provider,
    String category,
    String title,
    IconData icon,
    Color color,
  ) {
    final items = provider.getByCategory(category);
    final average = provider.categoryAverage(category);
    final highest = provider.categoryHighest(category);
    final lowest = provider.categoryLowest(category);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        GradeSummaryCard(
          title: title,
          average: average,
          itemCount: items.length,
          highest: highest,
          lowest: lowest,
          color: color,
          icon: icon,
        ),
        const SizedBox(height: 16),
        ...items.map((item) => GradeItemTile(item: item)),
      ],
    );
  }
}
