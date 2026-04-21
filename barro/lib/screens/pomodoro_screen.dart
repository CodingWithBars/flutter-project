import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/pomodoro_provider.dart';

class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Focus Mode',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<PomodoroProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mode Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ModeButton(
                        title: 'Focus',
                        isSelected: provider.mode == PomodoroMode.focus,
                        onTap: () => provider.setMode(PomodoroMode.focus),
                      ),
                      _ModeButton(
                        title: 'Short Break',
                        isSelected: provider.mode == PomodoroMode.shortBreak,
                        onTap: () => provider.setMode(PomodoroMode.shortBreak),
                      ),
                      _ModeButton(
                        title: 'Long Break',
                        isSelected: provider.mode == PomodoroMode.longBreak,
                        onTap: () => provider.setMode(PomodoroMode.longBreak),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Timer display
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: CircularProgressIndicator(
                        value: provider.progress,
                        strokeWidth: 12,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation(
                          _getColorForMode(provider.mode, context),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          provider.timeFormatted,
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getSubtitleForMode(provider.mode),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => provider.resetTimer(),
                      icon: const Icon(Icons.refresh_rounded),
                      iconSize: 32,
                      color: Colors.white54,
                    ),
                    const SizedBox(width: 32),
                    GestureDetector(
                      onTap: () {
                        if (provider.isRunning) {
                          provider.pauseTimer();
                        } else {
                          provider.startTimer();
                        }
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _getColorForMode(provider.mode, context),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _getColorForMode(provider.mode, context).withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          provider.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                    IconButton(
                      onPressed: () {
                        // Skip to next mode manually
                        if (provider.mode == PomodoroMode.focus) {
                          provider.setMode(PomodoroMode.shortBreak);
                        } else {
                          provider.setMode(PomodoroMode.focus);
                        }
                      },
                      icon: const Icon(Icons.skip_next_rounded),
                      iconSize: 32,
                      color: Colors.white54,
                    ),
                  ],
                ),
                const Spacer(),
                // Sessions completed
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${provider.sessionsCompleted} Focus Sessions Completed',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getColorForMode(PomodoroMode mode, BuildContext context) {
    switch (mode) {
      case PomodoroMode.focus:
        return const Color(0xFFEF4444); // Red
      case PomodoroMode.shortBreak:
        return const Color(0xFF10B981); // Green
      case PomodoroMode.longBreak:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  String _getSubtitleForMode(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.focus:
        return 'Stay Focused';
      case PomodoroMode.shortBreak:
        return 'Take a breather';
      case PomodoroMode.longBreak:
        return 'Relax and recharge';
    }
  }
}

class _ModeButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
