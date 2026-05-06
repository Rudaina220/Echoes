import 'package:permission_handler/permission_handler.dart';

class AppPermissions {

  static Future<void> requestBasicPermissions() async {

    await [
      Permission.camera,
      Permission.microphone,
      Permission.locationWhenInUse,
    ].request();

  }

}