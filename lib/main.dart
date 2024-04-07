import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'RSSI Monitoring App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late IOWebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    // 웹소켓 서버 주소를 실제 주소로 변경해주세요.
    channel = IOWebSocketChannel.connect('ws://192.168.1.102:8080');
    channel.stream.listen(_onMessage);
  }

  void _onMessage(dynamic message) {
    final jsonResponse = json.decode(message);
    Isolate.spawn(_processData, jsonResponse);
  }

  static void _processData(dynamic data) {
    // 데이터 처리 로직. 여기서는 로그 출력으로 간단하게 처리.
    print('Received data: $data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
