import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/bouncing_wrapper.dart';
import '../core/app_style.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    
    return Scaffold(
      backgroundColor: AppStyle.getBg(context),
      appBar: AppBar(
        title: Text('CONTROL CENTER', style: TextStyle(color: AppStyle.getOnSurface(context), fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5)),
        centerTitle: true,
      ),
      body: authState.when(
        data: (user) => SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppStyle.pL),
          child: Column(
            children: [
              const SizedBox(height: 32),
              
              // Profile Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppStyle.primary, width: 2),
                        boxShadow: AppStyle.neonGlow,
                      ),
                      child: Center(
                        child: Text(
                          user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                          style: TextStyle(color: AppStyle.getOnSurface(context), fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      user?.displayName ?? 'User',
                      style: TextStyle(color: AppStyle.getOnSurface(context), fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text('Member since 2026', style: TextStyle(color: AppStyle.getSubtitle(context), fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              _buildSectionHeader(context, 'APPEARANCE'),
              const SizedBox(height: 16),
              _buildSettingCard(
                context: context,
                icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: isDarkMode ? AppStyle.secondary : Colors.orange,
                title: 'Dark Mode',
                subtitle: isDarkMode ? 'Stealth edition active' : 'Light edition active',
                trailing: Switch(
                  value: isDarkMode,
                  activeColor: AppStyle.primary,
                  onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
                ),
              ),
              
              const SizedBox(height: 32),
              _buildSectionHeader(context, 'ACCOUNT'),
              const SizedBox(height: 16),
              _buildSettingCard(
                context: context,
                icon: Icons.logout,
                color: AppStyle.accentRed,
                title: 'Sign Out',
                subtitle: 'Terminate session safely',
                trailing: Icon(Icons.chevron_right, color: AppStyle.getSubtitle(context)),
                onTap: () => ref.read(authControllerProvider.notifier).signOut(),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppStyle.primary)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(color: AppStyle.getSubtitle(context), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildSettingCard({required BuildContext context, required IconData icon, required Color color, required String title, required String subtitle, required Widget trailing, VoidCallback? onTap}) {
    final card = Container(
      padding: EdgeInsets.all(AppStyle.pM),
      decoration: BoxDecoration(color: AppStyle.getSurface(context), borderRadius: AppStyle.rL),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: AppStyle.getOnSurface(context), fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: TextStyle(color: AppStyle.getSubtitle(context), fontSize: 11)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
    return onTap != null ? BouncingWrapper(onTap: onTap, child: card) : card;
  }
}
