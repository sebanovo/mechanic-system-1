import 'package:get_it/get_it.dart';
import 'package:mechanic_mobile/domain/repositories/service_request_repository.dart';
import 'package:mechanic_mobile/domain/repositories/vehicle_repository.dart';
import 'package:mechanic_mobile/domain/usecases/add_file_evidence_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/add_text_evidence_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/cancel_incident_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/create_incident_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/create_provider_service_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/create_technician_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/create_vehicle_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/get_all_incidents_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/get_catalog_services_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/get_incident_candidates_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/get_incident_details_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/get_my_incidents_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/get_provider_profile_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/get_provider_services_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/get_service_requests_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/get_my_vehicles_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/get_technicians_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/get_vehicle_by_id_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/publish_incident_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/update_incident_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/update_provider_profile_usecase.dart';
import 'package:mechanic_mobile/domain/usecases/update_technician_usecase.dart';
import 'package:mechanic_mobile/infrastructure/datasources/admin_incident_remote_data_source.dart';
import 'package:mechanic_mobile/infrastructure/datasources/catalog_remote_data_source.dart';
import 'package:mechanic_mobile/infrastructure/datasources/evidence_remote_data_source.dart';
import 'package:mechanic_mobile/infrastructure/datasources/incident_remote_data_source.dart';
import 'package:mechanic_mobile/infrastructure/datasources/mock_service_data_source.dart';
import 'package:mechanic_mobile/infrastructure/datasources/provider_remote_data_source.dart';
import 'package:mechanic_mobile/infrastructure/datasources/technician_datasource.dart';
import 'package:mechanic_mobile/infrastructure/datasources/vehicle_remote_data_source.dart';
import 'package:mechanic_mobile/infrastructure/repositories/admin_incident_repository_impl.dart';
import 'package:mechanic_mobile/infrastructure/repositories/catalog_repository_impl.dart';
import 'package:mechanic_mobile/infrastructure/repositories/evidence_repository_impl.dart';
import 'package:mechanic_mobile/infrastructure/repositories/incident_repository_impl.dart';
import 'package:mechanic_mobile/infrastructure/repositories/provider_repository_impl.dart';
import 'package:mechanic_mobile/infrastructure/repositories/service_request_repository_impl.dart';
import 'package:mechanic_mobile/infrastructure/repositories/technician_repository_impl.dart';
import 'package:mechanic_mobile/infrastructure/repositories/vehicle_repository_impl.dart';
import 'package:mechanic_mobile/presentation/viewmodels/admin_incidents_viewmodel.dart';
import 'package:mechanic_mobile/presentation/viewmodels/catalog_services_viewmodel.dart';
import 'package:mechanic_mobile/presentation/viewmodels/evidence_viewmodel.dart';
import 'package:mechanic_mobile/presentation/viewmodels/home_viewmodel.dart';
import 'package:mechanic_mobile/presentation/viewmodels/incidents_viewmodel.dart';
import 'package:mechanic_mobile/presentation/viewmodels/provider_profile_viewmodel.dart';
import 'package:mechanic_mobile/presentation/viewmodels/technicians_viewmodel.dart';
import 'package:mechanic_mobile/presentation/viewmodels/vehicle_viewmodel.dart';

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
import '../../domain/usecases/update_vehicle_usecase.dart';

// PRESENTATION
import '../../presentation/viewmodels/auth_viewmodel.dart';

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
  sl.registerLazySingleton<VehicleRemoteDataSource>(
    () => VehicleRemoteDataSource(sl()),
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
  sl.registerLazySingleton<VehicleRepository>(
    () => VehicleRepositoryImpl(sl()),
  );

  // =========================
  // 🎯 USE CASES
  // =========================
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetMeUseCase(sl()));
  sl.registerLazySingleton(() => GetMyProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMyProfileUseCase(sl()));
  sl.registerLazySingleton(() => CreateVehicleUseCase(sl()));
  sl.registerLazySingleton(() => GetMyVehiclesUseCase(sl()));
  sl.registerLazySingleton(() => GetVehicleByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateVehicleUseCase(sl()));

  // =========================
  // 🧩 VIEWMODELS
  // =========================
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
  sl.registerLazySingleton(
    () => VehicleViewModel(
      createVehicleUseCase: sl(),
      getMyVehiclesUseCase: sl(),
      getVehicleByIdUseCase: sl(),
      updateVehicleUseCase: sl(),
    ),
  );
  initTechniciansModule();
  initProviderModule();
  initCatalogModule();
  initIncidentModule();
  initEvidenceModule();
  initAdminIncidentModule();
}

