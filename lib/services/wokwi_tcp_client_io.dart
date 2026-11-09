import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Connects to Wokwi's RFC2217 / TCP serial server (`rfc2217ServerPort = 4000`
/// in `Firmware/wokwi.toml`) and emits clean UTF-8 lines from `Serial.println`.
///
/// Automatically tries `127.0.0.1:4000` (Windows/macOS/Linux desktop) and falls
/// back to `10.0.2.2:4000` (Android emulator host loopback).
class WokwiTcpClient {
  Socket? _socket;
  StreamSubscription<List<int>>? _sub;
  final StreamController<String> _lineController =
      StreamController<String>.broadcast();
  final StreamController<bool> _stateController =
      StreamController<bool>.broadcast();

  String _buffer = '';
  String _endpoint = '127.0.0.1:4000';

  Stream<String> get lines => _lineController.stream;
  Stream<bool> get connectionState => _stateController.stream;
  bool get isConnected => _socket != null;
  String get endpoint => _endpoint;

  Future<bool> connect({
    String host = '127.0.0.1',
    int port = 4000,
    Duration timeout = const Duration(milliseconds: 900),
  }) async {
    await disconnect();

    final candidates = <String>[
      host,
      if (host == '127.0.0.1' || host == 'localhost') '10.0.2.2',
    ];

    for (final candidate in candidates) {
      try {
        final sock = await Socket.connect(candidate, port, timeout: timeout);
        sock.setOption(SocketOption.tcpNoDelay, true);
        _socket = sock;
        _endpoint = '$candidate:$port';
        _buffer = '';
        _stateController.add(true);

        _sub = sock.listen(
          _onRawBytes,
          onError: (_) => disconnect(),
          onDone: () => disconnect(),
          cancelOnError: true,
        );
        return true;
      } catch (_) {
        // Try next candidate host
      }
    }
    return false;
  }

  void _onRawBytes(List<int> raw) {
    // Filter out Telnet / RFC2217 IAC (0xFF) control sequences and non-text bytes
    final cleanBytes = <int>[];
    int i = 0;
    while (i < raw.length) {
      final b = raw[i];
      if (b == 0xFF) {
        if (i + 1 < raw.length) {
          final cmd = raw[i + 1];
          if (cmd >= 251 && cmd <= 254) {
            i += 3; // IAC WILL/WONT/DO/DONT <opt>
            continue;
          } else if (cmd == 250) {
            // IAC SB ... IAC SE
            i += 2;
            while (i < raw.length && raw[i] != 240) {
              i++;
            }
            i++;
            continue;
          }
        }
        i += 2;
        continue;
      }
      if (b == 0x0A || b == 0x0D || (b >= 0x20 && b <= 0x7E)) {
        cleanBytes.add(b);
      }
      i++;
    }

    if (cleanBytes.isEmpty) return;
    _buffer += utf8.decode(cleanBytes, allowMalformed: true);

    while (true) {
      final nl = _buffer.indexOf('\n');
      if (nl < 0) break;
      final line = _buffer.substring(0, nl).trim();
      _buffer = _buffer.substring(nl + 1);
      if (line.isNotEmpty) {
        _lineController.add(line);
      }
    }
  }

  Future<void> disconnect() async {
    final wasConnected = _socket != null;
    await _sub?.cancel();
    _sub = null;
    try {
      await _socket?.close();
      _socket?.destroy();
    } catch (_) {}
    _socket = null;
    _buffer = '';
    if (wasConnected && !_stateController.isClosed) {
      _stateController.add(false);
    }
  }

  void dispose() {
    disconnect();
    _lineController.close();
    _stateController.close();
  }
}
