import 'package:flutter/material.dart';
import 'package:flutter_dynamic_language_translation/features/home/models/product_model.dart';
import 'package:flutter_dynamic_language_translation/features/home/screens/widgets/details_row.dart';
import 'package:get/get.dart';

import '../../../common_widgets/auto_translated_text.dart';
import '../controllers/language_controller.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController controller = Get.put(LanguageController());

    return Scaffold(
      appBar: AppBar(
        title: const AutoTranslatedText("Dynamic Language Translation"),
        actions: [
          Obx(
            () => DropdownButton<String>(
              value: controller.currentLanguage.value,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'fr', child: Text('French')),
                DropdownMenuItem(value: 'es', child: Text('Spanish')),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.changeLanguage(value);
                }
              },
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Obx(() {
        if (controller.status.value.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.status.value.isError) {
          return Center(
            child: Text(
              controller.status.value.errorMessage ?? "Something went wrong!",
            ),
          );
        } else {
          final ProductModel product = controller.product.value;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Title
                  AutoTranslatedText(
                    product.title ?? "",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Description
                  AutoTranslatedText(
                    product.description ?? "",
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  // Price & Discount
                  Row(
                    children: [
                      AutoTranslatedText(
                        "Price: \$${product.price}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(width: 16),

                      if (product.discountPercentage != null)
                        AutoTranslatedText(
                          "${product.discountPercentage}% OFF",
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Rating & Stock
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      Text(" ${product.rating} "),
                      const SizedBox(width: 16),
                      AutoTranslatedText("Stock: ${product.stock}"),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Brand
                  AutoTranslatedText(
                    "Brand: ${product.brand}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 20),

                  // Product Details Section
                  const AutoTranslatedText(
                    "Product Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const Divider(),

                  DetailsRow(label: "SKU", value: product.sku),
                  DetailsRow(label: "Weight", value: "${product.weight}"),

                  if (product.dimensions != null)
                    DetailsRow(
                      label: "Dimensions",
                      value:
                          "${product.dimensions!.width} x ${product.dimensions!.height} x ${product.dimensions!.depth}",
                    ),

                  DetailsRow(
                    label: "Availability",
                    value: product.availabilityStatus,
                  ),
                  DetailsRow(
                    label: "Warranty",
                    value: product.warrantyInformation,
                  ),
                  DetailsRow(
                    label: "Shipping",
                    value: product.shippingInformation,
                  ),

                  const SizedBox(height: 10),

                  // Tags
                  if (product.tags != null && product.tags!.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      children: product.tags!
                          .map(
                            (tag) => Chip(
                              label: AutoTranslatedText(tag),
                              backgroundColor: Colors.blue.shade50,
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          );
        }
      }),
    );
  }
}
