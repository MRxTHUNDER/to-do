import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trello_clone/screens/task_detail_screen.dart';

import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/task_column.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _sortBy = 'recent';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });
  }

  List<Task> _searchResults = [];
  List<String> _suggestions = [];

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final titles = Provider.of<TaskProvider>(context, listen: false).taskTitles;
    setState(() {
      _suggestions = titles.where((title) => title.toLowerCase().contains(query.toLowerCase())).toList();
    });

    final results = Provider.of<TaskProvider>(context, listen: false).searchTasks(query);
    setState(() {
      _searchResults = results;
    });
  }

  void _showTaskDetails(String title) {
    final task = Provider.of<TaskProvider>(context, listen: false).tasks.firstWhere((task) => task.title == title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null) Text('Description: ${task.description}'),
            Text('Priority: ${task.priority.toString().split('.').last}'),
            Text('Status: ${task.status.toString().split('.').last}'),
            Text('Created At: ${task.createdAt}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'To-Do',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          TextButton(
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => _showAddTaskDialog(context),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Task',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final title = _suggestions[index];
                        return ListTile(
                          title: Text(title),
                          onTap: () {
                            _showTaskDetails(title);
                            _searchController.clear();
                            setState(() => _suggestions = []);
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'recent', child: Text('Recent')),
                    DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                  ],
                  onChanged: (value) {
                    setState(() => _sortBy = value!);
                  },
                ),
              ],
            ),
          ),
          // Task Columns
          const Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TaskColumn(
                    title: 'TODO',
                    status: TaskStatus.todo,
                  ),
                ),
                Expanded(
                  child: TaskColumn(
                    title: 'IN PROGRESS',
                    status: TaskStatus.inProgress,
                  ),
                ),
                Expanded(
                  child: TaskColumn(
                    title: 'DONE',
                    status: TaskStatus.done,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTaskDialog(),
    );
  }

  void _openTaskDetails(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(task: task),
      ),
    );
  }
}
