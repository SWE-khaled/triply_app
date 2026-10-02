import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../controller/profile_controller.dart';
import '../model/emergency_contact.dart';
import '../widget/emergency_contact_card.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController(),
      child: const _EmergencyBody(),
    );
  }
}

class _EmergencyBody extends StatelessWidget {
  const _EmergencyBody();

  IconData _iconFor(String id) {
    switch (id) {
      case 'e1':
        return Icons.medical_services_outlined;
      case 'e2':
        return Icons.local_police_outlined;
      case 'e3':
        return Icons.fire_truck_outlined;
      default:
        return Icons.sos_outlined;
    }
  }

  Future<void> _copyNumber(
      BuildContext context, EmergencyContact contact) async {
    await Clipboard.setData(ClipboardData(text: contact.number));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              '${contact.name} number ${contact.number} copied')),
    );
  }

  Future<void> _callNumber(
      BuildContext context, EmergencyContact contact) async {
    final uri = Uri(scheme: 'tel', path: contact.number);
    try {
      final launched = await launchUrl(uri);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Could not open the dialer for ${contact.name}')),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Could not open the dialer for ${contact.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = context.watch<ProfileController>().emergencyContacts;
    return Scaffold(
      backgroundColor: AppColors.inputFill,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  CircleBackButton(),
                  SizedBox(width: 12),
                  Text(
                    'SOS / Emergency',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Egypt emergency numbers. Calling opens the phone dialer.',
                style:
                    TextStyle(fontSize: 13, color: AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              for (final contact in contacts)
                EmergencyContactCard(
                  contact: contact,
                  icon: _iconFor(contact.id),
                  onCopy: () => _copyNumber(context, contact),
                  onCall: () => _callNumber(context, contact),
                ),
            ],
          ),
        ),
      ),
    );
  }
}