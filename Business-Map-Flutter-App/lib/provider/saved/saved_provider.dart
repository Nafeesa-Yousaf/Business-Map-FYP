import 'dart:async';
import 'package:business_map/data/model/response/business_idea_suggestion_response.dart';
import 'package:business_map/data/model/response/location_suggestion_response.dart';
import 'package:business_map/data/repository/saved_repo.dart';
import 'package:flutter/material.dart';
import 'package:business_map/core/error/app_exception_handler.dart';

class SavedProvider with ChangeNotifier {
  final SavedRepo _savedRepo;
  final AppExceptionHandler _appExceptionHandler;

  SavedProvider(this._savedRepo, this._appExceptionHandler);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isToggling = false;
  bool _locationsLoaded = false;
  bool _ideasLoaded = false;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<TopLocation> _savedLocations = [];
  List<TopLocation> get savedLocations => _savedLocations;
  StreamSubscription? _locationSubscription;
  final Set<String> _selectedLocationIds = {};
  Set<String> get selectedLocationIds => _selectedLocationIds;
  bool _isLocSelectionMode = false;
  bool get isLocSelectionMode => _isLocSelectionMode;

  List<BusinessIdea> _savedIdeas = [];
  List<BusinessIdea> get savedIdeas => _savedIdeas;
  StreamSubscription? _ideaSubscription;
  final Set<String> _selectedIdeaIds = {};
  Set<String> get selectedIdeaIds => _selectedIdeaIds;
  bool _isIdeaSelectionMode = false;
  bool get isIdeaSelectionMode => _isIdeaSelectionMode;

  bool _isSaved = false;
  bool get isCurrentItemSaved => _isSaved;

  void _syncLoadingState() {
    if (_locationsLoaded && _ideasLoaded && !_isToggling) {
      _isLoading = false;
    }
    notifyListeners();
  }

  void initListeners() {
    if (_locationSubscription != null && _ideaSubscription != null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _locationSubscription ??= _savedRepo.getSavedLocationsStream().listen(
      (locations) {
        locations.sort((a, b) {
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        _savedLocations = locations;
        _locationsLoaded = true;
        _errorMessage = null;
        _syncLoadingState();
      },
      onError: (e) {
        _errorMessage = _appExceptionHandler.handleException(e);
        _locationsLoaded = true;
        _syncLoadingState();
      },
    );

    _ideaSubscription ??= _savedRepo.getSavedIdeasStream().listen(
      (ideas) {
        ideas.sort((a, b) {
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        _savedIdeas = ideas;
        _ideasLoaded = true;
        _errorMessage = null;
        _syncLoadingState();
      },
      onError: (e) {
        _errorMessage = _appExceptionHandler.handleException(e);
        _ideasLoaded = true;
        _syncLoadingState();
      },
    );
  }

  void retryListeners() {
    stopListeners();
    _locationsLoaded = false;
    _ideasLoaded = false;
    _savedLocations = [];
    _savedIdeas = [];
    initListeners();
  }


  void toggleLocationSelection(String id) {
    if (_selectedLocationIds.contains(id)) {
      _selectedLocationIds.remove(id);
      if (_selectedLocationIds.isEmpty) _isLocSelectionMode = false;
    } else {
      _selectedLocationIds.add(id);
      _isLocSelectionMode = true;
    }
    notifyListeners();
  }

  void toggleIdeaSelection(String id) {
    if (_selectedIdeaIds.contains(id)) {
      _selectedIdeaIds.remove(id);
      if (_selectedIdeaIds.isEmpty) _isIdeaSelectionMode = false;
    } else {
      _selectedIdeaIds.add(id);
      _isIdeaSelectionMode = true;
    }
    notifyListeners();
  }

  void clearSelection(bool isLocationTab) {
    if (isLocationTab) {
      _selectedLocationIds.clear();
      _isLocSelectionMode = false;
    } else {
      _selectedIdeaIds.clear();
      _isIdeaSelectionMode = false;
    }
    notifyListeners();
  }

  Future<bool> deleteSelected(bool isLocationTab) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (isLocationTab) {
        final ids = _selectedLocationIds.toList();
        final res = await _savedRepo.deleteMultipleItems(ids, true);
        if (res.success) {
          _selectedLocationIds.clear();
          _isLocSelectionMode = false;
        }
        return res.success;
      } else {
        final ids = _selectedIdeaIds.toList();
        final res = await _savedRepo.deleteMultipleItems(ids, false);
        if (res.success) {
          _selectedIdeaIds.clear();
          _isIdeaSelectionMode = false;
        }
        return res.success;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkSavedStatus(String name, bool isLocation) async {
    _isSaved = await _savedRepo.isItemSaved(name, isLocation);
    notifyListeners();
  }

  Future<bool> toggleSaveLocation(TopLocation location) async {
    _isLoading = true;
    _isToggling = true;
    notifyListeners();

    try {
      if (_isSaved) {
        final res = await _savedRepo.unsaveItem(location.locationName, true);
        if (res.success) _isSaved = false;
        return res.success;
      } else {
        final res = await _savedRepo.saveLocation(location);
        if (res.success) _isSaved = true;
        return res.success;
      }
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      _isToggling = false;
      notifyListeners();
    }
  }

  Future<bool> toggleSaveIdea(BusinessIdea idea, {String? category, String? area}) async {
    _isLoading = true;
    _isToggling = true;
    notifyListeners();

    try {
      if (_isSaved) {
        final res = await _savedRepo.unsaveItem(idea.businessName, false);
        if (res.success) _isSaved = false;
        return res.success;
      } else {
        final res = await _savedRepo.saveIdea(idea, category: category, area: area);
        if (res.success) _isSaved = true;
        return res.success;
      }
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      _isToggling = false;
      notifyListeners();
    }
  }

  void stopListeners() {
    _locationSubscription?.cancel();
    _ideaSubscription?.cancel();
    _locationSubscription = null;
    _ideaSubscription = null;
  }

  void clearData() {
    stopListeners();
    _savedLocations = [];
    _savedIdeas = [];
    _selectedLocationIds.clear();
    _selectedIdeaIds.clear();
    _isLocSelectionMode = false;
    _isIdeaSelectionMode = false;
    _isSaved = false;
    _locationsLoaded = false;
    _ideasLoaded = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
