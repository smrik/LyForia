/// Quick time selection options for logging events.
/// Provides common presets (Now, 5/15/30/60min ago) plus custom picker.
enum QuickTimeOption {
  now,
  min5Ago,
  min15Ago,
  min30Ago,
  hour1Ago,
  pickCustom,
}

extension QuickTimeOptionX on QuickTimeOption {
  /// User-facing label for dropdown
  String get label {
    switch (this) {
      case QuickTimeOption.now:
        return 'Now';
      case QuickTimeOption.min5Ago:
        return '5 minutes ago';
      case QuickTimeOption.min15Ago:
        return '15 minutes ago';
      case QuickTimeOption.min30Ago:
        return '30 minutes ago';
      case QuickTimeOption.hour1Ago:
        return '1 hour ago';
      case QuickTimeOption.pickCustom:
        return 'Pick exact time...';
    }
  }

  /// Calculate the DateTime for this option.
  /// For pickCustom, returns null (caller should show TimePicker).
  DateTime? toDateTime() {
    final now = DateTime.now();
    switch (this) {
      case QuickTimeOption.now:
        return now;
      case QuickTimeOption.min5Ago:
        return now.subtract(const Duration(minutes: 5));
      case QuickTimeOption.min15Ago:
        return now.subtract(const Duration(minutes: 15));
      case QuickTimeOption.min30Ago:
        return now.subtract(const Duration(minutes: 30));
      case QuickTimeOption.hour1Ago:
        return now.subtract(const Duration(hours: 1));
      case QuickTimeOption.pickCustom:
        return null; // Caller should show TimePicker
    }
  }
}
