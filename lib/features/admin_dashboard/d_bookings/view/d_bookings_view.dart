import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/repositories/admin_bookings_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../d_home/view/d_home_view.dart';
import '../cubit/bookings_cubit.dart';

/// Bookings management screen (connected dynamically to Firestore).
class BookingsView extends StatelessWidget {
  const BookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingsCubit()..start(),
      child: const _BookingsBody(),
    );
  }
}

class _BookingsBody extends StatelessWidget {
  const _BookingsBody();

  Future<void> _changeStatus(
    BuildContext context,
    AdminBooking booking,
    String status,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<BookingsCubit>().updateStatus(
      booking,
      status,
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Booking marked as $status.'
              : 'Could not update booking ${booking.bookingCode}.',
        ),
        backgroundColor: ok ? null : AppColors.adminDanger,
      ),
    );
  }

  void _showDetails(BuildContext context, AdminBooking booking) {
    showDialog(
      context: context,
      builder: (_) => _ViewBookingDialog(
        booking: booking,
        onStatusChange: (status) => _changeStatus(context, booking, status),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CardSectionHeader(
                    title: 'Manage Bookings',
                    subtitle: 'Search, review, edit and control all bookings.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SearchFilterRow(
              hintText: 'Search bookings...',
              onChanged: context.read<BookingsCubit>().search,
            ),
            const SizedBox(height: 24),

            BlocBuilder<BookingsCubit, BookingsState>(
              builder: (context, state) {
                final total = state is BookingsSuccess
                    ? state.bookings.length
                    : 0;
                final bookings = state is BookingsSuccess
                    ? state.filtered
                    : const <AdminBooking>[];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Recent Bookings" section
                    Row(
                      children: [
                        Text(
                          'Recent Bookings',
                          style: AppTextStyles.adminSectionTitle,
                        ),
                        const Spacer(),
                        Text(
                          '$total Total',
                          style: AppTextStyles.adminLinkText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildTable(context, state, bookings),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(
    BuildContext context,
    BookingsState state,
    List<AdminBooking> bookings,
  ) {
    final header = Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              _h('User', 3),
              _h('Trip', 3),
              _h('Guide', 3),
              _h('Date', 2),
              _h('Status', 2),
              _h('Price', 2),
              _h('Type', 2),
              _h('Actions', 2, end: true),
            ],
          ),
        ),
        const Divider(color: AppColors.adminDivider, height: 1),
      ],
    );

    if (state is BookingsInitial || state is BookingsLoading) {
      return Column(
        children: [
          header,
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }
    if (state is BookingsError) {
      return Column(
        children: [
          header,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text(state.message)),
          ),
        ],
      );
    }
    if (bookings.isEmpty) {
      return Column(
        children: [
          header,
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No bookings found.')),
          ),
        ],
      );
    }

    return AdminTableArea(
      minWidth: 900,
      child: Column(
        children: [
          header,
          for (final booking in bookings)
            _BookingRow(
              booking: booking,
              onView: () => _showDetails(context, booking),
            ),
        ],
      ),
    );
  }

  Widget _h(String label, int flex, {bool end = false}) => Expanded(
    flex: flex,
    child: Text(
      label,
      style: AppTextStyles.adminTableHeader,
      textAlign: end ? TextAlign.end : TextAlign.start,
    ),
  );
}

class _BookingRow extends StatelessWidget {
  final AdminBooking booking;
  final VoidCallback onView;
  const _BookingRow({required this.booking, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: AppColors.adminDivider, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  booking.user,
                  style: AppTextStyles.adminTableCell,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  booking.trip,
                  style: AppTextStyles.adminTableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  booking.guide,
                  style: AppTextStyles.adminTableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  booking.date,
                  style: AppTextStyles.adminTableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Expanded(flex: 2, child: StatusChip(status: booking.status)),
              Expanded(
                flex: 2,
                child: Text(
                  booking.price,
                  style: AppTextStyles.adminTableCellMuted,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(booking.type, style: AppTextStyles.adminLinkText),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [OutlineActionButton(label: 'View', onTap: onView)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Booking details dialog.
class _ViewBookingDialog extends StatelessWidget {
  final AdminBooking booking;
  final ValueChanged<String>? onStatusChange;

  const _ViewBookingDialog({required this.booking, this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Booking Details',
                      style: AppTextStyles.adminDialogTitle,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.adminDivider),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Close',
                        style: AppTextStyles.adminButtonSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _row('Booking Code:', booking.bookingCode),
              _row('Tourist:', booking.user),
              _row('Trip:', booking.trip),
              _row('Tour Guide:', booking.guide),
              _row('Date:', booking.date),
              _row('Travelers:', '${booking.travelers}'),
              if (booking.location.isNotEmpty)
                _row('Location:', booking.location),
              _row('Price:', booking.price),
              _row('Total:', booking.price),
              _row('Status:', booking.status.toUpperCase()),
              _row('Type:', booking.type),
              const SizedBox(height: 16),
              const Divider(color: AppColors.adminDivider),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (booking.status != 'confirmed')
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onStatusChange?.call('confirmed');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.adminPrimary,
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  if (booking.status != 'confirmed') const SizedBox(width: 8),
                  if (booking.status != 'cancelled')
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onStatusChange?.call('cancelled');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.adminDanger,
                        side: const BorderSide(color: AppColors.adminDanger),
                      ),
                      child: const Text('Cancel Booking'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTextStyles.adminFieldLabel),
          ),
          Expanded(child: Text(value, style: AppTextStyles.adminTableCell)),
        ],
      ),
    );
  }
}
