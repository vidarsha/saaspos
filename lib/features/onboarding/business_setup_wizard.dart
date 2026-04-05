import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saaspos/core/widgets/custom_widgets.dart';
import 'package:saaspos/features/onboarding/business_provider.dart';

class BusinessSetupWizard extends ConsumerStatefulWidget {
  const BusinessSetupWizard({super.key});

  @override
  ConsumerState<BusinessSetupWizard> createState() => _BusinessSetupWizardState();
}

class _BusinessSetupWizardState extends ConsumerState<BusinessSetupWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Controllers for Step 1: Identity
  final _businessNameController = TextEditingController();
  final _companyController = TextEditingController();
  final _contactNoController = TextEditingController();
  final _emailController = TextEditingController();
  final _regNoController = TextEditingController();
  final _taxNoController = TextEditingController();
  String _businessType = 'Retail';

  // Controllers for Step 2: Operations
  final _branchNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _branchContactNoController = TextEditingController();
  final _branchEmailController = TextEditingController();
  final _cityController = TextEditingController();
  String _country = 'Sri Lanka';
  String _language = 'English';
  String _currency = 'LKR';

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _completeOnboarding() async {
    final notifier = ref.read(businessSetupProvider.notifier);

    // Collect all data
    notifier.updateBusinessData({
      'name': _businessNameController.text,
      'company_name': _companyController.text,
      'business_type': _businessType,
      'contact_no': _contactNoController.text,
      'email': _emailController.text,
      'reg_no': _regNoController.text,
      'tax_no': _taxNoController.text,
    });

    notifier.updateBranchData({
      'name': _branchNameController.text.isEmpty ? 'Main Branch' : _branchNameController.text,
      'address': _addressController.text,
      'contact_no': _branchContactNoController.text,
      'email': _branchEmailController.text,
      'city': _cityController.text,
      'country': _country,
      'language': _language,
      'currency': _currency,
    });

    final success = await notifier.completeSetup();
    if (success && mounted) {
      context.go('/dashboard');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(businessSetupProvider).error ?? 'Setup failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Setup', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Custom Progress Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
            child: Row(
              children: [
                _buildStepIndicator(0, 'Identity'),
                _buildStepLine(0),
                _buildStepIndicator(1, 'Operational'),
                _buildStepLine(1),
                _buildStepIndicator(2, 'Subscription'),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = _currentStep >= step;
    return Column(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: isActive ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
          child: Text(
            (step + 1).toString(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        )
      ],
    );
  }

  Widget _buildStepLine(int step) {
    bool isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
        margin: const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Step 1: Business Identity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('Tell us about your brand and industry.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              CustomTextField(label: 'Business Name', hint: 'e.g. My Awesome Shop', controller: _businessNameController),
              const SizedBox(height: 16),
              CustomTextField(label: 'Company', hint: 'e.g. Awesome Group (Pvt) Ltd', controller: _companyController),
              const SizedBox(height: 16),
              const Text('Business Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _businessType,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
                items: ['Retail', 'Pharmacy', 'Restaurant', 'Other']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _businessType = v!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: CustomTextField(label: 'Contact No', hint: '0112345678', controller: _contactNoController)),
                  const SizedBox(width: 16),
                  Expanded(child: CustomTextField(label: 'Business Email', hint: 'biz@example.com', controller: _emailController)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: CustomTextField(label: 'Reg No (Optional)', hint: 'PV-12345', controller: _regNoController)),
                  const SizedBox(width: 16),
                  Expanded(child: CustomTextField(label: 'Tax No (Optional)', hint: 'TIN-98765', controller: _taxNoController)),
                ],
              ),
              const SizedBox(height: 40),
              CustomButton(text: 'Next', onPressed: _nextStep),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Step 2: Operational Setup', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('Configure your main branch and location.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              CustomTextField(label: 'Branch Name (Optional)', hint: 'e.g. Head Office / Colombo 07', controller: _branchNameController),
              const SizedBox(height: 16),
              CustomTextField(label: 'Address', hint: 'No 123, Galle Road', controller: _addressController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: CustomTextField(label: 'Branch Contact No', hint: '0112345678', controller: _branchContactNoController)),
                  const SizedBox(width: 16),
                  Expanded(child: CustomTextField(label: 'City', hint: 'Colombo', controller: _cityController)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Country', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _country,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
                items: ['Sri Lanka', 'UAE', 'USA', 'UK'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _country = v!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Language', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: _language,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
                          items: ['English', 'Sinhala', 'Tamil'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => _language = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Currency', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: _currency,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
                          items: ['LKR', 'USD', 'AED'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => _currency = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(child: CustomButton(text: 'Back', color: Colors.grey, onPressed: _prevStep)),
                  const SizedBox(width: 16),
                  Expanded(child: CustomButton(text: 'Next', onPressed: _nextStep)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep3() {
    final state = ref.watch(businessSetupProvider);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const Text('Step 3: Subscription Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('Select a plan to start your 14-day trial.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildPlanCard('Free', '0 LKR', ['1 Branch', '100 Orders/Month', 'Basic Reports'], state.subscriptionPlan == 'Free'),
                    _buildPlanCard('Basic', '5000 LKR', ['2 Branches', 'Unlimited Orders', 'Priority Support'], state.subscriptionPlan == 'Basic'),
                    _buildPlanCard('Pro', '15000 LKR', ['5 Branches', 'Inventory Management', 'Advanced Analytics'], state.subscriptionPlan == 'Pro'),
                    _buildPlanCard('Enterprise', 'Custom', ['Unlimited Branches', 'Full API Access', 'Dedicated Manager'], state.subscriptionPlan == 'Enterprise'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: CustomButton(text: 'Back', color: Colors.grey, onPressed: _prevStep)),
                  const SizedBox(width: 16),
                  Expanded(child: CustomButton(text: 'Start Free Trial', isLoading: state.isLoading, onPressed: _nextStep)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(String name, String price, List<String> features, bool isSelected) {
    return GestureDetector(
      onTap: () => ref.read(businessSetupProvider.notifier).setSubscriptionPlan(name),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
            width: 2,
          ),
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(price, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(height: 32),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text(f, style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
