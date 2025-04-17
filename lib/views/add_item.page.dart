import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:location/location.dart';

import '../components/common/custom_back_button.component.dart';
import '../components/common/custom_inkwell.component.dart';
import '../components/common/custom_input_field.dart';
import '../components/common/custom_snackbar.component.dart';
import '../components/common/gradient_button.component.dart';
import '../components/common/text.component.dart';
import '../models/item.entity.dart';
import '../models/product.entity.dart';
import '../providers/current_pickup.provider.dart';
import '../providers/products.provider.dart';
import '../utilities/theme/color_data.dart';
import '../utilities/theme/size_data.dart';

class AddItemPage extends ConsumerStatefulWidget {
  const AddItemPage({super.key});

  @override
  ConsumerState<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends ConsumerState<AddItemPage> {
  List<File> selectedImages = [];
  Product? selectedProduct; // Holds the selected product
  List<String> coordinates = [];

  TextEditingController customPriceCtr = TextEditingController();
  TextEditingController quantityCtr = TextEditingController();
  TextEditingController productNameCtr = TextEditingController();
  bool isWeight = true;

  @override
  initState() {
    super.initState();
    quantityCtr.addListener(() {
      setState(() {});
    });
  }

  fetchLocation() async {
    /// Loaction coordinates fetch! (will be optimized latter) // FOR NOW!
    PermissionStatus permissionStatus = await Location().hasPermission();
    if (permissionStatus != PermissionStatus.granted) {
      await Location().requestPermission();
    }

    LocationData locationData = await Location().getLocation();
    coordinates = [
      locationData.latitude.toString(),
      locationData.longitude.toString(),
    ];
  }

  // Image picker function
  imagePicker() async {
    if (selectedImages.length < 20) {
      ImagePicker imagePicker = ImagePicker();
      XFile? image = await imagePicker.pickImage(source: ImageSource.camera);

      if (image != null) {
        setState(() {
          selectedImages.add(File(image.path));
        });
      } else {
        CustomSnackBar.show(
          message: "Please select at least 1 image",
          type: SnackBarType.error,
          ref: ref,
        );
      }
    } else {
      CustomSnackBar.show(
        message: "You can only add 20 images",
        type: SnackBarType.error,
        ref: ref,
      );
    }
  }

  removeImage(File image) {
    setState(() {
      selectedImages.remove(image);
    });
  }

  setUnit(bool value) {
    setState(() {
      isWeight = value;
    });
  }

  addItem({required double totalPrice}) async {
    bool isWeightUnit =
        selectedProduct != null ? selectedProduct!.unit == "weight" : isWeight;

    ref
        .read(currentPickupProvider.notifier)
        .addItem(
          item: Item(
            id:
                (selectedProduct != null
                    ? selectedProduct!.id
                    : productNameCtr.text) +
                DateTime.now().toString(),
            createdAt: DateTime.now(),
            isUploaded: false,
            product:
                selectedProduct ??
                Product(
                  id: "${productNameCtr.text}.${customPriceCtr.text}",
                  name: productNameCtr.text,
                  price: customPriceCtr.text,
                  unit: isWeightUnit ? "weight" : "quantity",
                ),
            quantity: !isWeightUnit ? double.parse(quantityCtr.text.trim()) : 0,
            weight: isWeightUnit ? double.parse(quantityCtr.text.trim()) : 0,
            customPrice:
                customPriceCtr.text.isNotEmpty
                    ? double.parse(customPriceCtr.text.trim())
                    : null,
            localImagePaths: selectedImages.map((image) => image.path).toList(),
            totalPrice: totalPrice,
            coordinates: coordinates,
          ),
        );

    Navigator.pop(context);
  }

  clearControllers() {
    customPriceCtr.clear();
    quantityCtr.clear();
    productNameCtr.clear();
  }

  @override
  void dispose() {
    customPriceCtr.dispose();
    quantityCtr.dispose();
    productNameCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CustomColorData colorData = CustomColorData.from(ref);
    CustomSizeData sizeData = CustomSizeData.from(context);

    double height = sizeData.height;
    double width = sizeData.width;
    double aspectRatio = sizeData.aspectRatio;

    List<Product> products = ref.watch(productsProvider);

    bool canAddItem =
        (selectedProduct != null ||
            (productNameCtr.text.isNotEmpty &&
                customPriceCtr.text.isNotEmpty)) &&
        quantityCtr.text.isNotEmpty &&
        selectedImages.isNotEmpty;

    double totalPrice =
        quantityCtr.text.isNotEmpty &&
                (selectedProduct != null || customPriceCtr.text.isNotEmpty)
            ? (double.parse(quantityCtr.text.toString()) *
                double.parse(
                  selectedProduct != null && customPriceCtr.text.isEmpty
                      ? selectedProduct!.price
                      : customPriceCtr.text.toString(),
                ))
            : 0;

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
              // Page Title
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: CustomText(
                      text: "Add Item",
                      size: sizeData.superLarge,
                      weight: FontWeight.w900,
                      height: 1.5,
                    ),
                  ),
                  Positioned(top: 0, left: 0, child: CustomBackButton()),
                ],
              ),

              SizedBox(height: height * 0.03),

              Expanded(
                child: ListView(
                  children: [
                    // Image Picker Button
                    GradientButton(
                      onPressed: () => imagePicker(),
                      text: "Add Item Image +",
                      color: Colors.blue,
                    ),

                    SizedBox(height: height * 0.02),

                    // Image List Display
                    Row(
                      children: [
                        CustomText(
                          text: "Item Images:",
                          size: sizeData.header,
                          weight: FontWeight.w800,
                        ),
                        SizedBox(width: width * 0.02),
                        CustomText(
                          text: "(max 20 images)",
                          weight: FontWeight.w800,
                          color: colorData.fontColor(.5),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.01),

                    if (selectedImages.isNotEmpty)
                      SizedBox(
                        height: height * .225,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.02,
                            vertical: height * 0.01,
                          ),
                          itemCount: selectedImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: width * .05),
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: colorData.secondaryColor(1),
                                    border: Border.all(
                                      color: colorData.fontColor(.2),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(selectedImages[index]),
                                  ),
                                ),
                                Positioned(
                                  top: -aspectRatio * 10,
                                  right: width * 0.03,
                                  child: IconButton(
                                    onPressed:
                                        () =>
                                            removeImage(selectedImages[index]),
                                    icon: Icon(
                                      Symbols.delete_rounded,
                                      fill: 1,
                                      grade: 200,
                                      weight: 700,
                                      color: Colors.redAccent,
                                      size: aspectRatio * 50,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    else ...[
                      Image.asset("assets/images/UNF.png", height: height * .2),
                      CustomText(
                        text: "No images have been added yet!",
                        weight: FontWeight.w800,
                        color: colorData.fontColor(.5),
                      ),
                    ],

                    SizedBox(height: height * 0.03),
                    // Product Selection Dropdown
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomText(
                        text: "Select Product:",
                        size: sizeData.header,
                        weight: FontWeight.w800,
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(top: height * 0.02),
                      padding: EdgeInsets.symmetric(
                        horizontal: aspectRatio * 40,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blueAccent, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withAlpha(40),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownSearch<Product?>(
                        selectedItem: selectedProduct,
                        items:
                            (filter, infiniteScrollProps) => [
                              Product(
                                id: '',
                                name: 'Custom Product',
                                price: '',
                                unit: '',
                              ),
                              ...products,
                            ],
                        itemAsString:
                            (Product? item) => item?.name ?? "Custom Product",
                        compareFn: (item1, item2) => item1?.name == item2?.name,
                        decoratorProps: DropDownDecoratorProps(
                          decoration: InputDecoration(border: InputBorder.none),
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value != null && value.id.isNotEmpty) {
                              selectedProduct = value;
                            } else {
                              selectedProduct = null;
                            }
                            clearControllers();
                          });
                        },
                        dropdownBuilder: (context, selectedItem) {
                          return Row(
                            children: [
                              Expanded(
                                child: CustomText(
                                  text: selectedItem?.name ?? "Custom Product",
                                  size: sizeData.subHeader,
                                  weight: FontWeight.w800,
                                ),
                              ),
                              if (selectedItem != null &&
                                  selectedItem.id.isNotEmpty) ...[
                                SizedBox(width: width * 0.04),
                                CustomText(
                                  text: "₹${selectedItem.price}",
                                  size: sizeData.subHeader,
                                  color: Colors.green,
                                  weight: FontWeight.w900,
                                ),
                              ] else
                                SizedBox(),
                            ],
                          );
                        },
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              hintText: "Search product...",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    ),

                    ///
                    if (selectedProduct == null) ...[
                      SizedBox(height: height * 0.025),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CustomText(
                          text: "Product Name : ",
                          size: sizeData.header,
                          weight: FontWeight.w800,
                        ),
                      ),
                      CustomInputField(
                        controller: productNameCtr,
                        hintText: "Enter product name : (required)",
                        inputType: TextInputType.text,
                      ),
                      SizedBox(height: height * 0.025),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CustomText(
                          text: "Product unit [weight/quantity]: ",
                          size: sizeData.header,
                          weight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: height * 0.012),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GradientButton(
                            onPressed: () => setUnit(true),
                            text: "Weight",
                            color:
                                !isWeight
                                    ? colorData.secondaryColor(1)
                                    : Colors.greenAccent,
                            horizontalPadding: width * .1,
                          ),
                          GradientButton(
                            onPressed: () => setUnit(false),
                            text: "Quantity",
                            color:
                                isWeight
                                    ? colorData.secondaryColor(1)
                                    : Colors.purpleAccent,
                            horizontalPadding: width * .1,
                          ),
                        ],
                      ),
                    ],

                    SizedBox(height: height * 0.025),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomText(
                        text:
                            selectedProduct == null
                                ? "Product Price : "
                                : "Custom Price :",
                        size: sizeData.header,
                        weight: FontWeight.w800,
                      ),
                    ),
                    CustomInputField(
                      controller: customPriceCtr,
                      hintText:
                          selectedProduct == null
                              ? "Enter Product Price : (required)"
                              : "Enter Custom Price : (if needed)",
                      inputType: TextInputType.number,
                    ),

                    SizedBox(height: height * 0.025),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomText(
                        text: "Quantity / Weight :",
                        size: sizeData.header,
                        weight: FontWeight.w800,
                      ),
                    ),
                    CustomInputField(
                      controller: quantityCtr,
                      hintText: "Enter Quantity or weight : (required)",
                      inputType: TextInputType.number,
                    ),

                    if (canAddItem) ...[
                      SizedBox(height: height * 0.02),
                      Row(
                        children: [
                          CustomText(
                            text: "Total Price: ",
                            weight: FontWeight.w800,
                            color: colorData.fontColor(.6),
                            size: sizeData.subHeader,
                          ),
                          SizedBox(width: width * .02),
                          CustomText(
                            text: ' ₹ $totalPrice',
                            weight: FontWeight.w900,
                            color: colorData.fontColor(.9),
                            size: sizeData.header,
                          ),
                        ],
                      ),
                    ],
                    Center(
                      child: Opacity(
                        opacity: !canAddItem ? .5 : 1,
                        child: CustomInkWell(
                          onPressed:
                              () =>
                                  canAddItem
                                      ? addItem(totalPrice: totalPrice)
                                      : null,
                          borderRadius: 50,
                          splashColor:
                              !canAddItem
                                  ? Colors.transparent
                                  : colorData.fontColor(.5),
                          margin: EdgeInsets.only(
                            bottom: height * 0.05,
                            top: height * .03,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: aspectRatio * 24,
                              horizontal: width * .2,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorData.fontColor(.1),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(50),
                              gradient: LinearGradient(
                                colors: [
                                  colorData.secondaryColor(.4),
                                  colorData.secondaryColor(1),
                                ],
                              ),
                            ),
                            child: CustomText(
                              text: "Add Item",
                              size: sizeData.header,
                              weight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
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
