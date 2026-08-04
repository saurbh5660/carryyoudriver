import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../common/apputills.dart';
import '../model/wallet_response.dart';
import '../model/withdrawal_history_response.dart';
import '../network/api_provider.dart';
import '../views/home/stripe_onboarding_screen.dart';

class WalletController extends GetxController {
  Rx<WalletBody> walletBody = Rx(WalletBody());
  RxList<WithdrawalBody> withdrawalBody = RxList();

  TextEditingController amount = TextEditingController();

  Future<void> getWalletDetail() async {
    var response = await ApiProvider().getWalletDetail();
    if (response.success == true) {
      walletBody.value = response.body ?? WalletBody();
    } else {
      Utils.showErrorToast(message: response.message ?? "");
    }
  }

  Future<void> stripeConnect() async {
    var response = await ApiProvider().stripeConnect();
    if (response.success == true) {
      Get.to(() => StripeConnectScreen(url: response.body ?? ""));
    } else {
      Utils.showErrorToast(message: response.message ?? "");
    }
  }

  Future<void> withdrawalHistory() async {
    var response = await ApiProvider().withdrawalHistory();
    if (response.success == true) {
      withdrawalBody.clear();
      withdrawalBody.assignAll(response.body ?? []);
    } else {
      Utils.showErrorToast(message: response.message ?? "");
    }
  }

  Future<void> withdrawAmount() async {
    if(amount.text.isEmpty){
      Utils.showErrorToast(message: 'Please enter amount to withdraw');
      return;
    }
    if ((double.tryParse(amount.text) ?? 0.0) >
        (double.tryParse(walletBody.value.walletAmount ?? "0.0") ?? 0.0)) {
      Utils.showErrorToast(message: 'Entered amount exceeds wallet balance');
      return;
    }
    Map<String,dynamic> map = {
      'amount' : amount.text.toString()
    };
    var response = await ApiProvider().withdrawAmount(map, true);
    if (response.success == true) {
      if(response.body?.stripeAccountConnected != true && response.body?.id == null){
        stripeConnect();
      }else{
        amount.text = "";
        Utils.showSuccessToast(message: response.message ?? "");
        getWalletDetail();
        withdrawalHistory();
      }
    } else {
      Utils.showErrorToast(message: response.message ?? "");
    }
  }
}
