import 'package:flutter/material.dart';
import 'drawer.dart';
import 'theme_controller.dart';
import 'routine_model.dart';
import 'activity_model.dart';
import 'db_helper.dart';

class RoutineFormPage extends StatefulWidget {
  final Routine? routine; // Se vier preenchido, é EDIÇÃO
  final String? initialDay; 
  final String? initialTime;

  const RoutineFormPage({
    super.key, 
    this.routine, 
    this.initialDay, 
    this.initialTime
  });

  @override
  State<RoutineFormPage> createState() => _RoutineFormPageState();
}

class _RoutineFormPageState extends State<RoutineFormPage> {
  // Controladores
  final _activityController = TextEditingController();
  final _timeController = TextEditingController(text: "14:00");
  // MUDANÇA: Agora controlamos o Horário Final, não o texto da duração diretamente
  final _endTimeController = TextEditingController(text: "15:00"); 
  final _notesController = TextEditingController();

  String selectedCategory = 'Estudo';
  List<String> selectedDays = [];

  final List<String> categories = ['Estudo', 'Descanso', 'Saúde', 'Trabalho'];
  final List<String> weekDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];

  @override
  void initState() {
    super.initState();
    
    // CENÁRIO 1: EDIÇÃO
    if (widget.routine != null) {
      final r = widget.routine!;
      _activityController.text = r.activity.name;
      selectedCategory = r.activity.category;
      _timeController.text = r.time;
      _notesController.text = r.notes ?? '';
      
      if (r.days.isNotEmpty) {
        selectedDays = r.days.split(', ').where((d) => d.isNotEmpty).toList();
      }

      // LÓGICA MÁGICA: Calcular o horário de término baseado na duração salva
      _calculateEndTimeFromDuration(r.time, r.duration);
    } 
    // CENÁRIO 2: CRIAÇÃO
    else {
      if (widget.initialTime != null) _timeController.text = widget.initialTime!;
      
      // Define o término padrão para 1 hora depois do início
      _updateEndTimeBasedOnStart(widget.initialTime ?? "14:00");

      if (widget.initialDay != null && !selectedDays.contains(widget.initialDay!)) {
        selectedDays.add(widget.initialDay!);
      }
    }
  }

  // Auxiliar: Converte "HH:MM" para minutos totais do dia
  int _timeToMinutes(String time) {
    try {
      final parts = time.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (_) {
      return 0;
    }
  }

  // Auxiliar: Converte minutos totais para "HH:MM"
  String _minutesToTime(int totalMinutes) {
    // Garante que fique dentro de 24h
    final minutes = totalMinutes % (24 * 60);
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  // Ao criar/mudar hora inicio, joga o fim pra 1h depois
  void _updateEndTimeBasedOnStart(String startTime) {
    int startMin = _timeToMinutes(startTime);
    int endMin = startMin + 60; // +1 hora
    _endTimeController.text = _minutesToTime(endMin);
  }

  // Ao editar, lê "1h 30 min" e define o relógio final
  void _calculateEndTimeFromDuration(String startTime, String durationStr) {
    int startMin = _timeToMinutes(startTime);
    int durationMin = 0;

    // Parser simples de duração
    final numbers = durationStr.split(RegExp(r'[^0-9]')).where((e) => e.isNotEmpty).map(int.parse).toList();
    
    if (durationStr.contains(':')) {
       if (numbers.isNotEmpty) durationMin += numbers[0] * 60;
       if (numbers.length > 1) durationMin += numbers[1];
    } else {
       if (durationStr.contains('h')) {
          if (numbers.isNotEmpty) durationMin += numbers[0] * 60;
          if (numbers.length > 1) durationMin += numbers[1];
       } else {
          if (numbers.isNotEmpty) durationMin += numbers[0];
       }
    }

    _endTimeController.text = _minutesToTime(startMin + durationMin);
  }

  // Seletor Genérico de Hora
  Future<void> _pickTimeGeneric(TextEditingController controller) async {
    int hour = 12;
    int minute = 0;
    try {
      final parts = controller.text.split(':');
      hour = int.parse(parts[0]);
      minute = int.parse(parts[1]);
    } catch (_) {}

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark ? ThemeData.dark() : ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF2B4C8C)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedHour = picked.hour.toString().padLeft(2, '0');
      final formattedMinute = picked.minute.toString().padLeft(2, '0');
      setState(() {
        controller.text = "$formattedHour:$formattedMinute";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.routine != null;

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
        title: Text(
          isEditing ? 'Editar Atividade' : 'Nova Atividade',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("O que você vai fazer?", isDark),
              const SizedBox(height: 8),
              TextFormField(
                controller: _activityController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: _inputDecoration("Ex: Ler um livro, Treinar...", isDark),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("Categoria", isDark),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: categories.map((category) {
                  final isSelected = selectedCategory == category;
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) => setState(() => selectedCategory = category),
                    selectedColor: isDark ? Colors.deepPurple.shade700 : Colors.deepPurple.shade100,
                    backgroundColor: isDark ? Colors.black26 : Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? (isDark ? Colors.white : Colors.deepPurple.shade900) : (isDark ? Colors.white70 : Colors.black54),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              _buildSectionTitle("Dias da Semana", isDark),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: weekDays.map((day) {
                  final isSelected = selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => selected ? selectedDays.add(day) : selectedDays.remove(day));
                    },
                    selectedColor: isDark ? Colors.deepPurple.shade700 : Colors.deepPurple.shade100,
                    backgroundColor: isDark ? Colors.black26 : Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? (isDark ? Colors.white : Colors.deepPurple.shade900) : (isDark ? Colors.white70 : Colors.black54),
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildSectionTitle("Início", isDark),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _timeController,
                    readOnly: true,
                    onTap: () => _pickTimeGeneric(_timeController),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: _inputDecoration("00:00", isDark).copyWith(
                      suffixIcon: const Icon(Icons.access_time, size: 20),
                    ),
                  ),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // MUDANÇA NO TÍTULO
                  _buildSectionTitle("Término", isDark),
                  const SizedBox(height: 8),
                  TextFormField(
                    // MUDANÇA NO CONTROLLER (Agora é Hora Final)
                    controller: _endTimeController,
                    readOnly: true,
                    onTap: () => _pickTimeGeneric(_endTimeController),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: _inputDecoration("00:00", isDark).copyWith(
                      suffixIcon: const Icon(Icons.access_time_filled, size: 20),
                    ),
                  ),
                ])),
              ]),
              const SizedBox(height: 20),
              
              _buildSectionTitle("Notas (Opcional)", isDark),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: _inputDecoration("Detalhes extras...", isDark),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedDays.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("⚠️ Selecione pelo menos um dia!"), backgroundColor: Colors.orange),
                      );
                      return;
                    }

                    try {
                      // CÁLCULO DA DURAÇÃO ANTES DE SALVAR
                      int start = _timeToMinutes(_timeController.text);
                      int end = _timeToMinutes(_endTimeController.text);
                      
                      // Ajuste para virada de noite (ex: 23:00 as 01:00)
                      if (end < start) end += (24 * 60);
                      
                      int diff = end - start;
                      int h = diff ~/ 60;
                      int m = diff % 60;
                      
                      // Gera string compatível com o banco: "1h 30 min"
                      String durationString = "${h}h ${m}min";

                      final activity = Activity(
                        name: _activityController.text.isNotEmpty ? _activityController.text : "Atividade",
                        category: selectedCategory,
                      );

                      final routineToSave = Routine(
                        id: widget.routine?.id,
                        activity: activity, 
                        days: selectedDays.join(', '),
                        time: _timeController.text,
                        duration: durationString, // Salva calculado
                        notes: _notesController.text,
                      );

                      if (isEditing) {
                        await DatabaseHelper.instance.update(routineToSave);
                      } else {
                        await DatabaseHelper.instance.create(routineToSave);
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEditing ? "Atividade atualizada!" : "Atividade criada!"),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context, true);
                      }

                    } catch (e) {
                      print("ERRO: $e");
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Erro ao salvar: $e"), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text(
                    isEditing ? "Salvar Alterações" : "Adicionar à Rotina",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87));
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.black54),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2B4C8C), width: 2),
      ),
    );
  }
}