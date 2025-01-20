import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'screens/giris_ekrani.dart';

void main() {
  // Windows için SQLite'ı başlat
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
  }

  runApp(const HarcamaTakipUygulamasi());
}

class HarcamaTakipUygulamasi extends StatelessWidget {
  const HarcamaTakipUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harcama Takip',
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          surface: Colors.grey[900]!,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: Colors.grey[900],
          elevation: 4,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.grey[900],
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.grey[900],
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          surface: Colors.grey[900]!,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: Colors.grey[900],
          elevation: 4,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.grey[900],
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.grey[900],
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const GirisEkrani(),
    );
  }
}
