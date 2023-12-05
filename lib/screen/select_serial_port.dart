import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:video_display/screen/display_video.dart';
import 'package:video_display/screen/videos_settings.dart';

class SelectSerialScreen extends StatefulWidget {
  const SelectSerialScreen({super.key});

  @override
  State<SelectSerialScreen> createState() => _SelectSerialScreenState();
}

class _SelectSerialScreenState extends State<SelectSerialScreen> {
  List<String> availablePorts = [];

  @override
  void initState() {
    availablePorts = SerialPort.availablePorts;
    // Verifica a plataforma atual
    if (Platform.isWindows || Platform.isLinux) {
      // Obtém o caminho do diretório onde o aplicativo está sendo executado
      String currentDirectory = Directory.current.path;

      // Cria os diretórios "VideosPrincipal" e "VideosSecundarios"
      createVideosDirectories(currentDirectory);
    } else {
      print('Plataforma não suportada para esta implementação.');
    }
    super.initState();
  }

  void createVideosDirectories(String currentDirectory) {
    try {
      // Caminhos para os diretórios desejados
      String videosPrincipalPath =
          '$currentDirectory${Platform.pathSeparator}VideosPrincipal';
      String videosSecundariosPath =
          '$currentDirectory${Platform.pathSeparator}VideosSecundario';

      // Verifica se os diretórios já existem
      bool videosPrincipalExists = Directory(videosPrincipalPath).existsSync();
      bool videosSecundariosExists =
          Directory(videosSecundariosPath).existsSync();

      // Se os diretórios não existirem, cria-os
      if (!videosPrincipalExists) {
        Directory(videosPrincipalPath).createSync(recursive: true);
        print('Diretório "VideosPrincipal" criado com sucesso.');
      } else {
        print('Diretório "VideosPrincipal" já existe.');
      }

      if (!videosSecundariosExists) {
        Directory(videosSecundariosPath).createSync(recursive: true);
        print('Diretório "VideosSecundarios" criado com sucesso.');
      } else {
        print('Diretório "VideosSecundarios" já existe.');
      }
    } catch (e) {
      print('Erro ao criar ou verificar diretórios: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(),
            backgroundColor: Colors.grey.shade100,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VideosSettingsScreen(),
                ));
          },
          icon: const Icon(
            Icons.video_settings_rounded,
            color: Colors.black,
          ),
          label: const Text(
            'Ajustes',
            style: TextStyle(color: Colors.black),
          )),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * .8,
          child: Column(
            children: [
              Container(
                height: 100.0,
                alignment: Alignment.center,
                child: const Text("Seleccione el puerto del sensor",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    final serialPort = SerialPort(availablePorts[index]);
                    final manufacturer = serialPort.manufacturer;
                    serialPort.close();
                    return ListTile(
                      tileColor: Colors.grey[200],
                      shape: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      title: Center(
                        child: Text(availablePorts[index],
                            style: const TextStyle(fontSize: 18)),
                      ),
                      subtitle: Center(
                        child: Text(manufacturer ?? "Desconocido",
                            style: const TextStyle(fontSize: 12)),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayVideoScreen(
                              receivedSerialPort: availablePorts[index]),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8.0),
                  itemCount: availablePorts.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
