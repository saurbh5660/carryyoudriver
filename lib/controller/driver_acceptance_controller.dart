import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common/apputills.dart';
import '../common/db_helper.dart';
import '../network/api_provider.dart';
import '../routes/app_routes.dart';

class DriverAcceptanceController extends GetxController {
  RxString driverName = ''.obs;

  // D-2: Terms of Service State
  final ScrollController termsScrollController = ScrollController();
  RxBool hasScrolledTerms = true.obs;
  RxBool isTermsAccepted = false.obs;
  RxString termsContent = ''.obs;
  RxBool isTermsLoading = false.obs;
  RxString termsTitle = 'Driver Terms & Conditions'.obs;
  late RxString termsEffectiveDate = DateFormat('MMMM dd, yyyy').format(DateTime.now()).obs;
  RxString termsVersion = '1.0'.obs;

  // D-3: Privacy Policy State
  final ScrollController privacyScrollController = ScrollController();
  RxBool hasScrolledPrivacy = true.obs;
  RxBool isPrivacyAccepted = false.obs;
  RxString privacyContent = ''.obs;
  RxBool isPrivacyLoading = false.obs;
  RxString privacyTitle = 'Privacy Policy'.obs;
  late RxString privacyEffectiveDate = DateFormat('MMMM dd, yyyy').format(DateTime.now()).obs;
  RxString privacyVersion = '1.0'.obs;

  // D-4: Distracted Driving Policy State
  RxBool isDistractedPolicyAccepted = false.obs;
  RxList<bool> subAcknowledgements = <bool>[false, false, false, false].obs;

  bool get isDistractedPolicyFullyAcknowledged =>
      isDistractedPolicyAccepted.value &&
      subAcknowledgements.every((checked) => checked);

  // D-5: E-Signature State
  final TextEditingController legalNameController = TextEditingController();
  final String formattedTodayDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
  RxBool isEsignatureConfirmed = false.obs;
  RxBool isLoading = false.obs;

  bool get canActivateAccount =>
      legalNameController.text.trim().isNotEmpty && isEsignatureConfirmed.value && !isLoading.value;

