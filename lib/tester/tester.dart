import 'package:flutter/material.dart';

class TaskSearchFilter extends StatefulWidget {
  @override
  _TaskSearchFilterState createState() => _TaskSearchFilterState();
}

class _TaskSearchFilterState extends State<TaskSearchFilter> {


  
  final List<Map<String, String>> tasks = [
    {"name": "Task 1", "status": "Completed", "date": "2025-01-15"},
    {"name": "Task 2", "status": "Pending", "date": "2025-01-16"},
    {"name": "Task 3", "status": "In Progress", "date": "2025-01-17"},
    {"name": "Task 4", "status": "Completed", "date": "2025-01-18"}
  ];

  String searchQuery = '';
  String selectedStatus = 'All';
  String selectedDate = 'All';

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredTasks = tasks.where((task) {
      final matchesQuery =
          task['name']!.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesStatus =
          selectedStatus == 'All' || task['status'] == selectedStatus;
      final matchesDate = selectedDate == 'All' || task['date'] == selectedDate;
      return matchesQuery && matchesStatus && matchesDate;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Task Search and Filter')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search by Task Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<String>(
                value: selectedStatus,
                items: ['All', 'Completed', 'Pending', 'In Progress']
                    .map((status) =>
                        DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                },
              ),
              DropdownButton<String>(
                value: selectedDate,
                items: [
                  'All',
                  '2025-01-15',
                  '2025-01-16',
                  '2025-01-17',
                  '2025-01-18'
                ]
                    .map((date) =>
                        DropdownMenuItem(value: date, child: Text(date)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDate = value!;
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return ListTile(
                  title: Text(task['name']!),
                  subtitle:
                      Text('Status: ${task['status']}, Date: ${task['date']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
