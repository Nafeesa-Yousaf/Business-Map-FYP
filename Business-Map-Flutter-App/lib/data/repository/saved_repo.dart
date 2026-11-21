import 'package:business_map/data/datasource/remote/firebase/firebase_auth_service.dart';
import 'package:business_map/data/datasource/remote/firebase/firebase_crud_service.dart';
import 'package:business_map/data/model/request/firebase_filter_model.dart';
import 'package:business_map/data/model/response/business_idea_suggestion_response.dart';
import 'package:business_map/data/model/response/generic_response_model.dart';
import 'package:business_map/data/model/response/location_suggestion_response.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedRepo {
  final FirebaseCrudService _crudService;
  final FirebaseAuthService _authService;

  SavedRepo(this._crudService, this._authService);

  static const String _ideaCollection = 'save_business_idea';
  static const String _locationCollection = 'save_location';

  Stream<List<Map<String, dynamic>>> _getSavedItemsStream(String collection) {
    User? user = _authService.currentUser;
    if (user == null) return Stream.value([]);

    return _crudService.getFilteredStream(
      collection: collection,
      filters: [FirebaseFilterModel( 'userId',  user.uid)],
    );
  }

  Stream<List<TopLocation>> getSavedLocationsStream() {
    return _getSavedItemsStream(_locationCollection).map((list) =>
        list.map((item) {
          final data = Map<String, dynamic>.from(item['data']);
          data['id'] = item['id'];
          data['createdAt'] = item['createdAt'];
          return TopLocation.fromJson(data);
        }).toList());
  }

  Future<GenericResponseModel> saveLocation(TopLocation location) async {
    try {
      User? user = _authService.currentUser;
      if (user == null) return GenericResponseModel(success: false, message: "User not logged in");

      final docData = {
        'userId': user.uid,
        'createdAt': DateTime.now().toIso8601String(),
        'data': location.toJson(),
        'itemName': location.locationName, 
      };

      await _crudService.insert(
        collection: _locationCollection,
        data: docData,
      );
      return GenericResponseModel(success: true, message: "Location saved successfully");
    } catch (e) {
      return GenericResponseModel(success: false, message: e.toString());
    }
  }

  Stream<List<BusinessIdea>> getSavedIdeasStream() {
    return _getSavedItemsStream(_ideaCollection).map((list) =>
        list.map((item) {
          final data = Map<String, dynamic>.from(item['data']);
          data['id'] = item['id'];
          data['createdAt'] = item['createdAt'];
          return BusinessIdea.fromJson(data);
        }).toList());
  }

  Future<GenericResponseModel> saveIdea(BusinessIdea idea, {String? category, String? area}) async {
    try {
      User? user = _authService.currentUser;
      if (user == null) return GenericResponseModel(success: false, message: "User not logged in");

      final itemData = idea.toJson();
      if (category != null) itemData['category_context'] = category;
      if (area != null) itemData['area_context'] = area;

      final docData = {
        'userId': user.uid,
        'createdAt': DateTime.now().toIso8601String(),
        'data': itemData,
        'itemName': idea.businessName,
      };

      await _crudService.insert(
        collection: _ideaCollection,
        data: docData,
      );
      return GenericResponseModel(success: true, message: "Idea saved successfully");
    } catch (e) {
      return GenericResponseModel(success: false, message: e.toString());
    }
  }

  Future<GenericResponseModel> unsaveItem(String itemName, bool isLocation) async {
    try {
      User? user = _authService.currentUser;
      if (user == null) return GenericResponseModel(success: false, message: "User not logged in");

      final collection = isLocation ? _locationCollection : _ideaCollection;

      final results = await _crudService.search(
        collection: collection,
        filters: [
          FirebaseFilterModel( 'userId',  user.uid),
          FirebaseFilterModel( 'itemName',itemName),
        ],
      );

      if (results.isEmpty) return GenericResponseModel(success: true, message: "Item not found");

      await _crudService.delete(
        collection: collection,
        docId: results.first['id'],
      );
      return GenericResponseModel(success: true, message: "Item removed successfully");
    } catch (e) {
      return GenericResponseModel(success: false, message: e.toString());
    }
  }

  Future<GenericResponseModel> deleteMultipleItems(List<String> docIds, bool isLocation) async {
    try {
      final collection = isLocation ? _locationCollection : _ideaCollection;
      for (var id in docIds) {
        await _crudService.delete(collection: collection, docId: id);
      }
      return GenericResponseModel(success: true, message: "Items deleted successfully");
    } catch (e) {
      return GenericResponseModel(success: false, message: e.toString());
    }
  }

  Future<bool> isItemSaved(String name, bool isLocation) async {
    try {
      User? user = _authService.currentUser;
      if (user == null) return false;

      final collection = isLocation ? _locationCollection : _ideaCollection;

      final results = await _crudService.search(
        collection: collection,
        filters: [
          FirebaseFilterModel( 'userId',  user.uid),
          FirebaseFilterModel( 'itemName',name),
        ],
      );
          
      return results.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
