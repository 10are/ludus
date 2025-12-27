import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'game/gladiator_game.dart';
import 'game/models/game_state.dart';
import 'game/constants.dart';
import 'game/screens/menu_screen.dart';
import 'game/screens/home_screen.dart';
import 'game/screens/game_over_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const GladiatorApp());
}

class GladiatorApp extends StatelessWidget {
  const GladiatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GladiatorGame(),
      child: MaterialApp(
        title: 'Gladyatör Ludus',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: GameConstants.primaryDark,
        ),
        home: const GameRouter(),
      ),
    );
  }
}

class GameRouter extends StatelessWidget {
  const GameRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GladiatorGame>(
      builder: (context, game, child) {
        switch (game.state.phase) {
          case GamePhase.menu:
            return const MenuScreen();
          case GamePhase.playing:
            return const HomeScreen();
          case GamePhase.gameOver:
            return const GameOverScreen();
        }
      },
    );
  }
}
