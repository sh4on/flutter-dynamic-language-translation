import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class LanguageController extends GetxController {
  Rx<RxStatus> status = Rx<RxStatus>(RxStatus.success());
  RxString currentLanguage = 'en'.obs;
  Rx<ProductModel> product = ProductModel().obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  void changeLanguage(String lang) {
    currentLanguage.value = lang;
  }

  Future<void> fetchProducts() async {
    status.value = RxStatus.loading();

    try {
      final response = await http.get(
        Uri.parse("https://dummyjson.com/products/1"),
      );

      product.value = ProductModel.fromJson(jsonDecode(response.body));

      status.value = RxStatus.success();
    } catch (e) {
      debugPrint(e.toString());

      status.value = RxStatus.error(e.toString());
    }
  }
}
