import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_toast.dart';
import '../../domain/usecases/register_vendor_usecase.dart';

/// Controller for the 3-step vendor registration form.
class VendorRegisterController extends GetxController {
  final RegisterVendorUseCase _registerUseCase;

  VendorRegisterController({required RegisterVendorUseCase registerUseCase})
      : _registerUseCase = registerUseCase;

  // ── Step tracking ──
  final currentStep = 0.obs;
  final totalSteps = 3;

  // ── Step 1: Company Details ──
  final step1FormKey = GlobalKey<FormState>();
  final companyNameController = TextEditingController();
  final addressController = TextEditingController();
  final contactPersonController = TextEditingController();
  final phoneController = TextEditingController();

  // ── Step 2: Legal Documents ──
  final step2FormKey = GlobalKey<FormState>();
  final tradeLicenseNumberController = TextEditingController();
  final taxIdController = TextEditingController();
  final binNumberController = TextEditingController();
  final Rxn<PlatformFile> tradeLicenseFile = Rxn<PlatformFile>();
  final Rxn<PlatformFile> taxIdFile = Rxn<PlatformFile>();
  final Rxn<PlatformFile> binFile = Rxn<PlatformFile>();
  final tradeLicenseError = RxnString();
  final taxIdFileError = RxnString();
  final binFileError = RxnString();

  // ── Step 3: Credentials ──
  final step3FormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ── State ──
  final isLoading = false.obs;
  final fieldErrors = <String, String>{}.obs;

  // ── Navigation ──
  void nextStep() {
    switch (currentStep.value) {
      case 0:
        if (step1FormKey.currentState?.validate() ?? false) {
          currentStep.value = 1;
        }
        break;
      case 1:
        if (_validateStep2()) {
          currentStep.value = 2;
        }
        break;
      case 2:
        if (step3FormKey.currentState?.validate() ?? false) {
          submit();
        }
        break;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value = currentStep.value - 1;
    }
  }

  bool _validateStep2() {
    bool valid = step2FormKey.currentState?.validate() ?? false;
    if (tradeLicenseFile.value == null) {
      tradeLicenseError.value = 'Trade license document is strictly mandatory';
      valid = false;
    } else {
      tradeLicenseError.value = null;
    }
    if (taxIdFile.value == null) {
      taxIdFileError.value = 'TIN document is strictly mandatory';
      valid = false;
    } else {
      taxIdFileError.value = null;
    }
    if (binFile.value == null) {
      binFileError.value = 'BIN document is strictly mandatory';
      valid = false;
    } else {
      binFileError.value = null;
    }
    return valid;
  }

  // ── File Picking ──
  Future<void> pickTradeLicense() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (files.isNotEmpty) {
      final file = files.first;
      final size = file.lengthSync() ?? await file.length();
      if (size > AppConstants.maxUploadSizeBytes) {
        tradeLicenseError.value = 'File must be less than 5MB';
        return;
      }
      tradeLicenseFile.value = file;
      tradeLicenseError.value = null;
    }
  }

  Future<void> pickTaxIdFile() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (files.isNotEmpty) {
      final file = files.first;
      final size = file.lengthSync() ?? await file.length();
      if (size > AppConstants.maxUploadSizeBytes) {
        taxIdFileError.value = 'File must be less than 5MB';
        return;
      }
      taxIdFile.value = file;
      taxIdFileError.value = null;
    }
  }

  Future<void> pickBinFile() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (files.isNotEmpty) {
      final file = files.first;
      final size = file.lengthSync() ?? await file.length();
      if (size > AppConstants.maxUploadSizeBytes) {
        binFileError.value = 'File must be less than 5MB';
        return;
      }
      binFile.value = file;
      binFileError.value = null;
    }
  }

  // ── Submit ──
  Future<void> submit() async {
    isLoading.value = true;
    fieldErrors.clear();

    final tlBytes = tradeLicenseFile.value != null
        ? await tradeLicenseFile.value!.readAsBytes()
        : null;
    final taxBytes = taxIdFile.value != null
        ? await taxIdFile.value!.readAsBytes()
        : null;
    final binBytes = binFile.value != null
        ? await binFile.value!.readAsBytes()
        : null;

    final result = await _registerUseCase(
      companyName: companyNameController.text.trim(),
      address: addressController.text.trim(),
      contactPerson: contactPersonController.text.trim(),
      phone: phoneController.text.trim(),
      tradeLicenseNumber: tradeLicenseNumberController.text.trim(),
      tradeLicenseFile: tlBytes,
      taxId: taxIdController.text.trim(),
      taxIdFile: taxBytes,
      binNumber: binNumberController.text.trim(),
      binFile: binBytes,
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    result.fold(
      (failure) {
        isLoading.value = false;
        if (failure is ValidationFailure) {
          failure.fieldErrors.forEach((key, value) {
            fieldErrors[key] = value.first;
          });
        } else {
          AppToast.error(
            title: 'Registration Failed',
            description: failure.message,
          );
        }
      },
      (_) {
        isLoading.value = false;
        Get.offAllNamed('/pending-approval');
      },
    );
  }

  @override
  void onClose() {
    companyNameController.dispose();
    addressController.dispose();
    contactPersonController.dispose();
    phoneController.dispose();
    tradeLicenseNumberController.dispose();
    taxIdController.dispose();
    binNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
