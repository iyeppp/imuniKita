import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router/app_router.dart';

/// Bottom navigation utama ImuniKita (komponen UI global).
///
/// Sebelumnya `BottomNavigationBar` ditulis ulang manual di Dashboard,
/// Kalender, Faskes, ImuniBot, dan Profil. Urutan tab baku:
/// **Home · Kalender · Faskes · ImuniBot · Profil**.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.currentIndex});

  /// Indeks tab yang sedang aktif (0–4) agar ikon yang benar ter-highlight.
  final int currentIndex;

  /// Rute tujuan tiap tab, sejajar dengan urutan item di bawah.
  static const List<String> _routes = [
    AppRoutes.dashboard,
    AppRoutes.calendar,
    AppRoutes.faskes,
    AppRoutes.chatbot,
    AppRoutes.settings,
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        // Menekan tab yang sedang aktif tidak perlu navigasi ulang — selain
        // mubazir, ini juga akan me-reset state layar (mis. tanggal terpilih
        // di Kalender).
        if (index == currentIndex) return;
        context.go(_routes[index]);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Kalender',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_hospital_outlined),
          label: 'Faskes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'ImuniBot',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}
