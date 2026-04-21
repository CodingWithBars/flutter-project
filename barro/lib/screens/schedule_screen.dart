import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule_model.dart';
import '../provider/schedule_provider.dart';
import '../widgets/add_schedule_dialog.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  static const _days = [
    (1, 'Mon'),
    (2, 'Tue'),
    (3, 'Wed'),
    (4, 'Thu'),
    (5, 'Fri'),
    (6, 'Sat'),
    (7, 'Sun'),
  ];

  @override
  Widget build(BuildContext context) {
    // Default to current weekday, or Monday if weekend
    final currentWeekday = DateTime.now().weekday;
    final initialIndex = currentWeekday <= 7 ? currentWeekday - 1 : 0;

    return DefaultTabController(
      length: _days.length,
      initialIndex: initialIndex,
      child: SafeArea(
        child: Consumer<ScheduleProvider>(
          builder: (context, provider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Class Schedule',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${provider.schedules.length} total classes',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 14),
                          ),
                        ],
                      ),
                      // Add Button
                      IconButton.filled(
                        onPressed: () {
                          showAddScheduleSheet(context);
                        },
                        icon: const Icon(Icons.add_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
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
                  tabs: _days
                      .map((d) => Tab(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(d.$2),
                            ),
                          ))
                      .toList(),
                ),
                // Tab views
                Expanded(
                  child: TabBarView(
                    children: _days.map((d) {
                      return _buildDayView(context, provider, d.$1);
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

  Widget _buildDayView(BuildContext context, ScheduleProvider provider, int dayOfWeek) {
    final classes = provider.getSchedulesForDay(dayOfWeek);

    if (classes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy_rounded, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            const Text('No classes today', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                showAddScheduleSheet(context);
              },
              child: const Text('Add a class'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final schedule = classes[index];
        return Dismissible(
          key: ValueKey(schedule.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 16),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.redAccent),
          ),
          confirmDismiss: (_) async {
            return await _confirmDelete(context, schedule, provider);
          },
          onDismissed: (_) {
            provider.deleteSchedule(schedule.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"${schedule.subjectName}" removed'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () => provider.addSchedule(schedule),
                ),
              ),
            );
          },
          child: _buildClassCard(context, schedule, provider),
        );
      },
    );
  }

  Future<bool> _confirmDelete(
      BuildContext context, ClassSchedule schedule, ScheduleProvider provider) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Remove "${schedule.subjectName}" from your schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildClassCard(BuildContext context, ClassSchedule schedule, ScheduleProvider provider) {
    final color = Color(schedule.colorHex);
    
    // Format times
    String formatTime(TimeOfDay time) {
      final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
      final period = time.hour >= 12 ? 'PM' : 'AM';
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Color bar
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            schedule.subjectName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Context menu — Edit / Delete
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded, color: Colors.white38, size: 20),
                          onSelected: (value) {
                            if (value == 'edit') {
                              showAddScheduleSheet(context, schedule: schedule);
                            } else if (value == 'delete') {
                              _confirmDelete(context, schedule, provider).then((confirmed) {
                                if (confirmed) provider.deleteSchedule(schedule.id);
                              });
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(children: [
                                Icon(Icons.edit_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ]),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(children: [
                                Icon(Icons.delete_rounded, size: 18, color: Colors.redAccent),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.redAccent)),
                              ]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 16, color: color),
                        const SizedBox(width: 6),
                        Text(
                          '${formatTime(schedule.startTime)} - ${formatTime(schedule.endTime)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (schedule.room.isNotEmpty) ...[
                          const Icon(Icons.room_rounded, size: 16, color: Colors.white38),
                          const SizedBox(width: 4),
                          Text(
                            schedule.room,
                            style: const TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                          const SizedBox(width: 16),
                        ],
                        if (schedule.instructor.isNotEmpty) ...[
                          const Icon(Icons.person_rounded, size: 16, color: Colors.white38),
                          const SizedBox(width: 4),
                          Text(
                            schedule.instructor,
                            style: const TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
