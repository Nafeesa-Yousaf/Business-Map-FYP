import 'package:business_map/view/screens/state/error_state_screen.dart';
import 'package:flutter/material.dart';

/// Safe helpers for reading navigation / deep-link style route arguments.
class RouteArgs {
  RouteArgs._();

  static Object? raw(BuildContext context) =>
      ModalRoute.of(context)?.settings.arguments;

  /// Returns [arguments] when it is exactly [T], otherwise null.
  static T? castOrNull<T>(Object? arguments) {
    if (arguments is T) return arguments;
    return null;
  }

  static T? of<T>(BuildContext context) => castOrNull<T>(raw(context));

  static Map<String, dynamic>? asStringKeyedMap(Object? arguments) {
    if (arguments is Map<String, dynamic>) return arguments;
    if (arguments is Map) {
      return arguments.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  static String? readString(Map<String, dynamic>? map, String key) {
    final value = map?[key];
    if (value is String) return value;
    return null;
  }
}

class ErrorRouteArgs {
  final ErrorType errorType;
  final String? title;
  final String? message;
  final Future<void> Function(BuildContext context)? onRetry;

  const ErrorRouteArgs({
    required this.errorType,
    this.title,
    this.message,
    this.onRetry,
  });

  static ErrorRouteArgs? tryParse(Object? arguments) {
    final map = RouteArgs.asStringKeyedMap(arguments);
    if (map == null) return null;

    final type = map['errorType'];
    if (type is! ErrorType) return null;

    final onRetry = map['onRetry'];
    Future<void> Function(BuildContext context)? retryFn;
    if (onRetry is Future<void> Function(BuildContext)) {
      retryFn = onRetry;
    } else if (onRetry is Function) {
      retryFn = (context) async {
        await Function.apply(onRetry, [context]);
      };
    }

    return ErrorRouteArgs(
      errorType: type,
      title: RouteArgs.readString(map, 'title'),
      message: RouteArgs.readString(map, 'message'),
      onRetry: retryFn,
    );
  }
}
