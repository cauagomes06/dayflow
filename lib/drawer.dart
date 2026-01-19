import 'package:flutter/material.dart';
import 'routine_form.dart';
import 'settings_page.dart';
import 'weekly_view.dart';
import 'reports_page.dart';
import 'theme_controller.dart'; // <--- 1. Import necessário

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Variável para verificar se é Dark Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      // Fundo do Menu: Branco no claro, Slate 800 no escuro
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      
      child: Column(
        children: [
          // --- CABEÇALHO DO MENU (Perfil) ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              border: Border(
                // Linha divisória mais sutil no modo escuro
                bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: isDark ? Colors.white10 : Colors.deepPurple.shade50,
                  child: Icon(
                    Icons.person_outline,
                    color: isDark ? Colors.deepPurple.shade200 : Colors.deepPurple.shade400,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  "Nome", 
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    // Texto Branco no escuro
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),

          // --- ITENS DO MENU (Topo) ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context: context,
                  icon: Icons.home_outlined,
                  text: "Home",
                  color: Colors.brown.shade400,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.calendar_today_outlined,
                  text: "Visão Semanal",
                  color: Colors.red.shade400,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WeeklyViewPage(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.add_circle_outline,
                  text: "Adicionar Rotina",
                  isBold: true,
                  // Se não passar cor, ele usa a padrão (que adapta pro dark mode)
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const RoutineFormPage(isEditing: false),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.bar_chart_rounded,
                  text: "Relatórios",
                  color: Colors.blue.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReportsPage(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  text: "Configurações",
                  color: Colors.grey.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // --- RODAPÉ DO MENU ---
          Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
          
          // BOTÃO TEMA (AGORA FUNCIONAL)
          _buildMenuItem(
            context: context,
            // Alterna ícone: Lua no claro, Sol no escuro
            icon: isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
            text: isDark ? "Modo Claro" : "Modo Escuro",
            color: Colors.amber.shade700,
            onTap: () {
              // AÇÃO DE TROCAR TEMA
              ThemeController.instance.toggleTheme();
            },
          ),
          
          _buildMenuItem(
            context: context,
            icon: Icons.logout,
            text: "Sair",
            color: Colors.brown.shade700,
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget auxiliar atualizado para receber Contexto e tratar Dark Mode
  Widget _buildMenuItem({
    required BuildContext context, // Necessário para ler o tema
    required IconData icon,
    required String text,
    Color? color, // Agora é opcional
    bool isBold = false,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Cor do ícone: Se foi passada uma cor, usa ela. 
    // Se não (null), usa Cinza no claro e BrancoTransparente no escuro.
    final iconColor = color ?? (isDark ? Colors.white70 : Colors.black54);

    return ListTile(
      leading: Icon(icon, color: iconColor, size: 26),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          // Cor do texto se adapta ao fundo
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}