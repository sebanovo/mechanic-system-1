import '../../domain/entities/technician.dart';
import '../../domain/usecases/create_technician_usecase.dart';
import '../../domain/usecases/get_technicians_usecase.dart';
import '../datasources/technician_datasource.dart';

class TechnicianRepository {
  final TechnicianRemoteDataSource _dataSource;

  TechnicianRepository(this._dataSource);

  Future<Technician> createTechnician(CreateTechnicianParams params) async {
    final model = await _dataSource.createTechnician(params.toJson());
    return model.toEntity();
  }

  Future<List<Technician>> getTechnicians() async {
    final models = await _dataSource.getTechnicians();
    return models.map((model) => model.toEntity()).toList();
  }
}

// Implementación del UseCase que usa el repositorio
class CreateTechnicianUseCaseImpl implements CreateTechnicianUseCase {
  final TechnicianRepository _repository;

  CreateTechnicianUseCaseImpl(this._repository);

  @override
  Future<Technician> execute(CreateTechnicianParams params) async {
    return await _repository.createTechnician(params);
  }
}

// Implementación del UseCase que usa el repositorio
class GetTechniciansUseCaseImpl implements GetTechniciansUseCase {
  final TechnicianRepository _repository;

  GetTechniciansUseCaseImpl(this._repository);

  @override
  Future<List<Technician>> execute() async {
    return await _repository.getTechnicians();
  }
}
