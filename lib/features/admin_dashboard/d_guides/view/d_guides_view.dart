import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../core/widgets/d_circle_back_button.dart';
import '../../../../data/firestore/models/trip_doc.dart';
import '../../../../data/firestore/repositories/admin_repository.dart';
import '../../d_home/view/d_home_view.dart';

/// Guides verification management screen (server-backed).
///
/// Rows come from the canonical `guideVerifications` queue (plus review
/// history); approve/reject go through the admin-only `decideVerification`
/// callable; suspend/activate toggles the account's `isActive` flag.
/// Nothing here grants privileges client-side.
class GuidesView extends StatefulWidget {
  const GuidesView({super.key});

  @override
  State<GuidesView> createState() => _GuidesViewState();
}

class _GuidesViewState extends State<GuidesView> {
  final AdminRepository _repo = AdminRepository();
  List<AdminGuideRow> _rows = [];
  bool _loading = true;
  String? _error;
  final Set<String> _busy = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Reloads the queue. Returns false (with [error] set) when the list
  /// may be stale — callers that just mutated state surface a notice
  /// instead of a misleading success.
  Future<bool> _load() async {
    if (!mounted) return false;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await _repo.recentVerifications();
      if (!mounted) return false;
      setState(() {
        _rows = rows;
        _loading = false;
      });
      return true;
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        _loading = false;
        _error = _message(e);
      });
      return false;
    }
  }

  int get _pendingCount => _rows.where((g) => g.status == 'pending').length;

  static String _message(Object e) {
    const prefix = 'Exception: ';
    final text = e.toString();
    final msg = text.startsWith(prefix) ? text.substring(prefix.length) : text;
    return msg.isEmpty ? 'Operation failed. Please try again.' : msg;
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _approve(AdminGuideRow row) async {
    if (_busy.contains(row.guideId)) return;
    setState(() => _busy.add(row.guideId));
    try {
      await _repo.decideVerification(guideId: row.guideId, approved: true);
      final fresh = await _load();
      _snack(
        fresh
            ? 'Guide approved.'
            : 'Guide approved, but the list could not refresh.',
      );
    } catch (e) {
      _snack(_message(e));
    } finally {
      if (mounted) setState(() => _busy.remove(row.guideId));
    }
  }

  Future<void> _reject(AdminGuideRow row) async {
    if (_busy.contains(row.guideId)) return;
    final reason = await _askReason();
    if (reason == null || !mounted) return;
    setState(() => _busy.add(row.guideId));
    try {
      await _repo.decideVerification(
        guideId: row.guideId,
        approved: false,
        rejectionReason: reason,
      );
      final fresh = await _load();
      _snack(
        fresh
            ? 'Verification rejected.'
            : 'Rejected, but the list could not refresh.',
      );
    } catch (e) {
      _snack(_message(e));
    } finally {
      if (mounted) setState(() => _busy.remove(row.guideId));
    }
  }

  /// Optional rejection reason (empty allowed — matches the trip
  /// applications flow). Null means the admin dismissed the dialog.
  Future<String?> _askReason() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Reject verification'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'e.g., Blurry document...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text(
              'Reject',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  /// Suspend/activate toggles account access (`users.isActive`), which is
  /// orthogonal to the verification verdict. Admin-only by rules.
  Future<void> _toggleActive(AdminGuideRow row) async {
    if (_busy.contains(row.guideId)) return;
    setState(() => _busy.add(row.guideId));
    try {
      await _repo.setUserActive(row.guideId, !row.userActive);
      final fresh = await _load();
      if (!fresh) {
        _snack('Saved, but the list could not refresh.');
      } else {
        _snack(row.userActive ? 'Guide suspended.' : 'Guide reactivated.');
      }
    } catch (e) {
      _snack(_message(e));
    } finally {
      if (mounted) setState(() => _busy.remove(row.guideId));
    }
  }

  void _showDetails(AdminGuideRow row) {
    showDialog(
      context: context,
      builder: (_) => _GuideDetailsDialog(row: row, repo: _repo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Expanded(
                  child: CardSectionHeader(
                    title: 'Tour Guide Verification',
                    subtitle:
                        'Review documents, guide activity and uploaded content',
                  ),
                ),
                if (_pendingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.statusPendingBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_pendingCount pending',
                      style: AppTextStyles.tableCellMuted.copyWith(
                        color: AppColors.statusPendingText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null && _rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Table header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    _h('Guide', 3),
                    _h('Document', 4),
                    _h('City', 2),
                    _h('Status', 2),
                    _h('Actions', 4, end: true),
                  ],
                ),
              ),
              const Divider(color: AppColors.divider, height: 1),

              ..._rows.map(
                (g) => _GuideRow(
                  row: g,
                  busy: _busy.contains(g.guideId),
                  onApprove: () => _approve(g),
                  onReject: () => _reject(g),
                  onToggleActive: () => _toggleActive(g),
                  onDetails: () => _showDetails(g),
                ),
              ),
              if (_rows.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No guide applications found.')),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _h(String label, int flex, {bool end = false}) => Expanded(
    flex: flex,
    child: Text(
      label,
      style: AppTextStyles.tableHeader,
      textAlign: end ? TextAlign.end : TextAlign.start,
    ),
  );
}

class _GuideRow extends StatelessWidget {
  final AdminGuideRow row;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onToggleActive;
  final VoidCallback onDetails;

  const _GuideRow({
    required this.row,
    required this.busy,
    required this.onApprove,
    required this.onReject,
    required this.onToggleActive,
    required this.onDetails,
  });

  /// Submitted document files for this row (ID and/or license).
  String get _documents {
    final v = row.verification;
    final hasId = v.idDocumentUrl.isNotEmpty;
    final hasLicense = v.licenseDocumentUrl.isNotEmpty;
    if (hasId && hasLicense) return '2 files';
    if (hasId || hasLicense) return '1 file';
    return 'No files';
  }

  @override
  Widget build(BuildContext context) {
    final isPending = row.status == 'pending';
    final actions = busy
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : null;

    return Column(
      children: [
        const Divider(color: AppColors.divider, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              // Guide name + email
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.displayName,
                      style: AppTextStyles.tableCell,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      row.email,
                      style: AppTextStyles.tableCellMuted,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              // Document + "View file"
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _documents,
                        style: AppTextStyles.tableCellMuted,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _showDetails(context),
                      child: Text('View file', style: AppTextStyles.linkText),
                    ),
                  ],
                ),
              ),
              // City
              Expanded(
                flex: 2,
                child: Text(
                  row.city.isNotEmpty ? row.city : '—',
                  style: AppTextStyles.tableCellMuted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              // Status chip (verification verdict; suspended accounts keep
              // their verdict chip and toggle via Suspend/Activate).
              Expanded(
                flex: 2,
                child: StatusChip(
                  status: row.userActive ? row.status : 'suspended',
                ),
              ),
              // Actions
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlineActionButton(label: 'Details', onTap: onDetails),
                    const SizedBox(width: 6),
                    if (actions != null)
                      actions
                    else if (isPending) ...[
                      DangerActionButton(label: 'Reject', onTap: onReject),
                      const SizedBox(width: 6),
                      PrimaryActionButton(label: 'Approve', onTap: onApprove),
                    ] else if (row.status == 'rejected') ...[
                      PrimaryActionButton(label: 'Approve', onTap: onApprove),
                    ] else if (row.userActive) ...[
                      DangerActionButton(
                        label: 'Suspend',
                        onTap: onToggleActive,
                      ),
                    ] else ...[
                      OutlineActionButton(
                        label: 'Activate',
                        onTap: onToggleActive,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _GuideDetailsDialog(row: row, repo: AdminRepository()),
    );
  }
}

/// Guide details modal — shown on "Details" / "View file" tap.
class _GuideDetailsDialog extends StatelessWidget {
  final AdminGuideRow row;
  final AdminRepository repo;
  const _GuideDetailsDialog({required this.row, required this.repo});

  void _showTripDialog(BuildContext context, TripDoc trip) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          trip.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Status: ${trip.approvalStatus}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No document file available.')),
      );
      return;
    }
    try {
      final opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't open the document.")),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't open the document.")),
        );
      }
    }
  }

  static String _dateLabel(DateTime? date) {
    if (date == null) return '—';
    final d = date.toLocal();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final v = row.verification;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(row.displayName, style: AppTextStyles.dialogTitle),
                        const SizedBox(height: 3),
                        Text(
                          'Complete guide application',
                          style: AppTextStyles.dialogSubtitle,
                        ),
                      ],
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
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Close',
                        style: AppTextStyles.buttonSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Info grid
              Row(
                children: [
                  Expanded(
                    child: _InfoField(label: 'Email', value: row.email),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _InfoField(
                      label: 'Phone',
                      value: row.contactPhone.isNotEmpty
                          ? row.contactPhone
                          : '—',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoField(
                      label: 'City',
                      value: row.city.isNotEmpty ? row.city : '—',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _InfoField(
                      label: 'Submitted',
                      value: _dateLabel(v.submittedAt),
                    ),
                  ),
                ],
              ),
              if (v.status == 'rejected' && v.rejectionReason.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoField(label: 'Rejection reason', value: v.rejectionReason),
              ],
              const SizedBox(height: 18),

              // Document boxes (ID + license share the layout).
              _DocBox(
                title: 'Identity document',
                fileName: v.idDocumentUrl.isNotEmpty
                    ? v.idDocumentUrl.split('/').last
                    : 'Not uploaded',
                hasFile: v.idDocumentUrl.isNotEmpty,
                onOpen: () => _openUrl(context, v.idDocumentUrl),
              ),
              const SizedBox(height: 12),
              _DocBox(
                title: 'Guide license',
                fileName: v.licenseDocumentUrl.isNotEmpty
                    ? v.licenseDocumentUrl.split('/').last
                    : 'Not uploaded',
                hasFile: v.licenseDocumentUrl.isNotEmpty,
                onOpen: () => _openUrl(context, v.licenseDocumentUrl),
              ),
              const SizedBox(height: 20),

              // Uploaded trips (live).
              Text('Uploaded trips', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 12),
              FutureBuilder<List<TripDoc>>(
                future: repo.guideTrips(row.guideId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  final trips = snapshot.data ?? [];
                  if (trips.isEmpty) {
                    return Text(
                      'No trips uploaded yet.',
                      style: AppTextStyles.tableCellMuted,
                    );
                  }
                  return Row(
                    children: trips
                        .take(3)
                        .map(
                          (t) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.divider),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    style: AppTextStyles.tableCell,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  Text(
                                    t.approvalStatus,
                                    style: AppTextStyles.tableCellMuted,
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () => _showTripDialog(context, t),
                                    child: Text(
                                      'View full trip',
                                      style: AppTextStyles.linkText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocBox extends StatelessWidget {
  final String title;
  final String fileName;
  final bool hasFile;
  final VoidCallback onOpen;

  const _DocBox({
    required this.title,
    required this.fileName,
    required this.hasFile,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 15),
                    ),
                    Text(fileName, style: AppTextStyles.tableCellMuted),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onOpen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                child: Text('View', style: AppTextStyles.buttonPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Document preview area
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.documentPreviewBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.article_outlined,
                  size: 40,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 8),
                Text('Document preview', style: AppTextStyles.tableCellMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;
  const _InfoField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.tableCellMuted),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.fieldValue,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
