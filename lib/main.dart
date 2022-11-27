import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_test/provider/mqttProvider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const System());
}

class System extends StatelessWidget {
  const System({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MqttProvider>(create: (BuildContext _) => MqttProvider())
      ],
      child: MaterialApp(
        onGenerateRoute: (RouteSettings route) {
            return MaterialPageRoute(
              settings: const RouteSettings(name: TestPage.path),
              builder: (BuildContext context) {
                MqttProvider mqttProvider = Provider.of<MqttProvider>(context);
                return TestPage(mqttProvider: mqttProvider);
              }
            );
        }
      ),
    );
  }
}

class TestPage extends StatefulWidget {
  static const String path = "/test";
  final MqttProvider mqttProvider;
  const TestPage({Key? key, required this.mqttProvider}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Test Mqtt'),
            centerTitle: true,
          ),
          body: Center(
            child: widget.mqttProvider.isLoad ? const Text("Loading!") : ElevatedButton(
              child: const Text('Connect'),
              onPressed: () async => await move(context),
            ),
          ),
        )
    );
  }

  Future<void> move(BuildContext context) async {
    final bool connectCheck = await widget.mqttProvider.join(nickName: "Test");
    if(!connectCheck) {
      await showDialog<void>(
          context: context,
          builder: (BuildContext context) =>
              AlertDialog(
                title: const Text("연결 오류"),
                actions: [
                  TextButton(
                    child: const Text("닫기"),
                    onPressed: () => Navigator.of(context).pop(null),
                  )
                ],
              )
      );
      return;
    } else {
      await showDialog<void>(
          context: context,
          builder: (BuildContext context) =>
              AlertDialog(
                title: const Text("연결 성공!"),
                actions: [
                  TextButton(
                    child: const Text("닫기"),
                    onPressed: () => Navigator.of(context).pop(null),
                  )
                ],
              )
      );
    }
  }
}
