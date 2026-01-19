import 'package:flutter/material.dart';

class ThemeController extends ValueNotifier<ThemeMode> {
  // Construtor privado (Singleton) para garantir que só exista um controlador
  ThemeController._() : super(ThemeMode.light);
  
  static final instance = ThemeController._();

  // Função que alterna entre Claro e Escuro
  void toggleTheme() {
    value = (value == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
  }
}