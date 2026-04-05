import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saaspos/features/products/providers/product_provider.dart';
import 'package:saaspos/features/products/widgets/add_product_drawer.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      endDrawer: const AddProductDrawer(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategorySidebar(context, ref, state),
          const VerticalDivider(width: 1, color: Color(0xFFF1F5F9)),
          Expanded(child: _buildProductCatalog(context, ref, state)),
        ],
      ),
    );
  }

  Widget _buildCategorySidebar(BuildContext context, WidgetRef ref, ProductState state) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categories', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          const SizedBox(height: 24),
          _buildCategoryItem(ref, 'All Products', null, state.selectedCategory == null),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: state.categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final cat = state.categories[index];
                return _buildCategoryItem(ref, cat['name'], cat['id'].toString(), state.selectedCategory == cat['id'].toString());
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildAddCategoryButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(WidgetRef ref, String name, String? id, bool isSelected) {
    return InkWell(
      onTap: () => ref.read(productProvider.notifier).filterByCategory(id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(id == null ? Icons.all_inclusive : Icons.folder_open_outlined,
                size: 18, color: isSelected ? Colors.blueAccent : const Color(0xFF64748B)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.blueAccent : const Color(0xFF475569),
                ),
              ),
            ),
            if (isSelected) const Icon(Icons.chevron_right, size: 14, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCatalog(BuildContext context, WidgetRef ref, ProductState state) {
    return Column(
      children: [
        _buildTopBar(context, ref, state),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.products.isEmpty
                      ? _buildEmptyState()
                      : _buildDataTable(state),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref, ProductState state) {
    return Container(
      padding: const EdgeInsets.all(32),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => ref.read(productProvider.notifier).setSearchQuery(v),
              decoration: InputDecoration(
                hintText: 'Search products by name or SKU...',
                prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 24),
          ElevatedButton.icon(
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(ProductState state) {
    return SingleChildScrollView(
      child: DataTable(
        columnSpacing: 40,
        horizontalMargin: 24,
        headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 13),
        columns: const [
          DataColumn(label: Text('SKU')),
          DataColumn(label: Text('Product Name')),
          DataColumn(label: Text('Price (LKR)')),
          DataColumn(label: Text('Stock')),
          DataColumn(label: Text('Actions')),
        ],
        rows: state.products.map((p) {
          final stock = p['inventory'] != null && p['inventory'].isNotEmpty ? p['inventory'][0]['quantity'] : 0;
          return DataRow(cells: [
            DataCell(Text(p['sku'] ?? '-', style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold))),
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(p['name'], style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                  Text(p['category']?['name'] ?? 'Uncategorized',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            DataCell(Text(p['selling_price'].toString(), style: const TextStyle(fontWeight: FontWeight.w600))),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (stock > (p['low_stock_threshold'] ?? 5) ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  stock.toString(),
                  style: TextStyle(
                      color: (stock > (p['low_stock_threshold'] ?? 5) ? Colors.green : Colors.red),
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataCell(IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)))),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[200]),
          const SizedBox(height: 16),
          const Text('No products found', style: TextStyle(color: Color(0xFF64748B), fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const Text('Start building your inventory by adding a new product.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildAddCategoryButton(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      child: OutlinedButton.icon(
        onPressed: () => _showAddCategoryDialog(context, ref),
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Add Category'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final catController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(controller: catController, decoration: const InputDecoration(hintText: 'e.g. Pharmacy')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(productProvider.notifier).addCategory(catController.text);
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text('Save')),
        ],
      ),
    );
  }
}
