// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_post_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ProfilePostRepository Provider (GetIt Wrapper)
///
/// **DI 패턴**:
/// - GetIt에 등록된 IProfilePostRepository 인스턴스 반환
/// - Singleton으로 관리

@ProviderFor(profilePostRepository)
const profilePostRepositoryProvider = ProfilePostRepositoryProvider._();

/// ProfilePostRepository Provider (GetIt Wrapper)
///
/// **DI 패턴**:
/// - GetIt에 등록된 IProfilePostRepository 인스턴스 반환
/// - Singleton으로 관리

final class ProfilePostRepositoryProvider
    extends
        $FunctionalProvider<
          IProfilePostRepository,
          IProfilePostRepository,
          IProfilePostRepository
        >
    with $Provider<IProfilePostRepository> {
  /// ProfilePostRepository Provider (GetIt Wrapper)
  ///
  /// **DI 패턴**:
  /// - GetIt에 등록된 IProfilePostRepository 인스턴스 반환
  /// - Singleton으로 관리
  const ProfilePostRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profilePostRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profilePostRepositoryHash();

  @$internal
  @override
  $ProviderElement<IProfilePostRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IProfilePostRepository create(Ref ref) {
    return profilePostRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IProfilePostRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IProfilePostRepository>(value),
    );
  }
}

String _$profilePostRepositoryHash() =>
    r'b44951ca6ed4ffb74ef25f1c3c80ec7874db9d0b';

/// 내 게시물 목록 Stream Provider
///
/// **사용법**:
/// ```dart
/// final postsAsync = ref.watch(myPostsStreamProvider(userId));
///
/// postsAsync.when(
///   data: (posts) => ListView.builder(...),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => Text('Error: $error'),
/// );
/// ```
///
/// **특징**:
/// - StreamProvider.autoDispose.family 자동 생성
/// - userId 파라미터로 사용자별 게시물 조회
/// - Either → List 변환으로 UI 친화적
/// - 에러 시 빈 리스트 반환 (UI에서 AsyncValue.error로 처리)
///
/// **실시간 동기화**:
/// - Firestore snapshots() 사용
/// - 게시물 생성/수정/삭제 시 자동 업데이트
///
/// **자동 dispose**:
/// - Widget이 unmount되면 자동으로 구독 해제
/// - 메모리 누수 방지
///
/// **vs 이전 구현**:
/// - Before: PostDisplay (20+ fields) + Post Feature 의존
/// - After: UserPostItem (5 fields) + Repository 패턴

@ProviderFor(myPostsStream)
const myPostsStreamProvider = MyPostsStreamFamily._();

/// 내 게시물 목록 Stream Provider
///
/// **사용법**:
/// ```dart
/// final postsAsync = ref.watch(myPostsStreamProvider(userId));
///
/// postsAsync.when(
///   data: (posts) => ListView.builder(...),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => Text('Error: $error'),
/// );
/// ```
///
/// **특징**:
/// - StreamProvider.autoDispose.family 자동 생성
/// - userId 파라미터로 사용자별 게시물 조회
/// - Either → List 변환으로 UI 친화적
/// - 에러 시 빈 리스트 반환 (UI에서 AsyncValue.error로 처리)
///
/// **실시간 동기화**:
/// - Firestore snapshots() 사용
/// - 게시물 생성/수정/삭제 시 자동 업데이트
///
/// **자동 dispose**:
/// - Widget이 unmount되면 자동으로 구독 해제
/// - 메모리 누수 방지
///
/// **vs 이전 구현**:
/// - Before: PostDisplay (20+ fields) + Post Feature 의존
/// - After: UserPostItem (5 fields) + Repository 패턴

