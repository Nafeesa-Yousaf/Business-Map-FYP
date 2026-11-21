import 'package:business_map/data/model/request/business_idea_suggestion_request.dart';
import 'package:business_map/data/model/response/business_idea_suggestion_response.dart';
import 'package:business_map/data/repository/business_idea_repo.dart';
import 'package:business_map/core/error/app_exception_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class BusinessIdeaProvider with ChangeNotifier {
  final BusinessIdeaRepo businessIdeaRepo;
  final AppExceptionHandler appExceptionHandler;

  BusinessIdeaProvider({
    required this.businessIdeaRepo,
    required this.appExceptionHandler,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  BusinessIdeaSuggestionResponse? _suggestionResponse;
  BusinessIdeaSuggestionResponse? get suggestionResponse => _suggestionResponse;

  List<BusinessIdea> get suggestedIdeas =>
      _suggestionResponse?.businessIdeas ?? [];

  String? _streamMessage;
  String? get streamMessage => _streamMessage;

  BusinessIdeaSuggestionRequest? _lastRequest;
  BusinessIdeaSuggestionRequest? get lastRequest => _lastRequest;

  CancelToken? _streamCancelToken;
  bool _isCancelled = false;

  Future<void> suggestBusinessIdeas(
    BusinessIdeaSuggestionRequest request,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await businessIdeaRepo.suggestBusinessIdeas(request);

    if (result.success) {
      _suggestionResponse = result.data;
    } else {
      _errorMessage = result.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> suggestBusinessIdeasStream(
    BusinessIdeaSuggestionRequest request,
  ) async {
    cancelStream(notify: false);

    _lastRequest = request;
    _isCancelled = false;
    _streamCancelToken = CancelToken();
    _isLoading = true;
    _errorMessage = null;
    _streamMessage = "Initializing...";
    _suggestionResponse = null;
    notifyListeners();

    try {
      await for (final event in businessIdeaRepo.suggestBusinessIdeasStream(
        request,
        cancelToken: _streamCancelToken,
      )) {
        if (_isCancelled) break;

        if (event['status'] == 'progress') {
          _streamMessage = event['message'];
          notifyListeners();
        } else if (event['status'] == 'success') {
          _suggestionResponse = BusinessIdeaSuggestionResponse.fromJson(event);
          _streamMessage = null;
          _errorMessage = null;
          notifyListeners();
        } else if (event['status'] == 'error') {
          _errorMessage = event['message'];
        }
      }
    } on DioException catch (e) {
      if (!_isCancelled && e.type != DioExceptionType.cancel) {
        _errorMessage = appExceptionHandler.handleException(e);
      }
    } catch (e) {
      if (!_isCancelled) {
        _errorMessage = appExceptionHandler.handleException(e);
      }
    } finally {
      _streamCancelToken = null;
      if (_isCancelled) {
        _isLoading = false;
        _streamMessage = null;
        notifyListeners();
      } else if (_suggestionResponse == null || _errorMessage != null) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> retryLastSuggestion() async {
    if (_lastRequest == null) return;
    await suggestBusinessIdeasStream(_lastRequest!);
  }

  void clearError() {
    _errorMessage = null;
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
    _errorMessage = null;
    _streamMessage = null;
    _lastRequest = null;
    notifyListeners();
  }
}
