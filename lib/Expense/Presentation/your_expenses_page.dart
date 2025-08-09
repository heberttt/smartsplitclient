import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smartsplitclient/Authentication/Model/Account.dart';
import 'package:smartsplitclient/Authentication/State/auth_state.dart';
import 'package:smartsplitclient/Expense/Model/friend_payment.dart';
import 'package:smartsplitclient/Expense/Model/split_bill.dart';
import 'package:smartsplitclient/Friend/State/friend_state.dart';
import 'package:smartsplitclient/Split/Model/guest_friend.dart';
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

          if (currentUser.id == bill.creatorId) {
            profilePicture = currentUser.profilePictureLink;
          } else {
            final creator = context.read<FriendState>().myFriends.firstWhere(
              (f) => f.id == bill.creatorId,
              orElse: () => RegisteredFriend('', '', '', ''),
            );
            profilePicture = creator.profilePictureLink;
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

  Widget _expenseCard(Expense expense, {bool fromExpenses = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NonGroupViewSplitPage(expense.splitBill, fromExpenses: fromExpenses,),
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

  Widget _buildExpensesAnalyticsChart(List<SplitBill> bills, Account user) {
    final currentYear = DateTime.now().year;
    final Map<int, double> paidPerMonth = {};
    final Map<int, double> owedPerMonth = {};

    for (int i = 1; i <= 12; i++) {
      paidPerMonth[i] = 0;
      owedPerMonth[i] = 0;
    }

    for (var bill in bills) {
      final month = bill.receipt.now.month;
      final year = bill.receipt.now.year;
      if (year != currentYear || bill.creatorId != user.id) continue;

      final totalPaid =
          (bill.members.fold<int>(0, (sum, m) => sum + m.totalDebt) +
              bill.receipt.roundingAdjustment) /
          100;

      final othersOwe =
          bill.members
              .where((m) {
                final f = m.friend;
                return (f is RegisteredFriend && f.id != user.id) ||
                    f is GuestFriend;
              })
              .fold<int>(0, (sum, m) => sum + (m.hasPaid ? 0 : m.totalDebt)) /
          100;

      paidPerMonth[month] = paidPerMonth[month]! + totalPaid;
      owedPerMonth[month] = owedPerMonth[month]! + othersOwe;
    }

    return _buildBarChart(
      paidPerMonth,
      owedPerMonth,
      Colors.green,
      Colors.red,
      'Total Paid',
      'Still Owed',
    );
  }

  Widget _buildDebtsAnalyticsChart(List<SplitBill> debts, Account user) {
    final currentYear = DateTime.now().year;
    final Map<int, double> paidPerMonth = {};
    final Map<int, double> owedPerMonth = {};

    for (int i = 1; i <= 12; i++) {
      paidPerMonth[i] = 0;
      owedPerMonth[i] = 0;
    }

    for (var debt in debts) {
      final month = debt.receipt.now.month;
      final year = debt.receipt.now.year;
      if (year != currentYear) continue;

      final myMember = debt.members.firstWhere(
        (m) =>
            m.friend is RegisteredFriend &&
            (m.friend as RegisteredFriend).id == user.id,
        orElse:
            () => FriendPayment(
              friend: RegisteredFriend('', '', '', ''),
              totalDebt: 0,
              hasPaid: false,
            ),
      );

      owedPerMonth[month] = owedPerMonth[month]! + (myMember.totalDebt / 100);
      if (myMember.hasPaid) {
        paidPerMonth[month] = paidPerMonth[month]! + (myMember.totalDebt / 100);
      }
    }

    return _buildBarChart(
      owedPerMonth,
      paidPerMonth,
      Colors.red,
      Colors.green,
      'You Owed',
      'You Paid',
    );
  }

  Widget _buildBarChart(
    Map<int, double> bar1,
    Map<int, double> bar2,
    Color color1,
    Color color2,
    String label1,
    String label2,
  ) {
    final rawMax = [
      ...bar1.values,
      ...bar2.values,
    ].fold<double>(0, (prev, x) => x > prev ? x : prev);
    final maxY = ((rawMax / 10).ceil() * 10).toDouble();

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const months = [
                        'J',
                        'F',
                        'M',
                        'A',
                        'M',
                        'J',
                        'J',
                        'A',
                        'S',
                        'O',
                        'N',
                        'D',
                      ];
                      return Text(
                        value >= 1 && value <= 12
                            ? months[value.toInt() - 1]
                            : '',
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(12, (index) {
                final month = index + 1;
                return BarChartGroupData(
                  x: month,
                  barRods: [
                    BarChartRodData(
                      toY: bar1[month]!,
                      color: color1,
                      width: 8,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    BarChartRodData(
                      toY: bar2[month]!,
                      color: color2,
                      width: 8,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                  barsSpace: 6,
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(color1, label1),
            const SizedBox(width: 20),
            _buildLegendItem(color2, label2),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }

  Widget _buildScrollableTabContent(
    Map<String, List<Expense>> grouped,
    bool isLoading,
    Future<void> Function() onRefresh,
    SplitState splitState,
    Account user, {
    required bool isExpensesTab,
    required Widget graphWidget,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child:
          grouped.isEmpty
              ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Center(
                    child: Text(
                      'No data',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              )
              : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text("Spending in ${DateTime.now().year}"),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: graphWidget,
                  ),
                  const SizedBox(height: 20),
                  ..._flattenedItems(grouped).map((item) {
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
                      return _expenseCard(
                        item.expense,
                        fromExpenses: isExpensesTab,
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: 100),
                ],
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
      splitState.mySplitBills.values
          .expand((e) => e)
          .where((bill) => bill.groupId.isEmpty)
          .toList(),
      user,
      isDebt: false,
    );

    final groupedDebts = _groupExpensesOrDebts(
      splitState.myDebts.values
          .expand((e) => e)
          .where((bill) => bill.groupId.isEmpty)
          .toList(),
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
                  _buildScrollableTabContent(
                    groupedExpenses,
                    splitState.isLoadingBills,
                    () => splitState.loadExpenses(user),
                    splitState,
                    user,
                    graphWidget: _buildExpensesAnalyticsChart(
                      splitState.mySplitBills.values
                          .expand((e) => e)
                          .where((bill) => bill.groupId.isEmpty)
                          .toList(),
                      user,
                    ),
                    isExpensesTab: true
                  ),
                  _buildScrollableTabContent(
                    groupedDebts,
                    splitState.isLoadingDebts,
                    () => splitState.loadDebts(user),
                    splitState,
                    user,
                    graphWidget: _buildDebtsAnalyticsChart(
                      splitState.myDebts.values
                          .expand((e) => e)
                          .where((bill) => bill.groupId.isEmpty)
                          .toList(),
                      user,
                    ),
                    isExpensesTab: false
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
