import 'package:flutter/material.dart';

import 'package:bhada24_sp/core/theme/app_colors.dart';

typedef AiDescriptionGenerator = Future<String> Function(String language);

Future<String?> showAiDescriptionEditorDialog(
  BuildContext context, {
  required String initialText,
  required AiDescriptionGenerator onGenerate,
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final textCtrl = TextEditingController(text: initialText);
      var selectedLanguage = 'en';
      var generating = false;

      void wrapSelection(String start, String end) {
        final text = textCtrl.text;
        final selection = textCtrl.selection;
        if (!selection.isValid || selection.start == -1 || selection.end == -1) {
          textCtrl.text = '$text$start$end';
          textCtrl.selection = TextSelection.collapsed(
            offset: textCtrl.text.length - end.length,
          );
          return;
        }
        final selected = text.substring(selection.start, selection.end);
        final replaced = '$start$selected$end';
        textCtrl.text = text.replaceRange(
          selection.start,
          selection.end,
          replaced,
        );
        textCtrl.selection = TextSelection.collapsed(
          offset: selection.start + replaced.length,
        );
      }

      void prependLinePrefix(String prefix) {
        final text = textCtrl.text;
        final selection = textCtrl.selection;
        if (!selection.isValid || selection.start < 0 || selection.end < 0) {
          textCtrl.text = '$text\n$prefix';
          textCtrl.selection = TextSelection.collapsed(
            offset: textCtrl.text.length,
          );
          return;
        }

        final start = selection.start;
        final lineStart = text.lastIndexOf('\n', start == 0 ? 0 : start - 1) + 1;
        textCtrl.text = text.replaceRange(lineStart, lineStart, '$prefix ');
        textCtrl.selection = TextSelection.collapsed(
          offset: selection.end + prefix.length + 1,
        );
      }

      return StatefulBuilder(
        builder: (context, setDialogState) {
          final textLength = textCtrl.text.trim().length;

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760, maxHeight: 700),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Edit Service Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton.icon(
                                onPressed: generating
                                    ? null
                                    : () async {
                                        setDialogState(() => generating = true);
                                        try {
                                          final generatedText = await onGenerate(
                                            selectedLanguage,
                                          );
                                          textCtrl.text = generatedText;
                                        } finally {
                                          setDialogState(
                                            () => generating = false,
                                          );
                                        }
                                      },
                                icon: generating
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.auto_awesome, size: 16),
                                label: Text(
                                  generating ? 'Writing...' : 'AI Write',
                                ),
                              ),
                              ChoiceChip(
                                label: const Text('EN'),
                                selected: selectedLanguage == 'en',
                                onSelected: (
                                  _,
                                ) => setDialogState(() => selectedLanguage = 'en'),
                              ),
                              ChoiceChip(
                                label: const Text('हिंदी'),
                                selected: selectedLanguage == 'hi',
                                onSelected: (
                                  _,
                                ) => setDialogState(() => selectedLanguage = 'hi'),
                              ),
                              ChoiceChip(
                                label: const Text('Mix'),
                                selected: selectedLanguage == 'mix',
                                onSelected: (
                                  _,
                                ) => setDialogState(() => selectedLanguage = 'mix'),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  wrapSelection('**', '**');
                                  setDialogState(() {});
                                },
                                child: const Text('B'),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  wrapSelection('*', '*');
                                  setDialogState(() {});
                                },
                                child: const Text('/'),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  prependLinePrefix('•');
                                  setDialogState(() {});
                                },
                                child: const Text('• List'),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  prependLinePrefix('1.');
                                  setDialogState(() {});
                                },
                                child: const Text('1. List'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: textCtrl,
                            minLines: 10,
                            maxLines: 14,
                            onChanged: (_) => setDialogState(() {}),
                            decoration: const InputDecoration(
                              hintText: 'Describe your service in detail...',
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Tip: Use **bold**, *italic*, bullets, and 1. numbered lists',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$textLength characters',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop(textCtrl.text.trim());
                          },
                          child: const Text('Save & Close'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
