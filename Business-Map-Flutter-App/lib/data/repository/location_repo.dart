import 'dart:convert';
import 'package:business_map/data/datasource/remote/dio/dio_client.dart';
import 'package:business_map/data/model/request/location_suggestion_request.dart';
import 'package:business_map/data/model/response/generic_response_model.dart';
import 'package:business_map/data/model/response/location_suggestion_response.dart';
import 'package:business_map/core/error/app_exception_handler.dart';
import 'package:business_map/utils/app_constants.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as dev;

class LocationRepo {
  final DioClient dioClient;

  LocationRepo(this.dioClient);

  Future<GenericResponseModel<LocationSuggestionResponse>> suggestLocations(
      LocationSuggestionRequest request) async {
    try {
      final response = await dioClient.post(
        ApiEndPoints.suggestLocations,
        data: request.toJson(),
      );

      return GenericResponseModel(
        success: true,
        message: "Successfully fetched suggestions",
        data: LocationSuggestionResponse.fromJson(response.data),
      );
    } on DioException catch (e) {
      dev.log('DioError (SuggestLocations): ${e.message}');
      return GenericResponseModel(
        success: false,
        message: AppExceptionHandler().handleException(e),
      );
    } catch (e) {
      dev.log('Error (SuggestLocations): $e');
      return GenericResponseModel(
        success: false,
        message: AppExceptionHandler().handleException(e),
      );
    }
  }

  Stream<Map<String, dynamic>> suggestLocationsStream(
    LocationSuggestionRequest request, {
    CancelToken? cancelToken,
  }) async* {
    try {
      final response = await dioClient.postStream(
        ApiEndPoints.suggestLocationsStream,
        data: request.toJson(),
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        final stream = response.data!.stream
            .cast<List<int>>()
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        await for (final line in stream) {
          if (line.startsWith('data: ')) {
            final jsonString = line.substring(6).trim();
            if (jsonString.isNotEmpty) {
              try {
                yield json.decode(jsonString);
              } catch (e) {
                dev.log('Error decoding SSE JSON: $e');
              }
            }
          }
        }
      } else {
        throw Exception("Failed to load stream: ${response.statusCode}");
      }
    } catch (e) {
      dev.log('Error in suggestLocationsStream: $e');
      rethrow;
    }
  }
}
