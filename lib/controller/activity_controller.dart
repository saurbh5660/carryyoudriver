import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../common/apputills.dart';
import '../model/booking_list_response.dart';
import '../network/api_provider.dart';

class ActivityController extends GetxController {
  var ongoingRides = <Body>[].obs;
  var pastRides = <Body>[].obs;
  var isLoading = false.obs;
  var todayEarnings = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    getBookingList();
  }

  Future<void> getBookingList() async {
    isLoading.value = true;
    try {
      BookingListResponse response = await ApiProvider().bookingList(false);

      if (response.success == true && response.body != null) {
        ongoingRides.clear();
        pastRides.clear();
        double earningsCounter = 0.0;

        // Get today's date for earnings calculation
        String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

        for (var item in response.body!) {
          int status = item.status ?? 0;

          // Categorize Ongoing vs Past
          if (status == 1 || status == 4 || status == 5) {
            ongoingRides.add(item);
          } else {
            pastRides.add(item);

            // Calculate today's earnings if completed
            if (status == 6 && item.createdAt != null) {
              if (item.createdAt!.startsWith(today)) {
                earningsCounter += double.tryParse(item.amount.toString()) ?? 0.0;
              }
            }
          }
        }
        todayEarnings.value = earningsCounter;
      }
    } catch (e) {
      Utils.showErrorToast(message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String getStatusText(int? status) {
    switch (status) {
      case 1: return "Accepted";
      case 3: return "Customer Cancelled";
      case 4: return "Trip Started";
      case 5: return "Arrived at Pickup";
      case 6: return "Completed";
      case 7: return "You Cancelled";
      default: return "Pending";
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM • hh:mm a').format(dt);
    } catch (e) {
      return dateStr ?? "";
    }
  }
}