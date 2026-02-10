import '../models/client.dart';
import '../models/expense.dart';

abstract class BackendService {
  Future<void> uploadExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> createClient(Client client);
}

class FirebaseBackendService implements BackendService {
  @override
  Future<void> createClient(Client client) async {
    // Replace with Firebase Firestore write.
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> uploadExpense(Expense expense) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}

class SupabaseBackendService implements BackendService {
  @override
  Future<void> createClient(Client client) async {
    // Replace with Supabase insert.
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> uploadExpense(Expense expense) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
