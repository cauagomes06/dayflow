import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'drawer.dart';
import 'theme_controller.dart';
import 'db_helper.dart';
import 'routine_model.dart';
import 'activity_model.dart';
import 'routine_form.dart';

class WeeklyViewPage extends StatefulWidget {
  const WeeklyViewPage({super.key});

  @override
  State<WeeklyViewPage> createState() => _WeeklyViewPageState();
}

class _WeeklyViewPageState extends State<WeeklyViewPage> {
  List<Routine> allRoutines = [];
  // Lista de exceções: Strings no formato "ID_DA_ROTINA|YYYY-MM-DD" para busca rápida
  Set<String> exceptions = {};
  bool isLoading = true;

  late DateTime currentWeekStart;

  final List<String> timeSlots = [
    "06:00",
    "08:00",
    "10:00",
    "12:00",
    "14:00",
    "16:00",
    "18:00",
    "20:00",
    "22:00",
  ];

  final List<String> dbWeekDays = [
    'Dom',
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sab',
  ];

  @override
  void initState() {
    super.initState();
    currentWeekStart = _getStartOfWeek(DateTime.now());
    _loadData();
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
  }

  // Formata data para o padrão do banco de exceções (YYYY-MM-DD)
  String _formatDateDb(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _changeWeek(int daysToAdd) {
    setState(() {
      currentWeekStart = currentWeekStart.add(Duration(days: daysToAdd));
    });
  }

  Future<void> _loadData() async {
    if (kIsWeb) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final routines = await DatabaseHelper.instance.readAllRoutines();
      final rawExceptions = await DatabaseHelper.instance.getExceptions();

      // Transforma as exceções em um Conjunto (Set) de strings para facilitar a busca
      // Formato: "ID|2026-01-30"
      final exceptionSet = rawExceptions.map((e) {
        return "${e['routine_id']}|${e['date']}";
      }).toSet();

      setState(() {
        allRoutines = routines;
        exceptions = exceptionSet;
        isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _editRoutine(Routine routine) async {
    Navigator.pop(context);
    final saved = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutineFormPage(routine: routine),
      ),
    );
    if (saved == true) _loadData();
  }

  // --- NOVA LÓGICA DE APAGAR ---
  Future<void> _deleteRoutine(Routine routine, DateTime date) async {
    Navigator.pop(context); // Fecha menu de opções

    // Pergunta o tipo de exclusão
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Apagar Atividade"),
        content: const Text(
          "Você deseja apagar apenas desta data ou remover a recorrência completa?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          // OPÇÃO 1: APAGAR SÓ HOJE
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Adiciona exceção no banco
              await DatabaseHelper.instance.addException(routine.id!, date);
              _loadData();
            },
            child: const Text(
              "Apenas Hoje",
              style: TextStyle(color: Colors.orange),
            ),
          ),
          // OPÇÃO 2: APAGAR TUDO
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Apaga a rotina inteira
              await DatabaseHelper.instance.delete(routine.id!);
              _loadData();
            },
            child: const Text("Todos", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Precisa receber a DATA exata do clique para saber o que apagar
  void _showOptionsDialog(Routine routine, DateTime dateOfClick) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(routine.activity.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Data: ${_formatDate(dateOfClick)}"),
              Text("Horário: ${routine.time}"),
              Text("Categoria: ${routine.activity.category}"),
            ],
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.edit, color: Colors.blue),
              label: const Text("Editar Série"),
              onPressed: () => _editRoutine(routine),
            ),
            TextButton.icon(
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text("Apagar..."),
              // Passamos a data para a função de deletar
              onPressed: () => _deleteRoutine(routine, dateOfClick),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fechar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentWeekEnd = currentWeekStart.add(const Duration(days: 6));
    final weekRangeText =
        "Semana ${_formatDate(currentWeekStart)} - ${_formatDate(currentWeekEnd)}";

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Visão Semanal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined, color: Colors.white),
            onPressed: () => ThemeController.instance.toggleTheme(),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.chevron_left,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        onPressed: () => _changeWeek(-7),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? Colors.white24
                                : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          color: Theme.of(context).cardColor,
                        ),
                        child: Text(
                          weekRangeText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.chevron_right,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        onPressed: () => _changeWeek(7),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Table(
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.top,
                          columnWidths: const {
                            0: FixedColumnWidth(60),
                            1: FixedColumnWidth(90),
                            2: FixedColumnWidth(90),
                            3: FixedColumnWidth(90),
                            4: FixedColumnWidth(90),
                            5: FixedColumnWidth(90),
                            6: FixedColumnWidth(90),
                            7: FixedColumnWidth(90),
                          },
                          border: TableBorder(
                            horizontalInside: BorderSide(
                              color: isDark
                                  ? Colors.white10
                                  : Colors.grey.shade200,
                            ),
                            verticalInside: BorderSide(
                              color: isDark
                                  ? Colors.white10
                                  : Colors.grey.shade200,
                            ),
                          ),
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFF2B4C8C),
                              ),
                              children: [
                                _buildHeaderCell("Hora"),
                                ...List.generate(7, (index) {
                                  final date = currentWeekStart.add(
                                    Duration(days: index),
                                  );
                                  return _buildHeaderCell(
                                    "${dbWeekDays[index]} ${date.day}",
                                  );
                                }),
                              ],
                            ),
                            ...timeSlots.map((time) {
                              return TableRow(
                                children: [
                                  _buildTimeCell(time, isDark),
                                  // Passamos o índice do dia (0=Dom, 1=Seg...) para calcular a data
                                  ...List.generate(7, (index) {
                                    final dayName = dbWeekDays[index];
                                    // Calculamos a data exata desta coluna
                                    final columnDate = currentWeekStart.add(
                                      Duration(days: index),
                                    );
                                    return _buildActivityCell(
                                      dayName,
                                      time,
                                      isDark,
                                      columnDate,
                                    );
                                  }),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Agora recebe a DATA EXATA da coluna (columnDate)
  Widget _buildActivityCell(
    String dayOfWeek,
    String timeSlot,
    bool isDark,
    DateTime columnDate,
  ) {
    final routinesForDay = allRoutines
        .where((r) => r.days.contains(dayOfWeek))
        .toList();

    final match = routinesForDay.firstWhere(
      (r) {
        // 1. Verifica Horário
        String routineHour = r.time.split(':')[0];
        String slotHour = timeSlot.split(':')[0];
        if (routineHour != slotHour) return false;

        // 2. VERIFICAÇÃO DE EXCEÇÃO (NOVO!)
        // Cria a chave "ID|YYYY-MM-DD"
        final exceptionKey = "${r.id}|${_formatDateDb(columnDate)}";

        // Se essa chave estiver na lista de exceções, ignoramos essa rotina
        if (exceptions.contains(exceptionKey)) return false;

        return true;
      },
      orElse: () => Routine(
        activity: Activity(name: "", category: ""),
        days: "",
        time: "",
        duration: "",
      ),
    );

    // Célula Vazia (Adicionar)
    if (match.activity.name.isEmpty) {
      return InkWell(
        onTap: () async {
          final saved = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RoutineFormPage(initialDay: dayOfWeek, initialTime: timeSlot),
            ),
          );
          if (saved == true) _loadData();
        },
        child: Container(
          height: 60,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.add,
              size: 16,
              color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.3),
            ),
          ),
        ),
      );
    }

    // Célula Preenchida (Editar/Apagar)
    return InkWell(
      // Passamos a data exata para o diálogo saber qual exceção criar
      onTap: () => _showOptionsDialog(match, columnDate),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 60,
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _getCategoryColor(match.activity.category).withOpacity(0.2),
          border: Border.all(color: _getCategoryColor(match.activity.category)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              match.activity.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            Text(
              match.time,
              style: TextStyle(
                fontSize: 9,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Trabalho':
        return Colors.orange;
      case 'Saúde':
        return Colors.redAccent;
      case 'Descanso':
        return Colors.teal;
      case 'Estudo':
        return Colors.blue;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTimeCell(String time, bool isDark) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: Text(
        time,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }
}
