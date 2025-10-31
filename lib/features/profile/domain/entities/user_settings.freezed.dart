// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserSettings {

// Core Fields
 String get userId;// Foreign key to AuthUser.uid
// Premium Status
 bool get isPremiumUser;// Notification Preferences
 bool get receiveRankUpdateNotifications; bool get receiveTitleUpdateNotifications; bool get receiveVoteNotifications; bool get receiveCommentNotifications; bool get receiveFriendNotifications;// Complex Settings
 Map<String, dynamic> get subscription;// Subscription details
 Map<String, dynamic> get stats;// User statistics preferences
 Map<String, dynamic> get privacySettings;
/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSettingsCopyWith<UserSettings> get copyWith => _$UserSettingsCopyWithImpl<UserSettings>(this as UserSettings, _$identity);

  /// Serializes this UserSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSettings&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.isPremiumUser, isPremiumUser) || other.isPremiumUser == isPremiumUser)&&(identical(other.receiveRankUpdateNotifications, receiveRankUpdateNotifications) || other.receiveRankUpdateNotifications == receiveRankUpdateNotifications)&&(identical(other.receiveTitleUpdateNotifications, receiveTitleUpdateNotifications) || other.receiveTitleUpdateNotifications == receiveTitleUpdateNotifications)&&(identical(other.receiveVoteNotifications, receiveVoteNotifications) || other.receiveVoteNotifications == receiveVoteNotifications)&&(identical(other.receiveCommentNotifications, receiveCommentNotifications) || other.receiveCommentNotifications == receiveCommentNotifications)&&(identical(other.receiveFriendNotifications, receiveFriendNotifications) || other.receiveFriendNotifications == receiveFriendNotifications)&&const DeepCollectionEquality().equals(other.subscription, subscription)&&const DeepCollectionEquality().equals(other.stats, stats)&&const DeepCollectionEquality().equals(other.privacySettings, privacySettings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,isPremiumUser,receiveRankUpdateNotifications,receiveTitleUpdateNotifications,receiveVoteNotifications,receiveCommentNotifications,receiveFriendNotifications,const DeepCollectionEquality().hash(subscription),const DeepCollectionEquality().hash(stats),const DeepCollectionEquality().hash(privacySettings));

@override
String toString() {
  return 'UserSettings(userId: $userId, isPremiumUser: $isPremiumUser, receiveRankUpdateNotifications: $receiveRankUpdateNotifications, receiveTitleUpdateNotifications: $receiveTitleUpdateNotifications, receiveVoteNotifications: $receiveVoteNotifications, receiveCommentNotifications: $receiveCommentNotifications, receiveFriendNotifications: $receiveFriendNotifications, subscription: $subscription, stats: $stats, privacySettings: $privacySettings)';
}


}

