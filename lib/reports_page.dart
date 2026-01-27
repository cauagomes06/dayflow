import 'package:flutter/material.dart';
import 'drawer.dart';
import 'theme_controller.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Figma backgrounds:
    // Light: #FFFFFF
    // Dark:  #0F172A
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;

    // Cards no Figma (dark parece um azul bem escuro, com borda suave)
    final cardBg = isDark ? const Color(0xFF111827) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);

    // Texto
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.white70 : Colors.black54;

    // Cores dos cards pequenos (bordas)
    const plannedColor = Color(0xFF90A4AE);
    const doneColor = Color(0xFF00BFA5);
    const notDoneColor = Color(0xFFEF5350);
    const partialColor = Color(0xFFFFA000);

    // AppBar (igual ao Figma: light azul / dark bem escuro)
    final appBarBg = isDark ? const Color(0xFF0B1220) : const Color(0xFF1E3A8A);

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: const Text(
          'Relatório',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined, color: Colors.white),
            onPressed: () => ThemeController.instance.toggleTheme(),
          ),
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
        // Linha fina embaixo no dark (fica bem parecido com o contorno do Figma)
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark ? const Color(0xFF0EA5E9).withOpacity(0.35) : Colors.transparent,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          children: [
            // ====== SELETOR DE SEMANA (setas fora + pill no meio) ======
            _WeekSelector(
              isDark: isDark,
              cardBg: cardBg,
              borderColor: cardBorder,
              textColor: textPrimary,
              iconColor: textSecondary,
            ),

            const SizedBox(height: 18),

            // ====== RESUMO DA SEMANA ======
            _SummaryCard(
              isDark: isDark,
              bg: cardBg,
              border: cardBorder,
              titleColor: textPrimary,
              textColor: textPrimary,
              subtleText: textSecondary,
            ),

            const SizedBox(height: 18),

            // ====== 4 CARDS 2x2 ======
            Row(
              children: [
                Expanded(
                  child: _MiniStatCard(
                    title: "Planejados",
                    quantity: 16,
                    borderColor: plannedColor,
                    bg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStatCard(
                    title: "Concluídos",
                    quantity: 14,
                    borderColor: doneColor,
                    bg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MiniStatCard(
                    title: "Não Realizados",
                    quantity: 2,
                    borderColor: notDoneColor,
                    bg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStatCard(
                    title: "Parcial",
                    quantity: 3,
                    borderColor: partialColor,
                    bg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ====== GRÁFICO SEMANAL ======
            _WeeklyChart(
              isDark: isDark,
              bg: cardBg,
              border: cardBorder,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              plannedHours: 20,
              doneHours: 15,
            ),

            const SizedBox(height: 16),

            // ====== INSIGHTS (2 CARDS) ======
            Row(
              children: [
                Expanded(
                  child: _InsightCard(
                    isDark: isDark,
                    bg: cardBg,
                    border: cardBorder,
                    textColor: textPrimary,
                    iconColor: const Color(0xFFFBBF24),
                    text: "Você cumpriu 75%\ndo planejamento\nsemanal.",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InsightCard(
                    isDark: isDark,
                    bg: cardBg,
                    border: cardBorder,
                    textColor: textPrimary,
                    iconColor: const Color(0xFFFBBF24),
                    text: "A maior dificuldade\nfoi nos blocos de\nestudo.",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== WIDGETS =====================

class _WeekSelector extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;

  const _WeekSelector({
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          splashRadius: 18,
          onPressed: () {},
          icon: Icon(Icons.chevron_left, color: iconColor),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, size: 18, color: iconColor),
              const SizedBox(width: 10),
              Text(
                "Semana 11/01 - 17/01",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          splashRadius: 18,
          onPressed: () {},
          icon: Icon(Icons.chevron_right, color: iconColor),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final bool isDark;
  final Color bg;
  final Color border;
  final Color titleColor;
  final Color textColor;
  final Color subtleText;

  const _SummaryCard({
    required this.isDark,
    required this.bg,
    required this.border,
    required this.titleColor,
    required this.textColor,
    required this.subtleText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // barra lateral (no Figma parece um bloco/placa)
          Container(
            width: 18,
            height: 74,
            decoration: BoxDecoration(
              color: const Color(0xFF64748B),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Resumo da Semana",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: subtleText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Planejado: 20 horas",
                  style: TextStyle(color: textColor, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  "Realizado: 15 horas",
                  style: TextStyle(color: textColor, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  "Desvio: -5 horas",
                  style: TextStyle(color: textColor, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final int quantity;
  final Color borderColor;
  final Color bg;
  final Color textPrimary;
  final Color textSecondary;

  const _MiniStatCard({
    required this.title,
    required this.quantity,
    required this.borderColor,
    required this.bg,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 2.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            "Quantidade: $quantity",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final bool isDark;
  final Color bg;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final int plannedHours;
  final int doneHours;

  const _WeeklyChart({
    required this.isDark,
    required this.bg,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.plannedHours,
    required this.doneHours,
  });

  @override
  Widget build(BuildContext context) {
    // proporção do preenchimento das barras (0..1)
    final plannedPct = 1.0;
    final donePct = plannedHours == 0 ? 0.0 : (doneHours / plannedHours).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Column(
        children: [
          Text(
            "Gráfico Semanal",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          // Planejado
          _ChartRow(
            label: "Planejado",
            rightText: "${plannedHours}h",
            fillPercent: plannedPct,
            fillColor: const Color(0xFF1D4ED8), // azul (Figma)
            trackColor: isDark ? const Color(0xFF0B1220) : const Color(0xFFE5E7EB),
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),

          const SizedBox(height: 10),

          // Realizado
          _ChartRow(
            label: "Realizado",
            rightText: "${doneHours}h",
            fillPercent: donePct,
            fillColor: const Color(0xFF22C55E), // verde (Figma)
            trackColor: isDark ? const Color(0xFF0B1220) : const Color(0xFFE5E7EB),
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ],
      ),
    );
  }
}

class _ChartRow extends StatelessWidget {
  final String label;
  final String rightText;
  final double fillPercent;
  final Color fillColor;
  final Color trackColor;
  final Color textPrimary;
  final Color textSecondary;

  const _ChartRow({
    required this.label,
    required this.rightText,
    required this.fillPercent,
    required this.fillColor,
    required this.trackColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 8,
              color: trackColor,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: fillPercent,
                  child: Container(color: fillColor),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 34,
          child: Text(
            rightText,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final bool isDark;
  final Color bg;
  final Color border;
  final Color textColor;
  final Color iconColor;
  final String text;

  const _InsightCard({
    required this.isDark,
    required this.bg,
    required this.border,
    required this.textColor,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                height: 1.15,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
