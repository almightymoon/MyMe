/// One selectable avatar from the MeMy 3D art pack. No user photos.
class ProfileAvatarSpec {
  const ProfileAvatarSpec({
    required this.id,
    required this.label,
    required this.assetPath,
  });

  final String id;
  final String label;
  final String assetPath;
}

abstract final class ProfileAvatarCatalog {
  static const String defaultId = 'memy_3d_01';
  static const String _assetDir = 'assets/images/avatars';

  static const List<ProfileAvatarSpec> all = [
    ProfileAvatarSpec(
      id: 'memy_3d_01',
      label: '1',
      assetPath: '$_assetDir/memy_3d_01.webp',
    ),
    ProfileAvatarSpec(
      id: 'memy_3d_02',
      label: '2',
      assetPath: '$_assetDir/memy_3d_02.webp',
    ),
    ProfileAvatarSpec(
      id: 'memy_3d_03',
      label: '3',
      assetPath: '$_assetDir/memy_3d_03.webp',
    ),
    ProfileAvatarSpec(
      id: 'memy_3d_04',
      label: '4',
      assetPath: '$_assetDir/memy_3d_04.webp',
    ),
    ProfileAvatarSpec(
      id: 'memy_3d_05',
      label: '5',
      assetPath: '$_assetDir/memy_3d_05.webp',
    ),
    ProfileAvatarSpec(
      id: 'memy_3d_06',
      label: '6',
      assetPath: '$_assetDir/memy_3d_06.webp',
    ),
    ProfileAvatarSpec(
      id: 'memy_3d_07',
      label: '7',
      assetPath: '$_assetDir/memy_3d_07.webp',
    ),
    ProfileAvatarSpec(
      id: 'memy_3d_08',
      label: '8',
      assetPath: '$_assetDir/memy_3d_08.webp',
    ),
    ProfileAvatarSpec(
      id: 'memy_3d_09',
      label: '9',
      assetPath: '$_assetDir/memy_3d_09.webp',
    ),
    ProfileAvatarSpec(
      id: 'memy_3d_10',
      label: '10',
      assetPath: '$_assetDir/memy_3d_10.webp',
    ),
    ProfileAvatarSpec(
      id: 'memy_3d_11',
      label: '11',
      assetPath: '$_assetDir/memy_3d_11.webp',
    ),
    ProfileAvatarSpec(
      id: 'memy_3d_12',
      label: '12',
      assetPath: '$_assetDir/memy_3d_12.webp',
    ),
  ];

  static const List<String> ids = [
    'memy_3d_01',
    'memy_3d_02',
    'memy_3d_03',
    'memy_3d_04',
    'memy_3d_05',
    'memy_3d_06',
    'memy_3d_07',
    'memy_3d_08',
    'memy_3d_09',
    'memy_3d_10',
    'memy_3d_11',
    'memy_3d_12',
  ];

  /// Placeholder ids and the retired illustrated pack map onto the 3D set.
  static const Map<String, String> _legacyIds = {
    'ember': 'memy_3d_01',
    'moss': 'memy_3d_02',
    'sky': 'memy_3d_01',
    'dusk': 'memy_3d_02',
    'sand': 'memy_3d_03',
    'berry': 'memy_3d_04',
    'pine': 'memy_3d_03',
    'coral': 'memy_3d_05',
    'mist': 'memy_3d_04',
    'gold': 'memy_3d_06',
    'ink': 'memy_3d_05',
    'bloom': 'memy_3d_07',
    'memy_illustrated_01': 'memy_3d_01',
    'memy_illustrated_02': 'memy_3d_02',
    'memy_illustrated_03': 'memy_3d_03',
    'memy_illustrated_04': 'memy_3d_04',
    'memy_illustrated_05': 'memy_3d_05',
    'memy_illustrated_06': 'memy_3d_06',
    'memy_illustrated_07': 'memy_3d_07',
    'memy_illustrated_08': 'memy_3d_08',
    'memy_illustrated_09': 'memy_3d_09',
    'memy_illustrated_10': 'memy_3d_10',
    'memy_illustrated_11': 'memy_3d_11',
    'memy_illustrated_12': 'memy_3d_12',
  };

  static bool isValid(String? id) {
    if (id == null) return false;
    return ids.contains(id) || _legacyIds.containsKey(id);
  }

  static String resolve(String? id) {
    if (id == null || id.isEmpty) return defaultId;
    final mapped = _legacyIds[id] ?? id;
    return ids.contains(mapped) ? mapped : defaultId;
  }

  static ProfileAvatarSpec byId(String? id) {
    final resolved = resolve(id);
    return all.firstWhere((spec) => spec.id == resolved);
  }
}
