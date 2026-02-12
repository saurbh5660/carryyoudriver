import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/profile_controller.dart';
import '../generated/assets.dart';
import '../model/feed_item_model.dart';
import '../model/feed_media.dart';

class ProfileItemWidget extends StatelessWidget {
  final FeedItemModel item;

  ProfileItemWidget({super.key, required this.item});

  final ProfileController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 2, color: Colors.grey.shade200),

          /// ================= HEADER =================
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    item.profileImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.userName,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              item.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert),
              ],
            ),
          ),

          /// ================= MEDIA CAROUSEL =================
          Stack(
            children: [
              SizedBox(
                height: 260,
                child: PageView.builder(
                  itemCount: item.media.length,
                  onPageChanged: controller.onPageChanged,
                  itemBuilder: (context, index) {
                    final media = item.media[index];

                    if (media.type == MediaType.image) {
                      return Image.asset(
                        media.url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    } else {
                      return Container(
                        color: Colors.black,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 64,
                        ),
                      );
                    }
                  },
                ),
              ),

              Positioned(
                top: 16,
                right: 16,
                child: Obx(() {
                  if (item.media.length <= 1) return const SizedBox();
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 3,
                      ),
                      child: Text(
                        '${controller.pageIndex.value + 1}/${item.media.length}',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              /// ================= DOT INDICATOR =================
              Positioned(
                left: 24,
                right: 24,
                bottom: 8,
                child: Obx(() {
                  if (item.media.length <= 1) return const SizedBox();

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        item.media.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: controller.pageIndex.value == index ? 8 : 6,
                          height: controller.pageIndex.value == index ? 8 : 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: controller.pageIndex.value == index
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),

          SizedBox(height: 5),

          /// ================= ACTIONS =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Image.asset(
                  Assets.iconsHeartIcon,
                  width: 22,
                  height: 22,
                  color: Colors.black,
                ),
                SizedBox(width: 4),
                Text(
                  '4.5k',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                Image.asset(
                  Assets.iconsCommentIcon,
                  width: 20,
                  height: 20,
                  color: Colors.black,
                ),
                SizedBox(width: 4),
                Text(
                  '4.5k',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                Image.asset(
                  Assets.iconsShare,
                  width: 22,
                  height: 22,
                  color: Colors.black,
                ),
                const Spacer(),
                Text(
                  '4 mins ago',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          /// ================= CAPTION =================
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris read more..\n",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black
                    ),
                  ),
                  TextSpan(text: '#Shopping #Menshopnow',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.5),
                    ),),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