/// @nodoc
abstract mixin class $UserSettingsCopyWith<$Res>  {
  factory $UserSettingsCopyWith(UserSettings value, $Res Function(UserSettings) _then) = _$UserSettingsCopyWithImpl;
@useResult
$Res call({
 String userId, bool isPremiumUser, bool receiveRankUpdateNotifications, bool receiveTitleUpdateNotifications, bool receiveVoteNotifications, bool receiveCommentNotifications, bool receiveFriendNotifications, Map<String, dynamic> subscription, Map<String, dynamic> stats, Map<String, dynamic> privacySettings
});




}
/// @nodoc
class _$UserSettingsCopyWithImpl<$Res>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._self, this._then);

  final UserSettings _self;
  final $Res Function(UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? isPremiumUser = null,Object? receiveRankUpdateNotifications = null,Object? receiveTitleUpdateNotifications = null,Object? receiveVoteNotifications = null,Object? receiveCommentNotifications = null,Object? receiveFriendNotifications = null,Object? subscription = null,Object? stats = null,Object? privacySettings = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,isPremiumUser: null == isPremiumUser ? _self.isPremiumUser : isPremiumUser // ignore: cast_nullable_to_non_nullable
as bool,receiveRankUpdateNotifications: null == receiveRankUpdateNotifications ? _self.receiveRankUpdateNotifications : receiveRankUpdateNotifications // ignore: cast_nullable_to_non_nullable
as bool,receiveTitleUpdateNotifications: null == receiveTitleUpdateNotifications ? _self.receiveTitleUpdateNotifications : receiveTitleUpdateNotifications // ignore: cast_nullable_to_non_nullable
as bool,receiveVoteNotifications: null == receiveVoteNotifications ? _self.receiveVoteNotifications : receiveVoteNotifications // ignore: cast_nullable_to_non_nullable
as bool,receiveCommentNotifications: null == receiveCommentNotifications ? _self.receiveCommentNotifications : receiveCommentNotifications // ignore: cast_nullable_to_non_nullable
as bool,receiveFriendNotifications: null == receiveFriendNotifications ? _self.receiveFriendNotifications : receiveFriendNotifications // ignore: cast_nullable_to_non_nullable
as bool,subscription: null == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,privacySettings: null == privacySettings ? _self.privacySettings : privacySettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [UserSettings].
extension UserSettingsPatterns on UserSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSettings value)  $default,){
final _that = this;
switch (_that) {
case _UserSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSettings value)?  $default,){
final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  bool isPremiumUser,  bool receiveRankUpdateNotifications,  bool receiveTitleUpdateNotifications,  bool receiveVoteNotifications,  bool receiveCommentNotifications,  bool receiveFriendNotifications,  Map<String, dynamic> subscription,  Map<String, dynamic> stats,  Map<String, dynamic> privacySettings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.userId,_that.isPremiumUser,_that.receiveRankUpdateNotifications,_that.receiveTitleUpdateNotifications,_that.receiveVoteNotifications,_that.receiveCommentNotifications,_that.receiveFriendNotifications,_that.subscription,_that.stats,_that.privacySettings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  bool isPremiumUser,  bool receiveRankUpdateNotifications,  bool receiveTitleUpdateNotifications,  bool receiveVoteNotifications,  bool receiveCommentNotifications,  bool receiveFriendNotifications,  Map<String, dynamic> subscription,  Map<String, dynamic> stats,  Map<String, dynamic> privacySettings)  $default,) {final _that = this;
switch (_that) {
case _UserSettings():
return $default(_that.userId,_that.isPremiumUser,_that.receiveRankUpdateNotifications,_that.receiveTitleUpdateNotifications,_that.receiveVoteNotifications,_that.receiveCommentNotifications,_that.receiveFriendNotifications,_that.subscription,_that.stats,_that.privacySettings);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  bool isPremiumUser,  bool receiveRankUpdateNotifications,  bool receiveTitleUpdateNotifications,  bool receiveVoteNotifications,  bool receiveCommentNotifications,  bool receiveFriendNotifications,  Map<String, dynamic> subscription,  Map<String, dynamic> stats,  Map<String, dynamic> privacySettings)?  $default,) {final _that = this;
switch (_that) {
case _UserSettings() when $default != null:
return $default(_that.userId,_that.isPremiumUser,_that.receiveRankUpdateNotifications,_that.receiveTitleUpdateNotifications,_that.receiveVoteNotifications,_that.receiveCommentNotifications,_that.receiveFriendNotifications,_that.subscription,_that.stats,_that.privacySettings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserSettings extends UserSettings {
  const _UserSettings({required this.userId, this.isPremiumUser = false, this.receiveRankUpdateNotifications = true, this.receiveTitleUpdateNotifications = true, this.receiveVoteNotifications = true, this.receiveCommentNotifications = true, this.receiveFriendNotifications = true, final  Map<String, dynamic> subscription = const {}, final  Map<String, dynamic> stats = const {}, final  Map<String, dynamic> privacySettings = const {}}): _subscription = subscription,_stats = stats,_privacySettings = privacySettings,super._();
  factory _UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);

// Core Fields
@override final  String userId;
// Foreign key to AuthUser.uid
// Premium Status
@override@JsonKey() final  bool isPremiumUser;
// Notification Preferences
@override@JsonKey() final  bool receiveRankUpdateNotifications;
@override@JsonKey() final  bool receiveTitleUpdateNotifications;
@override@JsonKey() final  bool receiveVoteNotifications;
@override@JsonKey() final  bool receiveCommentNotifications;
@override@JsonKey() final  bool receiveFriendNotifications;
// Complex Settings
 final  Map<String, dynamic> _subscription;
// Complex Settings
@override@JsonKey() Map<String, dynamic> get subscription {
  if (_subscription is EqualUnmodifiableMapView) return _subscription;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_subscription);
}

// Subscription details
 final  Map<String, dynamic> _stats;
// Subscription details
@override@JsonKey() Map<String, dynamic> get stats {
  if (_stats is EqualUnmodifiableMapView) return _stats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stats);
}

// User statistics preferences
 final  Map<String, dynamic> _privacySettings;
// User statistics preferences
@override@JsonKey() Map<String, dynamic> get privacySettings {
  if (_privacySettings is EqualUnmodifiableMapView) return _privacySettings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_privacySettings);
}


