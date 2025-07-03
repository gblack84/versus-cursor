import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class SettingsRecord extends FirestoreRecord {
  SettingsRecord._(
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

  static Stream<SettingsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SettingsRecord.fromSnapshot(s));

  static Future<SettingsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SettingsRecord.fromSnapshot(s));

  static SettingsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SettingsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SettingsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SettingsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SettingsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SettingsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSettingsRecordData({
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

class SettingsRecordDocumentEquality implements Equality<SettingsRecord> {
  const SettingsRecordDocumentEquality();

  @override
  bool equals(SettingsRecord? e1, SettingsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.country == e2?.country &&
        e1?.themePreferences == e2?.themePreferences &&
        listEquality.equals(e1?.privacySettings, e2?.privacySettings);
  }

  @override
  int hash(SettingsRecord? e) => const ListEquality()
      .hash([e?.country, e?.themePreferences, e?.privacySettings]);

  @override
  bool isValidKey(Object? o) => o is SettingsRecord;
}
