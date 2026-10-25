import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../../my_trips_tg/model/guide_trip.dart';
import '../../trip_details_tg/model/guide_trip_details.dart';
import '../cubit/create_trip_cubit.dart';
import '../widgets/cover_upload_box.dart';
import '../widgets/form_bottom_bar.dart';
import '../widgets/form_sections.dart';
import '../widgets/highlight_row.dart';
import '../widgets/itinerary_row.dart';

class CreateTripScreen extends StatelessWidget {
  /// When set, the form opens pre-filled from details (edit/manage).
  final GuideTripDetails? initialDetails;

  /// Original trip for edit/manage mode (id/status/image kept on save).
  final GuideTrip? initialTrip;

  /// Header title. Defaults to the create flow.
  final String formTitle;

  /// Submit button label. Defaults to the create flow.
  final String submitLabel;

  const CreateTripScreen({
    super.key,
    this.initialDetails,
    this.initialTrip,
    this.formTitle = 'Create Trip',
    this.submitLabel = 'Submit for Approval',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = CreateTripCubit();
        // The cubit fills the Highlights / Itinerary rows and the cover;
        // the text fields are filled by the view.
        final details = initialDetails;
        if (details != null) cubit.prefill(details);
        return cubit;
      },
      child: _CreateTripView(
        isEditing: initialDetails != null,
        editingTrip: initialTrip,
        editingDetails: initialDetails,
        formTitle: formTitle,
        submitLabel: submitLabel,
      ),
    );
  }
}

class _CreateTripView extends StatefulWidget {
  final bool isEditing;
  final GuideTrip? editingTrip;
  final GuideTripDetails? editingDetails;
  final String formTitle;
  final String submitLabel;

  const _CreateTripView({
    this.isEditing = false,
    this.editingTrip,
    this.editingDetails,
    this.formTitle = 'Create Trip',
    this.submitLabel = 'Submit for Approval',
  });

  @override
  State<_CreateTripView> createState() => _CreateTripViewState();
}

