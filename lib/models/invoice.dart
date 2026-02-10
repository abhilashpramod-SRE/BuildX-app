import 'client.dart';
import 'expense.dart';

class Invoice {
  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.client,
    required this.projectName,
    required this.items,
    required this.date,
    this.notes,
  });

  final String id;
  final String invoiceNumber;
  final Client client;
  final String projectName;
  final List<Expense> items;
  final DateTime date;
  final String? notes;

  double get totalAmount =>
      items.fold<double>(0, (sum, expense) => sum + expense.amount);
}
