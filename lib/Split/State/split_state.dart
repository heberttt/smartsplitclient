import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartsplitclient/Authentication/Model/Account.dart';
import 'package:smartsplitclient/Expense/Model/split_bill.dart';
import 'package:smartsplitclient/Expense/Service/split_service.dart';

class SplitState extends ChangeNotifier {
  final SplitService _splitService = SplitService();

  Map<String, List<SplitBill>> _mySplitBills = {};
  Map<String, List<SplitBill>> _myDebts = {};
  bool _isLoadingBills = true;
  bool _isLoadingDebts = true;

  bool get isLoadingBills => _isLoadingBills;
  bool get isLoadingDebts => _isLoadingDebts;
  Map<String, List<SplitBill>> get mySplitBills => _mySplitBills;
  Map<String, List<SplitBill>> get myDebts => _myDebts;

  void clear() {
    _mySplitBills = {};
    _myDebts = {};
    notifyListeners();
  }

  Future<void> loadAllData(Account currentUser) async {
    await Future.wait([
      loadExpenses(currentUser),
      loadDebts(currentUser),
    ]);
  }

  Future<void> loadExpenses(Account currentUser) async {
    _isLoadingBills = true;
    notifyListeners();
    try {
      final bills = await _splitService.getMySplitBills(currentUser);
      _mySplitBills = _groupByMonth(bills);
    } finally {
      _isLoadingBills = false;
      notifyListeners();
    }
  }

  Future<void> loadDebts(Account currentUser) async {
    _isLoadingDebts = true;
    notifyListeners();
    try {
      final debts = await _splitService.getMyDebts(currentUser);
      _myDebts = _groupByMonth(debts);
    } finally {
      _isLoadingDebts = false;
      notifyListeners();
    }
  }

  Map<String, List<SplitBill>> _groupByMonth(List<SplitBill> bills) {
    bills.sort((a, b) => b.receipt.now.compareTo(a.receipt.now));
    final Map<String, List<SplitBill>> grouped = {};
    for (final bill in bills) {
      final key = DateFormat('MMMM yyyy').format(bill.receipt.now);
      grouped.putIfAbsent(key, () => []).add(bill);
    }
    return grouped;
  }
}