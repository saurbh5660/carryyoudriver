import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/app_colors.dart';
import '../../controller/profile_controller.dart';
import '../../generated/assets.dart';
import '../../item/profile_item_widget.dart';
import '../../routes/app_routes.dart';

class OtherProfileScreen extends StatefulWidget {
  const OtherProfileScreen({super.key});

  @override
  State<OtherProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<OtherProfileScreen> {
  ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.white,
        scrolledUnderElevation: 0,
        leading: Container(
          margin: EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                Get.back();
              },
            ),
          ),
        ),
        title: Text(
          'John Smith',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Image.asset(Assets.iconsProfileDummy, width: 75, height: 75),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Marker',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  '113',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    height: 1,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Posts',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    height: 1,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 16),
                            Column(
                              children: [
                                Text(
                                  '851',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    height: 1,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 2),
                                GestureDetector(
                                  onTap: (){
                                    Get.toNamed(AppRoutes.followerScreen);
                                  },
                                  child: Text(
                                    'Followers',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      height: 1,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bio',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Lorem Ipsum is a dummy text',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    if (controller.isFollowing.value == 1) return SizedBox();
                    return ElevatedButton(
                      onPressed: () {
                        controller.isFollowing.value = 1;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: Size(140, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Follow',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: AppColor.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            SizedBox(height: 16),
            Obx(() {
              if (controller.isFollowing.value == 0) return SizedBox();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Get.offAllNamed(AppRoutes.dashboardView);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColor.transparent,
                            foregroundColor: Colors.black,
                            minimumSize: Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            'Message',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: AppColor.blackColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.offAllNamed(AppRoutes.dashboardView);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            minimumSize: Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            'Following',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: AppColor.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
            SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                return ListView.builder(
                  itemCount: controller.feedList.length,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemBuilder: (item, index) {
                    final item = controller.feedList[index];
                    return ProfileItemWidget(item: item);
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
