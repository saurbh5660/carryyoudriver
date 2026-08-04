import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../common/apputills.dart';
import '../model/booking_history_response.dart';
import '../network/api_provider.dart';

class ActivityController extends GetxController {
  // Data lists for each Tab
  var ongoingList = <BookingJobHistory>[].obs;
  var pendingList = <BookingJobHistory>[].obs;
  var pastList = <BookingJobHistory>[].obs;

  // Pagination & Loading States
  var isLoading = false.obs;
  var isMoreLoading = false.obs;

  final int limit = 10;
  int ongoingSkip = 0;
  int pendingSkip = 0;
  int pastSkip = 0;

  var hasMoreOngoing = true.obs;
  var hasMorePending = true.obs;
  var hasMorePast = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch initial data for all tabs
    fetchData(status: 0, isRefresh: true); // Ongoing
    fetchData(status: 1, isRefresh: true); // Pending
    fetchData(status: 2, isRefresh: true); // Past
  }

  Future<void> fetchData({required int status, bool isRefresh = false}) async {
    // Prevent multiple simultaneous calls for the same tab
    if (isRefresh) {
      _setSkip(status, 0);
      _setHasMore(status, true);
      isLoading.value = true;
    } else {
      if (!_getHasMore(status) || isMoreLoading.value) return;
      isMoreLoading.value = true;
    }

    try {
      // Prepare the body for the query string
      Map<String, dynamic> queryBody = {
        "status": status.toString(),
        "limit": limit.toString(),
        "skip": _getSkip(status).toString(),
      };

      BookingHistoryResponse response = await ApiProvider().bookingJobHistory(queryBody, false);

      if (response.success == true && response.body != null) {
        if (isRefresh) {
          _getList(status).assignAll(response.body!);
        } else {
          _getList(status).addAll(response.body!);
        }

        // Handle Pagination logic
        if (response.body!.length < limit) {
          _setHasMore(status, false);
        } else {
          _setSkip(status, _getSkip(status) + limit);
        }
      }
    } catch (e) {
      Utils.showErrorToast(message: e.toString());
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  // --- Helper Helpers to manage state based on Tab index ---

  RxList<BookingJobHistory> _getList(int status) {
    if (status == 0) return ongoingList;
    if (status == 1) return pendingList;
    return pastList;
  }

  int _getSkip(int status) => status == 0 ? ongoingSkip : (status == 1 ? pendingSkip : pastSkip);

  void _setSkip(int status, int val) {
    if (status == 0) ongoingSkip = val;
    else if (status == 1) pendingSkip = val;
    else pastSkip = val;
  }

  bool _getHasMore(int status) => status == 0 ? hasMoreOngoing.value : (status == 1 ? hasMorePending.value : hasMorePast.value);

  void _setHasMore(int status, bool val) {
    if (status == 0) hasMoreOngoing.value = val;
    else if (status == 1) hasMorePending.value = val;
    else hasMorePast.value = val;
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      DateTime dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM, hh:mm a').format(dt);
    } catch (e) {
      return dateStr ?? "";
    }
  }
}