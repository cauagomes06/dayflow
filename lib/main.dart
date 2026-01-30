import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'theme_controller.dart';
import 'drawer.dart';
import 'routine_form.dart';
import 'routine_model.dart';
import 'db_helper.dart';
import 'routine_card.dart'; 

void main() {
  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }
  runApp(const DayFlowApp());
}

class DayFlowApp extends StatelessWidget {
  const DayFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DayFlow',
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF2B4C8C),
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF2B4C8C),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF0F172A),
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            cardColor: const Color(0xFF1E293B),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0F172A),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            useMaterial3: true,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Routine> routines = [];
  bool isLoading = true;
  String todayLabel = ""; 

  @override
  void initState() {
    super.initState();
    refreshRoutines();
  }

  String _getWeekDayAbbreviation() {
    final now = DateTime.now();
    switch (now.weekday) {
      case 1: return 'Seg';
      case 2: return 'Ter';
      case 3: return 'Qua';
      case 4: return 'Qui';
      case 5: return 'Sex';
      case 6: return 'Sab';
      case 7: return 'Dom';
      default: return '';
    }
  }

  String _getFullWeekDayName() {
    final now = DateTime.now();
    switch (now.weekday) {
      case 1: return 'Segunda-feira';
      case 2: return 'Terça-feira';
      case 3: return 'Quarta-feira';
      case 4: return 'Quinta-feira';
      case 5: return 'Sexta-feira';
      case 6: return 'Sábado';
      case 7: return 'Domingo';
      default: return '';
    }
  }

  Future refreshRoutines() async {
    if (kIsWeb) {
      setState(() => isLoading = false);
      return;
    }

    setState(() => isLoading = true);

    try {
      final allRoutines = await DatabaseHelper.instance.readAllRoutines();
      final todayTag = _getWeekDayAbbreviation();
      todayLabel = _getFullWeekDayName(); 

      routines = allRoutines.where((r) {
        return r.days.contains(todayTag);
      }).toList();
    } catch (e) {
      print("Erro: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> _deleteRoutine(int id) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Apagar Atividade?"),
        content: const Text("Isso removerá a atividade permanentemente."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseHelper.instance.delete(id);
              refreshRoutines();
            },
            child: const Text("Apagar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final dateString = "${now.day}/${now.month}/${now.year}";

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(
          'Minha Rotina',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined, color: Colors.white),
            onPressed: () => ThemeController.instance.toggleTheme(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RoutineFormPage()),
          );
          if (saved == true) refreshRoutines();
        },
        backgroundColor: const Color(0xFF2B4C8C),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: Column(
        children: [
          // Card de Resumo do Topo
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hoje ($todayLabel)",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateString,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${routines.length} atividades para hoje",
                      style: TextStyle(
                        color: isDark
                            ? Colors.blueAccent
                            : const Color(0xFF2B4C8C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : routines.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // --- WIDGET IMAGE ---
                        Opacity(
                          opacity: 0.8,
                          child: Image.asset(
                            'assets/images/empty_state.png',
                            height: 150,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.event_available, size: 80, color: Colors.grey[300]);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Nada agendado para $todayLabel.",
                          style: TextStyle(
                            color: isDark ? Colors.grey : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () async {
                            final all = await DatabaseHelper.instance.readAllRoutines();
                            setState(() {
                              routines = all;
                              todayLabel = "Todas as Atividades";
                            });
                          },
                          child: const Text("Ver todas as atividades"),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 0), // O Card já tem margin
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      final routine = routines[index];
                      
                      return RoutineCard(
                        routine: routine,
                        onTap: () async {
                          final saved = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoutineFormPage(routine: routine),
                            ),
                          );
                          if (saved == true) refreshRoutines();
                        },
                        onDelete: () => _deleteRoutine(routine.id!),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
