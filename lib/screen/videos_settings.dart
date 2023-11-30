import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class VideosSettingsScreen extends StatefulWidget {
  const VideosSettingsScreen({super.key});

  @override
  State<VideosSettingsScreen> createState() => _VideosSettingsScreenState();
}

class _VideosSettingsScreenState extends State<VideosSettingsScreen> {
  List<String> videosPrincipal = [];
  List<String> videosSecundarios = [];

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  // Metodo para remover um video de um diretorio
  Future<void> removeVideo(String directoryName, String videoName) async {
    try {
      String directoryPath = path.join(Directory.current.path, directoryName);
      String videoPath = path.join(directoryPath, videoName);

      if (await File(videoPath).exists()) {
        await File(videoPath).delete();

        await loadVideos();
      }
    } catch (e) {
      print('Erro ao remover vídeo: $e');
    }
  }

  // Metodo para carregar os arquivos de cada dir
  Future<void> loadVideos() async {
    try {
      String videosPrincipalPath =
          path.join(Directory.current.path, 'VideosPrincipal');
      if (await Directory(videosPrincipalPath).exists()) {
        List<FileSystemEntity> principalFiles =
            Directory(videosPrincipalPath).listSync();
        videosPrincipal =
            principalFiles.map((file) => path.basename(file.path)).toList();
        setState(() {});
      }

      String videosSecundariosPath =
          path.join(Directory.current.path, 'VideosSecundario');
      if (await Directory(videosSecundariosPath).exists()) {
        List<FileSystemEntity> secundariosFiles =
            Directory(videosSecundariosPath).listSync();
        videosSecundarios =
            secundariosFiles.map((file) => path.basename(file.path)).toList();
        setState(() {});
      }
    } catch (e) {
      print('Erro ao carregar vídeos: $e');
    }
  }

  //Metodo para adicionar videos aos diretorios
  Future<void> addVideoToDirectory(String directoryName) async {
    try {
      // Selecionar um vídeo usando FilePicker
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.video);

      if (result != null && result.files.isNotEmpty) {
        // Arquivo selecionado
        PlatformFile file = result.files.first;

        String currentDirectory = Directory.current.path;

        // Obter o diretório de destino
        Directory destinationDirectory = Directory(
            '$currentDirectory${Platform.pathSeparator}$directoryName');

        // Copiar o arquivo selecionado para o diretório de destino
        String newFilePath = path.join(destinationDirectory.path, file.name);
        File(file.path!).copy(newFilePath);

        await loadVideos();

        print('Vídeo adicionado ao diretório: $destinationDirectory');
      } else {
        print('Nenhum arquivo selecionado.');
      }
    } catch (e) {
      print('Erro ao adicionar vídeo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text('Ajustes de Videos'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Videos Principal',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: ListView.separated(
                      itemCount: videosPrincipal.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 8.0);
                      },
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            videosPrincipal[index],
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          ),
                          shape: const RoundedRectangleBorder(
                              side: BorderSide.none),
                          tileColor: Colors.grey.shade200,
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              removeVideo(
                                  'VideosPrincipal', videosPrincipal[index]);
                              setState(() {});
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      addVideoToDirectory('VideosPrincipal');
                      setState(() {});
                    },
                    child: Text('Adicionar Vídeo em VideosPrincipal'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Videos Secundarios',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16.0),
                  Expanded(
                    child: ListView.separated(
                      itemCount: videosSecundarios.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8.0),
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            videosSecundarios[index],
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          ),
                          shape: const BeveledRectangleBorder(
                              side: BorderSide.none),
                          tileColor: Colors.grey.shade200,
                          trailing: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              removeVideo(
                                  'VideosSecundario', videosSecundarios[index]);
                              setState(() {});
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      addVideoToDirectory('VideosSecundario');
                      setState(() {});
                    },
                    child: Text('Adicionar Vídeo em VideosSecundarios'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
