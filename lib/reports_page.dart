import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'drawer.dart';
import 'theme_controller.dart';
import 'db_helper.dart';
import 'routine_model.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  // Estado
  late DateTime currentWeekStart;
  bool isLoading = true;

  // Estatísticas
  int plannedCount = 0;
  int doneCount = 0;
  int notDoneCount = 0;
  // Parcial vamos deixar 0 por enquanto, pois precisaria de logica de "meio feito"
  int partialCount = 0; 
  
  double plannedHours = 0;
  double doneHours = 0;

  @override
  void initState() {
    super.initState();
    // Começa no domingo da semana atual
    final now = DateTime.now();
    currentWeekStart = now.subtract(Duration(days: now.weekday % 7));
    _loadData();
  }

  void _changeWeek(int days) {
    setState(() {
      currentWeekStart = currentWeekStart.add(Duration(days: days));
      isLoading = true;
    });
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final routines = await DatabaseHelper.instance.readAllRoutines();
      final exceptionsRaw = await DatabaseHelper.instance.getExceptions();
      final completionsRaw = await DatabaseHelper.instance.getCompletions();

      // Sets para busca rápida "ID|YYYY-MM-DD"
      final exceptionSet = exceptionsRaw.map((e) => "${e['routine_id']}|${e['date']}").toSet();
      final completionSet = completionsRaw.map((e) => "${e['routine_id']}|${e['date']}").toSet();

      // Zera contadores
      int pCount = 0;
      int dCount = 0;
      double pHours = 0;
      double dHours = 0;

      // Itera os 7 dias da semana selecionada
      for (int i = 0; i < 7; i++) {
        final date = currentWeekStart.add(Duration(days: i));
        final dateStr = _formatDateDb(date);
        final weekDayAbbr = _getWeekDayAbbr(date.weekday); // Seg, Ter...

        // Para cada rotina, vê se ela cai neste dia
        for (var r in routines) {
          if (r.days.contains(weekDayAbbr)) {
            final key = "${r.id}|$dateStr";

            // Se for exceção, ignora (foi apagada neste dia)
            if (exceptionSet.contains(key)) continue;

            // É uma atividade válida!
            pCount++;
            final durationInHours = _parseDuration(r.duration);
            pHours += durationInHours;

            // Foi concluída?
            if (completionSet.contains(key)) {
              dCount++;
              dHours += durationInHours;
            }
          }
        }
      }

      setState(() {
        plannedCount = pCount;
        doneCount = dCount;
        notDoneCount = pCount - dCount; // O que sobrou é "Não realizado"
        plannedHours = pHours;
        doneHours = dHours;
        isLoading = false;
      });

    } catch (e) {
      print("Erro ao carregar relatório: $e");
      setState(() => isLoading = false);
    }
  }

  // Auxiliares
  String _formatDateDb(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}";
  }

  String _getWeekDayAbbr(int weekday) {
    // DateTime: 1=Seg, 7=Dom. Nosso DB usa Strings.
    switch (weekday) {
      case 1: return 'Seg';
      case 2: return 'Ter';
      case 3: return 'Qua';
      case 4: return 'Qui';
      case 5: return 'Sex';
      case 6: return 'Sab';
      case 7: return 'Dom';
      default: return '';
    }
  }

  double _parseDuration(String durationStr) {
    // Tenta converter "1h 30 min", "01:30", "30 min" para double horas
    // Ex: 1h 30 min -> 1.5
    try {
      double total = 0;
      // Normaliza
      String s = durationStr.toLowerCase().replaceAll(':', ' '); 
      
      // Regex simples para capturar números
      // Se tiver "h", o numero antes é hora. Se tiver "m", é minuto.
      // Abordagem simplificada: split por espaço
      final parts = s.split(RegExp(r'[^0-9]')); // Split por não-números
      final numbers = parts.where((e) => e.isNotEmpty).map(int.parse).toList();

      if (durationStr.contains(':')) {
        // Formato HH:MM
        if (numbers.isNotEmpty) total += numbers[0];
        if (numbers.length > 1) total += numbers[1] / 60.0;
      } else {
        // Formato texto (ex: 1h 30min)
        // Essa lógica é frágil se o usuário digitar qualquer coisa, 
        // mas serve para o padrão sugerido "1h 30 min"
        if (durationStr.contains('h')) {
             // Assume o primeiro numero é hora
             if (numbers.isNotEmpty) total += numbers[0];
             if (numbers.length > 1) total += numbers[1] / 60.0;
        } else if (durationStr.contains('min')) {
             if (numbers.isNotEmpty) total += numbers[0] / 60.0;
        } else {
             // Só numero? assume min
             if (numbers.isNotEmpty) total += numbers[0] / 60.0;
        }
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardBg = isDark ? const Color(0xFF111827) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? Colors.white70 : Colors.black54;

    const plannedColor = Color(0xFF90A4AE);
    const doneColor = Color(0xFF00BFA5);
    const notDoneColor = Color(0xFFEF5350);
    const partialColor = Color(0xFFFFA000);

    final appBarBg = isDark ? const Color(0xFF0B1220) : const Color(0xFF1E3A8A);

    // Textos de data
    final startStr = DateFormat('dd/MM').format(currentWeekStart);
    final endStr = DateFormat('dd/MM').format(currentWeekStart.add(const Duration(days: 6)));
    final diffHours = (doneHours - plannedHours).toStringAsFixed(1);
    final diffLabel = (doneHours - plannedHours) >= 0 ? "+$diffHours" : diffHours;

    // Insight calculation
    final percent = plannedCount > 0 ? (doneCount / plannedCount * 100).toInt() : 0;
    String insightText = "Você cumpriu $percent%\ndo planejado.";
    if (percent < 50) insightText = "Semana difícil?\nVamos recuperar!";
    if (percent > 90) insightText = "Excelente semana!\nQuase 100%!";

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark ? const Color(0xFF0EA5E9).withOpacity(0.35) : Colors.transparent,
          ),
        ),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          children: [
            // ====== SELETOR DE SEMANA ======
            _WeekSelector(
              isDark: isDark,
              cardBg: cardBg,
              borderColor: cardBorder,
              textColor: textPrimary,
              iconColor: textSecondary,
              label: "Semana $startStr - $endStr",
              onPrev: () => _changeWeek(-7),
              onNext: () => _changeWeek(7),
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
              plannedH: "${plannedHours.toStringAsFixed(1)}h",
              doneH: "${doneHours.toStringAsFixed(1)}h",
              diffH: "${diffLabel}h",
            ),

            const SizedBox(height: 18),

            // ====== 4 CARDS 2x2 ======
            Row(
              children: [
                Expanded(
                  child: _MiniStatCard(
                    title: "Planejados",
                    quantity: plannedCount,
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
                    quantity: doneCount,
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
                    title: "Pendentes",
                    quantity: notDoneCount,
                    borderColor: notDoneColor,
                    bg: cardBg,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  // Mantido estático ou 0 pois requer lógica complexa
                  child: _MiniStatCard(
                    title: "Parcial",
                    quantity: partialCount,
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
              plannedHours: plannedHours,
              doneHours: doneHours,
            ),

            const SizedBox(height: 16),

            // ====== INSIGHTS ======
            Row(
              children: [
                Expanded(
                  child: _InsightCard(
                    isDark: isDark,
                    bg: cardBg,
                    border: cardBorder,
                    textColor: textPrimary,
                    iconColor: const Color(0xFFFBBF24),
                    text: insightText,
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
                    text: "Mantenha o\nritmo constante!",
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

// ===================== WIDGETS ATUALIZADOS =====================

class _WeekSelector extends StatelessWidget {
  final bool isDark;
  final Color cardBg;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _WeekSelector({
    required this.isDark,
    required this.cardBg,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          splashRadius: 18,
          onPressed: onPrev,
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
                label,
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
          onPressed: onNext,
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
  final String plannedH;
  final String doneH;
  final String diffH;

  const _SummaryCard({
    required this.isDark,
    required this.bg,
    required this.border,
    required this.titleColor,
    required this.textColor,
    required this.subtleText,
    required this.plannedH,
    required this.doneH,
    required this.diffH,
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
                  "Planejado: $plannedH",
                  style: TextStyle(color: textColor, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  "Realizado: $doneH",
                  style: TextStyle(color: textColor, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  "Desvio: $diffH",
                  style: TextStyle(
                    color: diffH.startsWith('-') ? Colors.redAccent : Colors.green, 
                    fontSize: 13
                  ),
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
  final double plannedHours;
  final double doneHours;

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
    final ph = plannedHours;
    final dh = doneHours;
    
    // Evita divisão por zero
    double plannedPct = 1.0;
    double donePct = 0.0;

    if (ph > 0) {
      donePct = (dh / ph).clamp(0.0, 1.0);
    } else if (dh > 0) {
      // Se não planejou nada mas fez, barra cheia
      donePct = 1.0; 
    }

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
            rightText: "${ph.toStringAsFixed(1)}h",
            fillPercent: plannedPct,
            fillColor: const Color(0xFF1D4ED8), 
            trackColor: isDark ? const Color(0xFF0B1220) : const Color(0xFFE5E7EB),
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),

          const SizedBox(height: 10),

          // Realizado
          _ChartRow(
            label: "Realizado",
            rightText: "${dh.toStringAsFixed(1)}h",
            fillPercent: donePct,
            fillColor: const Color(0xFF22C55E), 
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