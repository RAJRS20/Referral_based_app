import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/referral_provider.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final referralProvider = Provider.of<ReferralProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.darkBackground, AppTheme.cardBackground],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header with Profile Info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPurple.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Profile Picture
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: AppTheme.glowShadow,
                        ),
                        child: user?.profileImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  user!.profileImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: AppTheme.primaryPurple,
                              ),
                      )
                          .animate()
                          .scale(duration: 600.ms, curve: Curves.elasticOut),

                      const SizedBox(height: 16),

                      // Name
                      Text(
                        user?.name ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 100.ms),

                      const SizedBox(height: 8),

                      // Email
                      Text(
                        user?.email ?? 'email@example.com',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms),

                      const SizedBox(height: 24),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            icon: Icons.people_rounded,
                            value: '${referralProvider.totalReferrals}',
                            label: 'Referrals',
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _buildStatItem(
                            icon: Icons.trending_up_rounded,
                            value: '₹${walletProvider.wallet.totalEarnings.toStringAsFixed(0)}',
                            label: 'Total Earned',
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _buildStatItem(
                            icon: Icons.star_rounded,
                            value: 'Level ${referralProvider.currentLevel + 1}',
                            label: 'Current',
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 300.ms),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Referral Code Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentGreen.withOpacity(0.2),
                          AppTheme.primaryPurple.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.accentGreen.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Referral Code',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user?.referralCode ?? 'N/A',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: user?.referralCode ?? ''),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Code copied!'),
                                    backgroundColor: AppTheme.accentGreen,
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.copy_rounded,
                                color: AppTheme.accentGreen,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                final link = referralProvider.getReferralLink(
                                  user?.referralCode ?? '',
                                );
                                Share.share(
                                  'Join me on Referral Earn app! Use code: ${user?.referralCode}\n\n$link',
                                );
                              },
                              icon: const Icon(
                                Icons.share_rounded,
                                color: AppTheme.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideX(begin: -0.2, end: 0),
                ),

                const SizedBox(height: 24),

                // Menu Items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        context,
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit profile feature coming soon!'),
                            ),
                          );
                        },
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 500.ms)
                          .slideX(begin: -0.2, end: 0),

                      const SizedBox(height: 12),

                      _buildMenuItem(
                        context,
                        icon: Icons.group_outlined,
                        title: 'My Referrals',
                        subtitle: '${referralProvider.totalReferrals} people joined',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Referrals list feature coming soon!'),
                            ),
                          );
                        },
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 600.ms)
                          .slideX(begin: -0.2, end: 0),

                      const SizedBox(height: 12),

                      _buildMenuItem(
                        context,
                        icon: Icons.account_balance_outlined,
                        title: 'Bank Details',
                        subtitle: 'Manage withdrawal accounts',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bank details feature coming soon!'),
                            ),
                          );
                        },
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 700.ms)
                          .slideX(begin: -0.2, end: 0),

                      const SizedBox(height: 12),

                      _buildMenuItem(
                        context,
                        icon: Icons.history_rounded,
                        title: 'Transaction History',
                        subtitle: 'View all transactions',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Switch to Wallet tab to view transactions'),
                            ),
                          );
                        },
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 800.ms)
                          .slideX(begin: -0.2, end: 0),

                      const SizedBox(height: 12),

                      _buildMenuItem(
                        context,
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Support feature coming soon!'),
                            ),
                          );
                        },
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 900.ms)
                          .slideX(begin: -0.2, end: 0),

                      const SizedBox(height: 12),

                      _buildMenuItem(
                        context,
                        icon: Icons.info_outline,
                        title: 'About',
                        subtitle: 'Version 1.0.0',
                        onTap: () {
                          _showAboutDialog(context);
                        },
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 1000.ms)
                          .slideX(begin: -0.2, end: 0),

                      const SizedBox(height: 24),

                      // Logout Button
                      _buildMenuItem(
                        context,
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        iconColor: AppTheme.errorRed,
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppTheme.cardBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'Are you sure you want to logout?',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(color: AppTheme.errorRed),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            await authProvider.logout();
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          }
                        },
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 1100.ms)
                          .slideX(begin: -0.2, end: 0),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryPurple).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppTheme.primaryPurple,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'About Referral Earn',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),
            Text(
              'A premium referral-based earning platform where you can earn by inviting friends and completing tasks.',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2024 Referral Earn. All rights reserved.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
