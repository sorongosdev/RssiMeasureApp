import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rssi_measure_app/constants/rssi_consts.dart';
import 'package:web_socket_channel/io.dart';
import 'device_data.dart';
import 'package:intl/intl.dart';

import 'my_appbar.dart';

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
    channel = IOWebSocketChannel.connect(RssiConsts.MY_URL_test); // 웹소켓 채널
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

  /// 서버에서 받아온 메시지를 처리하는 함수
  void _onMessage(dynamic message) {
    // 메시지를 JSON 형태로 디코딩
    final jsonResponse = json.decode(message);

    // 메시지 내용 출력
    print("rssi: json msg $message");

    // JSON 응답이 유효하고 'macaddr' 키가 존재하는지 확인
    if (jsonResponse != null && jsonResponse['macaddr'] != null) {
      // jsonResponse에서 필요한 데이터 추출, 값이 없으면 0 또는 빈 문자열로 대체
      String macaddr = jsonResponse['macaddr'] ?? '';
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
    // Scaffold 위젯을 반환하여 앱의 기본 레이아웃을 구성
    return Scaffold(
      appBar: MyAppBar(
        title: widget.title,
        tabController: _tabController,
        macAddresses: macAddresses,
      ),
      // TabBarView를 사용하여 각 탭에 해당하는 내용을 표시
      body: TabBarView(
        controller: _tabController, // TabBarView 컨트롤러 설정
        children: macAddresses.map((macaddr) {
          // 각 MAC 주소에 해당하는 데이터를 deviceDataMap에서 추출
          final data = deviceDataMap[macaddr];
          // 추출된 데이터를 사용하여 화면 구성
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // 세로 방향으로 중앙 정렬
              crossAxisAlignment: CrossAxisAlignment.start, // 가로 방향으로 좌측 정렬
              children: [
                // MAC 주소, RSSI 값, Kalman 값, 측정 시간, 스캔 횟수를 텍스트로 표시
                // 각각의 값이 없을 경우를 대비하여 기본값 설정
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 22.0, color: Colors.black, fontWeight: FontWeight.bold), // 기본 스타일
                    children: [
                      TextSpan(text: 'Mac Address: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${data?.macaddr ?? ''}'),
                    ],
                  ),
                ),
                SizedBox(height: 8.0),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                    children: [
                      TextSpan(text: 'RSSI Value: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${data?.rssival ?? 0}'),
                    ],
                  ),
                ),
                SizedBox(height: 8.0),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                    children: [
                      TextSpan(text: 'Kalman Value: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${data?.kalmanval ?? 0.0}'),
                    ],
                  ),
                ),
                SizedBox(height: 8.0),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                    children: [
                      TextSpan(text: 'Measure Time: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${formatMeasureTime(data?.measuretime ?? '')}', style: TextStyle(fontSize: 15.0)),
                    ],
                  ),
                ),
                SizedBox(height: 8.0),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                    children: [
                      TextSpan(text: 'Scan Count: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${data?.scancnt ?? 0}'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(), // MAC 주소 리스트를 기반으로 위젯 리스트 생성
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
