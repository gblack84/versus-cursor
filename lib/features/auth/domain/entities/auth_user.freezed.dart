// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthUser {

// ==================== Authentication fields ====================
/// 사용자 고유 ID (Firebase UID)
 String get uid;/// 이메일 주소
 String? get email;/// 표시 이름 (Display Name)
 String? get displayName;/// 사용자 이름 (Unique Username)
 String? get userName;/// 프로필 사진 URL
 String? get photoUrl;/// 전화번호
 String? get phoneNumber;/// 이메일 인증 여부
 bool get isEmailVerified;/// 익명 사용자 여부
 bool get isAnonymous;/// 로그인 제공자 ID (google, apple, email, phone 등)
 String? get providerId;// ==================== Profile fields ====================
/// 자기소개
 String? get bio;/// 나이
 int? get age;/// 성별
 String? get gender;/// 관심사 목록
 List<String> get interests;/// 전문 분야 목록 (최대 4개)
 List<String> get expertise;/// 취미 목록 (최대 8개)
 List<String> get hobbies;// ==================== Points & Rewards ====================
/// A 포인트 (답변으로 얻은 포인트)
 int get pointsA;/// Q 포인트 (질문으로 얻은 포인트)
 int get pointsQ;// ==================== Role & Premium ====================
/// 사용자 역할 (admin, tester, user)
@JsonKey(fromJson: _userRoleFromJson, toJson: _userRoleToJson) UserRole get role;/// 프리미엄 사용자 여부
 bool get isPremium;// ==================== Timestamps ====================
/// 계정 생성 시간
 DateTime? get createdAt;/// 마지막 로그인 시간
 DateTime? get lastLoginAt;// ==================== Additional ====================
/// 사용자 설정 (Key-Value 형태)
 Map<String, dynamic> get settings;
/// Create a copy of AuthUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthUserCopyWith<AuthUser> get copyWith => _$AuthUserCopyWithImpl<AuthUser>(this as AuthUser, _$identity);

  /// Serializes this AuthUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUser&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other.interests, interests)&&const DeepCollectionEquality().equals(other.expertise, expertise)&&const DeepCollectionEquality().equals(other.hobbies, hobbies)&&(identical(other.pointsA, pointsA) || other.pointsA == pointsA)&&(identical(other.pointsQ, pointsQ) || other.pointsQ == pointsQ)&&(identical(other.role, role) || other.role == role)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&const DeepCollectionEquality().equals(other.settings, settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,displayName,userName,photoUrl,phoneNumber,isEmailVerified,isAnonymous,providerId,bio,age,gender,const DeepCollectionEquality().hash(interests),const DeepCollectionEquality().hash(expertise),const DeepCollectionEquality().hash(hobbies),pointsA,pointsQ,role,isPremium,createdAt,lastLoginAt,const DeepCollectionEquality().hash(settings)]);

@override
String toString() {
  return 'AuthUser(uid: $uid, email: $email, displayName: $displayName, userName: $userName, photoUrl: $photoUrl, phoneNumber: $phoneNumber, isEmailVerified: $isEmailVerified, isAnonymous: $isAnonymous, providerId: $providerId, bio: $bio, age: $age, gender: $gender, interests: $interests, expertise: $expertise, hobbies: $hobbies, pointsA: $pointsA, pointsQ: $pointsQ, role: $role, isPremium: $isPremium, createdAt: $createdAt, lastLoginAt: $lastLoginAt, settings: $settings)';
}


}