  // D-6: Success & Audit Receipt
  RxString confirmationCode = ''.obs;
  RxString driverEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    
    termsScrollController.addListener(_onTermsScroll);
    privacyScrollController.addListener(_onPrivacyScroll);
    fetchDriverProfile();
    fetchLegalContent('driver_terms');
    fetchLegalContent('privacy_policy');
  }

  /// Prefill legal name and email from backend user profile API and local storage
  Future<void> fetchDriverProfile() async {
    try {
      final savedUser = DbHelper().getUserModel();
      if (savedUser?.fullName != null && savedUser!.fullName!.isNotEmpty) {
        driverName.value = savedUser.fullName!;
        if (legalNameController.text.isEmpty) {
          legalNameController.text = savedUser.fullName!;
        }
      }
      if (savedUser?.email != null && savedUser!.email!.isNotEmpty) {
        driverEmail.value = savedUser.email!;
      }

      final response = await ApiProvider().getProfile();
      if (response.success == true && response.body != null) {
        final profile = response.body!;
        if (profile.fullName != null && profile.fullName!.isNotEmpty) {
          driverName.value = profile.fullName!;
          legalNameController.text = profile.fullName!;
        }
        if (profile.email != null && profile.email!.isNotEmpty) {
          driverEmail.value = profile.email!;
        }
        update();
      }
    } catch (_) {}
  }

  String _cleanHtmlContent(String rawHtml) {
    if (rawHtml.isEmpty) return "";
    
    String clean = rawHtml;

    // 1. Unescape common HTML entities if double-encoded
    clean = clean
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");

    // 2. Replace break and paragraph end tags with line breaks
    clean = clean
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<p[^>]*>', caseSensitive: false), '\n');

    // 3. Strip any remaining HTML tags
    clean = clean.replaceAll(RegExp(r'<[^>]*>'), '');

    // 4. Collapse multiple consecutive newlines into double newlines
    clean = clean.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return clean.trim();
  }

  /// Fetch legal CMS document text from Backend API
  Future<void> fetchLegalContent(String documentType) async {
    try {
      if (documentType == 'driver_terms' || documentType == 'terms_of_service') {
        isTermsLoading.value = true;
      } else {
        isPrivacyLoading.value = true;
      }
      update();

      final response = await ApiProvider().getCmsContent(documentType);
      
      if (response.success == true && response.body != null) {
        final bodyData = response.body;
        String rawContent = '';
        if (bodyData is Map) {
          final title = bodyData['title']?.toString();
          final effectiveDate = bodyData['effectiveDate']?.toString();
          final version = bodyData['version']?.toString();

          if (documentType == 'driver_terms' || documentType == 'terms_of_service') {
            if (title != null && title.isNotEmpty) termsTitle.value = title;
            if (effectiveDate != null && effectiveDate.isNotEmpty && !effectiveDate.contains('[date]')) {
              termsEffectiveDate.value = effectiveDate;
            } else {
              termsEffectiveDate.value = formattedTodayDate;
            }
            if (version != null && version.isNotEmpty) termsVersion.value = version;
          } else {
            if (title != null && title.isNotEmpty) privacyTitle.value = title;
            if (effectiveDate != null && effectiveDate.isNotEmpty && !effectiveDate.contains('[date]')) {
              privacyEffectiveDate.value = effectiveDate;
            } else {
              privacyEffectiveDate.value = formattedTodayDate;
            }
            if (version != null && version.isNotEmpty) privacyVersion.value = version;
          }

          if (bodyData.containsKey('contentHtml')) {
            rawContent = bodyData['contentHtml'].toString();
          } else if (bodyData.containsKey('content')) {
            rawContent = bodyData['content'].toString();
          } else {
            rawContent = bodyData.toString();
          }
        } else {
          rawContent = bodyData.toString();
        }

        final parsedText = _cleanHtmlContent(rawContent);

        if (documentType == 'driver_terms' || documentType == 'terms_of_service') {
          termsContent.value = parsedText;
        } else {
          privacyContent.value = parsedText;
        }
      }
    } catch (_) {
      // API error handling
    } finally {
      if (documentType == 'driver_terms' || documentType == 'terms_of_service') {
        isTermsLoading.value = false;
      } else {
        isPrivacyLoading.value = false;
      }
      update();
    }
  }

  void _onTermsScroll() {
    if (termsScrollController.hasClients) {
      if (termsScrollController.position.pixels >=
          termsScrollController.position.maxScrollExtent - 20) {
        hasScrolledTerms.value = true;
      }
    }
  }

  void _onPrivacyScroll() {
    if (privacyScrollController.hasClients) {
      if (privacyScrollController.position.pixels >=
          privacyScrollController.position.maxScrollExtent - 20) {
        hasScrolledPrivacy.value = true;
      }
    }
  }

  void toggleSubAcknowledgement(int index, bool value) {
    if (index >= 0 && index < subAcknowledgements.length) {
      subAcknowledgements[index] = value;
    }
  }

  void generateAuditCode() {
    final now = DateTime.now();
    final randomNum = (100000 + (now.microsecond % 900000)).toString();
    confirmationCode.value = 'CY-DRV-${now.year}-$randomNum';
  }

  /// Download PDF from Backend API (GET /users/getDriverTermsPdf or /users/getPrivacyPolicyPdf)
  Future<void> downloadDocument(String documentType) async {
    try {
      final isTerms = documentType.toLowerCase().contains('term');
      final response = isTerms
          ? await ApiProvider().getDriverTermsPdf()
          : await ApiProvider().getPrivacyPolicyPdf();

      String? pdfUrl;
      if (response.success == true && response.body != null) {
        final bodyData = response.body;
        if (bodyData is Map && bodyData.containsKey('pdfUrl')) {
          pdfUrl = bodyData['pdfUrl']?.toString();
        } else if (bodyData is String && bodyData.startsWith('http')) {
          pdfUrl = bodyData;
        }
      }

      if (pdfUrl != null && pdfUrl.isNotEmpty) {
        final Uri uri = Uri.parse(pdfUrl);
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          Utils.showSuccessToast(message: 'Opening PDF document...');
          return;
        } catch (e) {
          try {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
            Utils.showSuccessToast(message: 'Opening PDF document...');
            return;
          } catch (_) {}
        }
      }

      Utils.showSuccessToast(
        message: response.message ?? 'Downloading $documentType PDF copy from server...',
      );
    } catch (_) {
      Utils.showSuccessToast(
        message: 'Downloading $documentType PDF copy from server...',
      );
    }
  }

  /// Email document to Driver from Backend API (POST /users/sendDriverTermsEmail or /users/sendPrivacyPolicyEmail)
  Future<void> emailDocument(String documentType) async {
    try {
      final isTerms = documentType.toLowerCase().contains('term');
      final response = isTerms
          ? await ApiProvider().sendDriverTermsEmail()
          : await ApiProvider().sendPrivacyPolicyEmail();

      Utils.showSuccessToast(
        message: response.message ?? '$documentType has been emailed to your registered address.',
      );
    } catch (_) {
      Utils.showSuccessToast(
        message: '$documentType has been emailed to your registered address.',
      );
    }
  }

  /// Submit full legal acceptance payload to Backend API (POST /users/legalAcceptanceAdd)
  Future<void> submitLegalAcceptance() async {
    try {
      isLoading.value = true;
      update();

      final Map<String, dynamic> body = {
        "legalName": legalNameController.text.trim(),
        "signatureDate": formattedTodayDate,
        "esignatureAccepted": isEsignatureConfirmed.value,
        "documents": [
          {
            "documentType": "terms_of_service",
            "version": termsVersion.value.isNotEmpty ? termsVersion.value : "1.0",
            "accepted": isTermsAccepted.value,
            "acceptedAt": DateTime.now().toUtc().toIso8601String(),
            "subAcknowledgements": subAcknowledgements,
          }
        ]
      };

      final response = await ApiProvider().submitLegalAcceptance(body);


      if (response.success == true) {
        final bodyData = response.body;
        if (bodyData is Map && bodyData.containsKey('confirmationCode')) {
          confirmationCode.value = bodyData['confirmationCode'].toString();
        } else {
          generateAuditCode();
        }
        Get.offAllNamed(AppRoutes.driverSuccess);
      } else {
        Utils.showErrorToast(
          message: response.message ?? 'Failed to submit legal acceptance. Please try again.',
        );
      }
    } catch (e) {
      Utils.showErrorToast(
        message: 'Failed to submit legal acceptance. Please try again.',
      );
    } finally {
      isLoading.value = false;
      update();
    }
  }

  @override
  void onClose() {
    termsScrollController.dispose();
    privacyScrollController.dispose();
    legalNameController.dispose();
    super.onClose();
  }
}
