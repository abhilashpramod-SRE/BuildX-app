import 'client.dart';
import 'company_profile.dart';
import 'expense.dart';

class Invoice {
  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.client,
    required this.items,
    required this.date,
    required this.companyProfile,
    this.notes,
  });

  final String id;
  final String invoiceNumber;
  final Client client;
  final List<Expense> items;
  final DateTime date;
  final CompanyProfile companyProfile;
  final String? notes;

  double get totalAmount =>
      items.fold<double>(0, (sum, expense) => sum + expense.amount);
}
