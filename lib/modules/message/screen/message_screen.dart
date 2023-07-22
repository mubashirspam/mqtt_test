import 'package:flutter/material.dart';
import 'package:test/modules/core/managers/MQTTManager.dart';
import 'package:test/modules/core/models/MQTTAppState.dart';
import 'package:test/modules/core/widgets/status_bar.dart';
import 'package:test/modules/helpers/screen_route.dart';
import 'package:test/modules/helpers/status_info_message_utils.dart';
import 'package:provider/provider.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageTextController = TextEditingController();
  final TextEditingController _topicTextController = TextEditingController();
  final _controller = ScrollController();

  late MQTTManager _manager;

  @override
  void dispose() {
    _messageTextController.dispose();
    _topicTextController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _manager = Provider.of<MQTTManager>(context);
    if (_controller.hasClients) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    }

    return Scaffold(
        appBar: _buildAppBar(context) as PreferredSizeWidget?,
        body: _buildColumn(_manager));
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('MQTT'),
      backgroundColor: Colors.greenAccent,
    );
  }

  Widget _buildColumn(MQTTManager manager) {
    return Column(
      children: <Widget>[
        StatusBar(
            statusMessage: prepareStateMessageFrom(
                manager.currentState.getAppConnectionState)),
        _buildEditableColumn(manager.currentState),
      ],
    );
  }

  Widget _buildEditableColumn(MQTTAppState currentAppState) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          _buildTopicSubscribeRow(currentAppState),
          const SizedBox(height: 10),
          _buildPublishMessageRow(currentAppState),
          const SizedBox(height: 10),
          _buildScrollableTextWith(currentAppState.getHistoryText),
          const SizedBox(height: 10),
          _buildConnecteButtonFrom(currentAppState.getAppConnectionState),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(currentAppState.getReceivedJson['data'] == null
                ? "Reading..."
                : "${currentAppState.getReceivedJson['data']['content']}"),
          )
        ],
      ),
    );
  }

  Widget _buildPublishMessageRow(MQTTAppState currentAppState) {
    return _buildSendButtonFrom(currentAppState.getAppConnectionState);
  }

  Widget _buildSendButtonFrom(MQTTAppConnectionState state) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        disabledForegroundColor: Colors.black38.withOpacity(0.38),
        disabledBackgroundColor: Colors.black38.withOpacity(0.12),
        textStyle: const TextStyle(color: Colors.white),
      ),
      onPressed: state == MQTTAppConnectionState.connectedSubscribed
          ? () {
              _publishMessage(_messageTextController.text);
            }
          : null,
      child: const Text('publish_topic'),
    );
  }

  Widget _buildTopicSubscribeRow(MQTTAppState currentAppState) {
    return _buildSubscribeButtonFrom(currentAppState.getAppConnectionState);
  }

  Widget _buildSubscribeButtonFrom(MQTTAppConnectionState state) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.green,
          disabledForegroundColor: Colors.grey,
          disabledBackgroundColor: Colors.black38.withOpacity(0.12),
        ),
        onPressed: (state == MQTTAppConnectionState.connectedSubscribed) ||
                (state == MQTTAppConnectionState.connectedUnSubscribed) ||
                (state == MQTTAppConnectionState.connected)
            ? () {
                _handleSubscribePress(state);
              }
            : null, //,
        child: state == MQTTAppConnectionState.connectedSubscribed
            ? const Text('Unsubscribe')
            : const Text('Subscribe'));
  }

  Widget _buildConnecteButtonFrom(MQTTAppConnectionState state) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent),
            onPressed: state == MQTTAppConnectionState.disconnected
                ? _configureAndConnect
                : null,
            child: const Text('Connect'), //
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: state != MQTTAppConnectionState.disconnected
                ? () {
                    _manager.disconnect();
                  }
                : null,
            child: const Text('Disconnect'), //
          ),
        ),
      ],
    );
  }

  Widget _buildScrollableTextWith(String text) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        padding: const EdgeInsets.only(left: 10.0, right: 5.0),
        width: double.maxFinite,
        height: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black12,
        ),
        child: SingleChildScrollView(
          controller: _controller,
          child: Text(text),
        ),
      ),
    );
  }

  void _handleSubscribePress(MQTTAppConnectionState state) {
    if (state == MQTTAppConnectionState.connectedSubscribed) {
      _manager.unSubscribeFromCurrentTopic();
    } else {
      _manager.subScribeTo("KC_EC94CB6F61DC/app");
    }
  }

  void _publishMessage(String text) {
    Map unloack = {
      "id": "KC_EC94CB6F61DC",
      "patientID": "P8308",
      "doctorID": "D1204",
      "appointmentID": "AP123456",
      "type": "Doctor",
      "command": "unlock",
      "number": "0",
      "date": DateTime.now().millisecondsSinceEpoch
    };

    Map temp = {
      "id": "KC_EC94CB6F61DC",
      "patientID": "P8308",
      "doctorID": "D1204",
      "appointmentID": "AP123456",
      "type": "Doctor",
      "command": "device",
      "number": 2,
      "date": DateTime.now().millisecondsSinceEpoch
    };

    // _manager.publish(unloack.toString());
    _manager.publish(temp.toString());

    _messageTextController.clear();
  }

  void _configureAndConnect() {
    _manager.initializeMQTTClient();
    _manager.connect();
  }
}
