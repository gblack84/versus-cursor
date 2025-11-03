// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_post_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Profile Feature 전용: 사용자 게시물 스트림 Provider
///
/// **Architecture**: Feature-First - Profile Feature 자체 Provider
/// - ✅ Post Feature 의존성 제거 (Firebase 직접 쿼리)
/// - ✅ Riverpod 2.x StreamProvider.autoDispose.family
/// - ✅ 실시간 동기화 (Firestore Stream)
///
/// **사용처**:
/// - ProfilePageWidget: 프로필 페이지에서 최근 게시물 5개 표시
///
/// @param userId - 조회할 사용자 ID
/// @param limit - 조회할 게시물 최대 개수 (default: 5)
/// @returns Stream<List<PostDisplay>> - 실시간 게시물 목록

@ProviderFor(profileUserPostsStream)
const profileUserPostsStreamProvider = ProfileUserPostsStreamFamily._();

/// Profile Feature 전용: 사용자 게시물 스트림 Provider
///
/// **Architecture**: Feature-First - Profile Feature 자체 Provider
/// - ✅ Post Feature 의존성 제거 (Firebase 직접 쿼리)
/// - ✅ Riverpod 2.x StreamProvider.autoDispose.family
/// - ✅ 실시간 동기화 (Firestore Stream)
///
/// **사용처**:
/// - ProfilePageWidget: 프로필 페이지에서 최근 게시물 5개 표시
///
/// @param userId - 조회할 사용자 ID
/// @param limit - 조회할 게시물 최대 개수 (default: 5)
/// @returns Stream<List<PostDisplay>> - 실시간 게시물 목록

final class ProfileUserPostsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PostDisplay>>,
          List<PostDisplay>,
          Stream<List<PostDisplay>>
        >
    with
        $FutureModifier<List<PostDisplay>>,
        $StreamProvider<List<PostDisplay>> {
  /// Profile Feature 전용: 사용자 게시물 스트림 Provider
  ///
  /// **Architecture**: Feature-First - Profile Feature 자체 Provider
  /// - ✅ Post Feature 의존성 제거 (Firebase 직접 쿼리)
  /// - ✅ Riverpod 2.x StreamProvider.autoDispose.family
  /// - ✅ 실시간 동기화 (Firestore Stream)
  ///
  /// **사용처**:
  /// - ProfilePageWidget: 프로필 페이지에서 최근 게시물 5개 표시
  ///
  /// @param userId - 조회할 사용자 ID
  /// @param limit - 조회할 게시물 최대 개수 (default: 5)
  /// @returns Stream<List<PostDisplay>> - 실시간 게시물 목록
  const ProfileUserPostsStreamProvider._({
    required ProfileUserPostsStreamFamily super.from,
    required (String, {int limit}) super.argument,
  }) : super(
         retry: null,
         name: r'profileUserPostsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileUserPostsStreamHash();

  @override
  String toString() {
    return r'profileUserPostsStreamProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<PostDisplay>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PostDisplay>> create(Ref ref) {
    final argument = this.argument as (String, {int limit});
    return profileUserPostsStream(ref, argument.$1, limit: argument.limit);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileUserPostsStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileUserPostsStreamHash() =>
    r'999f863f837b2e5b0a54784ed954cae297bd009e';

/// Profile Feature 전용: 사용자 게시물 스트림 Provider
///
/// **Architecture**: Feature-First - Profile Feature 자체 Provider
/// - ✅ Post Feature 의존성 제거 (Firebase 직접 쿼리)
/// - ✅ Riverpod 2.x StreamProvider.autoDispose.family
/// - ✅ 실시간 동기화 (Firestore Stream)
///
/// **사용처**:
/// - ProfilePageWidget: 프로필 페이지에서 최근 게시물 5개 표시
///
/// @param userId - 조회할 사용자 ID
/// @param limit - 조회할 게시물 최대 개수 (default: 5)
/// @returns Stream<List<PostDisplay>> - 실시간 게시물 목록

final class ProfileUserPostsStreamFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<PostDisplay>>,
          (String, {int limit})
        > {
  const ProfileUserPostsStreamFamily._()
    : super(
        retry: null,
        name: r'profileUserPostsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Profile Feature 전용: 사용자 게시물 스트림 Provider
  ///
  /// **Architecture**: Feature-First - Profile Feature 자체 Provider
  /// - ✅ Post Feature 의존성 제거 (Firebase 직접 쿼리)
  /// - ✅ Riverpod 2.x StreamProvider.autoDispose.family
  /// - ✅ 실시간 동기화 (Firestore Stream)
  ///
  /// **사용처**:
  /// - ProfilePageWidget: 프로필 페이지에서 최근 게시물 5개 표시
  ///
  /// @param userId - 조회할 사용자 ID
  /// @param limit - 조회할 게시물 최대 개수 (default: 5)
  /// @returns Stream<List<PostDisplay>> - 실시간 게시물 목록

  ProfileUserPostsStreamProvider call(String userId, {int limit = 5}) =>
      ProfileUserPostsStreamProvider._(
        argument: (userId, limit: limit),
        from: this,
      );

  @override
  String toString() => r'profileUserPostsStreamProvider';
}

/// Profile Feature 전용: 사용자 게시물 개수 조회
///
/// **사용처**:
/// - 프로필 통계 표시
///
/// @param userId - 조회할 사용자 ID
/// @returns Future<int> - 사용자 게시물 총 개수

@ProviderFor(profileUserPostsCount)
const profileUserPostsCountProvider = ProfileUserPostsCountFamily._();

/// Profile Feature 전용: 사용자 게시물 개수 조회
///
/// **사용처**:
/// - 프로필 통계 표시
///
/// @param userId - 조회할 사용자 ID
/// @returns Future<int> - 사용자 게시물 총 개수

final class ProfileUserPostsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Profile Feature 전용: 사용자 게시물 개수 조회
  ///
  /// **사용처**:
  /// - 프로필 통계 표시
  ///
  /// @param userId - 조회할 사용자 ID
  /// @returns Future<int> - 사용자 게시물 총 개수
  const ProfileUserPostsCountProvider._({
    required ProfileUserPostsCountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profileUserPostsCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileUserPostsCountHash();

  @override
  String toString() {
    return r'profileUserPostsCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as String;
    return profileUserPostsCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileUserPostsCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileUserPostsCountHash() =>
    r'afe024ea00e1b859d2ca985551c5193bacf5f5ab';

/// Profile Feature 전용: 사용자 게시물 개수 조회
///
/// **사용처**:
/// - 프로필 통계 표시
///
/// @param userId - 조회할 사용자 ID
/// @returns Future<int> - 사용자 게시물 총 개수

final class ProfileUserPostsCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  const ProfileUserPostsCountFamily._()
    : super(
        retry: null,
        name: r'profileUserPostsCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Profile Feature 전용: 사용자 게시물 개수 조회
  ///
  /// **사용처**:
  /// - 프로필 통계 표시
  ///
  /// @param userId - 조회할 사용자 ID
  /// @returns Future<int> - 사용자 게시물 총 개수

  ProfileUserPostsCountProvider call(String userId) =>
      ProfileUserPostsCountProvider._(argument: userId, from: this);

  @override
  String toString() => r'profileUserPostsCountProvider';
}
