import 'package:carry_you_driver/common/apputills.dart';
import 'package:carry_you_driver/controller/wallet_controller.dart';
import 'package:carry_you_driver/model/withdrawal_history_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  WalletController controller = Get.put(WalletController());
  @override
  void initState() {
    super.initState();
    controller.getWalletDetail();
    controller.withdrawalHistory();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Payment Status",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // --- Total Balance Section ---
            Center(
              child: Column(
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Total Balance",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Obx(() {
                      return Text(
                        '\$${controller.walletBody.value.walletAmount ?? "0.0"}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- Withdrawal Input Section ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Enter Withdrawal Amount",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller.amount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "\$0.00",
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.withdrawAmount();
                  // Get.toNamed(AppRoutes.bankAccount);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Withdrawal Now",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- Transaction History Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Transaction History",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                //   decoration: BoxDecoration(
                //     border: Border.all(color: Colors.grey.shade200),
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: Row(
                //     children: [
                //       Text("Today", style: GoogleFonts.poppins(fontSize: 12)),
                //       const Icon(Icons.arrow_drop_down, size: 18),
                //     ],
                //   ),
                // ),
              ],
            ),

            const SizedBox(height: 15),

            Obx(() {
              if (controller.withdrawalBody.isEmpty) {
                return const Center(child: Text("No Transactions"));
              }

              return ListView.builder(
                itemCount: controller.withdrawalBody.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = controller.withdrawalBody[index];
                  String status = item.paymentStatus == 1 ? "Paid" : "Pending";
                  return _buildTransactionCard(
                      item
                  );
                },
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(WithdrawalBody item) {
    Color statusColor = item.paymentStatus == 1 ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Text(item., style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
              Text('Paid Date: ${Utils.formatDate(item.createdAt ?? "")}', style: GoogleFonts.poppins(color: Colors.black, fontSize: 12)),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Order Number: ${item.id ?? ""}",
                style: GoogleFonts.poppins(color: Colors.black, fontSize: 12)),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Withdrawal amount: \$${item.amount ?? ""}",
                  style: GoogleFonts.poppins(color: Colors.black,fontWeight: FontWeight.w500, fontSize: 13)),
              Text(
                'Paid' ,
                style: GoogleFonts.poppins(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
