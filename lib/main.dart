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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin { // 변경된 부분
  late IOWebSocketChannel channel;
  late TabController _tabController;
  List<String> macAddresses = [];

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect('ws://192.168.1.102:8080');
    channel.stream.listen(_onMessage);
    _tabController = TabController(length: 0, vsync: this);
  }

  void _onMessage(dynamic message) {
    final jsonResponse = json.decode(message);
    Isolate.spawn(_processData, jsonResponse);

    if (jsonResponse != null && jsonResponse['macaddr'] != null) {
      String macaddr = jsonResponse['macaddr'];
      if (!macAddresses.contains(macaddr)) {
        setState(() {
          macAddresses.add(macaddr);
          // TabController 재생성 시 기존의 TabController를 dispose
          _tabController.dispose(); // 추가된 부분
          _tabController = TabController(length: macAddresses.length, vsync: this);
        });
      }
    }
  }

  static void _processData(dynamic data) {
    // 데이터 처리 로직. 여기서는 로그 출력으로 간단하게 처리.
    print('Received data: $data');
  }

  void _addTab(String macaddr) {
    if (!macAddresses.contains(macaddr)) { // 새로운 macaddr인 경우에만 추가
      setState(() {
        macAddresses.add(macaddr);
        _tabController = TabController(length: macAddresses.length, vsync: this);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: macAddresses.map((macaddr) => Tab(text: macaddr)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: macAddresses.map((macaddr) {
          return Center(
            child: Text('Data for $macaddr'),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    _tabController.dispose();
    super.dispose();
  }
}
