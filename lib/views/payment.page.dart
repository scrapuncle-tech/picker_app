import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../components/common/custom_back_button.component.dart';
import '../components/common/custom_inkwell.component.dart';
import '../components/common/custom_snackbar.component.dart';
import '../components/common/gradient_button.component.dart';
import '../components/common/text.component.dart';
import '../models/pickup.entity.dart';
import '../utilities/theme/color_data.dart';
import '../utilities/theme/size_data.dart';

class PaymentPage extends ConsumerStatefulWidget {
  final Pickup pickup;

  const PaymentPage({super.key, required this.pickup});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  String _selectedPaymentMethod = 'upi';
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isScanning = false;
  String? _scannedUpiId;

  @override
  void dispose() {
    _upiIdController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _handlePayment() {
    // Placeholder method to handle payment processing
    String paymentDetails = '';

    switch (_selectedPaymentMethod) {
      case 'upi':
        paymentDetails = 'UPI ID: ${_upiIdController.text}';
        break;
      case 'phone':
        paymentDetails = 'Phone Number: ${_phoneNumberController.text}';
        break;
      case 'qr':
        paymentDetails = 'QR Scan: ${_scannedUpiId ?? "No UPI ID scanned"}';
        break;
      case 'cash':
        paymentDetails = 'Cash Payment';
        break;
    }

    debugPrint('Payment processed: $_selectedPaymentMethod');
    debugPrint('Payment details: $paymentDetails');
    debugPrint('Amount: ₹${widget.pickup.totalPrice}');

    CustomSnackBar.log(
      message: "Payment processed successfully",
      status: SnackBarType.success,
    );

    Navigator.pop(context);
  }

  Widget _buildPaymentOption({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return CustomInkWell(
      onPressed: () {
        setState(() {
          _selectedPaymentMethod = value;
          _isScanning = false;
        });
      },
      borderRadius: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                _selectedPaymentMethod == value
                    ? color
                    : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
          color:
              _selectedPaymentMethod == value
                  ? color.withOpacity(0.1)
                  : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: CustomText(text: title, weight: FontWeight.w600, size: 16),
            ),
            if (_selectedPaymentMethod == value)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiIdInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: "Enter UPI ID",
          weight: FontWeight.w600,
          size: 16,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _upiIdController,
          decoration: InputDecoration(
            hintText: "example@upi",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: "Enter Phone Number",
          weight: FontWeight.w600,
          size: 16,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneNumberController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: "10-digit phone number",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQrScanner() {
    return Column(
      children: [
        if (_isScanning)
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            clipBehavior: Clip.hardEdge,
            child: MobileScanner(
              onDetect: (BarcodeCapture capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  setState(() {
                    _scannedUpiId = barcode.rawValue;
                    _isScanning = false;
                  });
                  debugPrint('Scanned UPI: ${barcode.rawValue}');
                  CustomSnackBar.log(
                    message: "QR code scanned successfully",
                    status: SnackBarType.success,
                  );
                }
              },
            ),
          )
        else
          Column(
            children: [
              if (_scannedUpiId != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                    color: Colors.green.withOpacity(0.1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomText(
                          text: "UPI ID: $_scannedUpiId",
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              GradientButton(
                onPressed: () {
                  setState(() {
                    _isScanning = true;
                  });
                },
                text: "Scan QR Code",
                color: Colors.blue,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPaymentQrCode() {
    CustomColorData colorData = CustomColorData.from(ref);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const CustomText(
            text: "Scan to Pay",
            weight: FontWeight.w700,
            size: 18,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data:
                  "upi://pay?pa=example@upi&pn=ScrapUncle&am=${widget.pickup.totalPrice}&cu=INR&tn=Payment for Pickup",
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          CustomText(
            text: "₹${widget.pickup.totalPrice}",
            weight: FontWeight.w900,
            size: 24,
            color: colorData.secondaryColor(1),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);

    double height = sizeData.height;
    double width = sizeData.width;

    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(
            left: width * 0.04,
            right: width * 0.04,
            top: height * 0.02,
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: CustomText(
                      text: "Payment",
                      size: sizeData.superLarge,
                      weight: FontWeight.w900,
                      height: 1.5,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: CustomBackButton(
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.03),
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorData.secondaryColor(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                            text: "Amount to Pay:",
                            weight: FontWeight.w600,
                            size: 16,
                          ),
                          CustomText(
                            text: "₹${widget.pickup.totalPrice}",
                            weight: FontWeight.w900,
                            size: 20,
                            color: colorData.secondaryColor(1),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    const CustomText(
                      text: "Select Payment Method",
                      weight: FontWeight.w700,
                      size: 18,
                    ),
                    SizedBox(height: height * 0.02),
                    _buildPaymentOption(
                      title: "Pay via UPI ID",
                      value: "upi",
                      icon: Icons.account_balance_wallet,
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentOption(
                      title: "Pay via Phone Number",
                      value: "phone",
                      icon: Icons.phone_android,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentOption(
                      title: "Scan QR Code",
                      value: "qr",
                      icon: Icons.qr_code_scanner,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentOption(
                      title: "Cash Payment",
                      value: "cash",
                      icon: Icons.money,
                      color: Colors.orange,
                    ),
                    SizedBox(height: height * 0.03),

                    // Conditional UI based on selected payment method
                    if (_selectedPaymentMethod == "upi") _buildUpiIdInput(),
                    if (_selectedPaymentMethod == "phone")
                      _buildPhoneNumberInput(),
                    if (_selectedPaymentMethod == "qr") _buildQrScanner(),

                    SizedBox(height: height * 0.03),

                    // Show QR code for payment (except when scanning)
                    if (_selectedPaymentMethod != "qr" || !_isScanning)
                      _buildPaymentQrCode(),

                    SizedBox(height: height * 0.03),

                    GradientButton(
                      onPressed: _handlePayment,
                      text: "Process Payment",
                      color: colorData.secondaryColor(1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
