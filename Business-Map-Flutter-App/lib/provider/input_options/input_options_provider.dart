import 'package:business_map/data/model/response/business_type_model.dart';
import 'package:business_map/data/model/response/city_model.dart';
import 'package:business_map/data/model/response/budget_model.dart';
import 'package:business_map/data/model/response/target_area_model.dart';
import 'package:business_map/data/repository/input_options_repo.dart';
import 'package:flutter/material.dart';
import 'package:business_map/core/error/app_exception_handler.dart';

class InputOptionsProvider with ChangeNotifier {
  final InputOptionsRepo inputOptionsRepo;
  final AppExceptionHandler appExceptionHandler;

  InputOptionsProvider(this.inputOptionsRepo, this.appExceptionHandler);

  List<BusinessTypeModel> _businessTypes = [];
  List<BusinessTypeModel> get businessTypes => _businessTypes;

  List<CityModel> _cities = [];
  List<CityModel> get cities => _cities;

  BudgetModel? _budgetConstraints;
  BudgetModel? get budgetConstraints => _budgetConstraints;

  List<TargetAreaModel> _targetAreas = [];
  List<TargetAreaModel> get targetAreas => _targetAreas;

  bool _isBusinessTypesLoading = false;
  bool get isBusinessTypesLoading => _isBusinessTypesLoading;

  bool _isCitiesLoading = false;
  bool get isCitiesLoading => _isCitiesLoading;

  bool _isBudgetsLoading = false;
  bool get isBudgetsLoading => _isBudgetsLoading;

  bool _isTargetAreasLoading = false;
  bool get isTargetAreasLoading => _isTargetAreasLoading;

  bool get isLoading =>
      _isBusinessTypesLoading ||
      _isCitiesLoading ||
      _isBudgetsLoading ||
      _isTargetAreasLoading;

  String? _errorMsg;
  String? get errorMsg => _errorMsg;

  Future<void> getBusinessTypes() async {
    if (_businessTypes.isNotEmpty || _isBusinessTypesLoading) return;

    _isBusinessTypesLoading = true;
    _errorMsg = null;
    notifyListeners();

    try {
      final response = await inputOptionsRepo.getBusinessTypes();
      if (response.success && response.data != null) {
        _businessTypes = response.data!;
      } else {
        _errorMsg = response.message;
      }
    } catch (e) {
      _errorMsg = appExceptionHandler.handleException(e);
    } finally {
      _isBusinessTypesLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCities() async {
    if (_cities.isNotEmpty || _isCitiesLoading) {
      debugPrint('Cities already loaded, skipping fetch.');
      return;
    }

    debugPrint('Starting to fetch cities...');
    _isCitiesLoading = true;
    _errorMsg = null;
    notifyListeners();

    try {
      final response = await inputOptionsRepo.getCities();
      if (response.success && response.data != null) {
        _cities = response.data!;
        debugPrint('Cities fetch completed. Count: ${_cities.length}');
      } else {
        _errorMsg = response.message;
        debugPrint('Cities fetch failed in repo: ${response.message}');
      }
    } catch (e) {
      debugPrint('Cities fetch failed: $e');
      _errorMsg = 'Error loading cities: $e';
    } finally {
      _isCitiesLoading = false;
      debugPrint('isCitiesLoading set to false');
      notifyListeners();
    }
  }

  Future<void> getBudgets() async {
    if (_budgetConstraints != null || _isBudgetsLoading) return;

    _isBudgetsLoading = true;
    _errorMsg = null;
    notifyListeners();

    try {
      final response = await inputOptionsRepo.getBudgets();
      if (response.success && response.data != null) {
        _budgetConstraints = response.data!;
      } else {
        _errorMsg = response.message;
      }
    } catch (e) {
      _errorMsg = 'Error loading budgets: $e';
    } finally {
      _isBudgetsLoading = false;
      notifyListeners();
    }
  }

  String? _lastFetchedCityId;
  String? get lastFetchedCityId => _lastFetchedCityId;

  Future<void> getTargetAreas(String cityId) async {
    if (cityId.isEmpty) return;
    if (_lastFetchedCityId == cityId &&
        (_targetAreas.isNotEmpty || _isTargetAreasLoading)) {
      return;
    }

    _lastFetchedCityId = cityId;
    _targetAreas = [];
    _isTargetAreasLoading = true;
    _errorMsg = null;
    notifyListeners();

    try {
      final response = await inputOptionsRepo.getTargetAreas(cityId);
      // Ignore stale responses if the user switched cities mid-request.
      if (_lastFetchedCityId != cityId) return;

      if (response.success && response.data != null) {
        _targetAreas = response.data!;
      } else {
        _errorMsg = response.message;
      }
    } catch (e) {
      if (_lastFetchedCityId != cityId) return;
      _errorMsg = 'Error loading target areas: $e';
    } finally {
      if (_lastFetchedCityId == cityId) {
        _isTargetAreasLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchAllHomeData({String? cityId}) async {
    await Future.wait([
      getBusinessTypes(),
      getBudgets(),
      getCities(),
    ]);

    final resolvedCityId = cityId ??
        (_cities.isNotEmpty
            ? (_cities
                    .where((c) => c.id == 'isb' || c.name.toLowerCase() == 'islamabad')
                    .map((c) => c.id)
                    .firstOrNull ??
                _cities.first.id)
            : null);

    if (resolvedCityId != null) {
      await getTargetAreas(resolvedCityId);
    }

    if (_errorMsg != null) {
      throw Exception(_errorMsg);
    }
  }

  void clearData() {
    _businessTypes = [];
    _cities = [];
    _budgetConstraints = null;
    _targetAreas = [];
    _isBusinessTypesLoading = false;
    _isCitiesLoading = false;
    _isBudgetsLoading = false;
    _isTargetAreasLoading = false;
    _errorMsg = null;
    _lastFetchedCityId = null;
    notifyListeners();
  }
}