void initTechniciansModule() {
  sl.registerFactory<TechnicianRemoteDataSource>(
    () => TechnicianRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerFactory<TechnicianRepository>(
    () => TechnicianRepository(sl<TechnicianRemoteDataSource>()),
  );

  sl.registerFactory<CreateTechnicianUseCase>(
    () => CreateTechnicianUseCaseImpl(sl<TechnicianRepository>()),
  );

  sl.registerFactory<GetTechniciansUseCase>(
    () => GetTechniciansUseCaseImpl(sl<TechnicianRepository>()),
  );

  sl.registerFactory<UpdateTechnicianUseCase>(
    () => UpdateTechnicianUseCaseImpl(sl<TechnicianRepository>()),
  );

  sl.registerFactory<TechniciansViewModel>(
    () => TechniciansViewModel(
      createTechnicianUseCase: sl<CreateTechnicianUseCase>(),
      getTechniciansUseCase: sl<GetTechniciansUseCase>(),
      updateTechnicianUseCase: sl<UpdateTechnicianUseCase>(),
    ),
  );
}

// Agregar módulo
void initProviderModule() {
  // Data Source
  sl.registerFactory<ProviderRemoteDataSource>(
    () => ProviderRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerFactory<ProviderRepository>(
    () => ProviderRepository(sl<ProviderRemoteDataSource>()),
  );

  // Use Cases
  sl.registerFactory<GetProviderProfileUseCase>(
    () => GetProviderProfileUseCaseImpl(sl<ProviderRepository>()),
  );

  sl.registerFactory<UpdateProviderProfileUseCase>(
    () => UpdateProviderProfileUseCaseImpl(sl<ProviderRepository>()),
  );

  // ViewModel
  sl.registerFactory<ProviderProfileViewModel>(
    () => ProviderProfileViewModel(
      getProviderProfileUseCase: sl<GetProviderProfileUseCase>(),
      updateProviderProfileUseCase: sl<UpdateProviderProfileUseCase>(),
    ),
  );
}

void initCatalogModule() {
  // Data Source
  sl.registerFactory<CatalogRemoteDataSource>(
    () => CatalogRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerFactory<CatalogRepository>(
    () => CatalogRepository(sl<CatalogRemoteDataSource>()),
  );

  // Use Cases
  sl.registerFactory<GetCatalogServicesUseCase>(
    () => GetCatalogServicesUseCaseImpl(sl<CatalogRepository>()),
  );

  sl.registerFactory<GetProviderServicesUseCase>(
    () => GetProviderServicesUseCaseImpl(sl<CatalogRepository>()),
  );

  sl.registerFactory<CreateProviderServiceUseCase>(
    () => CreateProviderServiceUseCaseImpl(sl<CatalogRepository>()),
  );

  // ViewModel
  sl.registerFactory<CatalogServicesViewModel>(
    () => CatalogServicesViewModel(
      getCatalogServicesUseCase: sl<GetCatalogServicesUseCase>(),
      getProviderServicesUseCase: sl<GetProviderServicesUseCase>(),
      createProviderServiceUseCase: sl<CreateProviderServiceUseCase>(),
    ),
  );
}

void initIncidentModule() {
  // Data Source
  sl.registerFactory<IncidentRemoteDataSource>(
    () => IncidentRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerFactory<IncidentRepository>(
    () => IncidentRepository(sl<IncidentRemoteDataSource>()),
  );

  // Use Cases
  sl.registerFactory<GetMyIncidentsUseCase>(
    () => GetMyIncidentsUseCaseImpl(sl<IncidentRepository>()),
  );

  sl.registerFactory<CreateIncidentUseCase>(
    () => CreateIncidentUseCaseImpl(sl<IncidentRepository>()),
  );

  sl.registerFactory<UpdateIncidentUseCase>(
    () => UpdateIncidentUseCaseImpl(sl<IncidentRepository>()),
  );

  sl.registerFactory<CancelIncidentUseCase>(
    () => CancelIncidentUseCaseImpl(sl<IncidentRepository>()),
  );

  // ViewModel
  sl.registerFactory<IncidentsViewModel>(
    () => IncidentsViewModel(
      getMyIncidentsUseCase: sl<GetMyIncidentsUseCase>(),
      createIncidentUseCase: sl<CreateIncidentUseCase>(),
      updateIncidentUseCase: sl<UpdateIncidentUseCase>(),
      cancelIncidentUseCase: sl<CancelIncidentUseCase>(),
    ),
  );
}

void initEvidenceModule() {
  // Data Source
  sl.registerFactory<EvidenceRemoteDataSource>(
    () => EvidenceRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerFactory<EvidenceRepository>(
    () => EvidenceRepository(sl<EvidenceRemoteDataSource>()),
  );

  // Use Cases
  sl.registerFactory<AddTextEvidenceUseCase>(
    () => AddTextEvidenceUseCaseImpl(sl<EvidenceRepository>()),
  );

  sl.registerFactory<AddFileEvidenceUseCase>(
    () => AddFileEvidenceUseCaseImpl(sl<EvidenceRepository>()),
  );

  // ViewModel
  sl.registerFactory<EvidenceViewModel>(
    () => EvidenceViewModel(
      addTextEvidenceUseCase: sl<AddTextEvidenceUseCase>(),
      addFileEvidenceUseCase: sl<AddFileEvidenceUseCase>(),
    ),
  );
}

void initAdminIncidentModule() {
  // Data Source
  sl.registerFactory<AdminIncidentRemoteDataSource>(
    () => AdminIncidentRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerFactory<AdminIncidentRepository>(
    () => AdminIncidentRepository(sl<AdminIncidentRemoteDataSource>()),
  );

  // Use Cases
  sl.registerFactory<GetAllIncidentsUseCase>(
    () => GetAllIncidentsUseCaseImpl(sl<AdminIncidentRepository>()),
  );

  sl.registerFactory<GetIncidentDetailsUseCase>(
    () => GetIncidentDetailsUseCaseImpl(sl<AdminIncidentRepository>()),
  );

  sl.registerFactory<GetIncidentCandidatesUseCase>(
    () => GetIncidentCandidatesUseCaseImpl(sl<AdminIncidentRepository>()),
  );

  sl.registerFactory<PublishIncidentUseCase>(
    () => PublishIncidentUseCaseImpl(sl<AdminIncidentRepository>()),
  );

  // ViewModel
  sl.registerFactory<AdminIncidentsViewModel>(
    () => AdminIncidentsViewModel(
      getAllIncidentsUseCase: sl<GetAllIncidentsUseCase>(),
      getIncidentDetailsUseCase: sl<GetIncidentDetailsUseCase>(),
      getIncidentCandidatesUseCase: sl<GetIncidentCandidatesUseCase>(),
      publishIncidentUseCase: sl<PublishIncidentUseCase>(),
    ),
  );
}
