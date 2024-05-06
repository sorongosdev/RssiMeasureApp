///my_appbar.dart
import 'package:flutter/material.dart';

// MyAppBar를 StatefulWidget으로 변경
class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  late final String title;
  final TabController tabController;
  final List<String> macAddresses;
  final Function(int deviceId) onDeviceSelected; // 선택된 디바이스에 따라 액션을 정의하기 위한 콜백

  MyAppBar(
      {required this.tabController,
      required this.macAddresses,
      required this.onDeviceSelected});

  @override
  _MyAppBarState createState() => _MyAppBarState();

  // AppBar의 preferredSize와 동일한 값을 반환
  @override
  Size get preferredSize => const Size.fromHeight(100.0); // 여기로 이동
}

// _MyAppBarState 클래스에서 상태 관리
class _MyAppBarState extends State<MyAppBar> {
  String title = '기본 제목'; // 초기 제목 설정

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(
          '$title (${widget.tabController.index + 1}/${widget.tabController.length})'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: Column(
          children: [
            TabBar(
              controller: widget.tabController,
              isScrollable: true,
              tabs: widget.macAddresses
                  .map((macaddr) => Tab(text: macaddr))
                  .toList(),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        PopupMenuButton<int>(
          icon: Icon(Icons.arrow_drop_down),
          onSelected: (int deviceId) {
            widget.onDeviceSelected(deviceId); // 선택된 디바이스 ID에 따라 외부에서 정의된 액션 실행
            setState(() {
              title = '디바이스 $deviceId'; // 제목 업데이트
            });
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
            const PopupMenuItem<int>(
              value: 0,
              child: Text('디바이스 0'),
            ),
            const PopupMenuItem<int>(
              value: 1,
              child: Text('디바이스 1'),
            ),
          ],
        ),
      ],
    );
  }
}
