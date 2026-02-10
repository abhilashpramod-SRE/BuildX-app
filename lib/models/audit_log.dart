class AuditLog {
  AuditLog({
    required this.timestamp,
    required this.actor,
    required this.action,
    required this.entityId,
    this.metadata,
  });

  final DateTime timestamp;
  final String actor;
  final String action;
  final String entityId;
  final String? metadata;
}
