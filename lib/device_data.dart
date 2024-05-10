/// device_data.dart

class DeviceData {
  final int device;
  final String macaddr;
  final int rssival;
  final int kalmanval;
  final String measuretime;
  final int scancnt;

  DeviceData({
    required this.device,
    required this.macaddr,
    required this.rssival,
    required this.kalmanval,
    required this.measuretime,
    required this.scancnt,
  });
}
