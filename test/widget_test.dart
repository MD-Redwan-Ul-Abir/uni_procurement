import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:uni_procurement/core/error/failures.dart';
import 'package:uni_procurement/core/widgets/empty_state.dart';
import 'package:uni_procurement/features/auth/domain/entities/user_entity.dart';
import 'package:uni_procurement/features/auth/domain/repositories/auth_repository.dart';
import 'package:uni_procurement/features/auth/domain/usecases/register_vendor_usecase.dart';
import 'package:uni_procurement/features/auth/presentation/controllers/vendor_register_controller.dart';
import 'package:uni_procurement/features/auth/presentation/pages/pending_approval_page.dart';
import 'package:uni_procurement/features/auth/presentation/pages/vendor_register_page.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, UserEntity>> getMe() async =>
      const Left(ServerFailure('not implemented'));

  @override
  Future<Either<Failure, UserEntity>> login(
          String email, String password) async =>
      const Left(ServerFailure('not implemented'));

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
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> resetPassword(
          String token, String password, String passwordConfirmation) async =>
      const Right(null);
}

void main() {
  setUp(() {
    Get.reset();
    final repo = _FakeAuthRepository();
    final useCase = RegisterVendorUseCase(repo);
    Get.put(VendorRegisterController(registerUseCase: useCase));
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('step indicator tracker line alignment test', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 560,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HorizontalStepIndicator(currentStep: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final lineFinders = find.byWidgetPredicate(
      (widget) => widget is Container && widget.constraints?.maxHeight == 2,
    );
    expect(lineFinders, findsNWidgets(2));

    final circle1Center = tester.getCenter(find.text('1'));
    final circle2Center = tester.getCenter(find.text('2'));
    final circle3Center = tester.getCenter(find.text('3'));

    final line0Center = tester.getCenter(lineFinders.at(0));
    final line1Center = tester.getCenter(lineFinders.at(1));

    // Verify all circles and lines have identical vertical center
    expect(circle1Center.dy, equals(circle2Center.dy));
    expect(circle2Center.dy, equals(circle3Center.dy));
    expect(line0Center.dy, equals(circle1Center.dy));
    expect(line1Center.dy, equals(circle1Center.dy));
  });

  testWidgets('vendor register page desktop short height does not overflow',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 300);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const GetMaterialApp(
        home: VendorRegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Vendor\nRegistration'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('vendor register page mobile narrow size does not overflow',
      (tester) async {
    tester.view.physicalSize = const Size(360, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const GetMaterialApp(
        home: VendorRegisterPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Vendor Registration'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending approval page short height does not overflow',
      (tester) async {
    tester.view.physicalSize = const Size(800, 250);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: PendingApprovalPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Registration Under Review'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty state short height does not overflow', (tester) async {
    tester.view.physicalSize = const Size(800, 200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            title: 'No Data',
            subtitle: 'Nothing to see here',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No Data'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
