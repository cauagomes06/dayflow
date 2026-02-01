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
  Set<int> completedIds = {}; // <--- NOVO: Lista de IDs concluídos hoje
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
    if (kIsWeb) return;

    setState(() => isLoading = true);

    try {
      final now = DateTime.now();
      final todayTag = _getWeekDayAbbreviation();
      todayLabel = _getFullWeekDayName(); 

      // 1. Busca Rotinas
      final allRoutines = await DatabaseHelper.instance.readAllRoutines();
      final filteredRoutines = allRoutines.where((r) {
        return r.days.contains(todayTag);
      }).toList();

      // 2. Busca Conclusões de HOJE (NOVO)
      final allCompletions = await DatabaseHelper.instance.getCompletions();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}";
      
      final idsDoneToday = <int>{};
      for (var c in allCompletions) {
        if (c['date'] == todayStr) {
          idsDoneToday.add(c['routine_id'] as int);
        }
      }

      setState(() {
        routines = filteredRoutines;
        completedIds = idsDoneToday;
      });

    } catch (e) {
      print("Erro: $e");
    }

    setState(() => isLoading = false);
  }

  // --- NOVA LÓGICA: CHECK / UNCHECK ---
  Future<void> _toggleStatus(int routineId, bool? value) async {
    final now = DateTime.now();
    
    if (value == true) {
      await DatabaseHelper.instance.completeRoutine(routineId, now);
    } else {
      await DatabaseHelper.instance.uncompleteRoutine(routineId, now);
    }
    // Recarrega para atualizar a tela
    refreshRoutines();
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

    // Calcula progresso do dia
    final total = routines.length;
    final done = completedIds.where((id) => routines.any((r) => r.id == id)).length;
    
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
                Expanded(
                  child: Column(
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
                      // Texto de progresso dinâmico
                      Text(
                        total == 0 
                          ? "Sem atividades." 
                          : "$done de $total concluídas",
                        style: TextStyle(
                          color: isDark ? Colors.greenAccent : const Color(0xFF2B4C8C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Icone de progresso (Opcional)
                if(total > 0)
                  CircularProgressIndicator(
                    value: done / total,
                    backgroundColor: Colors.grey[300],
                    color: Colors.green,
                  )
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
                        Opacity(
                          opacity: 0.8,
                          child: Icon(Icons.event_available, size: 80, color: Colors.grey[300]),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Nada agendado para $todayLabel.",
                          style: TextStyle(
                            color: isDark ? Colors.grey : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 0), 
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      final routine = routines[index];
                      final isDone = completedIds.contains(routine.id);
                      
                      return RoutineCard(
                        routine: routine,
                        isCompleted: isDone, // Passa status
                        onCheckChanged: (val) => _toggleStatus(routine.id!, val), // Passa ação
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