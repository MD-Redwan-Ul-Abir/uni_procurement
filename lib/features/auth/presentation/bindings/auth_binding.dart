import 'package:get/get.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/get_me_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_vendor_usecase.dart';
import '../controllers/auth_controller.dart';
import '../controllers/vendor_register_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Data layer.
    final dioClient = DioClient();
    final datasource = AuthRemoteDatasource(dioClient);
    final repository = AuthRepositoryImpl(datasource);

    // Use cases.
    final loginUseCase = LoginUseCase(repository);
    final getMeUseCase = GetMeUseCase(repository);
    final registerVendorUseCase = RegisterVendorUseCase(repository);

    // Controllers.
    Get.lazyPut(() => AuthController(
          loginUseCase: loginUseCase,
          getMeUseCase: getMeUseCase,
        ));

    Get.lazyPut(() => VendorRegisterController(
          registerUseCase: registerVendorUseCase,
        ));
  }
}
