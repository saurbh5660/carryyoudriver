import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../common/app_colors.dart';
import '../../controller/feed_controller.dart';
import '../../generated/assets.dart';
import '../../item/feed_item_widget.dart';
import '../../routes/app_routes.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  FeedController controller = Get.put(FeedController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toolbar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      Assets.iconsProfileIcon,
                      width: 50,
                      height: 50,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Jolly Marker',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'New York City',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.shopScreen);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        color: AppColor.transparent,
                        child: Icon(Icons.shop, size: 17, color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.messageScreen);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        color: AppColor.transparent,
                        child: Icon(
                          Icons.message,
                          size: 17,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.black,
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.notificationScreen);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        color: AppColor.transparent,
                        child: Icon(
                          Icons.notifications,
                          size: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            //SearchBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Card(
                elevation: 1,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search..",
                              hintStyle: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: double.infinity,
                        width: 50,
                        decoration: BoxDecoration(
                          color: AppColor.yellowColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            // List
            Expanded(
              child: Obx(() {
                return ListView.builder(
                  itemCount: controller.feedList.length,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemBuilder: (item, index) {
                    final item = controller.feedList[index];
                    return FeedItemWidget(item: item);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
