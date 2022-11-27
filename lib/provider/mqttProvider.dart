import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'mqttRepo.dart';
import 'package:mqtt_test/model/connectionModel.dart';
import 'package:flutter/material.dart';

class MqttProvider extends ChangeNotifier {
  MqttRepo mqttService = MqttRepo();
  bool _isLoad = false;
  bool get isLoad => _isLoad;

  void _update(bool loadingStatus){
    _isLoad = loadingStatus;
    notifyListeners();
  }

  final List<String> _chatUserList = [];
  List<String> get chatUserList => [..._chatUserList];

  final List<ConnectionModel> _chat = [];
  List<ConnectionModel> get chat => [..._chat];

  void sendChat({required String nickName, required String chat}) => mqttService.client.publishMessage("CHAT", MqttQos.atMostOnce, MqttClientPayloadBuilder().addString(json.encode({"userNickName": nickName, "chat":chat})).payload!);

  final String TOPIC_CHAT_JOIN = "CHAT_LIST_JOIN";
  final String TOPIC_CHAT = "CHAT";

  Future<bool> join({required String nickName}) async{
    _update(true);
    final MqttConnectionState? _state = await mqttService.connect(nickName: nickName);
    _update(false);
    if(_state != MqttConnectionState.connected) return false;
    mqttService.client.subscribe(TOPIC_CHAT_JOIN, MqttQos.atMostOnce);
    mqttService.client.subscribe(TOPIC_CHAT, MqttQos.atMostOnce);

    mqttService.client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> event) {
      final String _payLoad = mqttService.parse(event);
      Map<String, dynamic> _json = json.decode(_payLoad);
      if(_json["join"] != null){
        String joinUserNickName = _json["join"];
        if(_chatUserList.indexOf(joinUserNickName) < 0){
          _chatUserList.add(joinUserNickName);
          print(_chatUserList);
        }
      }
      else{
        final ConnectionModel _chatModel = ConnectionModel.json(_json);
        _chat.insert(0, _chatModel);
      }
      notifyListeners();
    });
    mqttService.client.publishMessage(TOPIC_CHAT_JOIN, MqttQos.atMostOnce, MqttClientPayloadBuilder().addString(json.encode({"join" : nickName})).payload!);
    return true;
  }
}