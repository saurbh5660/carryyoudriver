import 'package:get/get.dart';

import '../common/apputills.dart';
import '../generated/assets.dart';
import '../model/feed_item_model.dart';
import '../model/feed_media.dart';
import '../model/profile_response.dart';
import '../network/api_provider.dart';

class ProfileController extends GetxController {
  final pageIndex = 0.obs;
  final isFollowing = 0.obs;
  RxList<FeedItemModel> feedList = RxList();

  Rx<ProfileBody> profileBody = Rx(ProfileBody());


  void onPageChanged(int index) {
    pageIndex.value = index;
  }

  Future<void> getProfile() async {
    try {
      var response = await ApiProvider().getProfile();
      if (response.success == true) {
        profileBody.value = response.body ?? ProfileBody();
      } else {
        Utils.showErrorToast(message: response.message ?? "");
      }
    } catch (e) {
      Utils.showErrorToast(message: "$e");
    }
  }
}
