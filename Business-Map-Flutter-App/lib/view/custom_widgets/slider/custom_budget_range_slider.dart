import 'package:business_map/data/model/response/budget_model.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:business_map/view/custom_widgets/text/section_label.dart';
import '../../../utils/price_converter.dart';

class CustomBudgetRangeSlider extends StatelessWidget {
  final RangeValues? values;
  final BudgetModel? constraints;
  final void Function(RangeValues) onChanged;
  final bool includeBudget;
  final void Function(bool?) onToggle;
  final bool isLoading;
  final String toggleMessage;
  final bool showToggle;

  const CustomBudgetRangeSlider({
    super.key,
    required this.values,
    required this.constraints,
    required this.onChanged,
    required this.includeBudget,
    required this.onToggle,
    this.isLoading = false,
    this.toggleMessage = 'Tailor results to fit your investment range',
    this.showToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool shouldShowSlider = !showToggle || includeBudget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showToggle)
          Padding(
            padding: EdgeInsets.only(bottom: SizeConfig.height(16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: includeBudget,
                    activeColor: theme.primaryColor,
                    onChanged: (val) => onToggle(val),
                  ),
                ),
                SizedBox(width: SizeConfig.width(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Budget Constraint",
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        toggleMessage,
                        style: AppTextStyles.formLabel(context).copyWith(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        if (shouldShowSlider && constraints != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                flex: 2,
                child: SectionLabel(label: 'Budget Range', bottomPadding: 0),
              ),
              Flexible(
                flex: 3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: theme.primaryColor.withOpacity(0.2)),
                  ),
                  child: Text(
                    '${PriceConverter.format(values?.start.toInt() ?? constraints!.minLimit)} - ${PriceConverter.format(values?.end.toInt() ?? constraints!.maxLimit)} ${constraints!.currency}',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: SizeConfig.height(12)),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: theme.primaryColor,
              inactiveTrackColor: theme.primaryColor.withOpacity(0.1),
              trackHeight: 6.0,
              rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
              
              thumbColor: Colors.white,
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 10,
                elevation: 4,
                pressedElevation: 8,
              ),
              
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2),
              activeTickMarkColor: Colors.white.withOpacity(0.5),
              inactiveTickMarkColor: theme.primaryColor.withOpacity(0.3),
              
              overlayColor: theme.primaryColor.withOpacity(0.12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: RangeSlider(
              values: values ??
                  RangeValues(
                    constraints!.minLimit.toDouble(),
                    constraints!.maxLimit.toDouble(),
                  ),
              min: constraints!.minLimit.toDouble(),
              max: constraints!.maxLimit.toDouble(),
              divisions: (constraints!.maxLimit - constraints!.minLimit) ~/
                  constraints!.interval,
              onChanged: (newValues) {
                if (newValues.end - newValues.start >= constraints!.interval) {
                  onChanged(newValues);
                }
              },
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.width(4)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  PriceConverter.format(constraints!.minLimit),
                  style: AppTextStyles.formLabel(context).copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  PriceConverter.format(constraints!.maxLimit),
                  style: AppTextStyles.formLabel(context).copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ] else if (shouldShowSlider && isLoading) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: SizeConfig.height(20)),
            child: const Center(child: CupertinoActivityIndicator()),
          ),
        ],
      ],
    );
  }
}
