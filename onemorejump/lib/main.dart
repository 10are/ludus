import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/one_more_jump_game.dart';
import 'game/overlays/main_menu.dart';
import 'game/overlays/hud.dart';
import 'game/overlays/game_over.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hide system UI for immersive experience
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const OneMoreJumpApp());
}

class OneMoreJumpApp extends StatelessWidget {
  const OneMoreJumpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One More Jump',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final OneMoreJumpGame game;

  @override
  void initState() {
    super.initState();
    game = OneMoreJumpGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<OneMoreJumpGame>(
        game: game,
        overlayBuilderMap: {
          'MainMenu': (context, game) => MainMenu(game: game),
          'HUD': (context, game) => HUD(game: game),
          'GameOver': (context, game) => GameOver(game: game),
        },
        initialActiveOverlays: const ['MainMenu'],
      ),
    );
  }
}
