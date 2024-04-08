import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'device_data.dart';
import 'package:intl/intl.dart';

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
  double _progress = 0.0; // 프로그레스 바의 진행 상태를 저장할 변수 추가

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect('ws://192.168.1.105:8080');
    channel.stream.listen(_onMessage);
    _tabController = TabController(length: 0, vsync: this);
    _tabController.addListener(_updateProgress); // TabController에 리스너 추가
  }

  void _updateProgress() {
    // 현재 탭의 인덱스를 기반으로 프로그레스 바의 값을 업데이트하는 함수
    print("rssi: _tabController.length ${_tabController.length}");
    if (_tabController.length > 1) {
      setState(() {
        _progress = _tabController.index / (_tabController.length - 1);
      });
      print("rssi: progress $_progress");
    }
  }

  void _onMessage(dynamic message) {
    final jsonResponse = json.decode(message);

    print("rssi: json msg $message");

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0), // TabBar와 프로그레스 바를 포함할 공간 확보
          child: Column(
            children: [
              LinearProgressIndicator(
                value: _progress, // 프로그레스 바의 값
                minHeight: 4.0, // 프로그레스 바의 높이 설정
                backgroundColor: Colors.grey, // 프로그레스 바의 배경색 설정
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // 프로그레스 바의 색상 설정
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: macAddresses.map((macaddr) => Tab(text: macaddr)).toList(),
              ),
            ],
          ),
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
                Text('Mac Address: ${data?.macaddr ?? ''}'), // string
                Text('RSSI Value: ${data?.rssival ?? 0}'), // int
                Text('Kalman Value: ${data?.kalmanval ?? 0.0}'), // double
                Text('Measure Time: ${data?.measuretime ?? ''}'), // string
                Text('Scan Count: ${data?.scancnt ?? 0}'), // int
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
    _tabController.removeListener(_updateProgress); // 리스너 제거
    _tabController.dispose();
    super.dispose();
  }
}
