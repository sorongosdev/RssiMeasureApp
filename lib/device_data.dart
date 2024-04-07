/// device_data.dart

class DeviceData {
  final String macaddr;
  final int rssival;
  final double kalmanval;
  final String measuretime;
  final int scancnt;

  DeviceData({
    required this.macaddr,
    required this.rssival,
    required this.kalmanval,
    required this.measuretime,
    required this.scancnt,
  });
}
