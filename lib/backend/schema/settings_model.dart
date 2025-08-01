import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class SettingsModel extends FirestoreRecord {
  SettingsModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "country" field.
  String? _country;
  String get country => _country ?? '';
  bool hasCountry() => _country != null;

  // "themePreferences" field.
  bool? _themePreferences;
  bool get themePreferences => _themePreferences ?? false;
  bool hasThemePreferences() => _themePreferences != null;

  // "privacySettings" field.
  List<String>? _privacySettings;
  List<String> get privacySettings => _privacySettings ?? const [];
  bool hasPrivacySettings() => _privacySettings != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _country = snapshotData['country'] as String?;
    _themePreferences = snapshotData['themePreferences'] as bool?;
    _privacySettings = getDataList(snapshotData['privacySettings']);
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('settings')
          : FirebaseFirestore.instance.collectionGroup('settings');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('settings').doc(id);

  static Stream<SettingsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SettingsModel.fromSnapshot(s));

  static Future<SettingsModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SettingsModel.fromSnapshot(s));

  static SettingsModel fromSnapshot(DocumentSnapshot snapshot) =>
      SettingsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SettingsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SettingsModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SettingsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SettingsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSettingsModelData({
  String? country,
  bool? themePreferences,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'country': country,
      'themePreferences': themePreferences,
    }.withoutNulls,
  );

  return firestoreData;
}

class SettingsModelDocumentEquality implements Equality<SettingsModel> {
  const SettingsModelDocumentEquality();

  @override
  bool equals(SettingsModel? e1, SettingsModel? e2) {
    const listEquality = ListEquality();
    return e1?.country == e2?.country &&
        e1?.themePreferences == e2?.themePreferences &&
        listEquality.equals(e1?.privacySettings, e2?.privacySettings);
  }

  @override
  int hash(SettingsModel? e) => const ListEquality()
      .hash([e?.country, e?.themePreferences, e?.privacySettings]);

  @override
  bool isValidKey(Object? o) => o is SettingsModel;
}
