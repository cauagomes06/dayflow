import 'package:flutter/material.dart';
import 'drawer.dart';
import 'theme_controller.dart'; // <--- 1. Import necessário

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      // Sem cor de fundo fixa (o main.dart controla)
      
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        // Sem cor de fundo fixa
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Configurações',
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
            // --- GRUPO 1: PREFERÊNCIAS ---
            SettingsGroup(
              children: [
                SettingsItem(
                  title: "Idioma",
                  trailingText: "Português",
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                SettingsItem(title: "Tema", trailingText: "Dia", onTap: () {}),
              ],
            ),

            const SizedBox(height: 20),

            // --- GRUPO 2: SEGURANÇA ---
            SettingsGroup(
              children: [
                SettingsItem(title: "Permissões", onTap: () {}),
                const SizedBox(height: 10),
                SettingsItem(title: "Privacidade", onTap: () {}),
              ],
            ),

            const SizedBox(height: 20),

            // --- GRUPO 3: GERAL ---
            SettingsGroup(
              children: [
                SettingsItem(title: "Conta", onTap: () {}),
                const SizedBox(height: 10),
                SettingsItem(title: "Acessibilidade", onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET DO GRUPO ---
class SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const SettingsGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    // Verifica Dark Mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // No claro: Lilás (FAEFFF). No escuro: Transparente ou levemente mais claro que o fundo
        color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFFAEFFF),
        borderRadius: BorderRadius.circular(20),
        // No escuro adicionamos uma borda azulada sutil para destacar o grupo
        border: isDark ? Border.all(color: Colors.blueAccent.withOpacity(0.3)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// --- WIDGET DO ITEM ---
class SettingsItem extends StatelessWidget {
  final String title;
  final String? trailingText;
  final VoidCallback onTap;

  const SettingsItem({
    super.key,
    required this.title,
    this.trailingText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            // Cor do card: Branco (Claro) ou Slate 800 (Escuro) vindo do Theme
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade200
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  // Texto Branco no escuro, Preto no claro
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              if (trailingText != null)
                Text(
                  trailingText!,
                  style: TextStyle(
                    fontSize: 14, 
                    color: isDark ? Colors.grey[400] : Colors.grey[600]
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}