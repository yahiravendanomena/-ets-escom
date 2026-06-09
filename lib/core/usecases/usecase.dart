import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

/// Interfaz base para todos los casos de uso de la aplicación.
///
/// - [ReturnType]: el tipo que retorna el caso de uso (lo que produce).
/// - [ParamsType]: los parámetros de entrada (lo que necesita).
abstract class UseCase<ReturnType, ParamsType> {
  Future<Either<Failure, ReturnType>> call(ParamsType params);
}

/// Parámetro vacío para casos de uso que no requieren input.
/// Ejemplo: GetAllExamsUseCase no necesita parámetros.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}