import 'package:flutter/material.dart';

/// Botão para centralizar o mapa na localização atual do usuário
class LocationButton extends StatelessWidget {
  final VoidCallback onTap;

  const LocationButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 250, // Acima do botão de reportar
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.my_location,
              color: Color(0xFF4A90E2),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
