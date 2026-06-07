import 'package:flutter/material.dart';
import '../data/itens_repository.dart';
import '../data/skills_repository.dart';
import 'login_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _iniciarTudo();
  }

  Future<void> _iniciarTudo() async {
    
    await Future.wait([
        ItensRepository.carregarItens(),
        SkillsRepository.carregarSkills(),
      ]);

    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => const LoginScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Journey Degree", 
              style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Color(0xFF2563EB)),
          ],
        ),
      ),
    );
  }
}