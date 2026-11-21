import 'package:business_map/data/datasource/remote/firebase/firebase_auth_service.dart';
import 'package:business_map/data/model/response/generic_response_model.dart';
import 'package:business_map/core/error/app_exception_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepo {
  final FirebaseAuthService _firebaseAuthService;
  final AppExceptionHandler _appExceptionHandler;

  AuthRepo(this._firebaseAuthService, this._appExceptionHandler);

  Future<GenericResponseModel<User>> signup({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      User? user = await _firebaseAuthService.signup(
        name: username,
        email: email,
        password: password,
      );
      return GenericResponseModel(
        success: true,
        message: "Successfully Signup",
        data: user,
      );
    } catch (e) {
      return GenericResponseModel(
        success: false,
        message: _appExceptionHandler.handleException(e),
      );
    }
  }

  Future<GenericResponseModel<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      User? user = await _firebaseAuthService.login(
        email: email,
        password: password,
      );
      return GenericResponseModel(
          success: true,
          message: "Successfully Login",
          data: user
      );
    } catch (e) {
      return GenericResponseModel(
        success: false,
        message: _appExceptionHandler.handleException(e),
      );
    }
  }

  Future<GenericResponseModel<UserCredential?>> signInWithGoogle() async {
    try {
      final UserCredential? userCredential =
          await _firebaseAuthService.signInWithGoogle();
      if (userCredential != null) {
        return GenericResponseModel(
          success: true,
          message: "Successfully Login",
          data: userCredential,
        );
      } else {
        return GenericResponseModel(success: false, message: "Login Failed");
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return GenericResponseModel(success: false, message: "");
      } else {
        return GenericResponseModel(
          success: false,
          message: _appExceptionHandler.handleException(e),
        );
      }
    } catch (e) {
      return GenericResponseModel(
        success: false,
        message: _appExceptionHandler.handleException(e),
      );
    }
  }

  Future<GenericResponseModel<User>> userCurrentAuthStatus() async {
    User? user = await _firebaseAuthService.authState();
    if (user != null) {
      return GenericResponseModel(
        success: true,
        message: "User Authentic",
        data: user,
      );
    } else {
      return GenericResponseModel(success: false, message: "User Unauthentic");
    }
  }

  Future<GenericResponseModel> logoutUser()async{
    try{
      await _firebaseAuthService.logout();
      return GenericResponseModel(success: true, message: "Successfully Logout");
    }catch(e){
      return GenericResponseModel(
        success: false,
        message: _appExceptionHandler.handleException(e),
      );
    }
  }

  Future<GenericResponseModel> sendResetLink(String email)async{
    try{
      await _firebaseAuthService.sendPasswordReset(email);
      return GenericResponseModel(success: true, message: "Reset Password Resend Successfully");
    }catch(e){
      return GenericResponseModel(
        success: false,
        message: _appExceptionHandler.handleException(e),
      );
    }
  }

  Future<GenericResponseModel> changePassword(
      {required String currentPassword,required String newPassword})async{
    try{
      await _firebaseAuthService.changePassword(currentPassword: currentPassword,newPassword: newPassword);
      return GenericResponseModel(success: true, message: "Password Successfully Updated");
    }catch(e){
      return GenericResponseModel(
        success: false,
        message: _appExceptionHandler.handleException(e),
      );
    }
  }
  bool getIsGoogleUser() {
    User? user = _firebaseAuthService.currentUser;
    if (user != null) {
      return user.providerData.any((p) => p.providerId == 'google.com');
    }
    return false;
  }

  Future<void> deleteUserAccount() async {
    await _firebaseAuthService.deleteUserAccount();
  }

  Future<void> reauthenticate({String? password}) async {
    await _firebaseAuthService.reauthenticate(password: password);
  }
}
