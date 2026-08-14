/// A calendar that exists on the device (a plugin-free stand-in for
/// `device_calendar`'s `Calendar` type — never leak the plugin type past
/// the gateway boundary).
class DeviceCalendarDescriptor {
  const DeviceCalendarDescriptor({
    required this.id,
    required this.name,
    this.color,
    this.accountName,
    this.isReadOnly = false,
    this.isDefault = false,
  });

  final String id;
  final String name;

  /// ARGB color, if the platform reports one.
  final int? color;
  final String? accountName;
  final bool isReadOnly;
  final bool isDefault;

  DeviceCalendarDescriptor copyWith({
    String? name,
    int? color,
    String? accountName,
    bool? isReadOnly,
    bool? isDefault,
  }) {
    return DeviceCalendarDescriptor(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      accountName: accountName ?? this.accountName,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DeviceCalendarDescriptor &&
      other.id == id &&
      other.name == name &&
      other.color == color &&
      other.accountName == accountName &&
      other.isReadOnly == isReadOnly &&
      other.isDefault == isDefault;

  @override
  int get hashCode =>
      Object.hash(id, name, color, accountName, isReadOnly, isDefault);

  @override
  String toString() => 'DeviceCalendarDescriptor(id: $id, name: $name)';
}
