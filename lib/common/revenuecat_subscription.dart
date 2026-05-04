import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../network/api_provider.dart';
import '../routes/app_routes.dart';
import 'apputills.dart';
import 'db_helper.dart';

class PurchaseApi {
  ///TO DO: add the entitlement ID from the RevenueCat dashboard that is activated upon successful in-app purchase for the duration of the purchase.
  static String entitlementID = 'com.live.ocymGlobalapp';

  ///TO DO: add the Apple API key for your app from the RevenueCat dashboard: https://app.revenuecat.com
  static String appleApiKey = "appl_GnQzqABGFLKJwhnmySgVHqoFIkA";

  ///TO DO: add the Google API key for your app from the RevenueCat dashboard: https://app.revenuecat.com
  static String googleApiKey = 'goog_XTLfJcMJZmRylkQYwxkvXQTLLLB';
  // static String googleApiKey = 'test_pQETTHXrKTmYPiquTLvdNgwSKaN';

  static Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.info);
    PurchasesConfiguration configuration = PurchasesConfiguration(appleApiKey);
    if (GetPlatform.isAndroid) {
      configuration = PurchasesConfiguration(googleApiKey);
    } else if (GetPlatform.isIOS) {
      configuration = PurchasesConfiguration(appleApiKey);
    }
    await Purchases.configure(configuration);
  }

  static Future<List<Offering>> fetchOffers() async {
    try {
      final offerings = await Purchases.getOfferings();
      debugPrint("offerings: ${offerings.all}");

      return offerings.all.values.toList();
    } catch (error) {
      log("$error", name: "BaseX");
      return [];
    }
  }

  static Future<void> buyPlan({
    required Package? package,
    required String timeDuration,
    required String screenType,
  }) async {
    log("value ===> buy plan ");
    Utils.showLoading();
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package!);
      removeProductId(package.storeProduct.identifier);
      var isPro =
          customerInfo.entitlements.all[entitlementID]?.isActive ?? false;

      log("value ===> $isPro");
      log(
        "value ===> ${customerInfo.entitlements.all[entitlementID]?.isActive}",
      );
      Utils.hideLoading();

      if (isPro) {
        log("Hello====> purchased completed====>");

        handlePackage(
          package.storeProduct.title,
          package.storeProduct.priceString,
          timeDuration,
          screenType,
          package.storeProduct.identifier,
        );
      }
    } on PlatformException catch (e, str) {
      log("str===============ddd====>$str");
      Utils.hideLoading();
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        log(
          "str==========eeee=====ddd====>${PurchasesErrorCode.productAlreadyPurchasedError}",
        );
        Utils.showErrorToast(message: e.message ?? '');
      }
    }
  }
  static List<String> purchasedProductIds =
  [];

  static void removeProductId(String productId) {
    purchasedProductIds.remove(productId);
    log("Removed product ID: $productId");
  }
  static String cleanPrice(String price) {
    return price.replaceAll(RegExp(r'[^\d.]'), '');
  }

  static Future subscriptionApi({
    required productId,
    required subscriptionPrice,
  }) async {
    Utils.showLoading();
    Map<String, dynamic> data = {};
    int priceInt = int.parse(cleanPrice(subscriptionPrice));
      data = {
        "productId": productId,
        "subscriptionPrice": priceInt.toString(),
      };
    // var response = await ApiProvider().userSubscription(data);
    // if (response.success == true) {
    //   Utils.hideLoading();
    //   if (response.body != null) {
    //     Utils.hideLoading();
    //     // DbHelper().saveUserModel(response.body);
    //     Utils.showSuccessToast(message: "Subscription purchased successfully");
    //     Get.offAllNamed(AppRoutes.dashboardView);
    //   }
    // } else {
    //   Utils.hideLoading();
    //   Get.back(result: 1);
    // }
  }
  static void handlePackage(
      String fullTitle,
      dynamic price,
      String timeDuration,
      String screenType,
      String productId,
      ) {
    try {

      // Call the API
      subscriptionApi(
        // productId: Utils.normalizeProductId(productId),
        productId: productId,
        subscriptionPrice: price,
      );
    } catch (e) {
      log("Error in handlePackage: $e");
    }
  }

  static String extractPackageTitle(String fullTitle) {
    final regex = RegExp(r'^[^(]+'); // everything before first "("
    final match = regex.firstMatch(fullTitle.trim());
    return match?.group(0)?.trim() ?? fullTitle;
  }
}
