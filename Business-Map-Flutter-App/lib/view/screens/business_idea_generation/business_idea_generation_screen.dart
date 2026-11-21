import 'package:business_map/data/model/request/business_idea_suggestion_request.dart';
import 'package:business_map/data/model/response/business_type_model.dart';
import 'package:business_map/data/model/response/city_model.dart';
import 'package:business_map/data/model/response/target_area_model.dart';
import 'package:business_map/provider/business/business_idea_provider.dart';
import 'package:business_map/provider/input_options/input_options_provider.dart';
import 'package:business_map/utils/app_colors.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/images.dart';
import 'package:business_map/core/routes/routes_name.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/button/app_primary_button.dart';
import 'package:business_map/view/custom_widgets/loader/analysis_loader.dart';
import 'package:business_map/view/custom_widgets/state/suggestion_error_overlay.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../custom_widgets/dropdown/custom_dropdown.dart';
import '../../custom_widgets/slider/custom_budget_range_slider.dart';

class BusinessIdeaGenerationScreen extends StatefulWidget {
  const BusinessIdeaGenerationScreen({super.key});

  @override
  State<BusinessIdeaGenerationScreen> createState() =>
      _BusinessIdeaGenerationScreenState();
}

class _BusinessIdeaGenerationScreenState
    extends State<BusinessIdeaGenerationScreen> {
  final _formKey = GlobalKey<FormState>();

  BusinessTypeModel? _selectedType;
  RangeValues? _selectedBudgetRange;
  bool _includeBudget = true;
  CityModel? _selectedCity;
  TargetAreaModel? _selectedArea;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<InputOptionsProvider>();
      provider.getBusinessTypes();
      provider.getBudgets();
      provider.getCities().then((_) {
        if (!mounted) return;
        if (_selectedCity != null || provider.cities.isEmpty) return;

        final preferred = provider.cities
                .where((c) =>
                    c.id == 'isb' || c.name.toLowerCase() == 'islamabad')
                .firstOrNull ??
            provider.cities.first;
        _onCityChanged(preferred, provider);
      });
    });
  }

  void _onCityChanged(CityModel? city, InputOptionsProvider provider) {
    if (city == null) return;
    setState(() {
      _selectedCity = city;
      _selectedArea = null;
    });
    provider.getTargetAreas(city.id);
  }

  void _clearFields() {
    setState(() {
      _selectedType = null;
      _selectedBudgetRange = null;
      _selectedArea = null;
      _includeBudget = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.width(20)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        "Not sure what to start? Let us find the right business for you.",
                        style: AppTextStyles.tagline(
                          context,
                        ).copyWith(color: AppColors.colorOnLight),
                      ),
                    ),
                    Image.asset(
                      Images.businessIdeaGenImg,
                      width: SizeConfig.width(91),
                      height: SizeConfig.height(91),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.height(10)),
                Card(
                  margin: const EdgeInsets.all(0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.width(20),
                        vertical: SizeConfig.height(20),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Consumer<InputOptionsProvider>(
                          builder: (context, inputOptionsProvider, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Business Category',
                                  style: AppTextStyles.formLabel(context),
                                ),
                                SizedBox(height: SizeConfig.height(7)),
                                CustomDropdownField<BusinessTypeModel>(
                                  value: _selectedType,
                                  hintText: inputOptionsProvider
                                          .isBusinessTypesLoading
                                      ? "Loading categories..."
                                      : "Select Category",
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedType = value;
                                    });
                                  },
                                  validator: (value) => value == null
                                      ? "Please select a category"
                                      : null,
                                  items: inputOptionsProvider.businessTypes
                                      .map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type.name),
                                    );
                                  }).toList(),
                                  fillColor: AppColors.colorOnDark,
                                ),
                                SizedBox(height: SizeConfig.height(12)),
                                Text(
                                  'City',
                                  style: AppTextStyles.formLabel(context),
                                ),
                                SizedBox(height: SizeConfig.height(7)),
                                CustomDropdownField<CityModel>(
                                  value: _selectedCity,
                                  hintText:
                                      inputOptionsProvider.isCitiesLoading
                                          ? "Loading cities..."
                                          : "Select City",
                                  onChanged: (city) => _onCityChanged(
                                    city,
                                    inputOptionsProvider,
                                  ),
                                  validator: (value) => value == null
                                      ? "Please select a city"
                                      : null,
                                  items:
                                      inputOptionsProvider.cities.map((city) {
                                    return DropdownMenuItem(
                                      value: city,
                                      child: Text(city.name),
                                    );
                                  }).toList(),
                                  fillColor: AppColors.colorOnDark,
                                ),
                                SizedBox(height: SizeConfig.height(12)),
                                Text(
                                  'Target Area',
                                  style: AppTextStyles.formLabel(context),
                                ),
                                SizedBox(height: SizeConfig.height(7)),
                                CustomDropdownField<TargetAreaModel>(
                                  key: ValueKey(
                                    _selectedCity?.id ?? 'no-city',
                                  ),
                                  value: _selectedArea,
                                  hintText: _selectedCity == null
                                      ? "Select a city first"
                                      : inputOptionsProvider
                                              .isTargetAreasLoading
                                          ? "Loading areas..."
                                          : "Select Area",
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedArea = value;
                                    });
                                  },
                                  validator: (value) => value == null
                                      ? "Please select a target area"
                                      : null,
                                  items: inputOptionsProvider.targetAreas
                                      .map((area) {
                                    return DropdownMenuItem(
                                      value: area,
                                      child: Text(area.name),
                                    );
                                  }).toList(),
                                  fillColor: AppColors.colorOnDark,
                                ),
                                SizedBox(height: SizeConfig.height(12)),
                                CustomBudgetRangeSlider(
                                  values: _selectedBudgetRange,
                                  constraints:
                                      inputOptionsProvider.budgetConstraints,
                                  includeBudget: _includeBudget,
                                  showToggle: false,
                                  isLoading:
                                      inputOptionsProvider.isBudgetsLoading,
                                  onToggle: (value) {
                                    setState(() {
                                      _includeBudget = value ?? false;
                                    });
                                  },
                                  onChanged: (values) {
                                    setState(() {
                                      _selectedBudgetRange = values;
                                    });
                                  },
                                ),
                                SizedBox(height: SizeConfig.height(24)),
                                Selector<BusinessIdeaProvider, bool>(
                                  selector: (_, p) => p.isLoading,
                                  builder: (context, isLoading, _) {
                                    return AppPrimaryButton(
                                      text: "Suggest Business Idea",
                                      isLoading: isLoading,
                                      onPressed: () => _handleSubmission(
                                        context,
                                        context.read<BusinessIdeaProvider>(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Selector<BusinessIdeaProvider, (bool, String?)>(
          selector: (_, p) => (p.isLoading, p.streamMessage),
          builder: (context, state, _) {
            final (isLoading, message) = state;
            if (!isLoading) return const SizedBox.shrink();
            return AnalysisLoader(
              message: message,
              onCancel: () =>
                  context.read<BusinessIdeaProvider>().cancelStream(),
            );
          },
        ),
        Selector<BusinessIdeaProvider, String?>(
          selector: (_, p) => p.isLoading ? null : p.errorMessage,
          builder: (context, errorMessage, _) {
            if (errorMessage == null) return const SizedBox.shrink();
            final ideaProvider = context.read<BusinessIdeaProvider>();
            return SuggestionErrorOverlay(
              message: errorMessage,
              isRetrying: false,
              onRetry: () => _retrySubmission(ideaProvider),
              onDismiss: () => ideaProvider.clearError(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _navigateOnSuccess(BusinessIdeaProvider ideaProvider) async {
    if (!mounted || ideaProvider.errorMessage != null) return;
    if (ideaProvider.suggestionResponse == null) return;

    await Navigator.pushNamed(
      context,
      RoutesName.businessIdeaSuggestionsScreen,
    );
    if (!mounted) return;
    ideaProvider.stopLoading();
    _clearFields();
  }

  Future<void> _handleSubmission(
    BuildContext context,
    BusinessIdeaProvider ideaProvider,
  ) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final request = BusinessIdeaSuggestionRequest(
      businessTypeId: _selectedType?.id ?? '',
      minBudget: (_selectedBudgetRange?.start.round() ?? 0),
      maxBudget: (_selectedBudgetRange?.end.round() ?? 0),
      targetAreaId: _selectedArea?.id ?? '',
    );

    await ideaProvider.suggestBusinessIdeasStream(request);
    await _navigateOnSuccess(ideaProvider);
  }

  Future<void> _retrySubmission(BusinessIdeaProvider ideaProvider) async {
    await ideaProvider.retryLastSuggestion();
    await _navigateOnSuccess(ideaProvider);
  }
}
