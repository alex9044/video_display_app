import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:video_display/screen/select_serial_port.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const VideoDisplay());
}

class VideoDisplay extends StatelessWidget {
  const VideoDisplay({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {'select_serial': (_) => const SelectSerialScreen()},
      initialRoute: 'select_serial',
    );
  }
}
