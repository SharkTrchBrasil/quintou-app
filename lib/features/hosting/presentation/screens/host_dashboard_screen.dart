import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';

class HostDashboardScreen extends ConsumerWidget {
  const HostDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    // Tratamento para não mostrar nomes nulos
    String firstName = 'Anfitrião';
    if (user != null && user.fullName.isNotEmpty) {
      firstName = user.fullName.split(' ').first;
    }

    final primaryColor = const Color(0xFF00AEEF);
    final secondaryColor = const Color(0xFFB7F65E);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Fundo leve para destacar os cards brancos
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Premium
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 32, 14, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bom dia,',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          firstName,
                          style: const TextStyle(
                            fontSize: 32, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                        child: user?.avatarUrl == null ? Icon(Icons.person, color: Colors.grey.shade400, size: 32) : null,
                      ),
                    ),
                  ],
                ),
              ),

              // KPI Cards (Resumo)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    _buildKpiCard('Receita Total', 'R\$ 0', Icons.account_balance_wallet, primaryColor),
                    const SizedBox(width: 12),
                    _buildKpiCard('Reservas', '0', Icons.calendar_today, Colors.orange),
                    const SizedBox(width: 12),
                    _buildKpiCard('Views', '0', Icons.visibility, Colors.green),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Chart Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Desempenho (7 dias)', style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              const Text('0 Views', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.trending_up, size: 16, color: primaryColor),
                                const SizedBox(width: 4),
                                Text('+0%', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 1,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.shade100,
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 22,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
                                    String text;
                                    switch (value.toInt()) {
                                      case 1: text = 'SEG'; break;
                                      case 3: text = 'QUA'; break;
                                      case 5: text = 'SEX'; break;
                                      case 7: text = 'DOM'; break;
                                      default: text = ''; break;
                                    }
                                    return SideTitleWidget(meta: meta, child: Text(text, style: style));
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            minX: 1,
                            maxX: 7,
                            minY: 0,
                            maxY: 6,
                            lineBarsData: [
                              LineChartBarData(
                                spots: const [
                                  FlSpot(1, 1),
                                  FlSpot(2, 1.5),
                                  FlSpot(3, 1.4),
                                  FlSpot(4, 3.4),
                                  FlSpot(5, 2),
                                  FlSpot(6, 2.2),
                                  FlSpot(7, 1.8),
                                ],
                                isCurved: true,
                                color: primaryColor,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor.withOpacity(0.3),
                                      primaryColor.withOpacity(0.0),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: const Text('Ações Rápidas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildQuickActionCard('Novo\nAnúncio', Icons.add_business, secondaryColor, Colors.black87, onTap: () => context.push('/create-space')),
                    _buildQuickActionCard('Agenda', Icons.calendar_month, primaryColor, Colors.white),
                    _buildQuickActionCard('Mensagens', Icons.chat_bubble_outline, Colors.orange, Colors.white),
                    _buildQuickActionCard('Financeiro', Icons.account_balance, Colors.deepPurple, Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color bgColor, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: bgColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 13, height: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
