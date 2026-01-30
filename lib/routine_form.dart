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
  final _durationController = TextEditingController(text: "1h 30 min");
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
      _durationController.text = r.duration;
      _notesController.text = r.notes ?? '';
      
      if (r.days.isNotEmpty) {
        selectedDays = r.days.split(', ').where((d) => d.isNotEmpty).toList();
      }
    } 
    // CENÁRIO 2: CRIAÇÃO
    else {
      if (widget.initialTime != null) _timeController.text = widget.initialTime!;
      if (widget.initialDay != null && !selectedDays.contains(widget.initialDay!)) {
        selectedDays.add(widget.initialDay!);
      }
    }
  }

  // --- NOVA FUNÇÃO: SELECIONAR HORA (SPRINT 4) ---
  Future<void> _pickTime() async {
    // Tenta ler a hora atual do campo para abrir o relógio nela
    int hour = 14;
    int minute = 0;
    try {
      final parts = _timeController.text.split(':');
      if (parts.length == 2) {
        hour = int.parse(parts[0]);
        minute = int.parse(parts[1]);
      }
    } catch (_) {}

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) {
        // Ajuste de cor para o relógio ficar bonito no Dark Mode
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
      // Formata para sempre ter 2 dígitos (ex: 08:05)
      final formattedHour = picked.hour.toString().padLeft(2, '0');
      final formattedMinute = picked.minute.toString().padLeft(2, '0');
      setState(() {
        _timeController.text = "$formattedHour:$formattedMinute";
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
                  _buildSectionTitle("Horário", isDark),
                  const SizedBox(height: 8),
                  // --- CAMPO DE HORA COM CLIQUE (SPRINT 4) ---
                  TextFormField(
                    controller: _timeController,
                    readOnly: true, // Impede digitar texto
                    onTap: _pickTime, // Abre o relógio ao clicar
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: _inputDecoration("00:00", isDark).copyWith(
                      suffixIcon: const Icon(Icons.access_time, size: 20),
                    ),
                  ),
                ])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildSectionTitle("Duração", isDark),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _durationController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: _inputDecoration("Ex: 30 min", isDark),
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
                      final activity = Activity(
                        name: _activityController.text.isNotEmpty ? _activityController.text : "Atividade",
                        category: selectedCategory,
                      );

                      final routineToSave = Routine(
                        id: widget.routine?.id,
                        activity: activity, 
                        days: selectedDays.join(', '),
                        time: _timeController.text,
                        duration: _durationController.text,
                        notes: _notesController.text,
                      );

                      if (isEditing) {
                        await DatabaseHelper.instance.update(routineToSave);
                      } else {
                        await DatabaseHelper.instance.create(routineToSave);
                      }

                      if (context.mounted) {
                        // FEEDBACK DE SUCESSO
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