class _CreateTripViewState extends State<_CreateTripView> {
  final _nameCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _labelCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _maxTravelersCtrl = TextEditingController();
  final _meetingCtrl = TextEditingController();
  final _includedCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _languagesCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fillFromExisting();
  }

  /// Pre-fills the text fields when the form opens for editing.
  void _fillFromExisting() {
    final details = widget.editingDetails;
    final trip = widget.editingTrip;
    if (details != null) {
      _nameCtrl.text = details.title;
      _aboutCtrl.text = details.about;
      _locationCtrl.text = details.location;
      _durationCtrl.text = details.duration;
      _priceCtrl.text = details.priceEgp.toInt().toString();
      _meetingCtrl.text = details.meetingPoint;
      _includedCtrl.text = details.included;
      _notesCtrl.text = details.notes.join('\n');
      _languagesCtrl.text = details.languages;
      // Experience Label is stored on the details, not the trip.
      _labelCtrl.text = details.tag.trim();
    }
    _phoneCtrl.text = trip?.phone ?? '';
    // The live capacity so the guide sees (and can change) the
    // maximum travelers they saved — not an empty field.
    final capacity = trip?.capacity ?? 0;
    _maxTravelersCtrl.text = capacity > 0 ? capacity.toString() : '';
    // The picked date/time come back in the exact formats the pickers
    // write and `TripFormData.startAt` parses (d/m/yyyy, h:mm AM/PM).
    final start = trip?.startAt;
    if (start != null) {
      _dateCtrl.text = '${start.day}/${start.month}/${start.year}';
      final hour12 = start.hour % 12 == 0 ? 12 : start.hour % 12;
      final marker = start.hour >= 12 ? 'PM' : 'AM';
      _timeCtrl.text =
      '$hour12:${start.minute.toString().padLeft(2, '0')} $marker';
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _aboutCtrl,
      _locationCtrl,
      _labelCtrl,
      _dateCtrl,
      _timeCtrl,
      _durationCtrl,
      _priceCtrl,
      _maxTravelersCtrl,
      _meetingCtrl,
      _includedCtrl,
      _notesCtrl,
      _languagesCtrl,
      _phoneCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// The text of the static fields, handed to the cubit.
  TripFormData _formData() {
    return TripFormData(
      name: _nameCtrl.text.trim(),
      about: _aboutCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      label: _labelCtrl.text.trim(),
      date: _dateCtrl.text.trim(),
      time: _timeCtrl.text.trim(),
      duration: _durationCtrl.text.trim(),
      price: _priceCtrl.text.trim(),
      maxTravelers: _maxTravelersCtrl.text.trim(),
      meeting: _meetingCtrl.text.trim(),
      included: _includedCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      languages: _languagesCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (d != null) {
      _dateCtrl.text = '${d.day}/${d.month}/${d.year}';
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null && context.mounted) {
      _timeCtrl.text = t.format(context);
    }
  }

  void _toast(BuildContext context, String msg) {
    showAppSnackBar(context, msg, icon: Icons.info_outline);
  }

  void _preview(BuildContext context) {
    // The trip is not published yet, so its details are cached in the
    // session for the preview screen to read back.
    final preview = context.read<CreateTripCubit>().buildPreview(_formData());
    if (preview.trip.title.isEmpty) {
      _toast(context, 'Enter a trip name to preview');
      return;
    }
    Navigator.of(context).push(AppRoutes.guideTripDetails(preview.trip));
  }

  Future<void> _submit(BuildContext context, bool isEditing) async {
    final cubit = context.read<CreateTripCubit>();
    final form = _formData();
    if (isEditing) {
      final trip = widget.editingTrip;
      final details = widget.editingDetails;
      if (trip == null || details == null) {
        _toast(context, 'Cannot save: missing original trip');
        return;
      }
      final error = await cubit.saveEdit(
        form: form,
        existingTrip: trip,
        existingDetails: details,
      );
      if (!context.mounted) return;
      if (error != null) {
        _toast(context, error);
        return;
      }
      showAppSnackBar(context, 'Changes saved', icon: Icons.check_circle);
      Navigator.of(context).pop(true);
      return;
    }
    final result = await cubit.submitTrip(form);
    if (!context.mounted) return;
    if (result.error != null) {
      _toast(context, result.error!);
      return;
    }
    showAppSnackBar(
      context,
      'Trip submitted for approval',
      icon: Icons.check_circle,
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;
    final halfWidth = (MediaQuery.sizeOf(context).width - 42) / 2;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleBackButton(
                    icon: Icons.chevron_left,
                    iconColor: AppColors.titleDark,
                    backgroundColor: const Color(0xFFF6F1E7),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isEditing ? widget.formTitle : 'Create Trip',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.priceTeal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3F4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Public Trip',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.priceTeal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Trips you publish are available for multiple tourists to discover and join. Private bookings are created automatically when one tourist books you directly.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.dateText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              BlocBuilder<CreateTripCubit, CreateTripState>(
                builder: (context, state) {
                  return CoverUploadBox(
                    cover: state.cover,
                    onTap: () async {
                      final error = await context
                          .read<CreateTripCubit>()
                          .pickCoverImage();
                      if (error != null && context.mounted) {
                        _toast(context, error);
                      }
                    },
                    onRemove: () =>
                        context.read<CreateTripCubit>().removeCoverImage(),
                  );
                },
              ),
              const SizedBox(height: 14),
              BasicsSection(
                nameCtrl: _nameCtrl,
                aboutCtrl: _aboutCtrl,
                locationCtrl: _locationCtrl,
                labelCtrl: _labelCtrl,
                phoneCtrl: _phoneCtrl,
              ),
              const SizedBox(height: 12),
              ScheduleSection(
                dateCtrl: _dateCtrl,
                timeCtrl: _timeCtrl,
                durationCtrl: _durationCtrl,
                priceCtrl: _priceCtrl,
                onPickDate: () => _pickDate(context),
                onPickTime: () => _pickTime(context),
              ),
              const SizedBox(height: 12),
              LogisticsSection(
                maxTravelersCtrl: _maxTravelersCtrl,
                meetingCtrl: _meetingCtrl,
              ),
              const SizedBox(height: 12),
              const HighlightsSection(),
              const SizedBox(height: 6),
              const ItinerarySection(),
              const SizedBox(height: 6),
              ExtrasSection(
                includedCtrl: _includedCtrl,
                notesCtrl: _notesCtrl,
                languagesCtrl: _languagesCtrl,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FormBottomBar(
        halfWidth: halfWidth,
        submitLabel: isEditing ? widget.submitLabel : 'Submit for Approval',
        onPreview: () => _preview(context),
        onSubmit: () => _submit(context, isEditing),
      ),
    );
  }
}