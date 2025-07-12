import 'package:smartsplitclient/Split/Model/friend.dart';

class FriendPayment {
  final Friend friend;
  final int totalDebt;
  final bool hasPaid;
  final String? paymentImageLink;
  final DateTime? paidAt;

  FriendPayment({
    required this.friend,
    required this.totalDebt,
    required this.hasPaid,
    this.paymentImageLink,
    this.paidAt,
  });
}
