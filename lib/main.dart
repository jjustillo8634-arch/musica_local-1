import 'package:flutter/material.dart';
import 'player_hub.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MiAppAudio());
}

class MiAppAudio extends StatelessWidget {
  const MiAppAudio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reproductor Local',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const PlayerHub(),
    );
  }
}
