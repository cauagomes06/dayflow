import 'package:flutter/material.dart';
import 'drawer.dart';
import 'theme_controller.dart'; // <--- 1. Importante para o botão funcionar

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Variável para detectar o modo escuro e ajustar textos/ícones manualmente se precisar
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(),
      // Removemos o backgroundColor: Colors.white para o tema controlar
      
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        // Removemos o backgroundColor fixo. O main.dart já define (Azul no Light, Escuro no Dark)
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Relatório',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        child: Column(
          children: [
            // --- 1. SELETOR DE DATA ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // <--- 3. Fundo Dinâmico
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.deepPurpleAccent,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time, 
                    size: 20, 
                    // Ícone cinza no claro, branco transparente no escuro
                    color: isDark ? Colors.white70 : Colors.black54 
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Semana 11/01 - 17/01",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      // Texto preto no claro, branco no escuro
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- 2. CARDS DE RESUMO ---
            const ReportCard(
              title: "Planejados",
              quantity: 16,
              color: Color(0xFF90A4AE),
            ),
            const ReportCard(
              title: "Concluídos",
              quantity: 14,
              color: Color(0xFF00BFA5),
            ),
            const ReportCard(
              title: "Não Realizados",
              quantity: 2,
              color: Color(0xFFEF5350),
            ),
            const ReportCard(
              title: "Parcial",
              quantity: 3,
              color: Color(0xFFFFA000),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET DO CARD DE RELATÓRIO ---
class ReportCard extends StatelessWidget {
  final String title;
  final int quantity;
  final Color color;

  const ReportCard({
    super.key,
    required this.title,
    required this.quantity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Verificação de Dark Mode local para este widget
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // <--- Fundo do Card Dinâmico
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color, 
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Barra Lateral Colorida
          Container(
            width: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          
          // Conteúdo de Texto
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      // Texto adapta para branco no Dark Mode
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Quantidade: $quantity",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      // Texto adapta para cinza claro no Dark Mode
                      color: isDark ? Colors.white70 : Colors.black87.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}