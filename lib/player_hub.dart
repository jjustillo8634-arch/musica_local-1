import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'equalizer_page.dart';

class PlayerHub extends StatefulWidget {
  const PlayerHub({super.key});

  @override
  State<PlayerHub> createState() => _PlayerHubState();
}

class _PlayerHubState extends State<PlayerHub> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentFileName;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioStreams();
  }

  void _initAudioStreams() {
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });

    _audioPlayer.durationStream.listen((newDuration) {
      if (mounted && newDuration != null) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.positionStream.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });
  }

  Future<void> _pickAndPlayAudio() async {
    await Permission.storage.request();
    await Permission.audio.request();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg'],
    );

    if (result != null && result.files.single.path != null) {
      String path = result.files.single.path!;
      String name = result.files.single.name;

      try {
        await _audioPlayer.setFilePath(path);
        _audioPlayer.play();
        setState(() {
          _currentFileName = name;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al reproducir el archivo: $e')),
          );
        }
      }
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reproductor de Audio Local'),
        actions: [
          IconButton(
            icon: const Icon(Icons.equalizer),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EqualizerPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 30),
            Text(
              _currentFileName ?? 'Ningún archivo seleccionado',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Slider(
              min: 0,
              max: _duration.inMilliseconds.toDouble() > 0 
                  ? _duration.inMilliseconds.toDouble() 
                  : 1.0,
              value: _position.inMilliseconds.toDouble().clamp(
                0.0, 
                _duration.inMilliseconds.toDouble() > 0 ? _duration.inMilliseconds.toDouble() : 1.0
              ),
              onChanged: (value) async {
                final position = Duration(milliseconds: value.toInt());
                await _audioPlayer.seek(position);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position)),
                Text(_formatDuration(_duration)),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 48,
                  icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                  onPressed: () {
                    if (_isPlaying) {
                      _audioPlayer.pause();
                    } else {
                      if (_currentFileName != null) {
                        _audioPlayer.play();
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _pickAndPlayAudio,
              icon: const Icon(Icons.folder_open),
              label: const Text('Buscar Archivo de Audio'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