final class MyPostsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserPostItem>>,
          List<UserPostItem>,
          Stream<List<UserPostItem>>
        >
    with
        $FutureModifier<List<UserPostItem>>,
        $StreamProvider<List<UserPostItem>> {
  /// 내 게시물 목록 Stream Provider
  ///
  /// **사용법**:
  /// ```dart
  /// final postsAsync = ref.watch(myPostsStreamProvider(userId));
  ///
  /// postsAsync.when(
  ///   data: (posts) => ListView.builder(...),
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (error, stack) => Text('Error: $error'),
  /// );
  /// ```
  ///
  /// **특징**:
  /// - StreamProvider.autoDispose.family 자동 생성
  /// - userId 파라미터로 사용자별 게시물 조회
  /// - Either → List 변환으로 UI 친화적
  /// - 에러 시 빈 리스트 반환 (UI에서 AsyncValue.error로 처리)
  ///
  /// **실시간 동기화**:
  /// - Firestore snapshots() 사용
  /// - 게시물 생성/수정/삭제 시 자동 업데이트
  ///
  /// **자동 dispose**:
  /// - Widget이 unmount되면 자동으로 구독 해제
  /// - 메모리 누수 방지
  ///
  /// **vs 이전 구현**:
  /// - Before: PostDisplay (20+ fields) + Post Feature 의존
  /// - After: UserPostItem (5 fields) + Repository 패턴
  const MyPostsStreamProvider._({
    required MyPostsStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myPostsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myPostsStreamHash();

  @override
  String toString() {
    return r'myPostsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<UserPostItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<UserPostItem>> create(Ref ref) {
    final argument = this.argument as String;
    return myPostsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyPostsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myPostsStreamHash() => r'c17e92a95f1c4fceaec169ade7c8f41b2ec5233c';

/// 내 게시물 목록 Stream Provider
///
/// **사용법**:
/// ```dart
/// final postsAsync = ref.watch(myPostsStreamProvider(userId));
///
/// postsAsync.when(
///   data: (posts) => ListView.builder(...),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => Text('Error: $error'),
/// );
/// ```
///
/// **특징**:
/// - StreamProvider.autoDispose.family 자동 생성
/// - userId 파라미터로 사용자별 게시물 조회
/// - Either → List 변환으로 UI 친화적
/// - 에러 시 빈 리스트 반환 (UI에서 AsyncValue.error로 처리)
///
/// **실시간 동기화**:
/// - Firestore snapshots() 사용
/// - 게시물 생성/수정/삭제 시 자동 업데이트
///
/// **자동 dispose**:
/// - Widget이 unmount되면 자동으로 구독 해제
/// - 메모리 누수 방지
///
/// **vs 이전 구현**:
/// - Before: PostDisplay (20+ fields) + Post Feature 의존
/// - After: UserPostItem (5 fields) + Repository 패턴

final class MyPostsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<UserPostItem>>, String> {
  const MyPostsStreamFamily._()
    : super(
        retry: null,
        name: r'myPostsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 내 게시물 목록 Stream Provider
  ///
  /// **사용법**:
  /// ```dart
  /// final postsAsync = ref.watch(myPostsStreamProvider(userId));
  ///
  /// postsAsync.when(
  ///   data: (posts) => ListView.builder(...),
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (error, stack) => Text('Error: $error'),
  /// );
  /// ```
  ///
  /// **특징**:
  /// - StreamProvider.autoDispose.family 자동 생성
  /// - userId 파라미터로 사용자별 게시물 조회
  /// - Either → List 변환으로 UI 친화적
  /// - 에러 시 빈 리스트 반환 (UI에서 AsyncValue.error로 처리)
  ///
  /// **실시간 동기화**:
  /// - Firestore snapshots() 사용
  /// - 게시물 생성/수정/삭제 시 자동 업데이트
  ///
  /// **자동 dispose**:
  /// - Widget이 unmount되면 자동으로 구독 해제
  /// - 메모리 누수 방지
  ///
  /// **vs 이전 구현**:
  /// - Before: PostDisplay (20+ fields) + Post Feature 의존
  /// - After: UserPostItem (5 fields) + Repository 패턴

  MyPostsStreamProvider call(String userId) =>
      MyPostsStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'myPostsStreamProvider';
}

/// Profile Feature 전용: 프로필 페이지 최근 게시물 (제한된 개수)
///
/// **사용처**:
/// - ProfilePageWidget: 프로필 페이지에서 최근 게시물 5개 표시
///
/// **특징**:
/// - myPostsStream의 결과를 limit 개수만큼 제한
/// - UI 최적화를 위한 Provider

@ProviderFor(profileUserPostsStream)
const profileUserPostsStreamProvider = ProfileUserPostsStreamFamily._();

/// Profile Feature 전용: 프로필 페이지 최근 게시물 (제한된 개수)
///
/// **사용처**:
/// - ProfilePageWidget: 프로필 페이지에서 최근 게시물 5개 표시
///
/// **특징**:
/// - myPostsStream의 결과를 limit 개수만큼 제한
/// - UI 최적화를 위한 Provider

final class ProfileUserPostsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserPostItem>>,
          List<UserPostItem>,
          Stream<List<UserPostItem>>
        >
    with
        $FutureModifier<List<UserPostItem>>,
        $StreamProvider<List<UserPostItem>> {
  /// Profile Feature 전용: 프로필 페이지 최근 게시물 (제한된 개수)
  ///
  /// **사용처**:
  /// - ProfilePageWidget: 프로필 페이지에서 최근 게시물 5개 표시
  ///
  /// **특징**:
  /// - myPostsStream의 결과를 limit 개수만큼 제한
  /// - UI 최적화를 위한 Provider
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
  $StreamProviderElement<List<UserPostItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<UserPostItem>> create(Ref ref) {
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
    r'b7f167561455f79ec5ccf529c0b4f6bdbe2258ec';

/// Profile Feature 전용: 프로필 페이지 최근 게시물 (제한된 개수)
///
/// **사용처**:
/// - ProfilePageWidget: 프로필 페이지에서 최근 게시물 5개 표시
///
/// **특징**:
/// - myPostsStream의 결과를 limit 개수만큼 제한
/// - UI 최적화를 위한 Provider

final class ProfileUserPostsStreamFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<UserPostItem>>,
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

  /// Profile Feature 전용: 프로필 페이지 최근 게시물 (제한된 개수)
  ///
  /// **사용처**:
  /// - ProfilePageWidget: 프로필 페이지에서 최근 게시물 5개 표시
  ///
  /// **특징**:
  /// - myPostsStream의 결과를 limit 개수만큼 제한
  /// - UI 최적화를 위한 Provider

  ProfileUserPostsStreamProvider call(String userId, {int limit = 5}) =>
      ProfileUserPostsStreamProvider._(
        argument: (userId, limit: limit),
        from: this,
      );

  @override
  String toString() => r'profileUserPostsStreamProvider';
}
