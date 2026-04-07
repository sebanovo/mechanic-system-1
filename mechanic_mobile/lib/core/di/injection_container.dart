import 'package:get_it/get_it.dart';
import 'package:mechanic_mobile/domain/repositories/service_request_repository.dart';
import 'package:mechanic_mobile/domain/usecases/get_service_requests_usecase.dart';
import 'package:mechanic_mobile/infrastructure/datasources/mock_service_data_source.dart';
import 'package:mechanic_mobile/infrastructure/repositories/service_request_repository_impl.dart';
import 'package:mechanic_mobile/presentation/home/viewmodels/home_viewmodel.dart';

// CORE
import '../../core/network/api_client.dart';

// DATA
import '../../infrastructure/datasources/auth_remote_data_source.dart';
import '../../infrastructure/repositories/auth_repository_impl.dart';

// DOMAIN
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/get_my_profile_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/update_my_profile_usecase.dart';

// PRESENTATION
import '../../presentation/auth/viewmodels/auth_viewmodel.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // =========================
  // 🔒 CORE
  // =========================
  sl.registerLazySingleton(() => ApiClient());

  // =========================
  // 📡 DATASOURCES (REAL API)
  // =========================
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl()),
  );

  // =========================
  // 🧠 REPOSITORIES
  // =========================
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );

  sl.registerLazySingleton<MockServiceDataSource>(
    () => MockServiceDataSourceImpl(),
  );
  sl.registerLazySingleton<ServiceRequestRepository>(
    () => ServiceRequestRepositoryImpl(remoteDataSource: sl()),
  );

  // =========================
  // 🎯 USE CASES
  // =========================
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetMeUseCase(sl()));
  sl.registerLazySingleton(() => GetMyProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMyProfileUseCase(sl()));

  // =========================
  // 🧩 VIEWMODELS
  // =========================
  // sl.registerFactory(
  //   () => AuthViewModel(
  //     sl<LoginUseCase>(),
  //     sl<RegisterUseCase>(),
  //     sl<GetMeUseCase>(),
  //     sl<GetMyProfileUseCase>(),
  //     sl<UpdateMyProfileUseCase>(),
  //   ),
  // );
  sl.registerLazySingleton(
    () => AuthViewModel(
      sl<LoginUseCase>(),
      sl<RegisterUseCase>(),
      sl<GetMeUseCase>(),
      sl<GetMyProfileUseCase>(),
      sl<UpdateMyProfileUseCase>(),
    ),
  );

  sl.registerLazySingleton(() => GetServiceRequestsUseCase(sl()));

  sl.registerLazySingleton(
    () => HomeViewModel(getServiceRequestsUseCase: sl()),
  );

  // (si usas home)
  // sl.registerFactory(
  //   () => HomeViewModel(
  //     getServiceRequestsUseCase: sl(),
  //   ),
  // );

  print(sl.isRegistered<HomeViewModel>());
  print(sl.isRegistered<AuthViewModel>());
}
