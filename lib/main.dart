import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'theme_controller.dart';
import 'drawer.dart';
import 'routine_form.dart';
import 'routine_model.dart';
import 'db_helper.dart';

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
  String todayLabel = ""; // Para mostrar "Hoje - Segunda"

  @override
  void initState() {
    super.initState();
    refreshRoutines();
  }

  // --- LÓGICA DE FILTRAR O DIA ---
  String _getWeekDayAbbreviation() {
    // DateTime.weekday retorna 1 (Segunda) a 7 (Domingo)
    final now = DateTime.now();
    switch (now.weekday) {
      case 1:
        return 'Seg';
      case 2:
        return 'Ter';
      case 3:
        return 'Qua';
      case 4:
        return 'Qui';
      case 5:
        return 'Sex';
      case 6:
        return 'Sab';
      case 7:
        return 'Dom';
      default:
        return '';
    }
  }

  String _getFullWeekDayName() {
    final now = DateTime.now();
    switch (now.weekday) {
      case 1:
        return 'Segunda-feira';
      case 2:
        return 'Terça-feira';
      case 3:
        return 'Quarta-feira';
      case 4:
        return 'Quinta-feira';
      case 5:
        return 'Sexta-feira';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return '';
    }
  }

  Future refreshRoutines() async {
    if (kIsWeb) {
      setState(() => isLoading = false);
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1. Busca TUDO do banco
      final allRoutines = await DatabaseHelper.instance.readAllRoutines();

      // 2. Descobre qual é o dia de hoje (ex: "Seg")
      final todayTag = _getWeekDayAbbreviation();
      todayLabel = _getFullWeekDayName(); // Para exibir na tela

      // 3. Filtra: Só mantém se a lista de dias da rotina conter "Seg"
      // Ex: se routine.days for "Seg, Qua", ela aparece. Se for "Ter, Qui", ela some.
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
                    // Exibe "Hoje (Segunda-feira)"
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
                        Icon(
                          Icons.event_available,
                          size: 60,
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
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
                            // Botão para ver tudo caso o usuário queira conferir se salvou errado
                            final all = await DatabaseHelper.instance
                                .readAllRoutines();
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      final routine = routines[index];
                      return TaskCard(
                        title: routine.activity.name,
                        category: routine.activity.category,
                        time: routine.time,
                        duration: routine.duration,
                        subtitle: routine.days, // Mostra os dias em que repete
                        onEdit: () async {
                          final saved = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RoutineFormPage(routine: routine),
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

class TaskCard extends StatelessWidget {
  final String title;
  final String category;
  final String time;
  final String duration;
  final String subtitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.title,
    required this.category,
    required this.time,
    required this.duration,
    required this.subtitle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color categoryColor = Colors.blue;
    if (category == 'Trabalho') categoryColor = Colors.orange;
    if (category == 'Saúde') categoryColor = Colors.redAccent;
    if (category == 'Descanso') categoryColor = Colors.teal;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: categoryColor, width: 6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: categoryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: isDark ? Colors.grey : Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                "$time - $duration",
                style: TextStyle(
                  color: isDark ? Colors.grey : Colors.grey[600],
                  fontSize: 13,
                ),
              ),

              const Spacer(), // Empurra os botões para a direita
              // --- Botões de Ação ---
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 20),
                onPressed: onEdit,
              ),
              const SizedBox(width: 16),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
