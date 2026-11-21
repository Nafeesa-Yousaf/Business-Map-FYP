import 'dart:async';
import 'package:business_map/data/model/request/location_suggestion_request.dart';
import 'package:business_map/data/model/response/location_suggestion_response.dart';
import 'package:business_map/data/repository/location_repo.dart';
import 'package:business_map/core/error/app_exception_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class LocationProvider with ChangeNotifier {
  final LocationRepo locationRepo;
  final AppExceptionHandler appExceptionHandler;

  LocationProvider(this.locationRepo, this.appExceptionHandler);

  LocationSuggestionResponse? _suggestionResponse;
  LocationSuggestionResponse? get suggestionResponse => _suggestionResponse;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMsg;
  String? get errorMsg => _errorMsg;

  String? _streamMessage;
  String? get streamMessage => _streamMessage;

  LocationSuggestionRequest? _lastRequest;
  LocationSuggestionRequest? get lastRequest => _lastRequest;

  CancelToken? _streamCancelToken;
  bool _isCancelled = false;

  Future<bool> getSuggestionsStream(LocationSuggestionRequest request) async {
    cancelStream(notify: false);

    _lastRequest = request;
    _isCancelled = false;
    _streamCancelToken = CancelToken();
    _isLoading = true;
    _errorMsg = null;
    _streamMessage = "Initializing analysis...";
    _suggestionResponse = null;
    notifyListeners();

    try {
      await for (final event in locationRepo.suggestLocationsStream(
        request,
        cancelToken: _streamCancelToken,
      )) {
        if (_isCancelled) break;

        if (event['status'] == 'progress') {
          _streamMessage = event['message'];
          dev.log('STREAM PROGRESS: $_streamMessage');
          notifyListeners();
        } else if (event['status'] == 'success') {
          _suggestionResponse = LocationSuggestionResponse.fromJson(event);
          _streamMessage = event['message'];
          _errorMsg = null;
          dev.log(
            'STREAM SUCCESS: Found ${_suggestionResponse?.topLocations.length} locations',
          );
          notifyListeners();
        } else if (event['status'] == 'error') {
          _errorMsg = event['message'];
          dev.log('STREAM ERROR EVENT: $_errorMsg');
          notifyListeners();
          return false;
        }
      }
      return !_isCancelled && _suggestionResponse != null;
    } on DioException catch (e) {
      if (_isCancelled || e.type == DioExceptionType.cancel) {
        return false;
      }
      _errorMsg = appExceptionHandler.handleException(e);
      dev.log('STREAM ERROR: $_errorMsg');
      return false;
    } catch (e) {
      if (_isCancelled) return false;
      _errorMsg = appExceptionHandler.handleException(e);
      dev.log('STREAM ERROR: $_errorMsg');
      return false;
    } finally {
      _streamCancelToken = null;
      if (_isCancelled) {
        _isLoading = false;
        _streamMessage = null;
        notifyListeners();
      } else if (_suggestionResponse == null || _errorMsg != null) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> retryLastSuggestion() async {
    if (_lastRequest == null) return false;
    return getSuggestionsStream(_lastRequest!);
  }

  void clearError() {
    _errorMsg = null;
    notifyListeners();
  }

  /// Cancels an in-flight suggestion stream (e.g. user left the loader/tab).
  void cancelStream({bool notify = true}) {
    if (_streamCancelToken == null && !_isLoading) return;

    _isCancelled = true;
    if (_streamCancelToken != null && !_streamCancelToken!.isCancelled) {
      _streamCancelToken!.cancel('User left analysis loader');
    }
    _streamCancelToken = null;
    _isLoading = false;
    _streamMessage = null;
    if (notify) notifyListeners();
  }

  void stopLoading() {
    if (_isLoading && _streamCancelToken != null) {
      cancelStream();
      return;
    }
    _isLoading = false;
    notifyListeners();
  }

  void clearData() {
    cancelStream(notify: false);
    _suggestionResponse = null;
    _isLoading = false;
    _errorMsg = null;
    _streamMessage = null;
    _lastRequest = null;
    notifyListeners();
  }
}
