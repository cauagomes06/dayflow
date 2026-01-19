import 'package:flutter/material.dart';
import 'theme_controller.dart'; // Certifique-se de ter criado este arquivo
import 'drawer.dart';           // Certifique-se de ter este arquivo
import 'routine_form.dart';     // Certifique-se de ter este arquivo

void main() {
  runApp(const DayFlowApp());
}

class DayFlowApp extends StatelessWidget {
  const DayFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    // O ValueListenableBuilder "escuta" as mudanças de tema no Controller
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DayFlow',
          themeMode: currentMode, // Define se é Light ou Dark agora
          
          // --- TEMA CLARO (LIGHT) ---
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF2B4C8C),
            scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Cinza Claro
            cardColor: Colors.white, // Fundo dos Cards
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF2B4C8C),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            useMaterial3: true,
          ),

          // --- TEMA ESCURO (DARK) ---
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF0F172A), // Azul Marinho Profundo
            scaffoldBackgroundColor: const Color(0xFF0F172A), // Fundo Geral
            cardColor: const Color(0xFF1E293B), // Fundo dos Cards (Slate 800)
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menu Lateral
      drawer: const AppDrawer(),

      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // BOTÃO DE TROCAR TEMA
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined, color: Colors.white), 
            onPressed: () {
              ThemeController.instance.toggleTheme();
            },
          ),
          // Botão de Perfil
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

      // Botão Flutuante (+) para Adicionar Rotina
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RoutineFormPage(isEditing: false),
            ),
          );
        },
        backgroundColor: const Color(0xFF2B4C8C),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card de Resumo do Dia
            const DailySummaryCard(),

            const SizedBox(height: 20),

            // Lista de Tarefas
            const TaskCard(
              title: "Estudo - Java",
              time: "14:00 - 16:00",
              status: "Planejado",
              statusColor: Colors.blueGrey,
            ),
            const TaskCard(
              title: "Estudo - Flutter",
              time: "14:00 - 16:00",
              status: "Concluído",
              statusColor: Color(0xFF00BFA5), // Verde Teal
            ),
            const TaskCard(
              title: "Reunião Projeto",
              time: "14:00 - 15:00",
              subtitle: "Estimado 14:00 - 16:00",
              status: "Parcial",
              statusColor: Colors.orange,
              isOutlined: true,
            ),
            const TaskCard(
              title: "Academia",
              time: "17:00 - 18:00",
              status: "Atrasado",
              statusColor: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS AUXILIARES (Adaptados para Dark Mode) ---

class DailySummaryCard extends StatelessWidget {
  const DailySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Cor dinâmica (Branco ou Slate 800)
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.blueGrey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hoje - 30/08/2026",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Seu plano para hoje.",
                style: TextStyle(
                  fontSize: 14, 
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: 0.20,
                  backgroundColor: isDark ? Colors.white10 : Colors.purple.shade50,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? Colors.blueAccent : Colors.deepPurple.shade300,
                  ),
                  strokeWidth: 6,
                ),
              ),
              Text(
                "20%", 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String time;
  final String status;
  final String? subtitle;
  final Color statusColor;
  final bool isOutlined;

  const TaskCard({
    super.key,
    required this.title,
    required this.time,
    required this.status,
    this.subtitle,
    required this.statusColor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Cor dinâmica
        borderRadius: BorderRadius.circular(16),
        border: isOutlined
            ? Border.all(color: statusColor, width: 2)
            : Border.all(color: isDark ? Colors.white10 : Colors.blueGrey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 12,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Container(
              width: 12,
              color: statusColor.withOpacity(isOutlined ? 0 : 0.1),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0, 
                  vertical: 16.0
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      time,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[300] : Colors.black87,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12, 
                          color: isDark ? Colors.grey[400] : Colors.grey[600]
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      status,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        // Ajusta contraste do texto de status no escuro
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}