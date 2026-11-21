import 'package:business_map/data/datasource/remote/firebase/firebase_auth_service.dart';
import 'package:business_map/data/datasource/remote/firebase/firebase_crud_service.dart';
import 'package:business_map/data/datasource/remote/firebase/firebase_storage_service.dart';
import 'package:business_map/data/repository/auth_repo.dart';
import 'package:business_map/data/repository/business_idea_repo.dart';
import 'package:business_map/data/repository/profile_repo.dart';
import 'package:business_map/data/repository/saved_repo.dart';
import 'package:business_map/provider/business/business_idea_provider.dart';
import 'package:business_map/provider/connectivity/connectivity_provider.dart';
import 'package:business_map/provider/saved/saved_provider.dart';
import 'package:business_map/provider/dashboard/bottom_nav_bar_provider.dart';
import 'package:business_map/provider/profile/profile_provider.dart';
import 'package:business_map/data/repository/input_options_repo.dart';
import 'package:business_map/data/repository/location_repo.dart';
import 'package:business_map/provider/input_options/input_options_provider.dart';
import 'package:business_map/provider/location/location_provider.dart';
import 'package:business_map/provider/tts/tts_provider.dart';
import 'package:business_map/utils/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:business_map/core/error/app_exception_handler.dart';
import 'package:business_map/provider/auth/auth_provider.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:business_map/data/datasource/remote/dio/dio_client.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Firebase Core services
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);

  // Firebase service wrapper
  sl.registerLazySingleton(() => FirebaseAuthService(sl(),sl()));
  sl.registerLazySingleton(() => FirebaseCrudService(sl()));
  sl.registerLazySingleton(() => FirebaseStorageService());

  // Utilities
  sl.registerLazySingleton(() => AppExceptionHandler());

  //DioClient
  final dioClient = await DioClient.create(
    ApiEndPoints.baseUrl,
    sl<FirebaseAuth>(),
    bypassSecret: AppConfigs.vercelAutomationBypassSecret,
  );
  sl.registerSingleton<DioClient>(dioClient);

  // Repo
  sl.registerLazySingleton(() => AuthRepo(sl(), sl()));
  sl.registerLazySingleton(() => ProfileRepo(sl(), sl(), sl(), sl()));
  sl.registerLazySingleton(() => InputOptionsRepo(sl()));
  sl.registerLazySingleton(() => LocationRepo(sl()));
  sl.registerLazySingleton(() => BusinessIdeaRepo(sl()));
  sl.registerLazySingleton(() => SavedRepo(sl(), sl()));


  //Provider
  sl.registerLazySingleton(() => auth.AuthProvider(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()));
  sl.registerLazySingleton(() => ProfileProvider(sl(), sl()));
  sl.registerLazySingleton(() => BottomNavBarProvider());
  sl.registerLazySingleton(() => InputOptionsProvider(sl(), sl()));
  sl.registerLazySingleton(() => LocationProvider(sl(), sl()));
  sl.registerLazySingleton(() => BusinessIdeaProvider(businessIdeaRepo: sl(), appExceptionHandler: sl()));
  sl.registerLazySingleton(() => SavedProvider(sl(), sl()));
  sl.registerLazySingleton(() => TTSProvider());
  sl.registerLazySingleton(() => ConnectivityProvider());

}
