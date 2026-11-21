import 'package:business_map/data/datasource/remote/dio/dio_client.dart';
import 'package:business_map/data/model/request/business_idea_suggestion_request.dart';
import 'package:business_map/data/model/response/business_idea_suggestion_response.dart';
import 'package:business_map/data/model/response/generic_response_model.dart';
import 'package:business_map/core/error/app_exception_handler.dart';
import 'package:business_map/utils/app_constants.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as dev;
import 'dart:convert';

class BusinessIdeaRepo {
  final DioClient dioClient;

  BusinessIdeaRepo(this.dioClient);

  Future<GenericResponseModel<BusinessIdeaSuggestionResponse>> suggestBusinessIdeas(
      BusinessIdeaSuggestionRequest request) async {
    try {
      final response = await dioClient.post(
        ApiEndPoints.suggestIdeas,
        data: request.toJson(),
      );

      dev.log("==== Business Suggestion API Response ====");
      dev.log(jsonEncode(response.data));
      dev.log("==========================================");

      return GenericResponseModel(
        success: true,
        message: "Successfully fetched business ideas",
        data: BusinessIdeaSuggestionResponse.fromJson(response.data),
      );
    } on DioException catch (e) {
      dev.log('DioError (SuggestIdeas): ${e.message}');
      return GenericResponseModel(
        success: false,
        message: AppExceptionHandler().handleException(e),
      );
    } catch (e) {
      dev.log('Error (SuggestIdeas): $e');
      return GenericResponseModel(
        success: false,
        message: AppExceptionHandler().handleException(e),
      );
    }
  }
  Stream<Map<String, dynamic>> suggestBusinessIdeasStream(
    BusinessIdeaSuggestionRequest request, {
    CancelToken? cancelToken,
  }) async* {
    try {
      final response = await dioClient.postStream(
        ApiEndPoints.suggestIdeasStream,
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
      dev.log('Error in suggestBusinessIdeasStream: $e');
      rethrow;
    }
  }
}
