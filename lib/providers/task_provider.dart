import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  List<String> _taskTitles = [];

  List<Task> get tasks => _tasks;
  List<String> get taskTitles => _taskTitles;

  List<Task> getTasksByStatus(TaskStatus status) {
    final filteredTasks = _tasks.where((task) => task.status == status).toList();
    filteredTasks.sort((a, b) {
      final priorityComparison = b.priority.index.compareTo(a.priority.index);
      if (priorityComparison == 0) {
        return a.createdAt.compareTo(b.createdAt);
      }
      return priorityComparison;
    });
    return filteredTasks;
  }

  List<Task> searchTasks(String query) {
    if (query.isEmpty) return [];
    return _tasks.where((task) => task.title.toLowerCase().contains(query.toLowerCase())).toList();
  }

  Future<void> addTask(Task task) async {
    if (task.priority == null) {
      task = task.copyWith(priority: TaskPriority.medium); // Default to Medium
    }
    _tasks.add(task);
    _updateTaskTitles();
    await _saveTasks();
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      _updateTaskTitles();
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    _updateTaskTitles();
    await _saveTasks();
    notifyListeners();
  }

  Future<void> moveTask(String taskId, TaskStatus newStatus) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex] = _tasks[taskIndex].copyWith(status: newStatus);
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((task) => task.toJson()).toList();
    await prefs.setString('tasks', json.encode(tasksJson));
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      final tasksList = json.decode(tasksString) as List;
      _tasks = tasksList.map((task) => Task.fromJson(task)).toList();
      notifyListeners();
    }
  }

  void _updateTaskTitles() {
    _taskTitles = _tasks.map((task) => task.title).toList();
  }
}
