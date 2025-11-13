import 'package:flutter/material.dart';
import 'dart:math' as math;

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedPeriod = 'Semaine';
  String selectedMetric = 'Tension';
  
  final List<String> periods = ['Jour', 'Semaine', 'Mois', 'Année'];
  final List<Map<String, dynamic>> metrics = [
    {'name': 'Tension', 'icon': Icons.favorite, 'color': Color(0xFFFF3B30), 'unit': 'mmHg'},
    {'name': 'Glycémie', 'icon': Icons.water_drop, 'color': Color(0xFF5856D6), 'unit': 'mg/dL'},
    {'name': 'Fréquence', 'icon': Icons.monitor_heart, 'color': Color(0xFFFF2D55), 'unit': 'bpm'},
    {'name': 'Température', 'icon': Icons.thermostat, 'color': Color(0xFFFF9500), 'unit': '°C'},
  ];

  // Générer des données simulées pour les graphiques
  List<Map<String, dynamic>> _getChartData() {
    final random = math.Random();
    List<Map<String, dynamic>> data = [];
    
    int points = selectedPeriod == 'Jour' ? 24 : 
                 selectedPeriod == 'Semaine' ? 7 : 
                 selectedPeriod == 'Mois' ? 30 : 12;
    
    for (int i = 0; i < points; i++) {
      double value;
      if (selectedMetric == 'Tension') {
        value = 110 + random.nextDouble() * 30;
      } else if (selectedMetric == 'Glycémie') {
        value = 80 + random.nextDouble() * 40;
      } else if (selectedMetric == 'Fréquence') {
        value = 60 + random.nextDouble() * 40;
      } else {
        value = 36.5 + random.nextDouble() * 1.5;
      }
      
      data.add({'index': i, 'value': value});
    }
    return data;
  }

  // Calculer les statistiques
  Map<String, double> _getStatistics() {
    final data = _getChartData();
    final values = data.map((d) => d['value'] as double).toList();
    
    double min = values.reduce(math.min);
    double max = values.reduce(math.max);
    double avg = values.reduce((a, b) => a + b) / values.length;
    
    return {'min': min, 'max': max, 'avg': avg};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildPeriodSelector(),
              const SizedBox(height: 20),
              _buildMetricSelector(),
              const SizedBox(height: 30),
              _buildChartSection(),
              const SizedBox(height: 30),
              _buildStatisticsCards(),
              const SizedBox(height: 30),
              _buildHistorySection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMeasureDialog,
        backgroundColor: const Color(0xFF34C759),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nouvelle mesure',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showSnackBar('Retour'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistiques',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Suivez vos mesures de santé',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: periods.map((period) {
            final isSelected = period == selectedPeriod;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPeriod = period;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF34C759) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    period,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF8E8E93),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMetricSelector() {
    return SizedBox(
      height: 100, // Augmenté de 90 à 100 pour plus d'espace
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: metrics.length,
        itemBuilder: (context, index) {
          final metric = metrics[index];
          final isSelected = metric['name'] == selectedMetric;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedMetric = metric['name'];
              });
            },
            child: Container(
              width: 95, // Légèrement augmenté pour éviter le débordement
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), // Ajustement du padding
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? metric['color'] : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Pour que la colonne prenne seulement l'espace nécessaire
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8), // Réduit le padding
                    decoration: BoxDecoration(
                      color: (metric['color'] as Color).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      metric['icon'],
                      color: metric['color'],
                      size: 20, // Légèrement réduit la taille de l'icône
                    ),
                  ),
                  const SizedBox(height: 6), // Espacement réduit
                  Text(
                    metric['name'],
                    textAlign: TextAlign.center,
                    maxLines: 2, // Permet le retour à la ligne si nécessaire
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? metric['color'] : const Color(0xFF1D1D1F),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartSection() {
    final data = _getChartData();
    final metric = metrics.firstWhere((m) => m['name'] == selectedMetric);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Évolution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (metric['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    metric['unit'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: metric['color'],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _buildLineChart(data, metric['color']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<Map<String, dynamic>> data, Color color) {
    return CustomPaint(
      painter: LineChartPainter(
        data: data,
        color: color,
      ),
      child: Container(),
    );
  }

  Widget _buildStatisticsCards() {
    final stats = _getStatistics();
    final metric = metrics.firstWhere((m) => m['name'] == selectedMetric);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Minimum',
              stats['min']!.toStringAsFixed(1),
              metric['unit'],
              const Color(0xFF5856D6),
              Icons.arrow_downward,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Moyenne',
              stats['avg']!.toStringAsFixed(1),
              metric['unit'],
              const Color(0xFF34C759),
              Icons.analytics,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Maximum',
              stats['max']!.toStringAsFixed(1),
              metric['unit'],
              const Color(0xFFFF3B30),
              Icons.arrow_upward,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String unit, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8E8E93),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D1D1F),
              ),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    final metric = metrics.firstWhere((m) => m['name'] == selectedMetric);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historique récent',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D1D1F),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: List.generate(5, (index) {
                final random = math.Random(index);
                double value;
                if (selectedMetric == 'Tension') {
                  value = 110 + random.nextDouble() * 30;
                } else if (selectedMetric == 'Glycémie') {
                  value = 80 + random.nextDouble() * 40;
                } else if (selectedMetric == 'Fréquence') {
                  value = 60 + random.nextDouble() * 40;
                } else {
                  value = 36.5 + random.nextDouble() * 1.5;
                }
                
                final now = DateTime.now();
                final date = now.subtract(Duration(days: index));
                
                return _buildHistoryItem(
                  value.toStringAsFixed(1),
                  metric['unit'],
                  date,
                  metric['color'],
                  index < 4,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String value, String unit, DateTime date, Color color, bool showDivider) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final dateStr = isToday ? "Aujourd'hui" : "${date.day}/${date.month}/${date.year}";
    final timeStr = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.favorite,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D1D1F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D1D1F),
                  ),
                  children: [
                    TextSpan(
                      text: ' $unit',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8E8E93),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.grey[200], height: 1),
          ),
      ],
    );
  }

  void _showAddMeasureDialog() {
    final metric = metrics.firstWhere((m) => m['name'] == selectedMetric);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(metric['icon'], color: metric['color']),
            const SizedBox(width: 12),
            const Text('Nouvelle mesure'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${metric['name']} (${metric['unit']})',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(metric['icon'], color: metric['color']),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Note (optionnel)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.note),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Mesure enregistrée avec succès!');
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF34C759),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

// Custom painter pour le graphique en ligne
class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final Color color;

  LineChartPainter({
    required this.data,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final values = data.map((d) => d['value'] as double).toList();
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = maxValue - minValue;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (size.width / (data.length - 1)) * i;
      final value = data[i]['value'] as double;
      final y = size.height - ((value - minValue) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Dessiner les points
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    // Compléter le chemin de remplissage
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Dessiner le remplissage puis la ligne
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}