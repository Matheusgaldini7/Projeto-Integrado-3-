import 'package:flutter/material.dart';
import 'h15_screen.dart';

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  State<CharacterCreationScreen> createState() =>
      _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  final TextEditingController nameController = TextEditingController();

  String selectedGender = 'masculino';

  String get personagemTexto {
    if (selectedGender == 'feminino') {
      return 'Você é uma estudante da PUC-Campinas que, após a frustração de ter seu TCC recusado, acaba sendo transportada para uma versão alternativa e sombria da faculdade. Ela deve percorrer os blocos para enfrentar os desafios que representam sua jornada acadêmica.';
    }

    return 'Você é um estudante da PUC-Campinas que, após a frustração de ter seu TCC recusado, acaba sendo transportado para uma versão alternativa e sombria da faculdade. Ele deve percorrer os blocos para enfrentar os desafios que representam sua jornada acadêmica.';
  }

  void startJourney() {
    final String playerName = nameController.text.trim();

    if (playerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite o nome do personagem antes de continuar.'),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => H15Screen(
          playerName: playerName,
          playerGender: selectedGender,
        ),
      ),
    );
  }

  Widget optionButton({
    required String text,
    required String value,
    required IconData icon,
  }) {
    final bool isSelected = selectedGender == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedGender = value;
          });
        },
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF38BDF8)
                  : const Color(0xFF64748B),
              width: 1.4,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget rpgButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon ?? Icons.arrow_forward),
        label: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.7,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      appBar: AppBar(
        title: const Text(
          'Criação do Personagem',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF111827),
        elevation: 8,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF050816),
              Color(0xFF111827),
              Color(0xFF1E1B4B),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),

                const Icon(
                  Icons.person,
                  size: 76,
                  color: Color(0xFF38BDF8),
                ),

                const SizedBox(height: 16),

                const Text(
                  'DEFINA SEU PERSONAGEM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Antes de iniciar sua jornada acadêmica, informe os dados do personagem.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 28),

                Card(
                  color: const Color(0xFF111827).withOpacity(0.92),
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: const BorderSide(
                      color: Color(0xFF38BDF8),
                      width: 1.2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Nome do personagem',
                          style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller: nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Digite o nome',
                            hintStyle: const TextStyle(
                              color: Color(0xFF94A3B8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1F2937),
                            prefixIcon: const Icon(
                              Icons.badge,
                              color: Color(0xFF38BDF8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF64748B),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF38BDF8),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        const Text(
                          'Sexo do personagem',
                          style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            optionButton(
                              text: 'Masculino',
                              value: 'masculino',
                              icon: Icons.male,
                            ),
                            const SizedBox(width: 12),
                            optionButton(
                              text: 'Feminino',
                              value: 'feminino',
                              icon: Icons.female,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF334155),
                            ),
                          ),
                          child: Text(
                            personagemTexto,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                rpgButton(
                  text: 'Começar Jornada',
                  icon: Icons.play_arrow,
                  onPressed: startJourney,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}