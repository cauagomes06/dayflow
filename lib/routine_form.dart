import 'package:flutter/material.dart';
import 'drawer.dart';
import 'theme_controller.dart'; // <--- 1. Import necessário

class RoutineFormPage extends StatefulWidget {
  final bool isEditing;

  const RoutineFormPage({super.key, this.isEditing = false});

  @override
  State<RoutineFormPage> createState() => _RoutineFormPageState();
}

class _RoutineFormPageState extends State<RoutineFormPage> {
  String selectedCategory = 'Estudo';
  List<String> selectedDays = [];
  
  final List<String> categories = ['Estudo', 'Descanso', 'Saúde', 'Trabalho'];
  final List<String> weekDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];

  @override
  Widget build(BuildContext context) {
    // Variável para verificar se é Dark Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(),
      // Removemos a cor fixa do background para o main.dart controlar
      
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        // Removemos backgroundColor fixo
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.isEditing ? 'Editar Rotina' : 'Adicionar Rotina',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // --- 2. BOTÃO DE TROCAR TEMA ---
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined, color: Colors.white),
            onPressed: () {
              ThemeController.instance.toggleTheme();
            },
          ),
          // -------------------------------
          IconButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, // <--- 3. Cor dinâmica (Branco/Escuro)
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
              // --- CAMPO: ATIVIDADE ---
              _buildSectionTitle("Atividade", isDark),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: widget.isEditing ? "Estudar Química" : null,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87), // Cor do texto digitado
                decoration: _inputDecoration("O que vai fazer?", isDark),
              ),

              const SizedBox(height: 20),

              // --- CAMPO: CATEGORIA ---
              _buildSectionTitle("Categoria", isDark),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: categories.map((category) {
                  final isSelected = selectedCategory == category;
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => selectedCategory = category);
                    },
                    selectedColor: isDark ? Colors.deepPurple.shade700 : Colors.deepPurple.shade100,
                    backgroundColor: isDark ? Colors.black26 : Colors.white, // Fundo do chip não selecionado
                    labelStyle: TextStyle(
                      // Texto do chip muda de cor se selecionado ou se está no modo escuro
                      color: isSelected 
                          ? (isDark ? Colors.white : Colors.deepPurple.shade900) 
                          : (isDark ? Colors.white70 : Colors.black54),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected 
                            ? Colors.deepPurple 
                            : (isDark ? Colors.white24 : Colors.grey.shade300), // Borda visível no escuro
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // --- CAMPO: DIA DA SEMANA ---
              _buildSectionTitle("Dia da Semana", isDark),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: weekDays.map((day) {
                  final isSelected = selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selected ? selectedDays.add(day) : selectedDays.remove(day);
                      });
                    },
                    selectedColor: isDark ? Colors.deepPurple.shade700 : Colors.deepPurple.shade100,
                    backgroundColor: isDark ? Colors.black26 : Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected 
                          ? (isDark ? Colors.white : Colors.deepPurple.shade900) 
                          : (isDark ? Colors.white70 : Colors.black54),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected 
                            ? Colors.deepPurple 
                            : (isDark ? Colors.white24 : Colors.grey.shade300),
                      ),
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // --- CAMPOS: HORÁRIO E DURAÇÃO ---
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Horário", isDark),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: "14:00",
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: _inputDecoration("Hora", isDark),
                          keyboardType: TextInputType.datetime,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Duração", isDark),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: "1h 30 min",
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                          decoration: _inputDecoration("Tempo", isDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- CAMPO: OBSERVAÇÕES ---
              _buildSectionTitle("Observações", isDark),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 3,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: _inputDecoration("Opcional", isDark),
              ),

              const SizedBox(height: 30),

              // --- BOTÃO SALVAR ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); 
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Salvar",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para o estilo dos títulos (Agora recebe isDark)
  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        // Cor do título adapta: branco no escuro, preto no claro
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  // Helper para o estilo dos inputs (Agora recebe isDark)
  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      // Cor do placeholder (dica)
      hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.black54),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        // Borda quando não está focado (precisa ser mais clara no dark mode)
        borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2B4C8C), width: 2),
      ),
    );
  }
}