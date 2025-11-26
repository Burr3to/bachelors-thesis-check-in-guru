// lib/features/tasks/views/pages/task_list_page.dart
import 'package:checkin_frontend/features/tasks/data/models/task_create_model.dart';
import 'package:checkin_frontend/features/tasks/data/task_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkin_frontend/features/auth/views/providers/auth_provider.dart';

class TaskListPage extends ConsumerStatefulWidget {
  const TaskListPage({super.key});

  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  final SearchController _searchController = SearchController();

  // 2. Všetky dáta (Databáza)
  final List<String> _allTasks = [
    "Dokončiť Flutter tutoriál",
    "Ísť na obed",
    "Kúpiť mlieko",
    "Zavolať mame",
    "Umyť auto",
  ];

  List<String> _filteredTasks = [];

  @override
  void initState() {
    super.initState();

    _filteredTasks = _allTasks;

    _searchController.addListener(_handleSearch);
  }

  @override
  void _handleSearch() {
    setState(() {
      final query = _searchController.text;
      if (query.isEmpty) {
        _filteredTasks = _allTasks;
      } else {
        _filteredTasks = _allTasks.where((task) {
          return task.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final meno = user?.name ?? 'hosť';

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Vitejte $meno", style: Theme.of(context).textTheme.headlineMedium),

            const SizedBox(width: 20, height: 35),

            SearchBar(
              controller: _searchController,
              hintText: "Search task",
              leading: const Icon(Icons.search),
              trailing: [
                IconButton.outlined(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.clear),
                ),
              ],
            ),

            const SizedBox(width: 20, height: 35),

            Expanded(
              child: _filteredTasks.isEmpty
                  ? const Center(child: Text("niec sa nenaslo"))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 350,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 3 / 1,
                      ),
                      padding: EdgeInsets.all(16),
                      physics: ClampingScrollPhysics(),
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(_allTasks[index]),
                            leading: Icon(Icons.check_circle_outline_rounded),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btnAdd",
            onPressed: () async {
              final newTask = TaskCreateModel(title: "prvy TASk", deadLine: DateTime.timestamp());
              await ref.read(taskApiServiceProvider).createTask(newTask);
            },
            child: Icon(Icons.add),
          ),

          const SizedBox(width: 25),

          FloatingActionButton(
            heroTag: "btnDelete",
            mini: true,
            onPressed: () {
              setState(() {
                _allTasks.removeLast();
                _handleSearch();
              });
            },
            child: Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
