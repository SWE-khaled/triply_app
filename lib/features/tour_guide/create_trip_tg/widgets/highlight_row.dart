import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/create_trip_cubit.dart';
import '../cubit/create_trip_state.dart';
import '../model/guide_trip_draft.dart';
import 'guide_form_field.dart';

/// Highlights section: label + cubit-driven dynamic rows.
class HighlightsSection extends StatelessWidget {
  const HighlightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GuideFormLabel(text: 'Highlights'),
        const SizedBox(height: 6),
        BlocBuilder<CreateTripCubit, CreateTripState>(
          builder: (context, state) {
            return Column(
              children: [
                ...state.highlights.map(
                  (h) => HighlightRow(key: ValueKey(h.id), item: h),
                ),
                GuideAddRow(
                  label: '+ Add highlight',
                  onTap: () => context.read<CreateTripCubit>().addHighlight(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Dynamic highlight row. Keyed by stable id; owns its controller
/// so typing survives list rebuilds and deletes can't shift text.
class HighlightRow extends StatefulWidget {
  final HighlightDraft item;

  const HighlightRow({super.key, required this.item});

  @override
  State<HighlightRow> createState() => _HighlightRowState();
}

class _HighlightRowState extends State<HighlightRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: GuideFormField(
              controller: _controller,
              hint: 'Highlight',
              onChanged: (v) => context.read<CreateTripCubit>().updateHighlight(
                widget.item.id,
                v,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GuideRemoveButton(
            onTap: () =>
                context.read<CreateTripCubit>().removeHighlight(widget.item.id),
          ),
        ],
      ),
    );
  }
}
