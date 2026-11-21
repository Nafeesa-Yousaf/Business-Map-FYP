import 'package:business_map/data/model/response/business_type_model.dart';
import 'package:business_map/data/model/response/city_model.dart';
import 'package:business_map/data/model/response/target_area_model.dart';
import 'package:business_map/data/model/request/location_suggestion_request.dart';
import 'package:business_map/provider/input_options/input_options_provider.dart';
import 'package:business_map/provider/location/location_provider.dart';
import 'package:business_map/view/custom_widgets/loader/analysis_loader.dart';
import 'package:business_map/view/custom_widgets/state/suggestion_error_overlay.dart';
import 'package:business_map/utils/app_colors.dart';
import 'package:business_map/utils/app_text_style.dart';
import 'package:business_map/utils/images.dart';
import 'package:business_map/core/routes/routes_name.dart';
import 'package:business_map/utils/size_config.dart';
import 'package:business_map/view/custom_widgets/button/app_primary_button.dart';
import 'package:business_map/view/custom_widgets/textfield/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../custom_widgets/dropdown/custom_dropdown.dart';
import '../../custom_widgets/slider/custom_budget_range_slider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _businessDescriptionController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  BusinessTypeModel? _selectedType;
  SubtypeModel? _selectedSubtype;
  RangeValues? _selectedBudgetRange;
  bool _includeBudget = false;
  CityModel? _selectedCity;
  TargetAreaModel? _selectedArea;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureCitiesAndDefaultSelection();
    });
  }

  void _ensureCitiesAndDefaultSelection() {
    final provider = context.read<InputOptionsProvider>();
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
      _selectedSubtype = null;
      _businessDescriptionController.clear();
      _selectedBudgetRange = null;
      _includeBudget = false;
      _selectedArea = null;
    });
  }

  @override
  void dispose() {
    _businessDescriptionController.dispose();
    super.dispose();
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
                        "Looking To Start a Business? Let Us Help You Find The Best Location",
                        style: AppTextStyles.tagline(
                          context,
                        ).copyWith(color: AppColors.colorOnLight),
                      ),
                    ),
                    Image.asset(
                      Images.shop,
                      width: SizeConfig.width(91),
                      height: SizeConfig.height(91),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.height(10)),
                Card(
                  margin: EdgeInsets.zero,
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
                                'Business Type',
                                style: AppTextStyles.formLabel(context),
                              ),
                              SizedBox(height: SizeConfig.height(7)),
                              CustomDropdownField<BusinessTypeModel>(
                                value: _selectedType,
                                hintText: inputOptionsProvider
                                        .isBusinessTypesLoading
                                    ? "Loading..."
                                    : "Select Business Type",
                                onChanged: (value) {
                                  setState(() {
                                    _selectedType = value;
                                    _selectedSubtype = null;
                                  });
                                },
                                validator: (value) => value == null
                                    ? "Please select business type"
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
                              if (_selectedType != null) ...[
                                Text(
                                  'Business Subtype',
                                  style: AppTextStyles.formLabel(context),
                                ),
                                SizedBox(height: SizeConfig.height(7)),
                                CustomDropdownField<SubtypeModel>(
                                  key: ValueKey(_selectedType?.id),
                                  value: _selectedSubtype,
                                  hintText: "Select Subtype",
                                  onChanged: (value) => setState(
                                    () => _selectedSubtype = value,
                                  ),
                                  validator: (value) => value == null
                                      ? "Please select subtype"
                                      : null,
                                  items: (_selectedType?.subTypes ?? [])
                                      .map((subtype) {
                                    return DropdownMenuItem(
                                      value: subtype,
                                      child: Text(subtype.name),
                                    );
                                  }).toList(),
                                  fillColor: AppColors.colorOnDark,
                                ),
                                SizedBox(height: SizeConfig.height(12)),
                              ],
                              Text(
                                'Business Description',
                                style: AppTextStyles.formLabel(context),
                              ),
                              SizedBox(height: SizeConfig.height(7)),
                              CustomTextField(
                                controller: _businessDescriptionController,
                                hintText: "Enter your Business Details",
                                maxLines: 3,
                                fillColor: AppColors.colorOnDark,
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                        ? "Please enter business description"
                                        : null,
                              ),
                              SizedBox(height: SizeConfig.height(12)),
                              Text(
                                'City',
                                style: AppTextStyles.formLabel(context),
                              ),
                              SizedBox(height: SizeConfig.height(7)),
                              CustomDropdownField<CityModel>(
                                value: _selectedCity,
                                hintText: inputOptionsProvider.isCitiesLoading
                                    ? "Loading cities..."
                                    : "Select City",
                                onChanged: (city) =>
                                    _onCityChanged(city, inputOptionsProvider),
                                validator: (value) => value == null
                                    ? "Please select a city"
                                    : null,
                                items: inputOptionsProvider.cities.map((city) {
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
                                key: ValueKey(_selectedCity?.id ?? 'no-city'),
                                value: _selectedArea,
                                hintText: _selectedCity == null
                                    ? "Select a city first"
                                    : inputOptionsProvider.isTargetAreasLoading
                                        ? "Loading..."
                                        : "Select Area",
                                onChanged: (value) =>
                                    setState(() => _selectedArea = value),
                                validator: (value) => value == null
                                    ? "Please select target area"
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
                                isLoading:
                                    inputOptionsProvider.isBudgetsLoading,
                                onToggle: (value) => setState(
                                  () => _includeBudget = value ?? false,
                                ),
                                onChanged: (values) => setState(
                                  () => _selectedBudgetRange = values,
                                ),
                              ),
                              SizedBox(height: SizeConfig.height(18)),
                              Selector<LocationProvider, bool>(
                                selector: (_, p) => p.isLoading,
                                builder: (context, isLoading, _) {
                                  return AppPrimaryButton(
                                    text: "Find Best Location",
                                    isLoading: isLoading,
                                    onPressed: () => _handleSubmission(
                                      context,
                                      context.read<LocationProvider>(),
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
              ],
            ),
          ),
        ),
        // Progress messages only rebuild the overlay, not the form tree.
        Selector<LocationProvider, (bool, String?)>(
          selector: (_, p) => (p.isLoading, p.streamMessage),
          builder: (context, state, _) {
            final (isLoading, message) = state;
            if (!isLoading) return const SizedBox.shrink();
            return AnalysisLoader(
              message: message,
              onCancel: () => context.read<LocationProvider>().cancelStream(),
            );
          },
        ),
        Selector<LocationProvider, String?>(
          selector: (_, p) => p.isLoading ? null : p.errorMsg,
          builder: (context, errorMsg, _) {
            if (errorMsg == null) return const SizedBox.shrink();
            final locationProvider = context.read<LocationProvider>();
            return SuggestionErrorOverlay(
              message: errorMsg,
              isRetrying: false,
              onRetry: () => _retrySubmission(locationProvider),
              onDismiss: () => locationProvider.clearError(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _navigateOnSuccess(
    LocationProvider locationProvider,
    bool success,
  ) async {
    if (!success || !mounted) return;
    await Navigator.pushNamed(context, RoutesName.locationSuggestionScreen);
    if (!mounted) return;
    locationProvider.stopLoading();
    _clearFields();
  }

  Future<void> _handleSubmission(
    BuildContext context,
    LocationProvider locationProvider,
  ) async {
    if (_formKey.currentState?.validate() ?? false) {
      final request = LocationSuggestionRequest(
        businessTypeId: _selectedType?.id ?? '',
        subTypeId: _selectedSubtype?.id ?? '',
        businessDescription: _businessDescriptionController.text,
        minBudget: _includeBudget
            ? (_selectedBudgetRange?.start.round() ?? 0)
            : null,
        maxBudget: _includeBudget
            ? (_selectedBudgetRange?.end.round() ?? 0)
            : null,
        targetAreaId: _selectedArea?.id ?? '',
        isPrioritizeBudget: _includeBudget,
      );

      final success = await locationProvider.getSuggestionsStream(request);
      await _navigateOnSuccess(locationProvider, success);
    }
  }

  Future<void> _retrySubmission(LocationProvider locationProvider) async {
    final success = await locationProvider.retryLastSuggestion();
    await _navigateOnSuccess(locationProvider, success);
  }
}
