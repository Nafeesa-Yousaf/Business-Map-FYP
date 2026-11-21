import 'package:business_map/utils/price_converter.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SimplePieChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const SimplePieChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final double total = data.fold(
      0,
          (sum, item) => sum + (item['amount'] as double),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height:  SizeConfig.height(220),
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 40,
              sectionsSpace: 3,
              sections: data.map((item) {
                final amount = item['amount'] as double;
                final percentage = (amount / total) * 100;

                return PieChartSectionData(
                  value: amount,
                  color: item['color'] as Color,
                  radius:  SizeConfig.width(60),
                  title: "${percentage.toStringAsFixed(1)}%",
                  titleStyle:  TextStyle(
                    color: Colors.white,
                    fontSize:  SizeConfig.text(12),
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
         SizedBox(height:  SizeConfig.height(16),),

        ...data.map((item) {
          return Padding(
            padding:  EdgeInsets.only(bottom:  SizeConfig.height(8),),
            child: Row(
              children: [
                Container(
                  width: SizeConfig.width(12),
                  height:  SizeConfig.width(12),
                  decoration: BoxDecoration(
                    color: item['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                 SizedBox(width: SizeConfig.width(8)),
                Expanded(
                  child: Text(item['title']),
                )
              ],
            ),
          );
        }),
      ],
    );
  }
}
