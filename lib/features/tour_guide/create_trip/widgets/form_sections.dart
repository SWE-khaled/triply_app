import 'package:flutter/material.dart';
import 'guide_form_field.dart';

/// Static form sections. Controllers stay in the screen State;
/// sections are pure layout over the shared field widgets.
class BasicsSection extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController aboutCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController labelCtrl;

  const BasicsSection({
    super.key,
    required this.nameCtrl,
    required this.aboutCtrl,
    required this.locationCtrl,
    required this.labelCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GuideFormLabel(text: 'Trip Name'),
        const SizedBox(height: 6),
        GuideFormField(
          controller: nameCtrl,
          hint: 'Enter the public trip title',
        ),
        const SizedBox(height: 12),
        const GuideFormLabel(text: 'About this trip'),
        const SizedBox(height: 6),
        GuideFormField(
          controller: aboutCtrl,
          hint: 'Describe the experience exactly as tourists will see it',
          maxLines: 4,
        ),
        const SizedBox(height: 12),
        GuideTwoCol(
          leftLabel: 'Location',
          leftField: GuideFormField(
            controller: locationCtrl,
            hint: 'Giza Plateau',
          ),
          rightLabel: 'Experience Label',
          rightField: GuideFormField(
            controller: labelCtrl,
            hint: 'Guided Tour',
          ),
        ),
      ],
    );
  }
}

class ScheduleSection extends StatelessWidget {
  final TextEditingController dateCtrl;
  final TextEditingController timeCtrl;
  final TextEditingController durationCtrl;
  final TextEditingController priceCtrl;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  const ScheduleSection({
    super.key,
    required this.dateCtrl,
    required this.timeCtrl,
    required this.durationCtrl,
    required this.priceCtrl,
    required this.onPickDate,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GuideTwoCol(
          leftLabel: 'Date',
          leftField: GuideFormField(
            controller: dateCtrl,
            hint: 'Choose date',
            readOnly: true,
            onTap: onPickDate,
          ),
          rightLabel: 'Start Time',
          rightField: GuideFormField(
            controller: timeCtrl,
            hint: 'e.g. 5:00 PM',
            readOnly: true,
            onTap: onPickTime,
          ),
        ),
        const SizedBox(height: 12),
        GuideTwoCol(
          leftLabel: 'Duration',
          leftField: GuideFormField(
            controller: durationCtrl,
            hint: 'e.g. 5 hours',
          ),
          rightLabel: 'Price per person',
          rightField: GuideFormField(
            controller: priceCtrl,
            hint: 'EGP',
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}

class LogisticsSection extends StatelessWidget {
  final TextEditingController maxTravelersCtrl;
  final TextEditingController meetingCtrl;

  const LogisticsSection({
    super.key,
    required this.maxTravelersCtrl,
    required this.meetingCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GuideFormLabel(text: 'Maximum Travelers'),
        const SizedBox(height: 6),
        GuideFormField(
          controller: maxTravelersCtrl,
          hint: 'e.g. 8 travelers',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        const GuideFormLabel(text: 'Meeting Point'),
        const SizedBox(height: 6),
        GuideFormField(
          controller: meetingCtrl,
          hint: 'Exact meeting point shown to tourists',
        ),
      ],
    );
  }
}

class ExtrasSection extends StatelessWidget {
  final TextEditingController includedCtrl;
  final TextEditingController notesCtrl;
  final TextEditingController languagesCtrl;

  const ExtrasSection({
    super.key,
    required this.includedCtrl,
    required this.notesCtrl,
    required this.languagesCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GuideFormLabel(text: "What's Included"),
        const SizedBox(height: 6),
        GuideFormField(
          controller: includedCtrl,
          hint: 'Entry tickets, transport, refreshments, guide...',
          maxLines: 4,
        ),
        const SizedBox(height: 12),
        const GuideFormLabel(text: 'Important Notes'),
        const SizedBox(height: 6),
        GuideFormField(
          controller: notesCtrl,
          hint:
              'What tourists should bring, accessibility and cancellation notes',
          maxLines: 4,
        ),
        const SizedBox(height: 12),
        const GuideFormLabel(text: 'Languages'),
        const SizedBox(height: 6),
        GuideFormField(
          controller: languagesCtrl,
          hint: 'Arabic, English, Italian...',
        ),
      ],
    );
  }
}
