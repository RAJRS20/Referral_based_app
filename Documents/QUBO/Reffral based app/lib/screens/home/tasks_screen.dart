import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/referral_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/app_theme.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final referralProvider = Provider.of<ReferralProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);

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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Referral Tasks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: -0.2, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      'Complete tasks to unlock rewards',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 100.ms),
                  ],
                ),
              ),

              // Tasks List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: referralProvider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = referralProvider.tasks[index];
                    return _buildTaskCard(
                      context,
                      task,
                      referralProvider,
                      walletProvider,
                      index,
                    )
                        .animate()
                        .fadeIn(
                          duration: 600.ms,
                          delay: Duration(milliseconds: 200 + (index * 100)),
                        )
                        .slideX(begin: -0.2, end: 0);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    task,
    ReferralProvider referralProvider,
    WalletProvider walletProvider,
    int index,
  ) {
    final isCurrentLevel = index == referralProvider.currentLevel;
    final progress = task.requiredReferrals > 0
        ? task.currentReferrals / task.requiredReferrals
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: task.isCompleted
            ? LinearGradient(
                colors: [
                  AppTheme.accentGreen.withOpacity(0.3),
                  AppTheme.accentGreen.withOpacity(0.1),
                ],
              )
            : isCurrentLevel
                ? LinearGradient(
                    colors: [
                      AppTheme.primaryPurple.withOpacity(0.3),
                      AppTheme.primaryPurple.withOpacity(0.1),
                    ],
                  )
                : null,
        color: task.isCompleted || isCurrentLevel
            ? null
            : AppTheme.cardBackground.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: task.isCompleted
              ? AppTheme.accentGreen
              : isCurrentLevel
                  ? AppTheme.primaryPurple
                  : Colors.white.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: task.isCompleted
                      ? LinearGradient(
                          colors: [
                            AppTheme.accentGreen,
                            AppTheme.accentGreen.withOpacity(0.7),
                          ],
                        )
                      : isCurrentLevel
                          ? AppTheme.primaryGradient
                          : null,
                  color: task.isCompleted || isCurrentLevel
                      ? null
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  task.isCompleted
                      ? Icons.check_circle_rounded
                      : isCurrentLevel
                          ? Icons.trending_up_rounded
                          : Icons.lock_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${task.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.isCompleted
                          ? 'Completed ✓'
                          : isCurrentLevel
                              ? 'In Progress'
                              : 'Locked',
                      style: TextStyle(
                        color: task.isCompleted
                            ? AppTheme.accentGreen
                            : isCurrentLevel
                                ? AppTheme.primaryPurple
                                : Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '₹${task.bonusAmount.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Requirements
          _buildRequirement(
            icon: Icons.people_rounded,
            title: 'Referrals Required',
            value: task.requiredReferrals > 0
                ? '${task.currentReferrals}/${task.requiredReferrals}'
                : '${task.currentReferrals} (Unlimited)',
            isCompleted: task.requiredReferrals > 0
                ? task.currentReferrals >= task.requiredReferrals
                : false,
          ),

          const SizedBox(height: 12),

          _buildRequirement(
            icon: Icons.games_rounded,
            title: 'Complete Games',
            value: task.gamesCompleted ? 'Completed' : 'Pending',
            isCompleted: task.gamesCompleted,
          ),

          // Progress Bar
          if (task.requiredReferrals > 0 && !task.isCompleted) ...[
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCurrentLevel ? AppTheme.accentGreen : Colors.white54,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% Complete',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],

          // Action Button
          if (isCurrentLevel && task.canPlayGames && !task.gamesCompleted) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Simulate game completion
                  await referralProvider.completeGames();
                  await walletProvider.addGameReward(
                    task.bonusAmount,
                    'Level ${task.level} Games',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Congratulations! You earned ₹${task.bonusAmount}!'),
                        backgroundColor: AppTheme.accentGreen,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Play Games to Complete',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequirement({
    required IconData icon,
    required String title,
    required String value,
    required bool isCompleted,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isCompleted
              ? AppTheme.accentGreen
              : Colors.white.withOpacity(0.5),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isCompleted ? AppTheme.accentGreen : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isCompleted) ...[
          const SizedBox(width: 8),
          const Icon(
            Icons.check_circle,
            color: AppTheme.accentGreen,
            size: 20,
          ),
        ],
      ],
    );
  }
}
