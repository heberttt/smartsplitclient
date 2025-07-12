import 'package:flutter/material.dart';

class YourExpensesPage extends StatefulWidget {
  const YourExpensesPage({super.key});

  @override
  State<YourExpensesPage> createState() => _YourExpensesPageState();
}

class _YourExpensesPageState extends State<YourExpensesPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // number of tabs
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.grey[300],
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {},
          ),
          title: const Text(
            'Your expenses',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.more_vert, color: Colors.white),
            )
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            // Analytics Placeholder
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black45),
                color: Colors.grey[400],
              ),
              child: const Center(
                child: Text(
                  'Analytics Placeholder',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tabs below analytics
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black54,
                indicatorColor: Colors.black,
                indicatorWeight: 2.5,
                tabs: [
                  Tab(text: 'Expenses'),
                  Tab(text: 'Summary'),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  // Expenses tab content
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                        child: Row(
                          children: [
                            Text(
                              'March 2025',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      expenseCard(
                        title: 'McDonald\'s',
                        subtitle: 'You paid for RM50\nYou are still owed RM23',
                        trailing: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 10),
                            SizedBox(width: 4),
                            Icon(Icons.circle, size: 10),
                            SizedBox(width: 4),
                            Icon(Icons.circle, size: 10),
                          ],
                        ),
                      ),
                      expenseCard(
                        title: 'KFC',
                        subtitle: 'You paid for RM 50',
                        trailing: const Text(
                          'RM 48',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  // Summary tab content
                  const Center(
                    child: Text('Summary content goes here'),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Add expense'),
        ),
      ),
    );
  }

  Widget expenseCard({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.grey,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: trailing,
      ),
    );
  }
}
