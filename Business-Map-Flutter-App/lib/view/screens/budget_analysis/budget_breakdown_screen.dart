import 'package:business_map/core/routes/route_args.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/price_converter.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/screens/budget_analysis/simple_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:business_map/view/custom_widgets/button/urdu_read_button.dart';
import 'package:business_map/provider/tts/tts_provider.dart';
import 'package:provider/provider.dart';

import '../../../data/model/response/location_suggestion_response.dart';

class BudgetBreakdownScreen extends StatefulWidget {
  const BudgetBreakdownScreen({super.key});

  @override
  State<BudgetBreakdownScreen> createState() => _BudgetBreakdownScreenState();
}

class _BudgetBreakdownScreenState extends State<BudgetBreakdownScreen> {
  TTSProvider? _ttsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ttsProvider = Provider.of<TTSProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _ttsProvider?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetAnalysis = RouteArgs.of<BudgetAnalysis>(context);
    if (budgetAnalysis == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Budget Breakdown')),
        body: const Center(child: Text('Invalid or missing budget data.')),
      );
    }

    final List<Color> palette = [
      Colors.blue[600]!,
      Colors.indigo[600]!,
      Colors.teal[600]!,
      Colors.purple[600]!,
      Colors.amber[700]!,
      Colors.cyan[600]!,
      Colors.deepOrange[600]!,
    ];

    final List<Map<String, dynamic>> chartData = budgetAnalysis.costBreakdown
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final item = entry.value;
          return {
            "title": item.categoryName,
            "amount": item.estimatedCost.toDouble(),
            "color": palette[index % palette.length],
          };
        })
        .toList();

    final bool hasStatus = budgetAnalysis.status != null && budgetAnalysis.status!.isNotEmpty;
    bool isWithinBudget = hasStatus &&
        budgetAnalysis.status!.toLowerCase().contains(
          "within",
        );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Budget Breakdown"),
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.width(20),
          vertical: SizeConfig.height(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalInvestmentCard(context, budgetAnalysis, isWithinBudget, hasStatus),

            SizedBox(height: SizeConfig.height(30)),
            Text(
              "Cost Breakdown",
              style: AppTextStyles.headingMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SimplePieChart(data: chartData),
            ),

            SizedBox(height: SizeConfig.height(30)),

            Text(
              "Detailed Breakdown",
              style: AppTextStyles.headingMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ...budgetAnalysis.costBreakdown.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildExpenseTile(
                context,
                item,
                palette[index % palette.length],
                budgetAnalysis.totalEstimatedBudget,
              );
            }).toList(),

            SizedBox(height: SizeConfig.height(35)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Cost Optimization Tips",
                    softWrap: true,
                    style: AppTextStyles.headingMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                ),
                SizedBox(width: SizeConfig.width(10)),
                UrduReadButton(
                  text: budgetAnalysis.optimizationTips.join('. '),
                  sectionId: 'cost_optimization',
                  title: 'Cost Optimization Tips',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildOptimizationTips(budgetAnalysis.optimizationTips),

            SizedBox(height: SizeConfig.height(20)),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalInvestmentCard(
    BuildContext context,
    BudgetAnalysis analysis,
    bool isWithin,
    bool hasStatus,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: !hasStatus
              ? [const Color(0xFF0D47A1), const Color(0xFF1565C0)]
              : isWithin
              ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
              : [const Color(0xFFC62828), const Color(0xFFD32F2F)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (!hasStatus ? Colors.blue : isWithin ? Colors.green : Colors.red).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
                "EST. TOTAL INVESTMENT",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  !hasStatus
                      ? "GENERAL ESTIMATE"
                      : isWithin
                      ? "WITHIN BUDGET"
                      : "EXCEEDS BUDGET",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            PriceConverter.format(analysis.totalEstimatedBudget),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "PKR",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseTile(
    BuildContext context,
    CostBreakdown item,
    Color color,
    num total,
  ) {
    double percentage = (item.estimatedCost / total) * 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.categoryName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${percentage.toStringAsFixed(1)}% of total",
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(
                PriceConverter.format(item.estimatedCost),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizationTips(List<String> tips) {
    return Column(
      children: tips
          .map(
            (tip) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withOpacity(0.05)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 18,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
