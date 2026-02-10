import 'user.dart';

enum ExpenseStatus { pending, approved, rejected }

class Expense {
  Expense({
    required this.id,
    required this.item,
    required this.amount,
    required this.date,
    required this.project,
    required this.submitter,
    this.billImagePath,
    this.notes,
    this.status = ExpenseStatus.pending,
    this.rejectionReason,
  });

  final String id;
  final String item;
  final double amount;
  final DateTime date;
  final String project;
  final AppUser submitter;
  final String? billImagePath;
  final String? notes;
  ExpenseStatus status;
  String? rejectionReason;
}
