import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'TelaHome.dart';
import 'screens/LoginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print("Firebase iniciado com sucesso");
  } catch (e) {
    print("ERRO FIREBASE:");
    print(e);
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Color(0xFF1A1040),
    ),
  );

  runApp(const MyApp());
}

/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp( // conectando ao firebase
  options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Firebase iniciado com sucesso");

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Color(0xFF1A1040),
    ),
  );
  runApp(const MyApp());
}
*/
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journey Degree',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1040),
      ),
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const TelaHome(),
      },
    );
  }
}
