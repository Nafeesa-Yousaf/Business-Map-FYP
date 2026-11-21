import 'dart:io';
import 'package:business_map/data/datasource/remote/firebase/firebase_auth_service.dart';
import 'package:business_map/data/datasource/remote/firebase/firebase_crud_service.dart';
import 'package:business_map/data/datasource/remote/firebase/firebase_storage_service.dart';
import 'package:business_map/data/model/response/generic_response_model.dart';
import 'package:business_map/core/error/app_exception_handler.dart';
import 'package:business_map/utils/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileRepo {
  final FirebaseCrudService _firebaseCrudService;
  final FirebaseAuthService _firebaseAuthService;
  final FirebaseStorageService _firebaseStorageService;
  final AppExceptionHandler _appExceptionHandler;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProfileRepo(this._firebaseCrudService, this._firebaseAuthService,
      this._firebaseStorageService, this._appExceptionHandler);

  Future<GenericResponseModel> insertUser(
      String uid, Map<String, dynamic> data) async {
    try {
      await _firebaseCrudService.insert(
          collection: FirebaseCollections.userCollection,
          data: data,
          docId: uid);
      return GenericResponseModel(success: true, message: "User Successfully");
    } catch (e) {
      return GenericResponseModel(
          success: false, message: _appExceptionHandler.handleException(e));
    }
  }

  Future<GenericResponseModel<Map<String, dynamic>>> fetchUserDetails() async {
    try {
      User? currentUser = await _firebaseAuthService.authState();
      final userDetails = await _firebaseCrudService.getById(
        collection: FirebaseCollections.userCollection,
        docId: currentUser!.uid,
      );

      return GenericResponseModel(
        success: true,
        message: "Successfully Fetched",
        data: userDetails,
      );
    } catch (e) {
      return GenericResponseModel(
        success: false,
        message: _appExceptionHandler.handleException(e),
        data: {},
      );
    }
  }

  Future<GenericResponseModel> updateUserName({required String name}) async {
    try {
      User? currentUser = await _firebaseAuthService.authState();
      await _firebaseCrudService.update(
          collection: FirebaseCollections.userCollection,
          docId: currentUser!.uid,
          data: {'name': name});
      return GenericResponseModel(
          success: true, message: "Successfully Updated");
    } catch (e) {
      return GenericResponseModel(
          success: false, message: _appExceptionHandler.handleException(e));
    }
  }

  Future<GenericResponseModel<String>> uploadProfileImage(File file) async {
    try {
      User? currentUser = await _firebaseAuthService.authState();
      final String uid = currentUser!.uid;

      final String storagePath = 'profile_images/$uid.jpg';

      final String downloadUrl =
          await _firebaseStorageService.uploadFile(file, storagePath);

      await _firebaseCrudService.update(
          collection: FirebaseCollections.userCollection,
          docId: uid,
          data: {'imageUrl': downloadUrl});

      return GenericResponseModel(
        success: true,
        message: "Successfully Uploaded Image",
        data: downloadUrl,
      );
    } catch (e) {
      return GenericResponseModel(
        success: false,
        message: _appExceptionHandler.handleException(e),
      );
    }
  }

  Future<GenericResponseModel> removeProfileImage() async {
    try {
      User? currentUser = await _firebaseAuthService.authState();
      final String uid = currentUser!.uid;

      await _firebaseStorageService.deleteFile('profile_images/$uid.jpg');

      await _firebaseCrudService.update(
          collection: FirebaseCollections.userCollection,
          docId: uid,
          data: {'imageUrl': ""});

      return GenericResponseModel(
          success: true, message: "Successfully Removed Image");
    } catch (e) {
      return GenericResponseModel(
          success: false, message: _appExceptionHandler.handleException(e));
    }
  }

  Future<GenericResponseModel> deleteUserFirestoreData() async {
    try {
      User? currentUser = await _firebaseAuthService.authState();
      if (currentUser == null) {
        return GenericResponseModel(
            success: false, message: "User not logged in");
      }

      final String uid = currentUser.uid;

      try {
        await _firebaseStorageService.deleteFile('profile_images/$uid.jpg');
      } catch (e) {
        // Ignore if no image exists
      }

      final collectionsToClean = ['save_location', 'save_business_idea'];
      
      for (var col in collectionsToClean) {
        final items = await _firestore
            .collection(col)
            .where('userId', isEqualTo: uid)
            .get();
        
        if (items.docs.isNotEmpty) {
          final batch = _firestore.batch();
          for (var doc in items.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
        }
      }

      await _firebaseCrudService.delete(
        collection: FirebaseCollections.userCollection,
        docId: uid,
      );

      return GenericResponseModel(
          success: true, message: "User data deleted from Firestore");
    } catch (e) {
      return GenericResponseModel(
        success: false,
        message: _appExceptionHandler.handleException(e),
      );
    }
  }
}