/// @nodoc
abstract mixin class $AuthUserCopyWith<$Res>  {
  factory $AuthUserCopyWith(AuthUser value, $Res Function(AuthUser) _then) = _$AuthUserCopyWithImpl;
@useResult
$Res call({
 String uid, String? email, String? displayName, String? userName, String? photoUrl, String? phoneNumber, bool isEmailVerified, bool isAnonymous, String? providerId, String? bio, int? age, String? gender, List<String> interests, List<String> expertise, List<String> hobbies, int pointsA, int pointsQ,@JsonKey(fromJson: _userRoleFromJson, toJson: _userRoleToJson) UserRole role, bool isPremium, DateTime? createdAt, DateTime? lastLoginAt, Map<String, dynamic> settings
});




}
/// @nodoc
class _$AuthUserCopyWithImpl<$Res>
    implements $AuthUserCopyWith<$Res> {
  _$AuthUserCopyWithImpl(this._self, this._then);

  final AuthUser _self;
  final $Res Function(AuthUser) _then;

/// Create a copy of AuthUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? email = freezed,Object? displayName = freezed,Object? userName = freezed,Object? photoUrl = freezed,Object? phoneNumber = freezed,Object? isEmailVerified = null,Object? isAnonymous = null,Object? providerId = freezed,Object? bio = freezed,Object? age = freezed,Object? gender = freezed,Object? interests = null,Object? expertise = null,Object? hobbies = null,Object? pointsA = null,Object? pointsQ = null,Object? role = null,Object? isPremium = null,Object? createdAt = freezed,Object? lastLoginAt = freezed,Object? settings = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,isEmailVerified: null == isEmailVerified ? _self.isEmailVerified : isEmailVerified // ignore: cast_nullable_to_non_nullable
as bool,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,providerId: freezed == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,interests: null == interests ? _self.interests : interests // ignore: cast_nullable_to_non_nullable
as List<String>,expertise: null == expertise ? _self.expertise : expertise // ignore: cast_nullable_to_non_nullable
as List<String>,hobbies: null == hobbies ? _self.hobbies : hobbies // ignore: cast_nullable_to_non_nullable
as List<String>,pointsA: null == pointsA ? _self.pointsA : pointsA // ignore: cast_nullable_to_non_nullable
as int,pointsQ: null == pointsQ ? _self.pointsQ : pointsQ // ignore: cast_nullable_to_non_nullable
as int,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,settings: null == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthUser].
extension AuthUserPatterns on AuthUser {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthUser() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthUser value)  $default,){
final _that = this;
switch (_that) {
case _AuthUser():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthUser value)?  $default,){
final _that = this;
switch (_that) {
case _AuthUser() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String? email,  String? displayName,  String? userName,  String? photoUrl,  String? phoneNumber,  bool isEmailVerified,  bool isAnonymous,  String? providerId,  String? bio,  int? age,  String? gender,  List<String> interests,  List<String> expertise,  List<String> hobbies,  int pointsA,  int pointsQ, @JsonKey(fromJson: _userRoleFromJson, toJson: _userRoleToJson)  UserRole role,  bool isPremium,  DateTime? createdAt,  DateTime? lastLoginAt,  Map<String, dynamic> settings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthUser() when $default != null:
return $default(_that.uid,_that.email,_that.displayName,_that.userName,_that.photoUrl,_that.phoneNumber,_that.isEmailVerified,_that.isAnonymous,_that.providerId,_that.bio,_that.age,_that.gender,_that.interests,_that.expertise,_that.hobbies,_that.pointsA,_that.pointsQ,_that.role,_that.isPremium,_that.createdAt,_that.lastLoginAt,_that.settings);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String? email,  String? displayName,  String? userName,  String? photoUrl,  String? phoneNumber,  bool isEmailVerified,  bool isAnonymous,  String? providerId,  String? bio,  int? age,  String? gender,  List<String> interests,  List<String> expertise,  List<String> hobbies,  int pointsA,  int pointsQ, @JsonKey(fromJson: _userRoleFromJson, toJson: _userRoleToJson)  UserRole role,  bool isPremium,  DateTime? createdAt,  DateTime? lastLoginAt,  Map<String, dynamic> settings)  $default,) {final _that = this;
switch (_that) {
case _AuthUser():
return $default(_that.uid,_that.email,_that.displayName,_that.userName,_that.photoUrl,_that.phoneNumber,_that.isEmailVerified,_that.isAnonymous,_that.providerId,_that.bio,_that.age,_that.gender,_that.interests,_that.expertise,_that.hobbies,_that.pointsA,_that.pointsQ,_that.role,_that.isPremium,_that.createdAt,_that.lastLoginAt,_that.settings);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String? email,  String? displayName,  String? userName,  String? photoUrl,  String? phoneNumber,  bool isEmailVerified,  bool isAnonymous,  String? providerId,  String? bio,  int? age,  String? gender,  List<String> interests,  List<String> expertise,  List<String> hobbies,  int pointsA,  int pointsQ, @JsonKey(fromJson: _userRoleFromJson, toJson: _userRoleToJson)  UserRole role,  bool isPremium,  DateTime? createdAt,  DateTime? lastLoginAt,  Map<String, dynamic> settings)?  $default,) {final _that = this;
switch (_that) {
case _AuthUser() when $default != null:
return $default(_that.uid,_that.email,_that.displayName,_that.userName,_that.photoUrl,_that.phoneNumber,_that.isEmailVerified,_that.isAnonymous,_that.providerId,_that.bio,_that.age,_that.gender,_that.interests,_that.expertise,_that.hobbies,_that.pointsA,_that.pointsQ,_that.role,_that.isPremium,_that.createdAt,_that.lastLoginAt,_that.settings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthUser extends AuthUser {
  const _AuthUser({required this.uid, this.email, this.displayName, this.userName, this.photoUrl, this.phoneNumber, this.isEmailVerified = false, this.isAnonymous = false, this.providerId, this.bio, this.age, this.gender, final  List<String> interests = const [], final  List<String> expertise = const [], final  List<String> hobbies = const [], this.pointsA = 0, this.pointsQ = 0, @JsonKey(fromJson: _userRoleFromJson, toJson: _userRoleToJson) this.role = UserRole.user, this.isPremium = false, this.createdAt, this.lastLoginAt, final  Map<String, dynamic> settings = const {}}): _interests = interests,_expertise = expertise,_hobbies = hobbies,_settings = settings,super._();
  factory _AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);

// ==================== Authentication fields ====================
/// 사용자 고유 ID (Firebase UID)
@override final  String uid;
/// 이메일 주소
@override final  String? email;
/// 표시 이름 (Display Name)
@override final  String? displayName;
/// 사용자 이름 (Unique Username)
@override final  String? userName;
/// 프로필 사진 URL
@override final  String? photoUrl;
/// 전화번호
@override final  String? phoneNumber;
/// 이메일 인증 여부
@override@JsonKey() final  bool isEmailVerified;
/// 익명 사용자 여부
@override@JsonKey() final  bool isAnonymous;
/// 로그인 제공자 ID (google, apple, email, phone 등)
@override final  String? providerId;
// ==================== Profile fields ====================
/// 자기소개
@override final  String? bio;
/// 나이
@override final  int? age;
/// 성별
@override final  String? gender;
/// 관심사 목록
 final  List<String> _interests;
/// 관심사 목록
@override@JsonKey() List<String> get interests {
  if (_interests is EqualUnmodifiableListView) return _interests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interests);
}

/// 전문 분야 목록 (최대 4개)
 final  List<String> _expertise;
/// 전문 분야 목록 (최대 4개)
@override@JsonKey() List<String> get expertise {
  if (_expertise is EqualUnmodifiableListView) return _expertise;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expertise);
}

/// 취미 목록 (최대 8개)
 final  List<String> _hobbies;
/// 취미 목록 (최대 8개)
@override@JsonKey() List<String> get hobbies {
  if (_hobbies is EqualUnmodifiableListView) return _hobbies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hobbies);
}

