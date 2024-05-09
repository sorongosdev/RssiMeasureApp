///my_appbar.dart
import 'package:flutter/material.dart';

// MyAppBar를 StatefulWidget으로 변경
class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  late final String title;
  final TabController tabController;
  final List<String> macAddresses;
  final ValueNotifier<int> selectedDeviceId;

  MyAppBar(
      {required this.tabController,
      required this.macAddresses,
      required this.selectedDeviceId
      });

  @override
  _MyAppBarState createState() => _MyAppBarState();

  // AppBar의 preferredSize와 동일한 값을 반환
  @override
  Size get preferredSize => const Size.fromHeight(100.0); // 여기로 이동
}

// _MyAppBarState 클래스에서 상태 관리
class _MyAppBarState extends State<MyAppBar> {
  String title = '기본 제목'; // 초기 제목 설정

  // @override
  // void initState() {
  //   super.initState();
  //   print("setTab: initState");
  //   // initState가 완료된 후 실행될 콜백을 스케줄링
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     widget.onDeviceSelected(0); // 첫 번째 디바이스를 자동으로 선택
  //     setState(() {
  //       print("setTab: setState");
  //
  //       title = '디바이스 0'; // 제목 업데이트
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: ValueListenableBuilder<int>(
        valueListenable: widget.selectedDeviceId,
        builder: (context, selectedDeviceId, child) {
          return Text(
              '디바이스 $selectedDeviceId (${widget.tabController.index + 1}/${widget.tabController.length})');
        },
      ),
      // title: Text(
      //     '$title (${widget.tabController.index + 1}/${widget.tabController.length})'),
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
            widget.selectedDeviceId.value = deviceId;
            // TODO : 탭뷰 업데이트,
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
