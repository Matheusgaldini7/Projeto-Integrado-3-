import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'TelaHome.dart';
import 'screens/LoginScreen.dart';
import 'services/ConfiguracoesService.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Color(0xFF1A1040),
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = ConfiguracoesService();

    return AnimatedBuilder(
      animation: config,
      builder: (context, _) => MaterialApp(
        title: 'Journey Degree',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF1A1040),
        ),
        home: const LoginScreen(),
        routes: {'/home': (context) => const TelaHome()},
        builder: (context, child) {
          final escurecer = (1 - config.luminosidade) * 0.65;
          return Stack(
            children: [
              if (child != null) child,
              IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  color: Colors.black.withOpacity(escurecer),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
