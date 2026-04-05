import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saaspos/core/providers/business_provider.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  final String title;

  const MainScaffold({
    super.key,
    required this.child,
    this.title = 'Dashboard',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessState = ref.watch(businessProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1100;

    return Scaffold(
      drawer: isDesktop ? null : _buildSidebar(context, ref, isMobile: true),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: isDesktop ? const SizedBox() : null,
        title: _buildTopbar(context, ref, businessState),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Color(0xFF64748B))),
          const SizedBox(width: 8),
          _buildUserProfile(context, businessState),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context, ref),
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopbar(BuildContext context, WidgetRef ref, BusinessState state) {
    return Row(
      children: [
        if (state.business != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.business!['name'] ?? 'GoBeeZ POS',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              if (state.currentBranch != null)
                Text(
                  state.currentBranch!['name'],
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.w500),
                ),
            ],
          ),
        const Spacer(),
        // Branch Switcher dropdown
        if (state.branches.length > 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Map<String, dynamic>>(
                value: state.currentBranch,
                items: state.branches.map((b) => DropdownMenuItem(value: b, child: Text(b['name'], style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (val) {
                  if (val != null) ref.read(businessProvider.notifier).switchBranch(val);
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserProfile(BuildContext context, BusinessState state) {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              state.profile?['full_name'] ?? 'Admin',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
            ),
            const Text('Super Admin', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
        const SizedBox(width: 12),
        const CircleAvatar(
          backgroundColor: Color(0xFFF1F5F9),
          child: Icon(Icons.person, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context, WidgetRef ref, {bool isMobile = false}) {
    final location = GoRouterState.of(context).uri.toString();

    return Container(
      width: 260,
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          _buildLogo(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildNavItem(context, Icons.dashboard_outlined, 'Dashboard', '/dashboard', location),
                _buildNavItem(context, Icons.point_of_sale_outlined, 'POS Terminal', '/pos', location),
                _buildNavItem(context, Icons.inventory_2_outlined, 'Products', '/products', location),
                _buildNavItem(context, Icons.shopping_bag_outlined, 'Orders', '/orders', location),
                _buildNavItem(context, Icons.people_outline, 'Customers', '/customers', location),
                _buildNavItem(context, Icons.bar_chart_outlined, 'Reports', '/reports', location),
                const Divider(color: Colors.white10, height: 40, indent: 20, endIndent: 20),
                _buildNavItem(context, Icons.settings_outlined, 'Settings', '/settings', location),
              ],
            ),
          ),
          _buildLogoutBtn(context),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          const Icon(Icons.rocket_launch_rounded, color: Colors.blueAccent, size: 28),
          const SizedBox(width: 12),
          Text(
            'GoBeeZ',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, String route, String currentLoc) {
    final isActive = currentLoc == route;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.blueAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: isActive ? Colors.white : const Color(0xFF94A3B8), size: 22),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: isActive ? Colors.white : const Color(0xFF94A3B8),
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutBtn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: OutlinedButton.icon(
        onPressed: () {
          // Add Logout Logic
        },
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.white10),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