// ==================== Points & Rewards ====================
/// A 포인트 (답변으로 얻은 포인트)
@override@JsonKey() final  int pointsA;
/// Q 포인트 (질문으로 얻은 포인트)
@override@JsonKey() final  int pointsQ;
// ==================== Role & Premium ====================
/// 사용자 역할 (admin, tester, user)
@override@JsonKey(fromJson: _userRoleFromJson, toJson: _userRoleToJson) final  UserRole role;
/// 프리미엄 사용자 여부
@override@JsonKey() final  bool isPremium;
// ==================== Timestamps ====================
/// 계정 생성 시간
@override final  DateTime? createdAt;
/// 마지막 로그인 시간
@override final  DateTime? lastLoginAt;
// ==================== Additional ====================
/// 사용자 설정 (Key-Value 형태)
 final  Map<String, dynamic> _settings;
// ==================== Additional ====================
/// 사용자 설정 (Key-Value 형태)
@override@JsonKey() Map<String, dynamic> get settings {
  if (_settings is EqualUnmodifiableMapView) return _settings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_settings);
}


/// Create a copy of AuthUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthUserCopyWith<_AuthUser> get copyWith => __$AuthUserCopyWithImpl<_AuthUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthUser&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other._interests, _interests)&&const DeepCollectionEquality().equals(other._expertise, _expertise)&&const DeepCollectionEquality().equals(other._hobbies, _hobbies)&&(identical(other.pointsA, pointsA) || other.pointsA == pointsA)&&(identical(other.pointsQ, pointsQ) || other.pointsQ == pointsQ)&&(identical(other.role, role) || other.role == role)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastLoginAt, lastLoginAt) || other.lastLoginAt == lastLoginAt)&&const DeepCollectionEquality().equals(other._settings, _settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,displayName,userName,photoUrl,phoneNumber,isEmailVerified,isAnonymous,providerId,bio,age,gender,const DeepCollectionEquality().hash(_interests),const DeepCollectionEquality().hash(_expertise),const DeepCollectionEquality().hash(_hobbies),pointsA,pointsQ,role,isPremium,createdAt,lastLoginAt,const DeepCollectionEquality().hash(_settings)]);

