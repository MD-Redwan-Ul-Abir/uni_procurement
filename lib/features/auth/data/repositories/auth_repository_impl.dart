import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Auth repository implementation — maps exceptions to failures.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepositoryImpl(this._remoteDatasource);

  @override
  Future<Either<Failure, UserEntity>> login(
      String email, String password) async {
    try {
      final user = await _remoteDatasource.login(email, password);
      return Right(user);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, fieldErrors: e.fieldErrors));
    } on UnauthorizedException {
      return const Left(
          ServerFailure('Invalid email or password', statusCode: 401));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> registerVendor({
    required String companyName,
    required String address,
    required String contactPerson,
    required String phone,
    required String tradeLicenseNumber,
    required dynamic tradeLicenseFile,
    required String taxId,
    required dynamic taxIdFile,
    required String binNumber,
    required dynamic binFile,
    required String email,
    required String password,
  }) async {
    try {
      await _remoteDatasource.registerVendor(
        companyName: companyName,
        address: address,
        contactPerson: contactPerson,
        phone: phone,
        tradeLicenseNumber: tradeLicenseNumber,
        tradeLicenseFile: tradeLicenseFile,
        taxId: taxId,
        taxIdFile: taxIdFile,
        binNumber: binNumber,
        binFile: binFile,
        email: email,
        password: password,
      );
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, fieldErrors: e.fieldErrors));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getMe() async {
    try {
      final user = await _remoteDatasource.getMe();
      return Right(user);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await _remoteDatasource.forgotPassword(email);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, fieldErrors: e.fieldErrors));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(
      String token, String password, String passwordConfirmation) async {
    try {
      await _remoteDatasource.resetPassword(
          token, password, passwordConfirmation);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, fieldErrors: e.fieldErrors));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }
}
