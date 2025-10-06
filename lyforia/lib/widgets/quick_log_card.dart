import 'package:flutter/material.dart';
import 'package:lyforia/utils/app_constants.dart';
import 'package:lyforia/utils/quick_time_option.dart';

/// Quick-log card for fast binge entry (time + place only).
/// Designed to reduce friction from 7-field form to 2-field form.
class QuickLogCard extends StatefulWidget {
  const QuickLogCard({
    super.key,
    required this.onSubmit,
  });

  /// Callback when user submits quick-log.
  /// Parameters: (DateTime selectedTime, String place)
  final void Function(DateTime selectedTime, String place) onSubmit;

  @override
  State<QuickLogCard> createState() => _QuickLogCardState();
}

class _QuickLogCardState extends State<QuickLogCard> {
  QuickTimeOption _selectedTimeOption = QuickTimeOption.now;
  DateTime? _customTime; // Used if user picks custom time
  final _placeController = TextEditingController();
  bool _saving = false;
  String? _placeError;

  @override
  void dispose() {
    _placeController.dispose();
    super.dispose();
  }

  /// Validate place field (required, min 2 chars)
  String? _validatePlace(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Place is required';
    }
    if (value.trim().length < 2) {
      return 'Please enter at least 2 characters';
    }
    return null;
  }

  /// Handle time dropdown selection
  Future<void> _onTimeOptionChanged(QuickTimeOption? option) async {
    if (option == null) return;

    if (option == QuickTimeOption.pickCustom) {
      // Show time picker
      final now = DateTime.now();
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_customTime ?? now),
      );

      if (picked != null) {
        setState(() {
          _selectedTimeOption = option;
          _customTime = DateTime(
            now.year,
            now.month,
            now.day,
            picked.hour,
            picked.minute,
          );
        });
      }
      // If user cancels, keep previous selection
    } else {
      setState(() {
        _selectedTimeOption = option;
        _customTime = null;
      });
    }
  }

  /// Get the effective DateTime based on selection
  DateTime _getEffectiveTime() {
    if (_selectedTimeOption == QuickTimeOption.pickCustom && _customTime != null) {
      return _customTime!;
    }
    return _selectedTimeOption.toDateTime() ?? DateTime.now();
  }

  /// Handle submit button tap
  void _onSubmit() {
    // Validate place
    final error = _validatePlace(_placeController.text);
    if (error != null) {
      setState(() => _placeError = error);
      return;
    }

    // Clear any previous error
    setState(() {
      _placeError = null;
      _saving = true;
    });

    // Get effective time and place
    final time = _getEffectiveTime();
    final place = _placeController.text.trim();

    // Call parent callback
    widget.onSubmit(time, place);

    // Reset form (parent will handle success state)
    setState(() {
      _saving = false;
      _selectedTimeOption = QuickTimeOption.now;
      _customTime = null;
      _placeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSubmit = _placeController.text.trim().length >= 2 && !_saving;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.bolt,
                color: theme.colorScheme.primary,
                size: AppSizes.iconLg,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Log',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      'Log in seconds, add details later',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Time dropdown
          DropdownButtonFormField<QuickTimeOption>(
            key: const Key('quickLogTimeDropdown'),
            value: _selectedTimeOption,
            decoration: InputDecoration(
              labelText: 'Time',
              prefixIcon: const Icon(Icons.access_time),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            items: QuickTimeOption.values.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(
                  option == QuickTimeOption.pickCustom && _customTime != null
                      ? TimeOfDay.fromDateTime(_customTime!).format(context)
                      : option.label,
                ),
              );
            }).toList(),
            onChanged: _saving ? null : _onTimeOptionChanged,
          ),

          const SizedBox(height: AppSpacing.md),

          // Place text field
          TextField(
            key: const Key('quickLogPlaceField'),
            controller: _placeController,
            enabled: !_saving,
            decoration: InputDecoration(
              labelText: 'Place *',
              hintText: 'e.g., Home, Work, Car',
              prefixIcon: const Icon(Icons.location_on),
              errorText: _placeError,
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            maxLength: 100,
            onChanged: (_) {
              // Clear error on type
              if (_placeError != null) {
                setState(() => _placeError = null);
              }
            },
            onSubmitted: (_) {
              if (canSubmit) _onSubmit();
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Submit button
          ElevatedButton.icon(
            key: const Key('quickLogSubmitButton'),
            onPressed: canSubmit ? _onSubmit : null,
            icon: _saving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : const Icon(Icons.check),
            label: Text(_saving ? 'Saving...' : 'Log It'),
          ),
        ],
      ),
    );
  }
}
