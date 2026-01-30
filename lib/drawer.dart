import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'weekly_view.dart';
import 'reports_page.dart';
import 'main.dart';
import 'theme_controller.dart'; 

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Variável para verificar se é Dark Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Column(
        children: [
          // --- CABEÇALHO DO MENU (Perfil) ---
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
            ),
            child: Row(
              children: [
                // 1. Substituição do Icon pelo Image (Avatar)
                CircleAvatar(
                  radius: 25,
                  backgroundColor: isDark ? Colors.white10 : Colors.deepPurple.shade50,
                  // Aqui usamos o widget Image dentro de um ClipOval ou backgroundImage
                  backgroundImage: const AssetImage('assets/images/avatar.png'), 
                  // Se não tiver imagem de avatar ainda, ele fica vazio ou você pode por um child de fallback
                ),
                const SizedBox(width: 15),
                Text(
                  "Nome",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),

          // --- ITENS DO MENU ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // 2. Chamada modularizada passando o caminho da imagem
                _buildImageMenuItem(
                  context: context,
                  imagePath: 'assets/images/ic_home.png', // Nome que definimos antes
                  text: "Home",
                  color: Colors.brown.shade400,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
                  },
                ),
                _buildImageMenuItem(
                  context: context,
                  imagePath: 'assets/images/ic_calendar.png',
                  text: "Visão Semanal",
                  color: Colors.red.shade400,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WeeklyViewPage()));
                  },
                ),
                _buildImageMenuItem(
                  context: context,
                  imagePath: 'assets/images/ic_chart.png',
                  text: "Relatórios",
                  color: Colors.blue.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsPage()));
                  },
                ),
                _buildImageMenuItem(
                  context: context,
                  imagePath: 'assets/images/ic_settings.png',
                  text: "Configurações",
                  color: Colors.grey.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                  },
                ),
              ],
            ),
          ),

          Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),

          // Botão Tema (Pode manter Ícone ou mudar para Imagem também)
          // Vou manter a lógica do ícone aqui pois é dinâmico (sol/lua), 
          // mas se baixou 'ic_theme.png', pode usar.
          _buildImageMenuItem(
             context: context,
             // Exemplo: se você tiver ic_moon.png e ic_sun.png, pode fazer ternário aqui
             imagePath: isDark ? 'assets/images/ic_sun.png' : 'assets/images/ic_theme.png', 
             text: isDark ? "Modo Claro" : "Modo Escuro",
             color: Colors.amber.shade700,
             onTap: () => ThemeController.instance.toggleTheme(),
          ),

          _buildImageMenuItem(
            context: context,
            imagePath: 'assets/images/ic_logout.png',
            text: "Sair",
            color: Colors.brown.shade700,
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- WIDGET MODULARIZADO PARA IMAGEM ---
  Widget _buildImageMenuItem({
    required BuildContext context,
    required String imagePath, // Recebe string em vez de IconData
    required String text,
    Color? color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Define a cor para "tingir" a imagem PNG (importante para o Dark Mode)
    final imageColor = color ?? (isDark ? Colors.white70 : Colors.black54);

    return ListTile(
      leading: Image.asset(
        imagePath,
        width: 24, // Tamanho fixo para simular ícone
        height: 24,
        color: imageColor, // Isso pinta o PNG da cor desejada (se o PNG for transparente)
        errorBuilder: (context, error, stackTrace) {
          // Fallback caso a imagem não exista ainda: mostra um ícone de alerta
          return Icon(Icons.broken_image, color: imageColor);
        },
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}