@override
String toString() {
  return 'AuthUser(uid: $uid, email: $email, displayName: $displayName, userName: $userName, photoUrl: $photoUrl, phoneNumber: $phoneNumber, isEmailVerified: $isEmailVerified, isAnonymous: $isAnonymous, providerId: $providerId, bio: $bio, age: $age, gender: $gender, interests: $interests, expertise: $expertise, hobbies: $hobbies, pointsA: $pointsA, pointsQ: $pointsQ, role: $role, isPremium: $isPremium, createdAt: $createdAt, lastLoginAt: $lastLoginAt, settings: $settings)';
}


}

/// @nodoc
abstract mixin class _$AuthUserCopyWith<$Res> implements $AuthUserCopyWith<$Res> {
  factory _$AuthUserCopyWith(_AuthUser value, $Res Function(_AuthUser) _then) = __$AuthUserCopyWithImpl;
@override @useResult
$Res call({
 String uid, String? email, String? displayName, String? userName, String? photoUrl, String? phoneNumber, bool isEmailVerified, bool isAnonymous, String? providerId, String? bio, int? age, String? gender, List<String> interests, List<String> expertise, List<String> hobbies, int pointsA, int pointsQ,@JsonKey(fromJson: _userRoleFromJson, toJson: _userRoleToJson) UserRole role, bool isPremium, DateTime? createdAt, DateTime? lastLoginAt, Map<String, dynamic> settings
});




}
/// @nodoc
class __$AuthUserCopyWithImpl<$Res>
    implements _$AuthUserCopyWith<$Res> {
  __$AuthUserCopyWithImpl(this._self, this._then);

  final _AuthUser _self;
  final $Res Function(_AuthUser) _then;

/// Create a copy of AuthUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = freezed,Object? displayName = freezed,Object? userName = freezed,Object? photoUrl = freezed,Object? phoneNumber = freezed,Object? isEmailVerified = null,Object? isAnonymous = null,Object? providerId = freezed,Object? bio = freezed,Object? age = freezed,Object? gender = freezed,Object? interests = null,Object? expertise = null,Object? hobbies = null,Object? pointsA = null,Object? pointsQ = null,Object? role = null,Object? isPremium = null,Object? createdAt = freezed,Object? lastLoginAt = freezed,Object? settings = null,}) {
  return _then(_AuthUser(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,userName: freezed == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,isEmailVerified: null == isEmailVerified ? _self.isEmailVerified : isEmailVerified // ignore: cast_nullable_to_non_nullable
as bool,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,providerId: freezed == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,interests: null == interests ? _self._interests : interests // ignore: cast_nullable_to_non_nullable
as List<String>,expertise: null == expertise ? _self._expertise : expertise // ignore: cast_nullable_to_non_nullable
as List<String>,hobbies: null == hobbies ? _self._hobbies : hobbies // ignore: cast_nullable_to_non_nullable
as List<String>,pointsA: null == pointsA ? _self.pointsA : pointsA // ignore: cast_nullable_to_non_nullable
as int,pointsQ: null == pointsQ ? _self.pointsQ : pointsQ // ignore: cast_nullable_to_non_nullable
as int,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLoginAt: freezed == lastLoginAt ? _self.lastLoginAt : lastLoginAt // ignore: cast_nullable_to_non_nullable
as DateTime?,settings: null == settings ? _self._settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
