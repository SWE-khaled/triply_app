import 'package:flutter/material.dart';
import 'package:triply/features/booking/controller/booking_controller.dart';
import 'package:triply/features/booking/widgets/booking_widgets.dart';

import '../../../core/theme/app_colors.dart';

/// Figma: BookingScreen — 4 states driven by [BookingController.stepIndex]:
/// 0 Date & Time, 1 Details, 2 Confirm, 3 Confirmed (success).
class BookingScreen extends StatefulWidget {
  final String guideId;

  const BookingScreen({super.key, required this.guideId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late final BookingController _controller;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _controller = BookingController(guideId: widget.guideId);
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            if (_controller.stepIndex == 3) return _buildSuccess();
            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: _buildStep(),
                  ),
                ),
                _buildBottomBar(),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------- Header ----------

  Widget _buildHeader() {
    final guide = _controller.guide;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _backButton(() {
                if (_controller.stepIndex == 0) {
                  Navigator.of(context).pop();
                } else {
                  _controller.back();
                }
              }),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Book Private Guide',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0E5261))),
                  Text(guide.name,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.subtitle)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          BookingStepper(stepIndex: _controller.stepIndex),
        ],
      ),
    );
  }

  Widget _backButton(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
            color: Color(0xFFF3F4F6), shape: BoxShape.circle),
        child: const Icon(Icons.chevron_left, color: Color(0xFF0E5261)),
      ),
    );
  }

  Widget _buildStep() {
    switch (_controller.stepIndex) {
      case 0:
        return _buildDateTimeStep();
      case 1:
        return _buildDetailsStep();
      default:
        return _buildConfirmStep();
    }
  }

  // ---------- Step 1: Date & Time ----------

  Widget _buildDateTimeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('SELECT DATE'),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: _controller.date ?? now,
              firstDate: now,
              lastDate: DateTime(now.year + 2),
            );
            if (picked != null) _controller.setDate(picked);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _controller.date == null
                        ? ''
                        : _controller.dateLabel,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.title),
                  ),
                ),
                const Icon(Icons.calendar_today,
                    size: 18, color: AppColors.hint),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _sectionLabel('SELECT TIME'),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: 44,
          ),
          itemCount: BookingController.timeSlots.length,
          itemBuilder: (context, i) {
            final t = BookingController.timeSlots[i];
            return SelectableChip(
              label: t,
              selected: _controller.timeSlot == t,
              onSelected: _controller.setTimeSlot,
            );
          },
        ),
        const SizedBox(height: 16),
        _sectionLabel('DURATION'),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: 44,
          ),
          itemCount: BookingController.durations.length,
          itemBuilder: (context, i) {
            final d = BookingController.durations[i];
            return SelectableChip(
              label: d,
              selected: _controller.durationLabel == d,
              onSelected: _controller.setDuration,
            );
          },
        ),
      ],
    );
  }

  // ---------- Step 2: Details ----------

  Widget _buildDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('NUMBER OF TRAVELERS'),
        const SizedBox(height: 8),
        Row(
          children: [
            _counterButton(Icons.remove, _controller.decrementTravelers),
            Expanded(
              child: Center(
                child: Text('${_controller.travelers}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.title)),
              ),
            ),
            _counterButton(Icons.add, _controller.incrementTravelers),
          ],
        ),
        const SizedBox(height: 16),
        _sectionLabel('MEETING POINT'),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: BookingController.meetingPoints.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final m = BookingController.meetingPoints[i];
            return MeetingPointTile(
              label: m,
              selected: _controller.meetingPoint == m,
              onSelected: _controller.setMeetingPoint,
            );
          },
        ),
        const SizedBox(height: 16),
        _sectionLabel('NOTES (OPTIONAL)'),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          onChanged: _controller.setNotes,
          maxLines: 4,
          decoration: InputDecoration(
            hintText:
                'Any special requests, accessibility needs, or things we should know...',
            hintStyle:
                const TextStyle(fontSize: 13, color: AppColors.hint),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
            color: AppColors.searchBg, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }

  // ---------- Step 3: Confirm ----------

  Widget _buildConfirmStep() {
    final guide = _controller.guide;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                guide.avatarUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 48,
                  height: 48,
                  color: AppColors.primaryLight,
                  alignment: Alignment.center,
                  child: Text(guide.name.isNotEmpty ? guide.name[0] : '?',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(guide.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.title)),
                Text(guide.specialty,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.subtitle)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Booking Summary',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.title)),
        const SizedBox(height: 6),
        SummaryRow(label: 'Date', value: _controller.dateLabel),
        SummaryRow(label: 'Time', value: _controller.timeSlot ?? ''),
        SummaryRow(label: 'Duration', value: _controller.durationLabel),
        SummaryRow(label: 'Travelers', value: _controller.travelersLabel),
        SummaryRow(label: 'Meeting Point', value: _controller.meetingPoint),
        const SizedBox(height: 12),
        const Text('Price Breakdown',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.title)),
        const SizedBox(height: 6),
        SummaryRow(
          label:
              '${guide.currency}${guide.pricePerHour.toStringAsFixed(0)}/hr × ${_controller.durationHours} hrs × ${_controller.travelers} travelers',
          value:
              '${guide.currency}${_controller.subtotal.toStringAsFixed(0)}',
        ),
        SummaryRow(
            label: 'Service fee (5%)',
            value:
                '${guide.currency}${_controller.serviceFee.toStringAsFixed(0)}'),
        const Divider(color: AppColors.cardBorder),
        SummaryRow(
            label: 'Total',
            value:
                '${guide.currency}${_controller.total.toStringAsFixed(0)}',
            bold: true),
      ],
    );
  }

  // ---------- Step 4: Success ----------

  Widget _buildSuccess() {
    final guide = _controller.guide;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
                color: AppColors.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.check_circle,
                color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 16),
          const Text('Booking Confirmed!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary)),
          const SizedBox(height: 8),
          Text(
            'Your private tour with ${guide.name} is confirmed. A confirmation email has been sent to your inbox.',
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 13, color: AppColors.subtitle),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        guide.avatarUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 44,
                          height: 44,
                          color: AppColors.primaryLight,
                          alignment: Alignment.center,
                          child: Text(
                              guide.name.isNotEmpty ? guide.name[0] : '?',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(guide.name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.title)),
                          Text(guide.specialty,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.subtitle)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _miniStat(
                            'Date', _controller.dateLabel)),
                    Expanded(
                        child: _miniStat('Duration',
                            _controller.durationLabel)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: _miniStat('Travelers',
                            _controller.travelersLabel)),
                    Expanded(
                      child: _miniStat(
                        'Total',
                        '${guide.currency}${_controller.total.toStringAsFixed(0)}',
                        highlight: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26)),
              ),
              child: const Text('Back to Guide',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppColors.subtitle)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: highlight ? AppColors.price : AppColors.title)),
      ],
    );
  }

  // ---------- Bottom bar ----------

  Widget _buildBottomBar() {
    if (_controller.stepIndex == 0) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _controller.canContinueStep1 ? _controller.next : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26)),
              ),
              child: const Text('Continue',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      );
    }
    if (_controller.stepIndex == 1) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _controller.back,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26)),
                    side: const BorderSide(color: AppColors.cardBorder),
                  ),
                  child: const Text('Back',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _controller.next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26)),
                  ),
                  child: const Text('Continue',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    // Step 3 confirm
    final totalLabel =
        '${_controller.guide.currency}${_controller.total.toStringAsFixed(0)}';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _controller.back,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                  side: const BorderSide(color: AppColors.cardBorder),
                ),
                child: const Text('Back',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                // No payment backend — builds local Booking model only.
                onPressed: () => _controller.confirm(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                ),
                child: Text('Confirm & Pay $totalLabel',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.subtitle,
          letterSpacing: 0.5),
    );
  }
}
