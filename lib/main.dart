import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'device_data.dart';

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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  // 변경된 부분
  late IOWebSocketChannel channel;
  late TabController _tabController;
  List<String> macAddresses = [];
  Map<String, DeviceData> deviceDataMap = {};

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect('ws://192.168.1.105:8080');
    channel.stream.listen(_onMessage);
    _tabController = TabController(length: 0, vsync: this);
  }

  void _onMessage(dynamic message) {
    final jsonResponse = json.decode(message);

    if (jsonResponse != null && jsonResponse['macaddr'] != null) {
      String macaddr = jsonResponse['macaddr'];
      int rssival = jsonResponse['rssival'] ?? 'N/A';
      double kalmanval = jsonResponse['kalmanval'].toDouble() ?? 'N/A';
      String measuretime = jsonResponse['measuretime'] ?? 'N/A';
      int scancnt = jsonResponse['scancnt'] ?? 'N/A';

      DeviceData deviceData = DeviceData(
        macaddr: macaddr,
        rssival: rssival,
        kalmanval: kalmanval,
        measuretime: measuretime,
        scancnt: scancnt,
      );

      if (!macAddresses.contains(macaddr)) {
        setState(() {
          macAddresses.add(macaddr);
          _tabController.dispose();
          _tabController =
              TabController(length: macAddresses.length, vsync: this);
        });
      }

      setState(() {
        deviceDataMap[macaddr] = deviceData;
      });
    }
  }

  static void _processData(dynamic data) {
    // 데이터 처리 로직. 여기서는 로그 출력으로 간단하게 처리.
    print('Received data: $data');
  }

  void _addTab(String macaddr) {
    if (!macAddresses.contains(macaddr)) {
      // 새로운 macaddr인 경우에만 추가
      setState(() {
        macAddresses.add(macaddr);
        _tabController =
            TabController(length: macAddresses.length, vsync: this);
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
          isScrollable: true,
          tabs: macAddresses.map((macaddr) => Tab(text: macaddr)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: macAddresses.map((macaddr) {
          final data = deviceDataMap[macaddr];
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('RSSI Value: ${data?.rssival ?? 'N/A'}'),
                Text('Kalman Value: ${data?.kalmanval ?? 'N/A'}'),
                Text('Measure Time: ${data?.measuretime ?? 'N/A'}'),
                Text('Scan Count: ${data?.scancnt ?? 'N/A'}'),
              ],
            ),
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
