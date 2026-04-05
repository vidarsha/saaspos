import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saaspos/core/widgets/onboarding_layout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  
  // Use separate form keys for each step to avoid validating hidden fields
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  // Logo State
  XFile? _logoFile;
  Uint8List? _logoBytes;

  // Step 1: Owner Details
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  // Step 2: Business Info
  final _businessNameController = TextEditingController();
  final _companyController = TextEditingController();
  final _businessContactController = TextEditingController();
  final _businessEmailController = TextEditingController();
  String _businessType = 'Retail';
  final _regNoController = TextEditingController();
  final _taxNoController = TextEditingController();

  // Step 3: Location & Setup
  final _addressController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _branchContactController = TextEditingController();
  final _branchEmailController = TextEditingController();
  final _cityController = TextEditingController();
  String _country = 'Sri Lanka';
  String _currency = 'LKR';
  String _language = 'English';

  // Step 4: Subscription Plan
  String _planType = 'Basic';

  final List<String> _businessTypes = ['Pharmacy', 'Supermarket', 'Restaurant', 'Retail', 'Service', 'Other'];
  final List<String> _plans = ['Free', 'Basic', 'Pro', 'Enterprise'];

  Future<void> _completeSignup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;

      // 0. Upload Logo if exists
      String? logoUrl;
      if (_logoBytes != null && _logoFile != null) {
        final fileExt = _logoFile!.name.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = 'business_logos/$fileName';
        
        final contentType = 'image/$fileExt'; // Basic content type detection

        try {
          await supabase.storage.from('logos').uploadBinary(
            filePath,
            _logoBytes!,
            fileOptions: FileOptions(cacheControl: '3600', upsert: false, contentType: contentType),
          );
          
          logoUrl = supabase.storage.from('logos').getPublicUrl(filePath);
        } catch (e) {
          debugPrint('Storage Upload Error: $e');
          // We can choose to continue without logo or fail. Let's show a warning.
          _showError('Logo upload failed, but continuing with registration...');
        }
      }

      // 1. Auth Signup
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {'full_name': _nameController.text.trim()},
      );

      final user = res.user;
      if (user == null) throw 'Signup failed';

      // 2. Create Business
      final businessResponse = await supabase.from('businesses').insert({
        'name': _businessNameController.text.trim(),
        'company_name': _companyController.text.trim(),
        'business_type': _businessType,
        'contact_no': _businessContactController.text.trim(),
        'email': _businessEmailController.text.trim(),
        'reg_no': _regNoController.text.trim(),
        'tax_no': _taxNoController.text.trim(),
        'logo_url': logoUrl,
      }).select().single();

      final businessId = businessResponse['id'];

      // 3. Create Initial Branch
      final branchResponse = await supabase.from('branches').insert({
        'business_id': businessId,
        'name': _branchNameController.text.isEmpty ? 'Main Branch' : _branchNameController.text.trim(),
        'address': _addressController.text.trim(),
        'contact_no': _branchContactController.text.trim(),
        'email': _branchEmailController.text.trim(),
        'city': _cityController.text.trim(),
        'country': _country,
        'currency': _currency,
        'language': _language,
      }).select().single();

      // 4. Update Profile
      await supabase.from('profiles').upsert({
        'id': user.id,
        'business_id': businessId,
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'status': 'active',
      });

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (error) {
      _showError('Error: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _nextStep() {
    // Only validate the form for the CURRENT step
    if (!_formKeys[_currentStep].currentState!.validate()) return;
    
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _completeSignup();
    }
  }

  Future<void> _pickLogo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _logoFile = image;
          _logoBytes = bytes;
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(),
          const SizedBox(height: 60),
          IndexedStack(
            index: _currentStep,
            children: [
              Form(key: _formKeys[0], child: _buildOwnerStep()),
              Form(key: _formKeys[1], child: _buildBusinessStep()),
              Form(key: _formKeys[2], child: _buildSetupStep()),
              Form(key: _formKeys[3], child: _buildPlanStep()),
            ],
          ),
          const SizedBox(height: 40),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(4, (index) {
        bool isDone = index < _currentStep;
        bool isCurrent = index == _currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: isDone || isCurrent ? Colors.blueAccent : Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildOwnerStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Owner Registration', 'Create your master administrator account.'),
        _buildTextField('Full Name', _nameController, Icons.person_outline),
        const SizedBox(height: 24),
        _buildTextField('Email Address', _emailController, Icons.mail_outline),
        const SizedBox(height: 24),
        _buildTextField('Phone Number', _phoneController, Icons.phone_android_outlined),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildTextField('Password', _passwordController, Icons.lock_outline, obscure: true)),
            const SizedBox(width: 20),
            Expanded(child: _buildTextField('Confirm Password', _confirmPasswordController, Icons.lock_clock_outlined, obscure: true)),
          ],
        ),
        const SizedBox(height: 24),
        _buildTextField('Verification Code (optional)', _verificationCodeController, Icons.verified_user_outlined),
      ],
    );
  }

  Widget _buildBusinessStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Business Identity', 'Tell us about your brand and industry.'),
        _buildTextField('Company', _companyController, Icons.business),
        const SizedBox(height: 24),
        _buildTextField('Business Name', _businessNameController, Icons.storefront),
        const SizedBox(height: 24),
        Text('Business Type', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _businessType,
          items: _businessTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => setState(() => _businessType = v!),
          decoration: InputDecoration(
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildTextField('Contact No', _businessContactController, Icons.phone)),
            const SizedBox(width: 20),
            Expanded(child: _buildTextField('Business Email', _businessEmailController, Icons.email)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildTextField('Reg Number (optional)', _regNoController, Icons.attribution)),
            const SizedBox(width: 20),
            Expanded(child: _buildTextField('Tax Number (optional)', _taxNoController, Icons.receipt_long)),
          ],
        ),
        const SizedBox(height: 24),
        Text('Upload Logo', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
        const SizedBox(height: 12),
        Row(
          children: [
            if (_logoBytes != null)
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: MemoryImage(_logoBytes!), fit: BoxFit.cover),
                  border: Border.all(color: Colors.grey[200]!),
                ),
              ),
            OutlinedButton.icon(
              onPressed: _pickLogo,
              icon: const Icon(Icons.upload),
              label: Text(_logoBytes == null ? 'Upload' : 'Change Logo'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSetupStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Operational Setup', 'Configure your main branch and location.'),
        _buildTextField('Branch Name (Optional)', _branchNameController, Icons.account_tree),
        const SizedBox(height: 24),
        _buildTextField('Address', _addressController, Icons.map_outlined),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildTextField('Branch Contact No', _branchContactController, Icons.phone)),
            const SizedBox(width: 20),
            Expanded(child: _buildTextField('Branch Email', _branchEmailController, Icons.email)),
          ],
        ),
        const SizedBox(height: 24),
        _buildTextField('City', _cityController, Icons.location_city),
        const SizedBox(height: 24),
        _buildDropdownField('Country', _country, ['Sri Lanka', 'UAE', 'USA', 'UK'], (v) => setState(() => _country = v!)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField('Currency', _currency, ['LKR', 'USD', 'AED'], (v) => setState(() => _currency = v!)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildDropdownField('Language', _language, ['English', 'Sinhala', 'Tamil'], (v) => setState(() => _language = v!)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Subscription Plan', 'Select a plan to start your 14-day trial.'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _plans.length,
          itemBuilder: (context, index) {
            final plan = _plans[index];
            final isSelected = _planType == plan;
            return GestureDetector(
              onTap: () => setState(() => _planType = plan),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueAccent.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? Colors.blueAccent : Colors.grey[200]!, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? Colors.blueAccent : Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text(plan, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('✔ Features list', style: TextStyle(fontSize: 10)),
                    const Text('✔ Pricing', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool obscure = false}) {
    bool isOptional = label.toLowerCase().contains('(optional)');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: (val) => (!isOptional && (val == null || val.isEmpty)) ? 'Required' : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        OutlinedButton(
          onPressed: _isLoading ? null : _prevStep,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text('BACK', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        ),
        const Spacer(),
        SizedBox(
          height: 60,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(_currentStep == 3 ? 'START FREE TRIAL' : 'CONTINUE', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
