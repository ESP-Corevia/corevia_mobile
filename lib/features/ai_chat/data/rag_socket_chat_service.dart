import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

typedef RagDeltaHandler = void Function(String delta);
typedef RagDoneHandler = void Function();
typedef RagErrorHandler = void Function(String message);
typedef RagConnectionHandler = void Function(bool connected);

class RagSocketChatService {
  final String url;
  io.Socket? _socket;
  bool _isStreaming = false;
  dynamic Function(dynamic)? _messageHandler;
  dynamic Function(dynamic)? _connectErrorHandler;

  RagSocketChatService({required this.url});

  bool get isConnected => _socket?.connected ?? false;
  bool get isStreaming => _isStreaming;

  void connect({RagConnectionHandler? onConnectionChanged}) {
    if (_socket != null) {
      _socket!.connect();
      return;
    }

    final socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableReconnection()
          .enableAutoConnect()
          .build(),
    );

    socket.on('connect', (_) {
      onConnectionChanged?.call(true);
      return null;
    });
    socket.on('disconnect', (_) {
      onConnectionChanged?.call(false);
      return null;
    });
    socket.on('connect_error', (_) {
      onConnectionChanged?.call(false);
      return null;
    });

    _socket = socket;
  }

  Future<void> sendQuery({
    required String agentId,
    required String query,
    required String userId,
    required RagDeltaHandler onDelta,
    required RagDoneHandler onDone,
    required RagErrorHandler onError,
    Duration connectTimeout = const Duration(seconds: 10),
  }) async {
    if (_isStreaming) return;
    _isStreaming = true;

    try {
      final socket = _ensureSocket();
      await _ensureConnected(socket, timeout: connectTimeout);

      _detachQueryHandlers();

      void cleanup() {
        _detachQueryHandlers();
        _isStreaming = false;
      }

      _connectErrorHandler = (dynamic _) {
        cleanup();
        onError('Connexion impossible au service IA');
        return null;
      };

      _messageHandler = (dynamic data) {
        try {
          if (data is! Map) return;
          final type = data['type']?.toString();

          switch (type) {
            case 'chunk':
              final content = data['content']?.toString() ?? '';
              if (content.isNotEmpty) onDelta(content);
              break;
            case 'done':
              cleanup();
              onDone();
              break;
            case 'error':
              cleanup();
              onError(data['message']?.toString() ?? 'Erreur du service IA');
              break;
          }
        } catch (_) {}
        return null;
      };

      socket.on('connect_error', _connectErrorHandler!);
      socket.on('message', _messageHandler!);

      socket.emit('query', {
        'type': 'query',
        'agent': agentId,
        'query': query,
        'userId': userId,
      });
    } catch (_) {
      _detachQueryHandlers();
      _isStreaming = false;
      onError('Erreur réseau : connexion impossible');
    }
  }

  void disconnect() {
    _isStreaming = false;
    _detachQueryHandlers();
    _socket?.disconnect();
  }

  void dispose() {
    _isStreaming = false;
    _detachQueryHandlers();

    final socket = _socket;
    _socket = null;

    try {
      socket?.disconnect();
    } catch (_) {}

    final dynamic dynSocket = socket;
    try {
      dynSocket?.dispose();
    } catch (_) {}
    try {
      dynSocket?.close();
    } catch (_) {}
    try {
      dynSocket?.destroy();
    } catch (_) {}
  }

  io.Socket _ensureSocket() {
    connect();
    return _socket!;
  }

  void _detachQueryHandlers() {
    final socket = _socket;
    if (socket == null) return;

    final messageHandler = _messageHandler;
    if (messageHandler != null) {
      try {
        socket.off('message', messageHandler);
      } catch (_) {}
    }
    final connectErrorHandler = _connectErrorHandler;
    if (connectErrorHandler != null) {
      try {
        socket.off('connect_error', connectErrorHandler);
      } catch (_) {}
    }

    _messageHandler = null;
    _connectErrorHandler = null;
  }

  Future<void> _ensureConnected(io.Socket socket, {required Duration timeout}) async {
    if (socket.connected) return;

    final completer = Completer<void>();
    dynamic onConnect(dynamic _) {
      socket.off('connect', onConnect);
      if (!completer.isCompleted) completer.complete();
      return null;
    }

    socket.on('connect', onConnect);
    socket.connect();

    await completer.future.timeout(timeout, onTimeout: () {
      socket.off('connect', onConnect);
      throw TimeoutException('socket connect timeout');
    });
  }
}
