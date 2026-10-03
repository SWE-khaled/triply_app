import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/circle_back_button.dart';
import '../cubit/create_trip_cubit.dart';
import '../cubit/create_trip_state.dart';
import '../../trip_details/model/guide_trip_details.dart';
import '../../my_trips/model/guide_trip.dart';
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

class _CreateTripView extends StatelessWidget {
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

  Future<void> _pickDate(BuildContext context) async {
    final cubit = context.read<CreateTripCubit>();
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (d != null) {
      cubit.dateCtrl.text = '${d.day}/${d.month}/${d.year}';
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final cubit = context.read<CreateTripCubit>();
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null && context.mounted) {
      cubit.timeCtrl.text = t.format(context);
    }
  }

  void _toast(BuildContext context, String msg) {
    showAppSnackBar(context, msg, icon: Icons.info_outline);
  }

  void _preview(BuildContext context) {
    final trip = context.read<CreateTripCubit>().buildTrip();
    if (trip.title.isEmpty) {
      _toast(context, 'Enter a trip name to preview');
      return;
    }
    Navigator.of(context).push(AppRoutes.guideTripDetails(trip));
  }

  void _submit(BuildContext context, bool isEditing) {
    final cubit = context.read<CreateTripCubit>();
    if (isEditing) {
      final trip = editingTrip;
      final details = editingDetails;
      if (trip == null || details == null) {
        _toast(context, 'Cannot save: missing original trip');
        return;
      }
      final error = cubit.saveEdit(
        existingTrip: trip,
        existingDetails: details,
      );
      if (error != null) {
        _toast(context, error);
        return;
      }
      showAppSnackBar(context, 'Changes saved', icon: Icons.check_circle);
      Navigator.of(context).pop(true);
      return;
    }
    final result = cubit.submitTrip();
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
    final cubit = context.read<CreateTripCubit>();
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
                    isEditing ? formTitle : 'Create Trip',
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
                    imagePath: state.coverImagePath,
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
                nameCtrl: cubit.nameCtrl,
                aboutCtrl: cubit.aboutCtrl,
                locationCtrl: cubit.locationCtrl,
                labelCtrl: cubit.labelCtrl,
              ),
              const SizedBox(height: 12),
              ScheduleSection(
                dateCtrl: cubit.dateCtrl,
                timeCtrl: cubit.timeCtrl,
                durationCtrl: cubit.durationCtrl,
                priceCtrl: cubit.priceCtrl,
                onPickDate: () => _pickDate(context),
                onPickTime: () => _pickTime(context),
              ),
              const SizedBox(height: 12),
              LogisticsSection(
                maxTravelersCtrl: cubit.maxTravelersCtrl,
                meetingCtrl: cubit.meetingCtrl,
              ),
              const SizedBox(height: 12),
              const HighlightsSection(),
              const SizedBox(height: 6),
              const ItinerarySection(),
              const SizedBox(height: 6),
              ExtrasSection(
                includedCtrl: cubit.includedCtrl,
                notesCtrl: cubit.notesCtrl,
                languagesCtrl: cubit.languagesCtrl,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FormBottomBar(
        halfWidth: halfWidth,
        submitLabel: isEditing ? submitLabel : 'Submit for Approval',
        onPreview: () => _preview(context),
        onSubmit: () => _submit(context, isEditing),
      ),
    );
  }
}
