import 'dart:convert';

enum MQTTAppConnectionState {
  connected,
  disconnected,
  connecting,
  connectedSubscribed,
  connectedUnSubscribed
}

class MQTTAppState {
  MQTTAppConnectionState _appConnectionState =
      MQTTAppConnectionState.disconnected;
  String _receivedText = '';
  String _historyText = '';
  Map<String, dynamic> _jsonData = {};

  void setReceivedText(String text) {
    _receivedText = text;
    _historyText = '$_historyText\n$_receivedText';
     _jsonData = jsonDecode(_receivedText);
  }

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
  }

 

  void clearText() {
    _historyText = "";
    _receivedText = "";
  }

  Map<String, dynamic> get getReceivedJson => _jsonData;

  String get getReceivedText => _receivedText;
  String get getHistoryText => _historyText;
  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;
}
