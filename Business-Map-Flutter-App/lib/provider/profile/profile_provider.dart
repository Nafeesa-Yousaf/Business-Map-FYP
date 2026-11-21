import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:business_map/core/error/app_exception_handler.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:business_map/data/model/response/generic_response_model.dart';
import 'package:business_map/data/model/response/user_profile_model.dart';
import 'package:business_map/data/repository/profile_repo.dart';

enum ProfileLoadingFor { none, fetchUser, updateUser, uploadImage }

class ProfileProvider extends ChangeNotifier {
  final ProfileRepo _profileRepo;
  final AppExceptionHandler _appExceptionHandler;
  final ImagePicker _picker = ImagePicker();

  ProfileProvider(this._profileRepo, this._appExceptionHandler);

  UserProfileModel? _userProfile;
  UserProfileModel? get userProfile => _userProfile;

  XFile? _file;
  XFile? get file => _file;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isNameChanged = false;
  bool get isNameChanged => _isNameChanged;

  bool _isEditEnable = false;
  bool get isEditEnable => _isEditEnable;

  String? _errorMsg;
  String? get errorMsg => _errorMsg;

  ProfileLoadingFor _loadingFor = ProfileLoadingFor.none;
  ProfileLoadingFor get loadingFor => _loadingFor;

  void _setLoadingState(bool loading, ProfileLoadingFor forAction) {
    _isLoading = loading;
    _loadingFor = forAction;
    notifyListeners();
  }

  void setNameChanged(bool changed) {
    _isNameChanged = changed;
    notifyListeners();
  }

  void setEnable(bool enabled) {
    _isEditEnable = enabled;
    notifyListeners();
  }

  Future<bool?> fetchUserData() async {
    if (_isLoading && _loadingFor == ProfileLoadingFor.fetchUser) return null;
    _errorMsg = null;
    _setLoadingState(true, ProfileLoadingFor.fetchUser);

    try {
      final GenericResponseModel response =
          await _profileRepo.fetchUserDetails();
      if (!response.success) {
        _errorMsg = response.message;
        throw Exception(_errorMsg);
      }
      _userProfile = UserProfileModel.fromMap(response.data!);
      return true;
    } catch (e) {
      _errorMsg = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _setLoadingState(false, ProfileLoadingFor.none);
    }
  }

  Future<bool> updateUserName(String name) async {
    if (_isLoading && _loadingFor == ProfileLoadingFor.updateUser) return false;
    _errorMsg = null;
    _setLoadingState(true, ProfileLoadingFor.updateUser);

    try {
      final GenericResponseModel response =
          await _profileRepo.updateUserName(name: name);
      if (!response.success) {
        _errorMsg = response.message;
        return false;
      }
      _userProfile = _userProfile?.copyWith(name: name);
      return true;
    } catch (e) {
      _errorMsg = _appExceptionHandler.handleException(e);
      return false;
    } finally {
      _setLoadingState(false, ProfileLoadingFor.none);
    }
  }

  Future<bool> captureFromCamera(BuildContext context) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return await _processImage(pickedFile.path, context);
    }
    return false;
  }

  Future<bool> pickFromGallery(BuildContext context) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return await _processImage(pickedFile.path, context);
    }
    return false;
  }

  Future<bool> _processImage(String path, BuildContext context) async {
    final croppedFile = await _cropImage(path, context);
    if (croppedFile != null) {
      _file = XFile(croppedFile.path);
      notifyListeners();
      return await _uploadToFirebase(File(croppedFile.path));
    }
    return false;
  }

  Future<CroppedFile?> _cropImage(String path, BuildContext context) async {
    return await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Image',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Profile Image',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
  }

  Future<bool> _uploadToFirebase(File file) async {
    if (_userProfile == null) return false;
    _setLoadingState(true, ProfileLoadingFor.uploadImage);

    try {
      final response = await _profileRepo.uploadProfileImage(file);
      
      if (response.success) {
        _userProfile = _userProfile?.copyWith(imageUrl: response.data);
        return true;
      } else {
        _errorMsg = response.message;
        return false;
      }
    } catch (e) {
      _errorMsg = "Failed to upload image: $e";
      return false;
    } finally {
      _setLoadingState(false, ProfileLoadingFor.none);
    }
  }

  Future<bool> removeProfileImage() async {
    if (_userProfile == null) return false;
    _setLoadingState(true, ProfileLoadingFor.updateUser);
    try {
      final response = await _profileRepo.removeProfileImage();
      
      if (response.success) {
        _userProfile = _userProfile?.copyWith(imageUrl: "");
        _file = null;
        return true;
      }
      _errorMsg = response.message;
      return false;
    } catch (e) {
      _errorMsg = _appExceptionHandler.handleException(e);
      return false;
    } finally {
      _setLoadingState(false, ProfileLoadingFor.none);
    }
  }

  void clearData() {
    _userProfile = null;
    _file = null;
    _isLoading = false;
    _errorMsg = null;
    _loadingFor = ProfileLoadingFor.none;
    notifyListeners();
  }
}
