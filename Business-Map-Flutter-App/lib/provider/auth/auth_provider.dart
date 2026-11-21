import 'package:business_map/provider/business/business_idea_provider.dart';
import 'package:business_map/provider/dashboard/bottom_nav_bar_provider.dart';
import 'package:business_map/provider/input_options/input_options_provider.dart';
import 'package:business_map/provider/location/location_provider.dart';
import 'package:business_map/provider/saved/saved_provider.dart';
import 'package:flutter/material.dart';
import 'package:business_map/data/model/response/generic_response_model.dart';
import 'package:business_map/data/model/response/user_profile_model.dart';
import 'package:business_map/data/repository/auth_repo.dart';
import 'package:business_map/data/repository/profile_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../profile/profile_provider.dart';

enum AuthLoadingFor {
  none,
  login,
  signup,
  logout,
  resetPassword,
  changePassword,
  googleAuth,
  deleteAccount
}

class AuthProvider extends ChangeNotifier {
  final AuthRepo _authRepo;
  final ProfileRepo _profileRepo;
  final ProfileProvider _profileProvider;
  final LocationProvider _locationProvider;
  final BusinessIdeaProvider _businessIdeaProvider;
  final InputOptionsProvider _inputOptionsProvider;
  final BottomNavBarProvider _bottomNavBarProvider;
  final SavedProvider _savedProvider;

  AuthProvider(
    this._authRepo,
    this._profileRepo,
    this._profileProvider,
    this._locationProvider,
    this._businessIdeaProvider,
    this._inputOptionsProvider,
    this._bottomNavBarProvider,
    this._savedProvider,
  );

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMsg;
  String? get errorMsg => _errorMsg;

  bool _isAccepted = false;
  bool get isAccepted => _isAccepted;

  AuthLoadingFor _loadingFor = AuthLoadingFor.none;
  AuthLoadingFor get loadingFor => _loadingFor;

  void _setLoadingState(bool loading, AuthLoadingFor forAction) {
    _isLoading = loading;
    _loadingFor = forAction;
    notifyListeners();
  }

  bool get isGoogleUser => _authRepo.getIsGoogleUser();

  void setAccepted(bool value) {
    _isAccepted = value;
    notifyListeners();
  }

  Future<bool?> login(String email, String password) async {
    if (_isLoading && _loadingFor == AuthLoadingFor.login) return null;

    _errorMsg = null;
    _setLoadingState(true, AuthLoadingFor.login);

    try {
      final GenericResponseModel response = await _authRepo.login(
        email: email,
        password: password,
      );

      if (!response.success) {
        _errorMsg = response.message;
        return false;
      }

      return true;
    } finally {
      _setLoadingState(false, AuthLoadingFor.none);
    }
  }

  Future<bool> googleAuth() async {
    if (_isLoading && _loadingFor == AuthLoadingFor.googleAuth) return false;

    _setLoadingState(true, AuthLoadingFor.googleAuth);
    _errorMsg = null;

    bool hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      _errorMsg = 'Network error. Please check your connection.';
      _setLoadingState(false, AuthLoadingFor.none);
      return false;
    }

