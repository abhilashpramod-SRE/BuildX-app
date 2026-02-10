typedef SyncTask = Future<void> Function();

class OfflineSyncService {
  final List<SyncTask> _queue = <SyncTask>[];

  bool isOnline = true;

  int get pendingActions => _queue.length;

  Future<void> enqueueOrRun(SyncTask task) async {
    if (isOnline) {
      await task();
      return;
    }
    _queue.add(task);
  }

  Future<void> sync() async {
    if (!isOnline) return;

    final queued = List<SyncTask>.from(_queue);
    _queue.clear();
    for (final task in queued) {
      await task();
    }
  }
}
