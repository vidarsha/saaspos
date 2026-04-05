import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:saaspos/core/providers/business_provider.dart';

class ProductState {
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> brands;
  final bool isLoading;
  final String? selectedCategory;
  final String searchQuery;

  ProductState({
    this.products = const [],
    this.categories = const [],
    this.brands = const [],
    this.isLoading = false,
    this.selectedCategory,
    this.searchQuery = '',
  });

  ProductState copyWith({
    List<Map<String, dynamic>>? products,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? brands,
    bool? isLoading,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return ProductState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      isLoading: isLoading ?? this.isLoading,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  final Ref ref;
  ProductNotifier(this.ref) : super(ProductState(isLoading: true)) {
    loadProductData();
  }

  Future<void> loadProductData() async {
    final businessId = ref.read(businessProvider).business?['id'];
    if (businessId == null) return;

    try {
      state = state.copyWith(isLoading: true);
      final supabase = Supabase.instance.client;

      // Fetch Categories
      final catResponse = await supabase
          .from('categories')
          .select()
          .eq('business_id', businessId)
          .order('name');

      // Fetch Brands
      final brandResponse = await supabase
          .from('brands')
          .select()
          .eq('business_id', businessId)
          .order('name');

      // Fetch Products with basic inventory count
      var query = supabase
          .from('products')
          .select('*, category:categories(name), inventory(quantity)')
          .eq('business_id', businessId);

      if (state.selectedCategory != null) {
        query = query.eq('category_id', state.selectedCategory!);
      }

      if (state.searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%${state.searchQuery}%,sku.ilike.%${state.searchQuery}%');
      }

      final prodResponse = await query.order('name');

      state = state.copyWith(
        products: List<Map<String, dynamic>>.from(prodResponse),
        categories: List<Map<String, dynamic>>.from(catResponse),
        brands: List<Map<String, dynamic>>.from(brandResponse),
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) print('Load Product Data Error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  void filterByCategory(String? categoryId) {
    state = state.copyWith(selectedCategory: categoryId);
    loadProductData();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadProductData();
  }

  Future<void> addCategory(String name, {String? parentId}) async {
    try {
      final businessId = ref.read(businessProvider).business?['id'];
      if (businessId == null) throw 'Business session expired';
      
      await Supabase.instance.client.from('categories').insert({
        'business_id': businessId,
        'name': name,
        'parent_id': parentId,
      });
      await loadProductData();
    } catch (e) {
      if (kDebugMode) print('Add Category Error: $e');
      rethrow;
    }
  }

  Future<void> createProduct(Map<String, dynamic> productData, {List<Map<String, dynamic>>? variants}) async {
    try {
      final businessId = ref.read(businessProvider).business?['id'];
      if (businessId == null) throw 'Business session expired';

      final supabase = Supabase.instance.client;

      final productResponse = await supabase.from('products').insert({
        ...productData,
        'business_id': businessId,
      }).select().single();

      if (variants != null && variants.isNotEmpty) {
        final productId = productResponse['id'];
        await supabase.from('product_variants').insert(
              variants.map((v) => {...v, 'product_id': productId, 'business_id': businessId}).toList(),
            );
      }

      await loadProductData();
    } catch (e) {
      if (kDebugMode) print('Create Product Error: $e');
      rethrow;
    }
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier(ref);
});
