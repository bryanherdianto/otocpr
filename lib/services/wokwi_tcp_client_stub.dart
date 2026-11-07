import 'dart:async';

/// Web stub for Wokwi TCP RFC2217 client (raw TCP sockets require dart:io).
class WokwiTcpClient {
  final StreamController<String> _lineController =
      StreamController<String>.broadcast();
  final StreamController<bool> _stateController =
      StreamController<bool>.broadcast();

  Stream<String> get lines => _lineController.stream;
  Stream<bool> get connectionState => _stateController.stream;
  bool get isConnected => false;
  String get endpoint => 'unsupported-on-web';

  Future<bool> connect({
    String host = '127.0.0.1',
    int port = 4000,
    Duration timeout = const Duration(milliseconds: 900),
  }) async {
    return false;
  }

  Future<void> disconnect() async {}

  void dispose() {
    _lineController.close();
    _stateController.close();
  }
}
