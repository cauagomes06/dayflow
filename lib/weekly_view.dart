import 'package:flutter/material.dart';
import 'drawer.dart';
import 'theme_controller.dart'; // <--- 1. Import necessário

class WeeklyViewPage extends StatelessWidget {
  const WeeklyViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Variável para verificar se é Dark Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(),
      // Removemos a cor fixa. O tema define (Branco ou Azul Escuro)
      
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        // Removemos a cor fixa para respeitar o Dark Theme configurado no main.dart
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Visão Semanal',
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
            // --- 1. SELETOR DE SEMANA ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: isDark ? Colors.white : Colors.black87),
                  onPressed: () {},
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    // Borda mais clara no modo escuro
                    border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    "Semana 11/01 - 17/01",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      // Texto branco no modo escuro
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: isDark ? Colors.white : Colors.black87),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- 2. TABELA COM SCROLL HORIZONTAL ---
            Container(
              decoration: BoxDecoration(
                // Borda da tabela
                border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: FixedColumnWidth(70), // Horário
                      1: FixedColumnWidth(100), // Dom
                      2: FixedColumnWidth(100), // Seg
                      3: FixedColumnWidth(100), // Ter
                      4: FixedColumnWidth(100), // Qua
                      5: FixedColumnWidth(100), // Qui
                      6: FixedColumnWidth(100), // Sex
                      7: FixedColumnWidth(100), // Sab
                    },
                    border: TableBorder(
                      horizontalInside: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
                      verticalInside: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
                    ),
                    children: [
                      // --- CABEÇALHO ---
                      TableRow(
                        decoration: BoxDecoration(
                          // No Dark Mode, o cabeçalho pode ser um pouco mais claro que o fundo ou manter a cor primary
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFF2B4C8C),
                        ),
                        children: [
                          _buildHeaderCell("Horário"),
                          _buildHeaderCell("Dom"),
                          _buildHeaderCell("Seg"),
                          _buildHeaderCell("Ter"),
                          _buildHeaderCell("Qua"),
                          _buildHeaderCell("Qui"),
                          _buildHeaderCell("Sex"),
                          _buildHeaderCell("Sáb"),
                        ],
                      ),

                      // --- LINHA 06:30 ---
                      TableRow(
                        children: [
                          _buildTimeCell("06:30", isDark),
                          _buildEmptyCell(),
                          _buildAutoPill("Correr", false, isDark),
                          _buildAutoPill("Correr", false, isDark),
                          _buildAutoPill("Correr", false, isDark),
                          _buildAutoPill("Correr", false, isDark),
                          _buildAutoPill("Correr", false, isDark),
                          _buildEmptyCell(),
                        ],
                      ),

                      // --- LINHA 10:00 ---
                      TableRow(
                        children: [
                          _buildTimeCell("10:00", isDark),
                          _buildEmptyCell(),
                          _buildAutoPill("Café", false, isDark),
                          _buildAutoPill("Café", false, isDark),
                          _buildAutoPill("Café", false, isDark),
                          _buildEmptyCell(),
                          _buildAutoPill("Café", false, isDark),
                          _buildEmptyCell(),
                        ],
                      ),

                      // --- LINHA 14:00 ---
                      TableRow(
                        children: [
                          _buildTimeCell("14:00", isDark),
                          _buildAutoPill("Almoço", true, isDark),
                          _buildAutoPill("Reunião", false, isDark),
                          _buildAutoPill("Estudo", false, isDark),
                          _buildEmptyCell(),
                          _buildAutoPill("Reunião", false, isDark),
                          _buildEmptyCell(),
                          _buildAutoPill("Lazer", true, isDark),
                        ],
                      ),

                      // --- LINHA 20:00 ---
                      TableRow(
                        children: [
                          _buildTimeCell("20:00", isDark),
                          _buildAutoPill("Filme", true, isDark),
                          _buildAutoPill("Lazer", true, isDark),
                          _buildAutoPill("Lazer", true, isDark),
                          _buildAutoPill("Jantar", true, isDark),
                          _buildEmptyCell(),
                          _buildAutoPill("Pizza", true, isDark),
                          _buildAutoPill("Festa", true, isDark),
                        ],
                      ),

                      // --- LINHA 23:00 ---
                      TableRow(
                        children: [
                          _buildTimeCell("23:00", isDark),
                          _buildAutoPill("Dormir", true, isDark),
                          _buildAutoPill("Dormir", true, isDark),
                          _buildAutoPill("Dormir", true, isDark),
                          _buildAutoPill("Dormir", true, isDark),
                          _buildAutoPill("Dormir", true, isDark),
                          _buildAutoPill("Dormir", true, isDark),
                          _buildAutoPill("Dormir", true, isDark),
                        ],
                      ),
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

  // --- LÓGICA DE CORES (Psicologia das Cores) ---
  Color _getCategoryColor(String activity) {
    final act = activity.toLowerCase();
    if (act.contains('correr') || act.contains('treino') || act.contains('academia')) {
      return const Color(0xFF2ECC71);
    }
    if (act.contains('café') || act.contains('almoço') || act.contains('jantar') || act.contains('pizza')) {
      return const Color(0xFFF39C12);
    }
    if (act.contains('lazer') || act.contains('filme') || act.contains('festa') || act.contains('jogar')) {
      return const Color(0xFFFF7043); 
    }
    if (act.contains('dormir') || act.contains('sono')) {
      return const Color(0xFF5E35B1); 
    }
    return const Color(0xFF3498DB);
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // Recebe isDark para ajustar a cor do texto do horário
  Widget _buildTimeCell(String time, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Text(
        time,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54, // Cinza claro no escuro
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyCell() {
    return const SizedBox(height: 50);
  }

  // Recebe isDark para ajustar o texto da pílula
  Widget _buildAutoPill(String text, bool isSolid, bool isDark) {
    final color = _getCategoryColor(text);

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSolid ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSolid ? Colors.transparent : color,
            width: 1.5,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            // Se for sólido: Branco.
            // Se for transparente: No claro é preto, no escuro é branco (para ler no fundo azul)
            color: isSolid ? Colors.white : (isDark ? Colors.white : Colors.black87),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}