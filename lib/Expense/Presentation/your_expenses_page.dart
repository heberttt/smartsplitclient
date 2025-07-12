import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smartsplitclient/Authentication/Model/Account.dart';
import 'package:smartsplitclient/Authentication/State/auth_state.dart';
import 'package:smartsplitclient/Expense/Model/split_bill.dart';
import 'package:smartsplitclient/Expense/Service/split_service.dart';
import 'package:smartsplitclient/Friend/State/friend_state.dart';
import 'package:smartsplitclient/Split/Model/registered_friend.dart';

abstract class ExpenseListItem {}

class MonthHeaderItem extends ExpenseListItem {
  final String month;
  MonthHeaderItem(this.month);
}

class ExpenseCardItem extends ExpenseListItem {
  final Expense expense;
  ExpenseCardItem(this.expense);
}

class Expense {
  final String title;
  final String subtitle;
  final DateTime date;
  final String? profilePictureLink;

  Expense({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.profilePictureLink,
  });
}

class YourExpensesPage extends StatefulWidget {
  const YourExpensesPage({super.key});

  @override
  State<YourExpensesPage> createState() => _YourExpensesPageState();
}

class _YourExpensesPageState extends State<YourExpensesPage> {
  final SplitService _splitService = SplitService();
  Map<String, List<Expense>> _groupedExpenses = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  List<ExpenseListItem> _flattenedExpenseItems() {
    final List<ExpenseListItem> items = [];

    _groupedExpenses.forEach((month, expenses) {
      items.add(MonthHeaderItem(month));
      items.addAll(expenses.map((e) => ExpenseCardItem(e)));
    });

    return items;
  }

  Future<void> _loadExpenses() async {
    try {
      final friendState = context.read<FriendState>();
      final friends = friendState.myFriends;

      Account? currentUser = context.read<AuthState>().currentUser;

      List<SplitBill> bills = await _splitService.getMySplitBills();

      List<Expense> allExpenses = bills.map((bill) {
        final paid = bill.receipt.receiptItems.fold<int>(
              0,
              (sum, item) => sum + item.totalPrice,
            ) /
            100;
        final owed = bill.members
                .where((m) => !m.hasPaid)
                .fold<int>(0, (sum, m) => sum + m.totalDebt) /
            100;

        String? profilePicture;

        if (currentUser != null || currentUser!.id == bill.creatorId){
          profilePicture = currentUser.profilePictureLink;
        }else{
        final creator = friends.firstWhere(
          (f) => f.id == bill.creatorId,
          orElse: () => RegisteredFriend('', '', '', ''),
        );
        if (creator.id.isNotEmpty) {
          profilePicture = creator.profilePictureLink;
        }
        }
        return Expense(
          title: bill.receipt.title,
          subtitle: 'You paid for RM$paid\nYou are still owed RM$owed',
          date: bill.receipt.now,
          profilePictureLink: profilePicture,
        );
      }).toList();

      final Map<String, List<Expense>> grouped = {};
      for (var expense in allExpenses) {
        final key = DateFormat('MMMM yyyy').format(expense.date);
        grouped.putIfAbsent(key, () => []).add(expense);
      }

      setState(() {
        _groupedExpenses = grouped;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load expenses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _getTransparentButton(IconData icon, VoidCallback callback) {
    return GestureDetector(
      onTap: callback,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          size: 35,
          color: Theme.of(context).secondaryHeaderColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _flattenedExpenseItems();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          toolbarHeight: 70,
          title: const Text(
            'Your expenses',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          leading: _getTransparentButton(Icons.arrow_back, () {
            Navigator.pop(context);
          }),
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black54,
                indicatorColor: Colors.black,
                indicatorWeight: 2.5,
                tabs: [Tab(text: 'Expenses'), Tab(text: 'Summary')],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _groupedExpenses.isEmpty
                          ? const Center(child: Text('No expenses found'))
                          : RefreshIndicator(
                              onRefresh: _loadExpenses,
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: items.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == items.length) {
                                    return const SizedBox(height: 100);
                                  }

                                  final item = items[index];

                                  if (item is MonthHeaderItem) {
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        16,
                                        16,
                                        8,
                                      ),
                                      child: Text(
                                        item.month,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  } else if (item is ExpenseCardItem) {
                                    return expenseCard(
                                      title: item.expense.title,
                                      subtitle: item.expense.subtitle,
                                      profilePictureLink:
                                          item.expense.profilePictureLink,
                                    );
                                  }

                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                  const Center(child: Text('Summary content goes here')),
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
    required String? profilePictureLink,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          foregroundImage:
              profilePictureLink != null ? NetworkImage(profilePictureLink) : null,
          child: profilePictureLink == null ? const Icon(Icons.person) : null,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}