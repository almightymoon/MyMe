/// Where a [MemyCalendarEvent] was first authored.
enum CalendarEventOrigin {
  /// Created inside MeMy.
  local,

  /// Imported from a device calendar via [DeviceCalendarGateway].
  external,
}
