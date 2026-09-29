import 'package:flutter/material.dart';

/// Delete confirmation replacing post dialog (`community_screen.dart:498`)
/// and story dialog (`story_viewer_screen.dart:111`). Fixes the 'Cancle' typo.
class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelLabel;
  final String deleteLabel;

  const ConfirmDeleteDialog({
    super.key,
    this.title = 'Deleting post',
    this.content = 'Are you sure you want to delete this post?',
    this.cancelLabel = 'Cancel',
    this.deleteLabel = 'Delete',
  });

  static Future<bool> show(
    BuildContext context, {
    String title = 'Deleting post',
    String content = 'Are you sure you want to delete this post?',
    String cancelLabel = 'Cancel',
    String deleteLabel = 'Delete',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDeleteDialog(
        title: title,
        content: content,
        cancelLabel: cancelLabel,
        deleteLabel: deleteLabel,
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(deleteLabel, style: const TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
