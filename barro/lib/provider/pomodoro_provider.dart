import 'dart:async';
import 'package:flutter/material.dart';

enum PomodoroMode { focus, shortBreak, longBreak }

class PomodoroProvider extends ChangeNotifier {
  static const int focusDuration = 25 * 60;
  static const int shortBreakDuration = 5 * 60;
  static const int longBreakDuration = 15 * 60;

  PomodoroMode _mode = PomodoroMode.focus;
  int _secondsRemaining = focusDuration;
  bool _isRunning = false;
  Timer? _timer;
  int _sessionsCompleted = 0;

  PomodoroMode get mode => _mode;
  int get secondsRemaining => _secondsRemaining;
  bool get isRunning => _isRunning;
  int get sessionsCompleted => _sessionsCompleted;
  
  double get progress {
    int total = _getTotalDuration();
    return 1 - (_secondsRemaining / total);
  }

  String get timeFormatted {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int _getTotalDuration() {
    switch (_mode) {
      case PomodoroMode.focus:
        return focusDuration;
      case PomodoroMode.shortBreak:
        return shortBreakDuration;
      case PomodoroMode.longBreak:
        return longBreakDuration;
    }
  }

  void startTimer() {
    if (_isRunning) return;
    _isRunning = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
        _isRunning = false;
        _onSessionComplete();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _secondsRemaining = _getTotalDuration();
    notifyListeners();
  }

  void setMode(PomodoroMode mode) {
    _timer?.cancel();
    _isRunning = false;
    _mode = mode;
    _secondsRemaining = _getTotalDuration();
    notifyListeners();
  }

  void _onSessionComplete() {
    if (_mode == PomodoroMode.focus) {
      _sessionsCompleted++;
      if (_sessionsCompleted % 4 == 0) {
        setMode(PomodoroMode.longBreak);
      } else {
        setMode(PomodoroMode.shortBreak);
      }
    } else {
      setMode(PomodoroMode.focus);
    }
    // Auto-start next session? For now, let user start it.
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
