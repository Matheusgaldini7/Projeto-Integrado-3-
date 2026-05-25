import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
=======
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
>>>>>>> e197abd03abdd84f7f741a76be305dc0711c6d8a
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MaterialApp(
      title: 'Journey Degree',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF050816),
      ),
      home: const HomeScreen(),
=======
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
>>>>>>> e197abd03abdd84f7f741a76be305dc0711c6d8a
    );
  }
}
