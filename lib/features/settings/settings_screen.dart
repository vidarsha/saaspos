import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saaspos/core/providers/business_provider.dart';
import 'package:saaspos/features/settings/providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const BusinessInfoTab(),
                const UsersRolesTab(),
                const UserGroupsTab(),
                const Center(child: Text('Subscription Management (Coming Soon)')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.settings_outlined, size: 32, color: Color(0xFF0F172A)),
          const SizedBox(width: 16),
          Text(
            'Settings & Administration',
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.blueAccent,
        unselectedLabelColor: const Color(0xFF64748B),
        indicatorColor: Colors.blueAccent,
        indicatorWeight: 3,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        tabs: const [
          Tab(text: 'Business Info'),
          Tab(text: 'Users & Roles'),
          Tab(text: 'User Groups'),
          Tab(text: 'Subscription'),
        ],
      ),
    );
  }
}

// 📌 TAB 1: Business Info
class BusinessInfoTab extends ConsumerStatefulWidget {
  const BusinessInfoTab({super.key});

  @override
  ConsumerState<BusinessInfoTab> createState() => _BusinessInfoTabState();
}

class _BusinessInfoTabState extends ConsumerState<BusinessInfoTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;
  late TextEditingController _regNoController;
  late TextEditingController _taxNoController;

  @override
  void initState() {
    super.initState();
    final business = ref.read(businessProvider).business;
    _nameController = TextEditingController(text: business?['name']);
    _companyController = TextEditingController(text: business?['company_name']);
    _contactController = TextEditingController(text: business?['contact_no']);
    _emailController = TextEditingController(text: business?['email']);
    _regNoController = TextEditingController(text: business?['reg_no']);
    _taxNoController = TextEditingController(text: business?['tax_no']);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Business Identity', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildField('Company', _companyController),
              const SizedBox(height: 16),
              _buildField('Business Name', _nameController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildField('Contact No', _contactController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField('Business Email', _emailController)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildField('Reg No (Optional)', _regNoController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField('Tax No (Optional)', _taxNoController)),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  ref.read(settingsProvider.notifier).updateBusiness({
                    'name': _nameController.text,
                    'company_name': _companyController.text,
                    'contact_no': _contactController.text,
                    'email': _emailController.text,
                    'reg_no': _regNoController.text,
                    'tax_no': _taxNoController.text,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Business information updated!')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            fillColor: const Color(0xFFF8FAFC),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}

// 👥 TAB 2: Users & Roles
class UsersRolesTab extends ConsumerWidget {
  const UsersRolesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search staff...',
                    prefixIcon: const Icon(Icons.search),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddUserDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 60,
                        horizontalMargin: 24,
                        headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                        columns: const [
                          DataColumn(label: Text('EMP NO')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Role')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: state.staff.map((s) {
                          return DataRow(cells: [
                            DataCell(Text(s['emp_no'] ?? '-')),
                            DataCell(Text(s['full_name'] ?? '-')),
                            DataCell(Text(s['group']?['name'] ?? 'No Role')),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (s['status'] == 'active' ? Colors.green : Colors.red).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  s['status']?.toUpperCase() ?? '-',
                                  style: TextStyle(color: (s['status'] == 'active' ? Colors.green : Colors.red), fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            DataCell(IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AddUserDialog(),
    );
  }
}

class AddUserDialog extends ConsumerStatefulWidget {
  const AddUserDialog({super.key});

  @override
  ConsumerState<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends ConsumerState<AddUserDialog> {
  final _empNoController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedGroupId;
  String _status = 'active';

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(settingsProvider).userGroups;

    return AlertDialog(
      title: Text('Add New User', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _empNoController, decoration: const InputDecoration(labelText: 'EMP NO')),
              const SizedBox(height: 12),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name')),
              const SizedBox(height: 12),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone')),
              const SizedBox(height: 12),
              TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Default Password')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGroupId,
                onChanged: (v) => setState(() => _selectedGroupId = v),
                items: groups.map((g) => DropdownMenuItem(value: g['id'].toString(), child: Text(g['name']))).toList(),
                decoration: const InputDecoration(labelText: 'User Group'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                onChanged: (v) => setState(() => _status = v!),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                decoration: const InputDecoration(labelText: 'Status'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            ref.read(settingsProvider.notifier).createStaff({
              'emp_no': _empNoController.text,
              'full_name': _nameController.text,
              'email': _emailController.text,
              'phone': _phoneController.text,
              'group_id': _selectedGroupId,
              'status': _status,
            });
            Navigator.pop(context);
          },
          child: const Text('Save User'),
        ),
      ],
    );
  }
}

// 🔐 TAB 3: User Groups
class UserGroupsTab extends ConsumerWidget {
  const UserGroupsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Role Templates', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () => _showCreateGroupDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Create Group'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.all(24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: state.userGroups.length,
                      itemBuilder: (context, index) {
                        final g = state.userGroups[index];
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(g['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Icon(Icons.more_horiz),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(g['description'] ?? 'No description', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              const Spacer(),
                              Text('Permissions: Partial Access', style: TextStyle(color: Colors.blueAccent[700], fontWeight: FontWeight.w600, fontSize: 11)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (context) => const CreateGroupDialog());
  }
}

class CreateGroupDialog extends ConsumerStatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  ConsumerState<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends ConsumerState<CreateGroupDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final Map<String, bool> _permissions = {
    'Products:View': true,
    'Products:Edit': false,
    'POS:Access': true,
    'POS:Discount': false,
    'Reports:View': false,
    'Settings:View': false,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create User Group'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Group Name')),
              const SizedBox(height: 12),
              TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 24),
              const Align(alignment: Alignment.centerLeft, child: Text('Permissions', style: TextStyle(fontWeight: FontWeight.bold))),
              const Divider(),
              ..._permissions.keys.map((key) {
                return CheckboxListTile(
                  title: Text(key),
                  value: _permissions[key],
                  onChanged: (v) => setState(() => _permissions[key] = v!),
                );
              }).toList(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            ref.read(settingsProvider.notifier).createGroup(_nameController.text, _descController.text, _permissions);
            Navigator.pop(context);
          },
          child: const Text('Save Group'),
        ),
      ],
    );
  }
}
