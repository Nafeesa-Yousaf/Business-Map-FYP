import 'package:business_map/data/datasource/remote/dio/dio_client.dart';
import 'package:business_map/data/model/response/business_type_model.dart';
import 'package:business_map/data/model/response/city_model.dart';
import 'package:business_map/data/model/response/budget_model.dart';
import 'package:business_map/data/model/response/generic_response_model.dart';
import 'package:business_map/data/model/response/target_area_model.dart';
import 'package:business_map/core/error/app_exception_handler.dart';
import 'package:business_map/utils/app_constants.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as dev;

class InputOptionsRepo {
  final DioClient dioClient;

  InputOptionsRepo(this.dioClient);

  Future<GenericResponseModel<List<BusinessTypeModel>>> getBusinessTypes() async {
    try {
      final response = await dioClient.get(ApiEndPoints.businessTypes);
      return GenericResponseModel(
          success: true,
          message: "Successful",
          data: (response.data as List)
              .map((e) => BusinessTypeModel.fromJson(e))
              .toList());
    } on DioException catch (e) {
      dev.log('DioError (BusinessTypes): ${e.message}');
      return GenericResponseModel(
          success: false, message: AppExceptionHandler().handleException(e));
    } catch (e) {
      dev.log('Error (BusinessTypes): $e');
      return GenericResponseModel(
          success: false, message: AppExceptionHandler().handleException(e));
    }
  }

  Future<GenericResponseModel<List<CityModel>>> getCities() async {
    try {
      final response = await dioClient.get(ApiEndPoints.cities);
      final rawData = response.data;
      List data = [];
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map && rawData.containsKey('cities')) {
        data = rawData['cities'] as List? ?? [];
      } else {
        return GenericResponseModel(
            success: false, message: "Unexpected response format for cities");
      }

      return GenericResponseModel(
          success: true,
          message: "Successful",
          data: data.map((e) => CityModel.fromJson(e)).toList());
    } on DioException catch (e) {
      dev.log('DioError (Cities): ${e.message}');
      return GenericResponseModel(
          success: false, message: AppExceptionHandler().handleException(e));
    } catch (e) {
      dev.log('Error (Cities): $e');
      return GenericResponseModel(
          success: false, message: AppExceptionHandler().handleException(e));
    }
  }

  Future<GenericResponseModel<BudgetModel>> getBudgets() async {
    try {
      final response = await dioClient.get(ApiEndPoints.budgets);
      return GenericResponseModel(
          success: true,
          message: "Successful",
          data: BudgetModel.fromJson(response.data));
    } on DioException catch (e) {
      dev.log('DioError (Budgets): ${e.message}');
      return GenericResponseModel(
          success: false, message: AppExceptionHandler().handleException(e));
    } catch (e) {
      dev.log('Error (Budgets): $e');
      return GenericResponseModel(
          success: false, message: AppExceptionHandler().handleException(e));
    }
  }

  Future<GenericResponseModel<List<TargetAreaModel>>> getTargetAreas(
      String cityId) async {
    try {
      final response = await dioClient.get(ApiEndPoints.targetAreas(cityId));
      return GenericResponseModel(
          success: true,
          message: "Successful",
          data: (response.data as List)
              .map((e) => TargetAreaModel.fromJson(e))
              .toList());
    } on DioException catch (e) {
      dev.log('DioError (TargetAreas): ${e.message}');
      return GenericResponseModel(
          success: false, message: AppExceptionHandler().handleException(e));
    } catch (e) {
      dev.log('Error (TargetAreas): $e');
      return GenericResponseModel(
          success: false, message: AppExceptionHandler().handleException(e));
    }
  }
}
