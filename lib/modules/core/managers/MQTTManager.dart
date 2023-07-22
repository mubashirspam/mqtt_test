import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/MQTTAppState.dart';

class MQTTManager extends ChangeNotifier {
  // Private instance of client
  final MQTTAppState _currentState = MQTTAppState();
  MqttServerClient? _client;


  String _topic = "";

  String username = 'kzeus';
  String passwd = 'Kelloo8*';

  void initializeMQTTClient() {
  

    _client = MqttServerClient('3.86.51.160', '');
    _client!.port = 1883;
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = onDisconnected;
    _client!.secure = false;
    _client!.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    _client!.logging(on: true);

    /// Add the successful connection callback
    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;
    _client!.onUnsubscribed = onUnsubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier("_identifier")
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    log('EXAMPLE::Mosquitto client connecting....');
    _client!.connectionMessage = connMess;
  }


  MQTTAppState get currentState => _currentState;
  // Connect to the host
  void connect() async {
    try {
      await _client!.connect(username, passwd);
    } on NoConnectionException catch (e) {
      log('KevellCare :_client exception - $e');
      disconnect();
    } on SocketException catch (e) {
      log('KevellCare :socket exception - $e');
      disconnect();
    }
  }

  void disconnect() {
    log('Disconnected');
    _client!.disconnect();
  }

  void publish(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(
        "KC_EC94CB6F61DC/app", MqttQos.atLeastOnce, builder.payload!);
  }

  /// The subscribed callback

  void onSubscribed(String topic) {
    log('EXAMPLE::Subscription confirmed for topic $topic');
    _currentState
        .setAppConnectionState(MQTTAppConnectionState.connectedSubscribed);
    updateState();
  }

  void onUnsubscribed(String? topic) {
    log('EXAMPLE::onUnsubscribed confirmed for topic $topic');
    _currentState.clearText();
    _currentState
        .setAppConnectionState(MQTTAppConnectionState.connectedUnSubscribed);
    updateState();
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    log('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (_client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      log('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
    _currentState.clearText();
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
    updateState();
  }

  /// The successful connect callback
  void onConnected() {
    _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    updateState();
    log('EXAMPLE::Mosquitto client connected....');
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      _currentState.setReceivedText(pt);

      updateState();
      log('EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      log('');
    });
    log('EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }

  void subScribeTo(String topic) {
    // Save topic for future use
    _topic = topic;
    _client!.subscribe(topic, MqttQos.atLeastOnce);
  }

  /// Unsubscribe from a topic
  void unSubscribe(String topic) {
    _client!.unsubscribe(topic);
  }

  /// Unsubscribe from a topic
  void unSubscribeFromCurrentTopic() {
    _client!.unsubscribe(_topic);
  }

  void updateState() {
    //controller.add(_currentState);
    notifyListeners();
  }
}
