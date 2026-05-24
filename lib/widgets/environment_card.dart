import 'package:flutter/material.dart';

class EnvironmentCard extends StatelessWidget {

  final String text;
  final String image;

  const EnvironmentCard({
    super.key,
    required this.text,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      color: const Color(0xFF111827),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),

        side: const BorderSide(
          color: Color(0xFF64748B),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: [

          Padding(
            padding: const EdgeInsets.all(20),

            child: Text(
              text,

              style: const TextStyle(
                fontSize: 18,
                height: 1.6,
                color: Color(0xFFE5E7EB),
              ),
            ),
          ),

          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),

              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,

                child: Image.asset(
                  image,

                  width: double.infinity,

                  fit: BoxFit.contain,

                  alignment: Alignment.center,

                  errorBuilder: (_, __, ___) =>
                      const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}