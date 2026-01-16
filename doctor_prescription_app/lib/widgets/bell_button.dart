import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';

class BellButton extends StatefulWidget {
  final Color? iconColor;
  
  const BellButton({super.key, this.iconColor});

  @override
  State<BellButton> createState() => _BellButtonState();
}

class _BellButtonState extends State<BellButton> {
  bool _isSending = false;

  Future<void> _sendAlert() async {
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      await context.read<DatabaseService>().sendPharmacyAlert();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alert sent to pharmacy'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Call Pharmacist?'),
        content: const Text('This will notify the pharmacy to come to your cabin.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _sendAlert();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _isSending ? null : _showConfirmDialog,
      icon: _isSending
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.iconColor ?? AppColors.primary,
                ),
              ),
            )
          : Icon(
              Icons.notifications_outlined,
              color: widget.iconColor,
            ),
      tooltip: 'Call Pharmacy',
    );
  }
}