/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSettingsCopyWith<_UserSettings> get copyWith => __$UserSettingsCopyWithImpl<_UserSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSettings&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.isPremiumUser, isPremiumUser) || other.isPremiumUser == isPremiumUser)&&(identical(other.receiveRankUpdateNotifications, receiveRankUpdateNotifications) || other.receiveRankUpdateNotifications == receiveRankUpdateNotifications)&&(identical(other.receiveTitleUpdateNotifications, receiveTitleUpdateNotifications) || other.receiveTitleUpdateNotifications == receiveTitleUpdateNotifications)&&(identical(other.receiveVoteNotifications, receiveVoteNotifications) || other.receiveVoteNotifications == receiveVoteNotifications)&&(identical(other.receiveCommentNotifications, receiveCommentNotifications) || other.receiveCommentNotifications == receiveCommentNotifications)&&(identical(other.receiveFriendNotifications, receiveFriendNotifications) || other.receiveFriendNotifications == receiveFriendNotifications)&&const DeepCollectionEquality().equals(other._subscription, _subscription)&&const DeepCollectionEquality().equals(other._stats, _stats)&&const DeepCollectionEquality().equals(other._privacySettings, _privacySettings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,isPremiumUser,receiveRankUpdateNotifications,receiveTitleUpdateNotifications,receiveVoteNotifications,receiveCommentNotifications,receiveFriendNotifications,const DeepCollectionEquality().hash(_subscription),const DeepCollectionEquality().hash(_stats),const DeepCollectionEquality().hash(_privacySettings));

@override
String toString() {
  return 'UserSettings(userId: $userId, isPremiumUser: $isPremiumUser, receiveRankUpdateNotifications: $receiveRankUpdateNotifications, receiveTitleUpdateNotifications: $receiveTitleUpdateNotifications, receiveVoteNotifications: $receiveVoteNotifications, receiveCommentNotifications: $receiveCommentNotifications, receiveFriendNotifications: $receiveFriendNotifications, subscription: $subscription, stats: $stats, privacySettings: $privacySettings)';
}


}

/// @nodoc
abstract mixin class _$UserSettingsCopyWith<$Res> implements $UserSettingsCopyWith<$Res> {
  factory _$UserSettingsCopyWith(_UserSettings value, $Res Function(_UserSettings) _then) = __$UserSettingsCopyWithImpl;
@override @useResult
$Res call({
 String userId, bool isPremiumUser, bool receiveRankUpdateNotifications, bool receiveTitleUpdateNotifications, bool receiveVoteNotifications, bool receiveCommentNotifications, bool receiveFriendNotifications, Map<String, dynamic> subscription, Map<String, dynamic> stats, Map<String, dynamic> privacySettings
});




}
/// @nodoc
class __$UserSettingsCopyWithImpl<$Res>
    implements _$UserSettingsCopyWith<$Res> {
  __$UserSettingsCopyWithImpl(this._self, this._then);

  final _UserSettings _self;
  final $Res Function(_UserSettings) _then;

/// Create a copy of UserSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? isPremiumUser = null,Object? receiveRankUpdateNotifications = null,Object? receiveTitleUpdateNotifications = null,Object? receiveVoteNotifications = null,Object? receiveCommentNotifications = null,Object? receiveFriendNotifications = null,Object? subscription = null,Object? stats = null,Object? privacySettings = null,}) {
  return _then(_UserSettings(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,isPremiumUser: null == isPremiumUser ? _self.isPremiumUser : isPremiumUser // ignore: cast_nullable_to_non_nullable
as bool,receiveRankUpdateNotifications: null == receiveRankUpdateNotifications ? _self.receiveRankUpdateNotifications : receiveRankUpdateNotifications // ignore: cast_nullable_to_non_nullable
as bool,receiveTitleUpdateNotifications: null == receiveTitleUpdateNotifications ? _self.receiveTitleUpdateNotifications : receiveTitleUpdateNotifications // ignore: cast_nullable_to_non_nullable
as bool,receiveVoteNotifications: null == receiveVoteNotifications ? _self.receiveVoteNotifications : receiveVoteNotifications // ignore: cast_nullable_to_non_nullable
as bool,receiveCommentNotifications: null == receiveCommentNotifications ? _self.receiveCommentNotifications : receiveCommentNotifications // ignore: cast_nullable_to_non_nullable
as bool,receiveFriendNotifications: null == receiveFriendNotifications ? _self.receiveFriendNotifications : receiveFriendNotifications // ignore: cast_nullable_to_non_nullable
as bool,subscription: null == subscription ? _self._subscription : subscription // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,stats: null == stats ? _self._stats : stats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,privacySettings: null == privacySettings ? _self._privacySettings : privacySettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
