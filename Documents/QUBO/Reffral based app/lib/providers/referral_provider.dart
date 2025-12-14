import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:math';
import '../models/referral_model.dart';

class ReferralProvider with ChangeNotifier {
  List<ReferralTask> _tasks = [];
  List<ReferredUser> _referredUsers = [];
  int _currentLevel = 0;

  List<ReferralTask> get tasks => _tasks;
  List<ReferredUser> get referredUsers => _referredUsers;
  int get currentLevel => _currentLevel;
  ReferralTask? get currentTask => _currentLevel < _tasks.length ? _tasks[_currentLevel] : null;

  // Initialize referral tasks
  Future<void> initializeTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString('referralTasks');
      final usersJson = prefs.getString('referredUsers');
      final level = prefs.getInt('currentLevel') ?? 0;

      if (tasksJson != null) {
        final List<dynamic> tasksList = jsonDecode(tasksJson);
        _tasks = tasksList.map((t) => ReferralTask.fromJson(t)).toList();
      } else {
        _initializeDefaultTasks();
      }

      if (usersJson != null) {
        final List<dynamic> usersList = jsonDecode(usersJson);
        _referredUsers = usersList.map((u) => ReferredUser.fromJson(u)).toList();
      }

      _currentLevel = level;
      notifyListeners();
    } catch (e) {
      _initializeDefaultTasks();
    }
  }

  // Initialize default tasks based on requirements
  void _initializeDefaultTasks() {
    _tasks = [
      ReferralTask(
        level: 1,
        requiredReferrals: 1,
        isUnlocked: true,
        isCompleted: false,
        currentReferrals: 0,
        gamesCompleted: false,
        bonusAmount: 50,
      ),
      ReferralTask(
        level: 2,
        requiredReferrals: 6,
        isUnlocked: false,
        isCompleted: false,
        currentReferrals: 0,
        gamesCompleted: false,
        bonusAmount: 100,
      ),
      ReferralTask(
        level: 3,
        requiredReferrals: 12,
        isUnlocked: false,
        isCompleted: false,
        currentReferrals: 0,
        gamesCompleted: false,
        bonusAmount: 200,
      ),
      ReferralTask(
        level: 4,
        requiredReferrals: 18,
        isUnlocked: false,
        isCompleted: false,
        currentReferrals: 0,
        gamesCompleted: false,
        bonusAmount: 300,
      ),
      ReferralTask(
        level: 5,
        requiredReferrals: -1, // Unlimited
        isUnlocked: false,
        isCompleted: false,
        currentReferrals: 0,
        gamesCompleted: false,
        bonusAmount: 500,
      ),
    ];
    _saveTasks();
  }

  // Save tasks to storage
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    final usersJson = jsonEncode(_referredUsers.map((u) => u.toJson()).toList());
    await prefs.setString('referralTasks', tasksJson);
    await prefs.setString('referredUsers', usersJson);
    await prefs.setInt('currentLevel', _currentLevel);
  }

  // Add a referred user
  Future<void> addReferredUser(String name, double depositAmount) async {
    final user = ReferredUser(
      id: const Uuid().v4(),
      name: name,
      joinedDate: DateTime.now(),
      hasDeposited: true,
      depositAmount: depositAmount,
      level: _currentLevel + 1,
    );

    _referredUsers.add(user);

    // Update current task
    if (_currentLevel < _tasks.length) {
      final currentTask = _tasks[_currentLevel];
      _tasks[_currentLevel] = currentTask.copyWith(
        currentReferrals: currentTask.currentReferrals + 1,
      );
    }

    await _saveTasks();
    notifyListeners();
  }

  // Mark games as completed for current level
  Future<void> completeGames() async {
    if (_currentLevel < _tasks.length) {
      final currentTask = _tasks[_currentLevel];
      _tasks[_currentLevel] = currentTask.copyWith(
        gamesCompleted: true,
        isCompleted: true,
      );

      // Unlock next level
      if (_currentLevel + 1 < _tasks.length) {
        final nextTask = _tasks[_currentLevel + 1];
        _tasks[_currentLevel + 1] = ReferralTask(
          level: nextTask.level,
          requiredReferrals: nextTask.requiredReferrals,
          isUnlocked: true,
          isCompleted: nextTask.isCompleted,
          currentReferrals: nextTask.currentReferrals,
          gamesCompleted: nextTask.gamesCompleted,
          bonusAmount: nextTask.bonusAmount,
        );
        _currentLevel++;
      }

      await _saveTasks();
      notifyListeners();
    }
  }

  // Get referred users by level
  List<ReferredUser> getReferredUsersByLevel(int level) {
    return _referredUsers.where((u) => u.level == level).toList();
  }

  // Get total referrals count
  int get totalReferrals => _referredUsers.length;

  // Get total earnings from referrals
  double get totalReferralEarnings {
    return _tasks
        .where((t) => t.isCompleted)
        .fold(0.0, (sum, task) => sum + task.bonusAmount);
  }

  // Check if can play games
  bool get canPlayGames {
    if (_currentLevel >= _tasks.length) return false;
    final task = _tasks[_currentLevel];
    return task.canPlayGames;
  }

  // Get referral link
  String getReferralLink(String referralCode) {
    return 'https://referral-app.com/join?ref=$referralCode';
  }

  // Simulate adding random referred users (for demo)
  Future<void> addDemoReferrals(int count) async {
    final random = Random();
    final names = ['John', 'Emma', 'Michael', 'Sophia', 'William', 'Olivia', 'James', 'Ava'];
    
    for (int i = 0; i < count; i++) {
      final name = names[random.nextInt(names.length)];
      await addReferredUser(
        '$name ${random.nextInt(100)}',
        [100.0, 500.0, 1000.0][random.nextInt(3)],
      );
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
