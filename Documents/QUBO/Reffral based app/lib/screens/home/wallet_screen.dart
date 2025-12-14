import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/wallet_model.dart';
import '../../widgets/gradient_button.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final wallet = walletProvider.wallet;

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
                      'My Wallet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: -0.2, end: 0),
                    const SizedBox(height: 24),

                    // Balance Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildBalanceCard(
                            title: 'Deposit',
                            amount: wallet.depositBalance,
                            icon: Icons.account_balance_rounded,
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryPurple,
                                AppTheme.primaryPurple.withOpacity(0.7),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 100.ms)
                              .slideX(begin: -0.2, end: 0),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildBalanceCard(
                            title: 'Earnings',
                            amount: wallet.earningsBalance,
                            icon: Icons.trending_up_rounded,
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.accentGreen,
                                AppTheme.accentGreen.withOpacity(0.7),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 200.ms)
                              .slideX(begin: 0.2, end: 0),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Total Earnings Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryPurple.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.wallet_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Earnings',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${wallet.totalEarnings.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 300.ms)
                        .scale(delay: 300.ms),

                    const SizedBox(height: 24),

                    // Withdraw Button
                    if (wallet.earningsBalance > 0)
                      GradientButton(
                        onPressed: walletProvider.isProcessing
                            ? null
                            : () => _showWithdrawDialog(context, walletProvider),
                        gradient: AppTheme.primaryGradient,
                        child: walletProvider.isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.download_rounded,
                                      color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Withdraw Earnings',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 400.ms)
                          .shimmer(duration: 2000.ms, delay: 1000.ms),
                  ],
                ),
              ),

              // Transactions Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${wallet.transactions.length} total',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 500.ms),
              ),

              const SizedBox(height: 16),

              // Transactions List
              Expanded(
                child: wallet.transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 80,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions yet',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(duration: 600.ms),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: wallet.transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = wallet.transactions[index];
                          return _buildTransactionItem(transaction)
                              .animate()
                              .fadeIn(
                                duration: 600.ms,
                                delay: Duration(
                                    milliseconds: 600 + (index * 50)),
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

  Widget _buildBalanceCard({
    required String title,
    required double amount,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isCredit = transaction.type == TransactionType.deposit ||
        transaction.type == TransactionType.referralBonus ||
        transaction.type == TransactionType.gameReward;

    IconData icon;
    Color iconColor;

    switch (transaction.type) {
      case TransactionType.deposit:
        icon = Icons.add_card_rounded;
        iconColor = AppTheme.accentGreen;
        break;
      case TransactionType.withdrawal:
        icon = Icons.download_rounded;
        iconColor = AppTheme.errorRed;
        break;
      case TransactionType.referralBonus:
        icon = Icons.people_rounded;
        iconColor = AppTheme.primaryPurple;
        break;
      case TransactionType.gameReward:
        icon = Icons.games_rounded;
        iconColor = AppTheme.accentGreen;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? 'Transaction',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(transaction.date),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? "+" : "-"}₹${transaction.amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: isCredit ? AppTheme.accentGreen : AppTheme.errorRed,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, WalletProvider provider) {
    final withdrawController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Withdraw Earnings',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Available Balance: ₹${provider.wallet.earningsBalance.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: withdrawController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(color: AppTheme.accentGreen),
                hintText: 'Enter amount',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: AppTheme.darkBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          GradientButton(
            onPressed: () async {
              final amount = double.tryParse(withdrawController.text);
              if (amount != null && amount > 0) {
                if (amount <= provider.wallet.earningsBalance) {
                  Navigator.pop(context);
                  final success = await provider.withdrawEarnings(amount);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Withdrawal successful!'
                            : 'Withdrawal failed. Try again.'),
                        backgroundColor: success
                            ? AppTheme.accentGreen
                            : AppTheme.errorRed,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Insufficient balance'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
              }
            },
            gradient: AppTheme.primaryGradient,
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }
}
