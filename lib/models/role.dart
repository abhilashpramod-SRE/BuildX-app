enum UserRole {
  contractor('Contractor'),
  engineer('Engineer/Procurement'),
  supervisor('Supervisor/Owner');

  const UserRole(this.label);
  final String label;
}