    try {
      final response = await _authRepo.signInWithGoogle();
      if (response.success && response.data != null) {
        bool isNewUser = response.data?.additionalUserInfo?.isNewUser ?? false;
        if (isNewUser) {
          final User user = response.data!.user!;
          final userProfile = UserProfileModel.fromFirebaseUser(user);
            final createRes =
                await _profileRepo.insertUser(user.uid, userProfile.toMap());
            if (!createRes.success) {
              _errorMsg = createRes.message;
              _setLoadingState(false, AuthLoadingFor.none);
              return false;
            }
        }
        await _profileProvider.fetchUserData();
        _setLoadingState(false, AuthLoadingFor.none);
        return true;
      } else {
        _setLoadingState(false, AuthLoadingFor.none);
        _errorMsg = response.message;
        return false;
      }
    } catch (e) {
      _errorMsg = e.toString();
      _setLoadingState(false, AuthLoadingFor.none);
      return false;
    }
  }

  Future<bool?> signup(String username, String email, String password) async {
    if (_isLoading && _loadingFor == AuthLoadingFor.signup) return null;

    _errorMsg = null;
    _setLoadingState(true, AuthLoadingFor.signup);

    try {
      final GenericResponseModel response = await _authRepo.signup(
        username: username,
        email: email,
        password: password,
      );

      if (!response.success) {
        _errorMsg = response.message;
        return false;
      }

      final user = UserProfileModel.fromFirebaseUser(response.data!);
      final profileResult =
          await _profileRepo.insertUser(response.data!.uid, user.toMap());
      if (!profileResult.success) {
        _errorMsg = profileResult.message ?? 'Failed to create user profile';
        return false;
      }
      return true;
    } catch (e) {
      _errorMsg = e.toString();
      return false;
    } finally {
      _setLoadingState(false, AuthLoadingFor.none);
    }
  }

  Future<bool?> logout() async {
    if (_isLoading && _loadingFor == AuthLoadingFor.logout) return null;

    _errorMsg = null;
    _setLoadingState(true, AuthLoadingFor.logout);

    try {
      final GenericResponseModel response = await _authRepo.logoutUser();

      if (!response.success) {
        _errorMsg = response.message;
        return false;
      }

      _clearAllProvidersData();

      return true;
    } finally {
      _setLoadingState(false, AuthLoadingFor.none);
    }
  }

  void _clearAllProvidersData() {
    _profileProvider.clearData();
    _locationProvider.clearData();
    _businessIdeaProvider.clearData();
    _inputOptionsProvider.clearData();
    _bottomNavBarProvider.setIndex(0);
    _savedProvider.clearData();
  }

  Future<bool?> sendResetLink(String email) async {
    if (_isLoading && _loadingFor == AuthLoadingFor.resetPassword) return null;

    _errorMsg = null;
    _setLoadingState(true, AuthLoadingFor.resetPassword);

    try {
      final GenericResponseModel response = await _authRepo.sendResetLink(
        email,
      );

      if (!response.success) {
        _errorMsg = response.message;
        return false;
      }

      return true;
    } finally {
      _setLoadingState(false, AuthLoadingFor.none);
    }
  }

  Future<bool?> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_isLoading && _loadingFor == AuthLoadingFor.changePassword) return null;

    _errorMsg = null;
    _setLoadingState(true, AuthLoadingFor.changePassword);

    try {
      final GenericResponseModel response = await _authRepo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (!response.success) {
        _errorMsg = response.message;
        return false;
      }

      return true;
    } finally {
      _setLoadingState(false, AuthLoadingFor.none);
    }
  }

  Future<bool> deleteAccount({String? password}) async {
    if (_isLoading && _loadingFor == AuthLoadingFor.deleteAccount) {
      return false;
    }

    _errorMsg = null;
    _setLoadingState(true, AuthLoadingFor.deleteAccount);

    final trimmedPassword = password?.trim();
    final googleUser = isGoogleUser;

    try {
      final loggedIn = await isUserLoggedIn();
      if (!loggedIn) {
        _errorMsg = 'Please sign in again before deleting your account.';
        return false;
      }

      if (!googleUser && (trimmedPassword == null || trimmedPassword.isEmpty)) {
        _errorMsg = 'Password is required to delete your account.';
        return false;
      }

      // Firebase requires a recent login before account deletion.
      await _authRepo.reauthenticate(
        password: googleUser ? null : trimmedPassword,
      );

      final firestoreRes = await _profileRepo.deleteUserFirestoreData();
      if (!firestoreRes.success) {
        _errorMsg = firestoreRes.message;
        return false;
      }

      await _authRepo.deleteUserAccount();
      _clearAllProvidersData();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMsg = _mapDeleteAccountError(e);
      return false;
    } catch (e) {
      _errorMsg = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoadingState(false, AuthLoadingFor.none);
    }
  }

  String _mapDeleteAccountError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      case 'requires-recent-login':
        return 'For security, please sign in again and retry deleting your account.';
      case 'user-mismatch':
        return 'Please re-authenticate with the same Google account used for this profile.';
      case 'user-not-found':
      case 'user-disabled':
        return 'This account is no longer available.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message?.isNotEmpty == true
            ? e.message!
            : 'Could not delete account. Please try again.';
    }
  }

  Future<bool> isUserLoggedIn() async {
    final result = await _authRepo.userCurrentAuthStatus();
    return result.success;
  }
}
