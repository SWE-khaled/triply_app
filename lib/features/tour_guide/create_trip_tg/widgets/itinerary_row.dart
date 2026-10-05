import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/create_trip_cubit.dart';
import '../cubit/create_trip_state.dart';
import '../model/guide_trip_draft.dart';
import 'guide_form_field.dart';

/// Itinerary section: label + cubit-driven dynamic rows.
class ItinerarySection extends StatelessWidget {
  const ItinerarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GuideFormLabel(text: 'Itinerary'),
        const SizedBox(height: 6),
        BlocBuilder<CreateTripCubit, CreateTripState>(
          builder: (context, state) {
            return Column(
              children: [
                ...state.itinerary.map(
                  (s) => ItineraryRow(key: ValueKey(s.id), item: s),
                ),
                GuideAddRow(
                  label: '+ Add itinerary stop',
                  onTap: () => context.read<CreateTripCubit>().addStop(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Dynamic itinerary row (time + activity). Keyed by stable id;
/// owns its controllers so typing survives list rebuilds.
class ItineraryRow extends StatefulWidget {
  final ItineraryStopDraft item;

  const ItineraryRow({super.key, required this.item});

  @override
  State<ItineraryRow> createState() => _ItineraryRowState();
}

class _ItineraryRowState extends State<ItineraryRow> {
  late final TextEditingController _timeController;
  late final TextEditingController _activityController;

  @override
  void initState() {
    super.initState();
    _timeController = TextEditingController(text: widget.item.time);
    _activityController = TextEditingController(text: widget.item.activity);
  }

  @override
  void dispose() {
    _timeController.dispose();
    _activityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateTripCubit>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: GuideFormField(
              controller: _timeController,
              hint: '8:00 AM',
              onChanged: (v) => cubit.updateStopTime(widget.item.id, v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GuideFormField(
              controller: _activityController,
              hint: 'Activity or stop',
              onChanged: (v) => cubit.updateStopActivity(widget.item.id, v),
            ),
          ),
          const SizedBox(width: 8),
          GuideRemoveButton(onTap: () => cubit.removeStop(widget.item.id)),
        ],
      ),
    );
  }
}
