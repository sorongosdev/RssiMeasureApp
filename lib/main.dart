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
  late IOWebSocketChannel channel; // 웹소켓 채널
  late TabController _tabController; // 탭 컨트롤러
  List<String> macAddresses = []; // 탭 제목을 표시하기 위한 macaddr만을 저장하는 변수
  Map<String, DeviceData> deviceDataMap = {}; // <macaddr, 서버에서 받아온 정보들>
  int _currentTabIndex = 0; // 현재 선택된 탭의 인덱스를 추적하는 변수

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect('ws://192.168.1.102:8080'); // 웹소켓 채널
    channel.stream.listen(_onMessage);
    _tabController = TabController(length: 0, vsync: this);
    _tabController.addListener(() {
      // 탭 컨트롤러의 리스너 추가
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index; // 현재 선택된 탭의 인덱스 업데이트
        });
      }
    });
  }

  void _onMessage(dynamic message) {
    // 메시지를 JSON 형태로 디코딩
    final jsonResponse = json.decode(message);

    // 메시지 내용 출력
    print("rssi: json msg $message");

    // JSON 응답이 유효하고 'macaddr' 키가 존재하는지 확인
    if (jsonResponse != null && jsonResponse['macaddr'] != null) {
      // jsonResponse에서 필요한 데이터 추출, 값이 없으면 0 또는 빈 문자열로 대체
      String macaddr = jsonResponse['macaddr'];
      int rssival = jsonResponse['rssival'] ?? 0;
      double kalmanval = jsonResponse['kalmanval'].toDouble() ?? 0.0;
      String measuretime = jsonResponse['measuretime'] ?? '';
      int scancnt = jsonResponse['scancnt'] ?? 0;

      // DeviceData 객체 생성
      DeviceData deviceData = DeviceData(
        macaddr: macaddr,
        rssival: rssival,
        kalmanval: kalmanval,
        measuretime: measuretime,
        scancnt: scancnt,
      );

      // macAddresses 리스트에 macaddr이 없는 경우 새로 추가
      if (!macAddresses.contains(macaddr)) {
        setState(() {
          macAddresses.add(macaddr);
          int previousIndex = _tabController.index; // 현재 인덱스를 저장
          _tabController.dispose(); // 기존의 탭 컨트롤러를 해제

          // 새로운 탭 컨트롤러를 생성하고 이전에 선택된 탭 인덱스를 초기 인덱스로 설정
          _tabController = TabController(
              length: macAddresses.length,
              vsync: this,
              initialIndex: previousIndex); // 이전 인덱스를 초기 인덱스로 설정

          // 탭 컨트롤러의 리스너를 추가하여 탭 변경 시 이벤트를 처리
          _tabController.addListener(() {
            if (!_tabController.indexIsChanging) {
              setState(() {
                _currentTabIndex = _tabController.index; // 현재 선택된 탭의 인덱스 업데이트
              });
            }
          });
        });
      }

      // deviceDataMap에 macaddr을 키로 하여 deviceData를 저장
      setState(() {
        deviceDataMap[macaddr] = deviceData;
      });
    }
  }

  /// '20240327085015' -> '2024년 3월 27일 8시 50분 15초'로 포맷을 변경해주는 함수
  String formatMeasureTime(String measuretime) {
    try {
      // 입력된 문자열에서 연, 월, 일을 나타내는 부분과 시, 분, 초를 나타내는 부분 사이에 'T' 문자를 삽입
      // ISO 8601 날짜 및 시간 형식을 따르기 위함
      // "20240408123045" -> "20240408T123045"
      String dateWithT =
          measuretime.substring(0, 8) + 'T' + measuretime.substring(8);

      // DateTime 객체 생성
      DateTime dateTime = DateTime.parse(dateWithT);

      // 문자열 변환
      return DateFormat('yyyy년 M월 d일 H시 m분 s초').format(dateTime);
    } catch (e) {
      // 파싱 과정에서 오류가 발생하면 빈 문자열을 반환하고, 에러를 출력함
      print("Error parsing measuretime: $e");
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
            '${widget.title} (${_currentTabIndex + 1}/${_tabController.length})'), // 현재 선택된 탭 정보 표시
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          // TabBar와 프로그레스 바를 포함할 공간 확보
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs:
                    macAddresses.map((macaddr) => Tab(text: macaddr)).toList(),
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
              crossAxisAlignment: CrossAxisAlignment.start, // 좌측 정렬
              children: [
                Text('Mac Address: ${data?.macaddr ?? ''}',
                    style: TextStyle(fontSize: 16.0)), // 텍스트 사이즈 조정
                SizedBox(height: 8.0),
                Text('RSSI Value: ${data?.rssival ?? 0}',
                    style: TextStyle(fontSize: 16.0)), // 텍스트 사이즈 조정
                SizedBox(height: 8.0),
                Text('Kalman Value: ${data?.kalmanval ?? 0.0}',
                    style: TextStyle(fontSize: 16.0)), // 텍스트 사이즈 조정
                SizedBox(height: 8.0),
                Text(
                    'Measure Time: ${formatMeasureTime(data?.measuretime ?? '')}',
                    style: TextStyle(fontSize: 16.0)), // 텍스트 사이즈 조정
                SizedBox(height: 8.0),
                Text('Scan Count: ${data?.scancnt ?? 0}',
                    style: TextStyle(fontSize: 16.0)), // 텍스트 사이즈 조정
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
