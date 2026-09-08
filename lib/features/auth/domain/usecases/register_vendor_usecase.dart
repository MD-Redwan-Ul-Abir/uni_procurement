import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class RegisterVendorUseCase {
  final AuthRepository repository;

  RegisterVendorUseCase(this.repository);

  Future<Either<Failure, void>> call({
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
  }) {
    return repository.registerVendor(
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
  }
}
