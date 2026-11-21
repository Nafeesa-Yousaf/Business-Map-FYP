import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppExceptionHandler {
  String handleException(dynamic error) {
    log("==========>Error: ${_safeErrorLog(error)}");

    String message;
    if (error is DioException) {
      message = _getDioErrorMessage(error);
    } else if (error is FirebaseAuthException) {
      message = _mapFirebaseAuthError(error.code);
    } else if (error is FirebaseException) {
      message = _mapFirebaseGeneralError(error.code);
    } else if (error is SocketException) {
      message = 'Network error. Please check your internet connection.';
    } else if (error is TimeoutException) {
      message = 'The request took too long. Please try again.';
    } else if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
    } else {
      message = 'An unexpected error occurred.';
    }

    return _normalizeTechnicalError(message);
  }

  String _getDioErrorMessage(DioException error) {
    String errorDescription = "";

    switch (error.type) {
      case DioExceptionType.cancel:
        errorDescription = "The request was cancelled.";
        break;
      case DioExceptionType.connectionTimeout:
        errorDescription = "Connection timed out. Please check your internet and try again.";
        break;
      case DioExceptionType.unknown:
        errorDescription = "Failed to connect to the server. Please verify your internet connection.";
        break;
      case DioExceptionType.receiveTimeout:
        errorDescription = "Server is taking too long to respond. Please try again later.";
        break;
      case DioExceptionType.badResponse:
        final responseData = error.response?.data;
        switch (error.response?.statusCode) {
          case 400:
          case 404:
          case 422:
          case 500:
            errorDescription = _extractDetailMessage(responseData);
            break;
          case 401:
            errorDescription = "Session expired. Please log in again.";
            break;
          case 403:
            errorDescription = _extractDetailMessage(responseData);
            break;
          case 413:
            errorDescription = _extractDetailMessage(responseData);
            break;
          case 429:
            errorDescription = _extractDetailMessage(responseData);
            break;
          case 503:
            errorDescription = _extractDetailMessage(responseData);
            break;
          default:
            errorDescription = _extractDetailMessage(responseData);
        }
        break;
      case DioExceptionType.sendTimeout:
        errorDescription = "Failed to send data to the server. Please try again.";
        break;
      case DioExceptionType.badCertificate:
        errorDescription = "Secure connection failed. Please try again.";
        break;
      case DioExceptionType.connectionError:
        errorDescription = "No internet connection detected. Please check your network.";
        break;
    }

    return _normalizeTechnicalError(errorDescription);
  }

  String _extractDetailMessage(dynamic data) {
    if (data == null || data is! Map) {
      return "Something went wrong on our end. Please try again.";
    }

    // Backend stable shape: { code, message, correlation_id, details? }
    final message = data['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message.trim();
    }

    final detail = data['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail.trim();
    }
    if (detail is List) {
      try {
        final errors = <String>[];
        for (final e in detail) {
          if (e is Map) {
            final msg = e['msg'] ?? 'Required';
            final loc = e['loc'] as List?;
            if (loc != null && loc.isNotEmpty) {
              final field = loc.last.toString().replaceAll('_', ' ');
              final fieldDisplay = field[0].toUpperCase() + field.substring(1);
              errors.add("$fieldDisplay: $msg");
            } else {
              errors.add(msg.toString());
            }
          }
        }
        if (errors.isNotEmpty) return errors.join("\n");
      } catch (_) {
        return "Please verify the information you provided.";
      }
    }

    // FastAPI validation details nested under our error schema
    final details = data['details'];
    if (details is List && details.isNotEmpty) {
      try {
        final errors = <String>[];
        for (final e in details) {
          if (e is Map) {
            final msg = e['msg'] ?? 'Invalid value';
            final loc = e['loc'] as List?;
            if (loc != null && loc.isNotEmpty) {
              final field = loc.last.toString().replaceAll('_', ' ');
              final fieldDisplay = field[0].toUpperCase() + field.substring(1);
              errors.add("$fieldDisplay: $msg");
            } else {
              errors.add(msg.toString());
            }
          }
        }
        if (errors.isNotEmpty) return errors.join("\n");
      } catch (_) {
        // fall through
      }
    }

    final msg = data['msg'];
    if (msg is String && msg.trim().isNotEmpty) return msg.trim();

    return "An unexpected error occurred. Please try again later.";
  }

  String _normalizeTechnicalError(String message) {
    final technicalMap = {
      'REQUEST_DENIED': 'Mapping services are temporarily unavailable. We are working on a fix!',
      'API_KEY_INVALID': 'System configuration error. Please contact support.',
      'OVER_QUERY_LIMIT': 'System is busy due to high traffic. Please try again in a few minutes.',
      'ZERO_RESULTS': 'No exact matches found for your criteria. Try adjusting your filters.',
      'FAILED_PRECONDITION': 'This specific request or location is not currently supported.',
      'Internal Server Error': 'Our servers are having trouble processing this request. Please try again later.',
      'Traceback': 'An internal error occurred. Our team has been notified.',
      'Google Places Error': 'Location data is currently unavailable. Please try again in a moment.',
      'unauthorized': 'Your session has expired. Please log in again.',
      'forbidden': 'You do not have permission to access this resource.',
    };

    for (var entry in technicalMap.entries) {
      if (message.contains(entry.key)) {
        return entry.value;
      }
    }

    if (message.length > 150 || message.contains('Error: ') || message.contains('Exception: ')) {
      return 'Something went wrong while processing your request. Please try again.';
    }

    return message;
  }

  static String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many login attempts. Try again later.';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'requires-recent-login':
        return 'For security, please sign in again and retry.';
      case 'user-mismatch':
        return 'Please authenticate with the same account.';
      case 'no-current-user':
        return 'Please sign in again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  static String _mapFirebaseGeneralError(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'unavailable':
        return 'Service is temporarily unavailable. Try again later.';
      case 'not-found':
        return 'Requested document or file not found.';
      case 'cancelled':
        return 'The operation was cancelled.';
      default:
        return 'A Firebase error occurred: $code';
    }
  }

  static String _safeErrorLog(dynamic error) {
    var text = error.toString();
    text = text.replaceAll(
      RegExp(r'Bearer\s+[A-Za-z0-9\-._~+/]+=*', caseSensitive: false),
      'Bearer ***',
    );
    text = text.replaceAll(
      RegExp(r'(api[_-]?key|access_token|id_token|token)=([^&\s]+)',
          caseSensitive: false),
      r'$1=***',
    );
    if (text.length > 300) {
      text = '${text.substring(0, 300)}…';
    }
    return text;
  }
}
