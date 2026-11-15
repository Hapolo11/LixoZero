import 'package:flutter/material.dart';

// Cores e contrastes definidos em Docs/justificativas.md.
class AppColors {
  static const verdeEscuro = Color(0xFF007F3D);
  static const verdeMedio = Color(0xFF43AD7A);
  static const verdeClaro = Color(0xFFD6F4DD);
  static const fundo = Color(0xFFF6FCF5);
  static const branco = Colors.white;
  static const texto = Color(0xFF1A1A1A);
  static const textoApoio = Color(0xFF666666);
  static const borda = Color(0xFFE3EDE2);
  static const cinza = Color(0xFF8A8A8A);
}

// Montserrat no conteúdo; Inter em números e distâncias.
const fonteTexto = 'Montserrat';
const fonteNumeros = 'Inter';

ThemeData criarTema() {
  const cantos = BorderRadius.all(Radius.circular(14));
  const bordaCampo = OutlineInputBorder(
    borderRadius: cantos,
    borderSide: BorderSide(color: AppColors.verdeMedio),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.verdeEscuro,
      primary: AppColors.verdeEscuro,
      surface: AppColors.branco,
      onSurface: AppColors.texto,
    ),
    scaffoldBackgroundColor: AppColors.fundo,
    fontFamily: fonteTexto,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.texto),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.texto),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.texto),
      bodyLarge: TextStyle(fontSize: 15, color: AppColors.texto, height: 1.4),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textoApoio, height: 1.4),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textoApoio,
        letterSpacing: 0.4,
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.branco,
      elevation: 1.5,
      shadowColor: Color(0x22000000),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: cantos),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.verdeEscuro,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 48),
        shape: const RoundedRectangleBorder(borderRadius: cantos),
        textStyle: const TextStyle(fontFamily: fonteTexto, fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.verdeEscuro,
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: AppColors.verdeMedio),
        shape: const RoundedRectangleBorder(borderRadius: cantos),
        textStyle: const TextStyle(fontFamily: fonteTexto, fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.verdeEscuro),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.branco,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: AppColors.textoApoio),
      border: bordaCampo,
      enabledBorder: bordaCampo,
      focusedBorder: OutlineInputBorder(
        borderRadius: cantos,
        borderSide: BorderSide(color: AppColors.verdeEscuro, width: 2),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
