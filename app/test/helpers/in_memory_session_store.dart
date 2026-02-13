import 'package:arivest/data/session_store.dart';

class InMemorySessionStore implements SessionStore {
  StoredSession? _stored;

  @override
  Future<void> clear() async {
    _stored = null;
  }

  @override
  Future<StoredSession?> read() async {
    return _stored;
  }

  @override
  Future<void> save(StoredSession session) async {
    _stored = session;
  }
}
