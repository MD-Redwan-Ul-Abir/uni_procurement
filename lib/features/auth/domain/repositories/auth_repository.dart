import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Abstract auth repository — presentation depends on this, never on the impl.
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);

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
  });

  Future<Either<Failure, UserEntity>> getMe();

  Future<Either<Failure, void>> forgotPassword(String email);

  Future<Either<Failure, void>> resetPassword(
      String token, String password, String passwordConfirmation);
}
