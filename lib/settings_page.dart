import 'package:flutter/material.dart';
import 'drawer.dart';
import 'theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Variável para verificar se é Dark Mode para ajustar textos e ações
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Configurações',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined, color: Colors.white),
            onPressed: () {
              ThemeController.instance.toggleTheme();
            },
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
                  icon: Icons.language,
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                // ITEM TEMA: Agora interativo!
                SettingsItem(
                  title: "Tema",
                  trailingText: isDark ? "Escuro" : "Claro",
                  icon: isDark ? Icons.dark_mode : Icons.light_mode,
                  onTap: () {
                    // Troca o tema ao clicar na opção também
                    ThemeController.instance.toggleTheme();
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- GRUPO 2: SEGURANÇA ---
            SettingsGroup(
              children: [
                SettingsItem(
                  title: "Permissões",
                  icon: Icons.security,
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                SettingsItem(
                  title: "Privacidade",
                  icon: Icons.lock,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- GRUPO 3: GERAL ---
            SettingsGroup(
              children: [
                SettingsItem(title: "Conta", icon: Icons.person, onTap: () {}),
                const SizedBox(height: 10),
                SettingsItem(
                  title: "Acessibilidade",
                  icon: Icons.accessibility,
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                SettingsItem(
                  title: "Sobre o App",
                  icon: Icons.info_outline,
                  trailingText: "v1.0.0",
                  onTap: () {},
                ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : const Color(0xFFFAEFFF),
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.white10) : null,
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
  final IconData? icon; // Adicionei ícone opcional para ficar mais bonito
  final VoidCallback onTap;

  const SettingsItem({
    super.key,
    required this.title,
    this.trailingText,
    this.icon,
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
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
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
            children: [
              // Ícone Opcional à esquerda
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                const SizedBox(width: 16),
              ],

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),

              if (trailingText != null) ...[
                Text(
                  trailingText!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.blueAccent[100]
                        : const Color(0xFF2B4C8C),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
