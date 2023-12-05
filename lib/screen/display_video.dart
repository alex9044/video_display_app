import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path/path.dart' as path;

class DisplayVideoScreen extends StatefulWidget {
  final String receivedSerialPort;

  const DisplayVideoScreen({super.key, required this.receivedSerialPort});

  @override
  State<DisplayVideoScreen> createState() => _DisplayVideoScreenState();
}

class _DisplayVideoScreenState extends State<DisplayVideoScreen> {
  List<Media> secondaryList = [];
  List<Media> primaryList = [];

  // Porta Serial
  late SerialPort port;
  final streamVideoController = StreamController<VideoController>();

  // Create a [Player] to control playback.
  late final playerAd = Player();
  late final playerVideo = Player();

  // // Create a [VideoController] to handle video output from [Player].
  late final controllerAd = VideoController(playerAd);
  late final controllerVideo = VideoController(playerVideo);

  void loadVideosFromDirectory() {
    // Path dos Diretorios que contem os videos
    String videosPrincipalPath =
        path.join(Directory.current.path, 'VideosPrincipal');
    String videosSecundariosPath =
        path.join(Directory.current.path, 'VideosSecundario');

    try {
      List<FileSystemEntity> principalFiles =
          Directory(videosPrincipalPath).listSync();
      primaryList = principalFiles
          .map((file) => Media(
              'file://$videosPrincipalPath${Platform.pathSeparator}${path.basename(file.path)}'))
          .toList();

      List<FileSystemEntity> secundariosFiles =
          Directory(videosSecundariosPath).listSync();
      secondaryList = secundariosFiles
          .map((file) => Media(
              'file://$videosSecundariosPath${Platform.pathSeparator}${path.basename(file.path)}'))
          .toList();
    } catch (e) {
      print('Erro ao carregar vídeos: $e');
    }
  }

  // Stream<int> generateStream() {
  //   late StreamController<int> controller;
  //   late Timer timer;
  //   int count = 0;

  //   void generateData() {
  //     if (count < 34) {
  //       controller.add(0);
  //       count++;
  //     } else {
  //       controller.add(1);
  //       count = 0; // Reinicia a contagem após 60 segundos
  //     }
  //   }

  //   void startTimer() {
  //     timer = Timer.periodic(Duration(seconds: 1), (_) {
  //       generateData();
  //     });
  //   }

  //   controller = StreamController<int>(
  //     onListen: startTimer,
  //     onPause: () {
  //       timer.cancel();
  //     },
  //     onResume: () {
  //       startTimer();
  //     },
  //     onCancel: () {
  //       timer.cancel();
  //       controller.close();
  //     },
  //   );

  //   return controller.stream;
  // }

  void videoController() {
    // Carregamos os videos nas listas
    loadVideosFromDirectory();

    // Abrimos o leitor da porta serial
    port = SerialPort(widget.receivedSerialPort);
    if (!port.openRead()) {
      print(SerialPort.lastError);
      exit(-1);
    }
    final reader = SerialPortReader(port);

    // Ouvinte da porta serial
    Stream<int> upcommingData = reader.stream
        .map((data) => int.tryParse(String.fromCharCodes(data)) ?? 0);

    // Sensor de teste
    // Stream<int> upcommingData = generateStream();

    // Carregamos a playlist segundaria no playerAd
    controllerAd.player.open(Playlist(secondaryList));
    // Para playerAd voltar a repetir a playlist
    playerAd.setPlaylistMode(PlaylistMode.loop);

    upcommingData.listen((data) {
      print(data);
      switch (data) {
        case 1:
          // Se o video principal não estiver sendo executado
          if (!playerVideo.state.playing) {
            controllerAd.player.pause();
            controllerVideo.player.play();
            // Carregamos o video principal no Player
            controllerVideo.player.open(Playlist(primaryList));
            // Envia o controlador do playerVideo para que seja o pricipal
            streamVideoController.add(controllerVideo);
          }
        default:
          // Se o video principal ja foi reproduzido completo
          if (playerVideo.state.completed) {
            controllerAd.player.play();
            controllerVideo.player.pause();
            // Envia o controlador do playerAd para que seja o pricipal
            streamVideoController.add(controllerAd);
          }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    videoController();
  }

  @override
  void dispose() {
    port.dispose();
    playerAd.dispose();
    playerVideo.dispose();
    streamVideoController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<VideoController>(
          stream: streamVideoController.stream,
          builder: (context, snapshot) {
            return Video(
              controller: snapshot.data ?? controllerAd,
              fit: BoxFit.cover,
              onEnterFullscreen: () {
                return defaultEnterNativeFullscreen();
              },
            );
          }),
    );
  }
}
