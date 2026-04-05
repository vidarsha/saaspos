import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saaspos/features/products/providers/product_provider.dart';

class AddProductDrawer extends ConsumerStatefulWidget {
  const AddProductDrawer({super.key});

  @override
  ConsumerState<AddProductDrawer> createState() => _AddProductDrawerState();
}

class _AddProductDrawerState extends ConsumerState<AddProductDrawer> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _descController = TextEditingController();
  final _brandController = TextEditingController();
  final _unitController = TextEditingController(text: 'Piece');

  // Pricing
  final _costController = TextEditingController(text: '0');
  final _sellingController = TextEditingController(text: '0');
  final _taxController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');

  // Inventory
  final _stockController = TextEditingController(text: '0');
  final _lowStockController = TextEditingController(text: '5');
  final _batchController = TextEditingController();
  final _expiryController = TextEditingController();

  String? _selectedCategoryId;
  String _productType = 'simple'; // simple, variable
  bool _trackInventory = true;

  double _profitAmount = 0;
  double _profitMargin = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _costController.addListener(_calculateProfit);
    _sellingController.addListener(_calculateProfit);
  }

  void _calculateProfit() {
    final cost = double.tryParse(_costController.text) ?? 0;
    final selling = double.tryParse(_sellingController.text) ?? 0;

    if (selling > 0) {
      setState(() {
        _profitAmount = selling - cost;
        _profitMargin = (_profitAmount / selling) * 100;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text('Add New Product', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
          actions: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.black))],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: const Color(0xFF64748B),
            indicatorColor: Colors.blueAccent,
            tabs: const [
              Tab(text: 'General'),
              Tab(text: 'Pricing'),
              Tab(text: 'Inventory'),
              Tab(text: 'Advanced'),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildGeneralTab(),
              _buildPricingTab(),
              _buildInventoryTab(),
              _buildAdvancedTab(),
            ],
          ),
        ),
        bottomNavigationBar: _buildFooter(),
      ),
    );
  }

  Widget _buildGeneralTab() {
    final categories = ref.watch(productProvider).categories;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Product Name', _nameController, hint: 'e.g. Coca Cola 500ml'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                      items: categories.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['name']))).toList(),
                      decoration: _inputDecoration('Select Category'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: IconButton(
                  onPressed: () => _showAddCategoryDialog(),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTextField('SKU', _skuController,
                    hint: 'Auto-gen',
                    suffix: IconButton(
                      icon: const Icon(Icons.refresh, size: 18),
                      onPressed: () => setState(() => _skuController.text = 'PRD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'),
                    )),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Barcode', _barcodeController, hint: 'Scan or Input')),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField('Brand (Optional)', _brandController, hint: 'e.g. Coca-Cola Company'),
          const SizedBox(height: 20),
          _buildTextField('Short Description', _descController, hint: 'Brief details about the product...', maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildPricingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildTextField('Cost Price (LKR)', _costController, keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Selling Price (LKR)', _sellingController, keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Profit Intelligence', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const Icon(Icons.auto_awesome, size: 16, color: Colors.orangeAccent),
                  ],
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Profit Amount', style: TextStyle(color: Color(0xFF64748B))),
                    Text('LKR ${_profitAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Profit Margin (%)', style: TextStyle(color: Color(0xFF64748B))),
                    Text('${_profitMargin.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueAccent)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField('Tax (%)', _taxController, keyboardType: TextInputType.number),
        ],
      ),
    );
  }

  Widget _buildInventoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Track Inventory', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Keep track of stock levels for this product'),
            value: _trackInventory,
            onChanged: (v) => setState(() => _trackInventory = v),
          ),
          const Divider(height: 48),
          if (_trackInventory) ...[
            _buildTextField('Opening Stock Quantity', _stockController, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField('Low Stock Alert Threshold', _lowStockController, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField('Batch No (Optional)', _batchController),
            const SizedBox(height: 20),
            _buildTextField('Expiry Date (Optional)', _expiryController, hint: 'YYYY-MM-DD'),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Product Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _productType,
            onChanged: (v) => setState(() => _productType = v!),
            items: const [
              DropdownMenuItem(value: 'simple', child: Text('Simple Product')),
              DropdownMenuItem(value: 'variable', child: Text('Variable (Variants)')),
            ],
            decoration: _inputDecoration(''),
          ),
          if (_productType == 'variable') ...[
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const Icon(Icons.layers_outlined, size: 48, color: Colors.blueAccent),
                  const SizedBox(height: 16),
                  const Text('Variant Engine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Add variants like Size or Color to this product.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Add Variant Attribute'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          const SizedBox(width: 16),
          OutlinedButton(onPressed: () {}, child: const Text('Save Draft')),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await ref.read(productProvider.notifier).createProduct({
                    'name': _nameController.text,
                    'sku': _skuController.text,
                    'barcode': _barcodeController.text,
                    'description': _descController.text,
                    'category_id': _selectedCategoryId,
                    'cost_price': double.tryParse(_costController.text) ?? 0,
                    'selling_price': double.tryParse(_sellingController.text) ?? 0,
                    'tax_percent': double.tryParse(_taxController.text) ?? 0,
                    'track_inventory': _trackInventory,
                    'low_stock_threshold': int.tryParse(_lowStockController.text) ?? 5,
                    'product_type': _productType,
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product added successfully!')),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Product'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {String? hint, TextInputType keyboardType = TextInputType.text, int maxLines = 1, Widget? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: _inputDecoration(hint ?? '').copyWith(suffixIcon: suffix),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  void _showAddCategoryDialog() {
    final catController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(controller: catController, decoration: const InputDecoration(hintText: 'e.g. Bakery')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                ref.read(productProvider.notifier).addCategory(catController.text);
                Navigator.pop(context);
              },
              child: const Text('Save')),
        ],
      ),
    );
  }
}
