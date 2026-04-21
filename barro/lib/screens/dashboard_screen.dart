import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/todo_model.dart';
import '../provider/grade_provider.dart';
import '../provider/schedule_provider.dart';
import '../provider/todo_provider.dart';
import '../provider/user_provider.dart';
import '../widgets/flip_card.dart';
import '../widgets/line_graph.dart';
import '../widgets/stat_card.dart';
import '../widgets/user_avatar.dart';
import 'flashcard_screen.dart';
import 'pomodoro_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer4<GradeProvider, TodoProvider, UserProvider, ScheduleProvider>(
        builder: (context, grades, todos, user, schedule, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildHeader(context, user),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 16),
              _buildUpNextClass(context, schedule),
              _buildFlipGradeCard(context, grades),
              const SizedBox(height: 20),
              _buildStatsGrid(context, grades, todos),
              const SizedBox(height: 24),
              _buildCategoryBreakdown(context, grades),
              const SizedBox(height: 24),
              _buildUpcomingTasks(context, todos),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProvider user) {
    return Row(
      children: [
        UserAvatar(user: user, radius: 24),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, ${user.profile.name.split(' ').first}! 👋',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('EEEE, MMMM d').format(DateTime.now()),
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Quick Actions ──
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.style_rounded,
            label: 'Flashcards',
            color: const Color(0xFF06B6D4),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FlashcardDeckScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.timer_rounded,
            label: 'Focus Timer',
            color: const Color(0xFFEF4444),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PomodoroScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // ── Up Next Class ──
  Widget _buildUpNextClass(BuildContext context, ScheduleProvider schedule) {
    final nextClass = schedule.getUpNextClass();
    if (nextClass == null) return const SizedBox.shrink();

    final color = Color(nextClass.colorHex);

    String formatTime(TimeOfDay time) {
      final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
      final period = time.hour >= 12 ? 'PM' : 'AM';
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    }

    // Determine if it's today
    final now = DateTime.now();
    int currentDay = now.weekday;
    String dayLabel = nextClass.dayOfWeek == currentDay ? 'Today' : 'Upcoming';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.school_rounded, size: 20, color: Colors.white54),
            const SizedBox(width: 8),
            Text(
              'Up Next',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.class_rounded, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextClass.subjectName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text(
                          '$dayLabel • ${formatTime(nextClass.startTime)} - ${formatTime(nextClass.endTime)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    if (nextClass.room.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.room_rounded, size: 14, color: Colors.white54),
                          const SizedBox(width: 4),
                          Text(
                            nextClass.room,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Flip Card: Overall Grade ↔ Line Graph ──

  Widget _buildFlipGradeCard(BuildContext context, GradeProvider grades) {
    return SizedBox(
      height: 295,
      child: FlipCard(
        front: _buildGradeFront(context, grades),
        back: _buildGraphBack(context, grades),
      ),
    );
  }

  Widget _buildGradeFront(BuildContext context, GradeProvider grades) {
    final overall = grades.overallGrade;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded,
                  color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Overall Grade',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  grades.overallLetterGrade,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${overall.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          Text(
            grades.overallRemark,
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: overall / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 6,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              _buildWeightChip('Quiz 20%'),
              const SizedBox(width: 6),
              _buildWeightChip('Project 20%'),
              const SizedBox(width: 6),
              _buildWeightChip('Exam 30%'),
              const Spacer(),
              Icon(Icons.touch_app_rounded,
                  color: Colors.white.withValues(alpha: 0.3), size: 14),
              const SizedBox(width: 4),
              Text(
                'Tap to flip',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white60, fontSize: 10),
      ),
    );
  }

  Widget _buildGraphBack(BuildContext context, GradeProvider grades) {
    final categories = [
      ('quiz', 'Quiz'),
      ('project', 'Project'),
      ('assignment', 'Assign'),
      ('oral', 'Recit'),
      ('exam', 'Exam'),
    ];

    final values =
        categories.map((c) => grades.categoryAverage(c.$1)).toList();
    final labels = categories.map((c) => c.$2).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Icon(Icons.show_chart_rounded,
                    color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Grade Distribution',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.touch_app_rounded,
                    color: Colors.white.withValues(alpha: 0.3), size: 14),
                const SizedBox(width: 4),
                Text(
                  'Tap to flip',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: LineGraph(values: values, labels: labels),
          ),
        ],
      ),
    );
  }

  // ── Stats Grid ──

  Widget _buildStatsGrid(
      BuildContext context, GradeProvider grades, TodoProvider todos) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        StatCard(
          title: 'Quizzes Avg',
          value: '${grades.categoryAverage('quiz').toStringAsFixed(0)}%',
          icon: Icons.quiz_rounded,
          color: const Color(0xFF7C3AED),
        ),
        StatCard(
          title: 'Projects Avg',
          value: '${grades.categoryAverage('project').toStringAsFixed(0)}%',
          icon: Icons.folder_rounded,
          color: const Color(0xFF06B6D4),
        ),
        StatCard(
          title: 'Exams Avg',
          value: '${grades.categoryAverage('exam').toStringAsFixed(0)}%',
          icon: Icons.school_rounded,
          color: const Color(0xFFEC4899),
        ),
        StatCard(
          title: 'Pending Tasks',
          value: '${todos.pendingCount}',
          icon: Icons.assignment_late_rounded,
          color: const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  // ── Category Breakdown ──

  Widget _buildCategoryBreakdown(BuildContext context, GradeProvider grades) {
    final categories = [
      ('quiz', 'Quizzes', Icons.quiz_rounded, const Color(0xFF7C3AED)),
      ('project', 'Projects', Icons.folder_rounded, const Color(0xFF06B6D4)),
      ('assignment', 'Assignments', Icons.assignment_rounded,
          const Color(0xFF10B981)),
      ('oral', 'Recitation', Icons.record_voice_over_rounded,
          const Color(0xFFF59E0B)),
      ('exam', 'Exams', Icons.school_rounded, const Color(0xFFEC4899)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bar_chart_rounded,
                size: 20, color: Colors.white54),
            const SizedBox(width: 8),
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...categories.map((c) {
          final avg = grades.categoryAverage(c.$1);
          final count = grades.getByCategory(c.$1).length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showCategoryDetails(context, grades, c.$1, c.$2, c.$4),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: c.$4.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(c.$3, size: 18, color: c.$4),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.$2,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('$count items',
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 12)),
                            const SizedBox(width: 8),
                            Text(
                              '· Weight: ${(GradeProvider.categoryWeights[c.$1]! * 100).toInt()}%',
                              style: const TextStyle(
                                  color: Colors.white24, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: avg / 100,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.08),
                            valueColor: AlwaysStoppedAnimation(c.$4),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${avg.toStringAsFixed(1)}%',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: c.$4),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }),
  ],
    );
  }

  // ── Upcoming Tasks ──

  Widget _buildUpcomingTasks(BuildContext context, TodoProvider todos) {
    final pending = todos.getFiltered('pending');
    pending.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final upcoming = pending.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.upcoming_rounded,
                size: 20, color: Colors.white54),
            const SizedBox(width: 8),
            Text(
              'Upcoming Tasks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (upcoming.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No pending tasks — you\'re all caught up! 🎉',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ),
          )
        else
          ...upcoming.map((todo) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildMiniTodoTile(context, todo),
              )),
      ],
    );
  }

  Widget _buildMiniTodoTile(BuildContext context, Todo todo) {
    Color priorityColor;
    switch (todo.priority) {
      case 'high':
        priorityColor = const Color(0xFFEF4444);
        break;
      case 'medium':
        priorityColor = const Color(0xFFF59E0B);
        break;
      default:
        priorityColor = const Color(0xFF06B6D4);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showTodoDetails(context, todo),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: priorityColor, width: 3)),
          ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(todo.title,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                if (todo.subjectName != null && todo.subjectName!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    todo.subjectName!,
                    style: TextStyle(
                      color: priorityColor.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Due: ${DateFormat('MMM dd').format(todo.dueDate)}',
                  style: TextStyle(
                    color: todo.isOverdue
                        ? const Color(0xFFEF4444)
                        : Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              todo.priority.toUpperCase(),
              style: TextStyle(
                  color: priorityColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }

  void _showCategoryDetails(BuildContext context, GradeProvider grades, String categoryId, String categoryName, Color color) {
    final items = grades.getByCategory(categoryId);
    final avg = grades.categoryAverage(categoryId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  categoryName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Avg: ${avg.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open_rounded, size: 64, color: Colors.white24),
                          const SizedBox(height: 16),
                          Text('No items in this category yet', style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('MMM dd, yyyy').format(item.date),
                                      style: const TextStyle(
                                          color: Colors.white54, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${item.score}/${item.totalPoints}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTodoDetails(BuildContext context, Todo todo) {
    Color priorityColor;
    switch (todo.priority) {
      case 'high':
        priorityColor = const Color(0xFFEF4444);
        break;
      case 'medium':
        priorityColor = const Color(0xFFF59E0B);
        break;
      default:
        priorityColor = const Color(0xFF06B6D4);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    todo.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    todo.priority.toUpperCase(),
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (todo.subjectName != null && todo.subjectName!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.class_rounded, size: 16, color: priorityColor),
                  const SizedBox(width: 8),
                  Text(
                    todo.subjectName!,
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            if (todo.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  todo.description,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.calendar_today_rounded, size: 20, color: Colors.white54),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Due Date', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(todo.dueDate),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: todo.isOverdue ? const Color(0xFFEF4444) : Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
