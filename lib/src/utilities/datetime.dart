library;

/// DateTime will parse string and always treat it as local time when there is no
/// timezone information in the string.
/// Meanwhile server always returns UTC time.
/// This function will copy the DateTime object and set it as UTC time.
/// Details: https://github.com/dart-lang/sdk/issues/37420
DateTime getLocalDateTimeFromUTC(DateTime datetime) {
  return datetime.copyWith(isUtc: true).toLocal();
}
