import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smartsplitclient/Authentication/Model/Account.dart';
import 'package:smartsplitclient/Authentication/State/auth_state.dart';
import 'package:smartsplitclient/Expense/Model/friend_payment.dart';
import 'package:smartsplitclient/Expense/Model/split_bill.dart';
import 'package:smartsplitclient/Expense/Service/split_service.dart';
import 'package:smartsplitclient/Friend/State/friend_state.dart';
import 'package:smartsplitclient/Split/Model/registered_friend.dart';
import 'package:smartsplitclient/Split/Presentation/non_group_choose_friend_page.dart';
import 'package:smartsplitclient/Split/Presentation/non_group_view_split_page.dart';
import 'package:smartsplitclient/Split/State/split_state.dart';

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
  final DateTime date;
  final String? profilePictureLink;
  final SplitBill splitBill;
  final List<InlineSpan> subtitleSpans;

  Expense({
    required this.title,
    required this.subtitleSpans,
    required this.date,
    required this.profilePictureLink,
    required this.splitBill,
  });
}

class YourExpensesPage extends StatefulWidget {
  const YourExpensesPage({super.key});
  @override
  State<YourExpensesPage> createState() => _YourExpensesPageState();
}

class _YourExpensesPageState extends State<YourExpensesPage> {
  final SplitService _splitService = SplitService();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthState>().currentUser;
    if (user != null &&
        context.read<SplitState>().myDebts.isEmpty &&
        context.read<SplitState>().mySplitBills.isEmpty) {
      context.read<SplitState>().loadAllData(user);
    }
  }

  Map<String, List<Expense>> _groupExpensesOrDebts(
    List<SplitBill> bills,
    Account currentUser, {
    required bool isDebt,
  }) {
    final List<Expense> all =
        bills.map((bill) {
          final paid =
              (bill.members.fold<int>(0, (sum, m) => sum + m.totalDebt) +
                  bill.receipt.roundingAdjustment) /
              100;

          final myMember = bill.members.firstWhere(
            (m) =>
                m.friend is RegisteredFriend &&
                (m.friend as RegisteredFriend).id == currentUser.id,
            orElse:
                () => FriendPayment(
                  friend: RegisteredFriend('', '', '', ''),
                  totalDebt: 0,
                  hasPaid: false,
                ),
          );

          final double owed =
              isDebt
                  ? myMember.totalDebt / 100
                  : bill.members
                          .where((m) {
                            final friend = m.friend;
                            return friend is RegisteredFriend
                                ? friend.id != currentUser.id
                                : true;
                          })
                          .fold<int>(
                            0,
                            (sum, m) => sum + (m.hasPaid ? 0 : m.totalDebt),
                          ) /
                      100;
          final hasPaid = myMember.hasPaid;

          String? profilePicture;
          String? name;

          if (currentUser.id == bill.creatorId) {
            profilePicture = currentUser.profilePictureLink;
            name = currentUser.username;
          } else {
            final creator = context.read<FriendState>().myFriends.firstWhere(
              (f) => f.id == bill.creatorId,
              orElse: () => RegisteredFriend('', '', '', ''),
            );
            profilePicture = creator.profilePictureLink;
            name = creator.username;
          }

          final subtitleSpans =
              isDebt
                  ? [
                    if (!hasPaid) ...[
                      const TextSpan(text: 'You owe '),
                      TextSpan(
                        text: 'RM$owed',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ] else ...[
                      const TextSpan(text: 'You paid '),
                      TextSpan(
                        text: 'RM$owed',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ]
                  : [
                    const TextSpan(text: 'You paid for '),
                    TextSpan(
                      text: 'RM$paid\n',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    owed != 0
                        ? const TextSpan(text: 'You are still owed ')
                        : const TextSpan(
                          text: 'All debts are ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                    owed != 0
                        ? TextSpan(
                          text: 'RM$owed',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        )
                        : TextSpan(
                          text: 'paid',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                  ];

          return Expense(
            title: bill.receipt.title,
            subtitleSpans: subtitleSpans,
            date: bill.receipt.now,
            profilePictureLink: profilePicture,
            splitBill: bill,
          );
        }).toList();

    all.sort((a, b) => b.date.compareTo(a.date));

    final Map<String, List<Expense>> grouped = {};
    for (final expense in all) {
      final key = DateFormat('MMMM yyyy').format(expense.date);
      grouped.putIfAbsent(key, () => []).add(expense);
    }

    return grouped;
  }

  List<ExpenseListItem> _flattenedItems(Map<String, List<Expense>> grouped) {
    final List<ExpenseListItem> items = [];

    grouped.forEach((month, expenses) {
      items.add(MonthHeaderItem(month));
      items.addAll(expenses.map((e) => ExpenseCardItem(e)));
    });

    return items;
  }

  Widget _buildExpenseList({
    required bool isLoading,
    required Map<String, List<Expense>> grouped,
    required Future<void> Function() onRefresh,
  }) {
    final items = _flattenedItems(grouped);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child:
          grouped.isEmpty
              ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('No data found')),
                  SizedBox(height: 500),
                ],
              )
              : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: items.length + 1,
                itemBuilder: (context, index) {
                  if (index == items.length) return const SizedBox(height: 100);
                  final item = items[index];

                  if (item is MonthHeaderItem) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        item.month,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  } else if (item is ExpenseCardItem) {
                    return _expenseCard(item.expense);
                  }

                  return const SizedBox.shrink();
                },
              ),
    );
  }

  Widget _expenseCard(Expense expense) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NonGroupViewSplitPage(expense.splitBill),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          foregroundImage:
              expense.profilePictureLink != null
                  ? NetworkImage(expense.profilePictureLink!)
                  : null,
          child:
              expense.profilePictureLink == null
                  ? const Icon(Icons.person)
                  : null,
        ),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black),
            children: expense.subtitleSpans,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final splitState = context.watch<SplitState>();
    final user = context.read<AuthState>().currentUser!;
    final colorScheme = theme.colorScheme;
    final groupedExpenses = _groupExpensesOrDebts(
      splitState.mySplitBills.values.expand((e) => e).toList(),
      user,
      isDebt: false,
    );
    final groupedDebts = _groupExpensesOrDebts(
      splitState.myDebts.values.expand((e) => e).toList(),
      user,
      isDebt: true,
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            'Your expenses',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                tabs: [Tab(text: 'Expenses'), Tab(text: 'Debts')],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildExpenseList(
                    isLoading: splitState.isLoadingBills,
                    grouped: groupedExpenses,
                    onRefresh: () => splitState.loadExpenses(user),
                  ),
                  _buildExpenseList(
                    isLoading: splitState.isLoadingDebts,
                    grouped: groupedDebts,
                    onRefresh: () => splitState.loadDebts(user),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => NonGroupChooseFriendPage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add expense'),
        ),
      ),
    );
  }
}
