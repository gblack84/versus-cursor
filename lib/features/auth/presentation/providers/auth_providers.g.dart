// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Firebase Authentication 실시간 상태 Stream Provider
///
/// **Creation Feature 패턴 적용**:
/// - ✅ StreamProvider.family + keepAlive()
/// - ✅ yield null로 즉시 로딩
/// - ✅ Firebase Stream 실시간 동기화
/// - ✅ 중복 리스너 방지
///
/// **사용 예시**:
/// ```dart
/// final authState = ref.watch(authStateStreamProvider(const AuthStateParams()));
///
/// authState.when(
///   loading: () => CircularProgressIndicator(),
///   error: (e, s) => ErrorWidget(e),
///   data: (user) => user == null ? LoginScreen() : HomeScreen(),
/// );
/// ```

@ProviderFor(authStateStream)
const authStateStreamProvider = AuthStateStreamFamily._();

/// Firebase Authentication 실시간 상태 Stream Provider
///
/// **Creation Feature 패턴 적용**:
/// - ✅ StreamProvider.family + keepAlive()
/// - ✅ yield null로 즉시 로딩
/// - ✅ Firebase Stream 실시간 동기화
/// - ✅ 중복 리스너 방지
///
/// **사용 예시**:
/// ```dart
/// final authState = ref.watch(authStateStreamProvider(const AuthStateParams()));
///
/// authState.when(
///   loading: () => CircularProgressIndicator(),
///   error: (e, s) => ErrorWidget(e),
///   data: (user) => user == null ? LoginScreen() : HomeScreen(),
/// );
/// ```

final class AuthStateStreamProvider
    extends
        $FunctionalProvider<AsyncValue<AuthUser?>, AuthUser?, Stream<AuthUser?>>
    with $FutureModifier<AuthUser?>, $StreamProvider<AuthUser?> {
  /// Firebase Authentication 실시간 상태 Stream Provider
  ///
  /// **Creation Feature 패턴 적용**:
  /// - ✅ StreamProvider.family + keepAlive()
  /// - ✅ yield null로 즉시 로딩
  /// - ✅ Firebase Stream 실시간 동기화
  /// - ✅ 중복 리스너 방지
  ///
  /// **사용 예시**:
  /// ```dart
  /// final authState = ref.watch(authStateStreamProvider(const AuthStateParams()));
  ///
  /// authState.when(
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (e, s) => ErrorWidget(e),
  ///   data: (user) => user == null ? LoginScreen() : HomeScreen(),
  /// );
  /// ```
  const AuthStateStreamProvider._({
    required AuthStateStreamFamily super.from,
    required AuthStateParams super.argument,
  }) : super(
         retry: null,
         name: r'authStateStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$authStateStreamHash();

  @override
  String toString() {
    return r'authStateStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<AuthUser?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AuthUser?> create(Ref ref) {
    final argument = this.argument as AuthStateParams;
    return authStateStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AuthStateStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$authStateStreamHash() => r'a18fc5fa5dc293daa2ded40fea01d0a69cc8d019';

/// Firebase Authentication 실시간 상태 Stream Provider
///
/// **Creation Feature 패턴 적용**:
/// - ✅ StreamProvider.family + keepAlive()
/// - ✅ yield null로 즉시 로딩
/// - ✅ Firebase Stream 실시간 동기화
/// - ✅ 중복 리스너 방지
///
/// **사용 예시**:
/// ```dart
/// final authState = ref.watch(authStateStreamProvider(const AuthStateParams()));
///
/// authState.when(
///   loading: () => CircularProgressIndicator(),
///   error: (e, s) => ErrorWidget(e),
///   data: (user) => user == null ? LoginScreen() : HomeScreen(),
/// );
/// ```

final class AuthStateStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<AuthUser?>, AuthStateParams> {
  const AuthStateStreamFamily._()
    : super(
        retry: null,
        name: r'authStateStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Firebase Authentication 실시간 상태 Stream Provider
  ///
  /// **Creation Feature 패턴 적용**:
  /// - ✅ StreamProvider.family + keepAlive()
  /// - ✅ yield null로 즉시 로딩
  /// - ✅ Firebase Stream 실시간 동기화
  /// - ✅ 중복 리스너 방지
  ///
  /// **사용 예시**:
  /// ```dart
  /// final authState = ref.watch(authStateStreamProvider(const AuthStateParams()));
  ///
  /// authState.when(
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (e, s) => ErrorWidget(e),
  ///   data: (user) => user == null ? LoginScreen() : HomeScreen(),
  /// );
  /// ```

  AuthStateStreamProvider call(AuthStateParams params) =>
      AuthStateStreamProvider._(argument: params, from: this);

  @override
  String toString() => r'authStateStreamProvider';
}

/// 로딩 상태 Notifier
///
/// **역할**: 로그인/회원가입 등 비동기 작업 중 로딩 UI 표시
/// **패턴**: @riverpod class Notifier<bool>
/// **사용처**: SignInScreen, SignUpScreen
///
/// **사용 예시**:
/// ```dart
/// // 로딩 시작
/// ref.read(authLoadingProvider.notifier).setLoading(true);
///
/// // 로딩 종료
/// ref.read(authLoadingProvider.notifier).setLoading(false);
///
/// // 로딩 상태 감시
/// final isLoading = ref.watch(authLoadingProvider);
/// ```

@ProviderFor(AuthLoading)
const authLoadingProvider = AuthLoadingProvider._();

/// 로딩 상태 Notifier
///
/// **역할**: 로그인/회원가입 등 비동기 작업 중 로딩 UI 표시
/// **패턴**: @riverpod class Notifier<bool>
/// **사용처**: SignInScreen, SignUpScreen
///
/// **사용 예시**:
/// ```dart
/// // 로딩 시작
/// ref.read(authLoadingProvider.notifier).setLoading(true);
///
/// // 로딩 종료
/// ref.read(authLoadingProvider.notifier).setLoading(false);
///
/// // 로딩 상태 감시
/// final isLoading = ref.watch(authLoadingProvider);
/// ```
final class AuthLoadingProvider extends $NotifierProvider<AuthLoading, bool> {
  /// 로딩 상태 Notifier
  ///
  /// **역할**: 로그인/회원가입 등 비동기 작업 중 로딩 UI 표시
  /// **패턴**: @riverpod class Notifier<bool>
  /// **사용처**: SignInScreen, SignUpScreen
  ///
  /// **사용 예시**:
  /// ```dart
  /// // 로딩 시작
  /// ref.read(authLoadingProvider.notifier).setLoading(true);
  ///
  /// // 로딩 종료
  /// ref.read(authLoadingProvider.notifier).setLoading(false);
  ///
  /// // 로딩 상태 감시
  /// final isLoading = ref.watch(authLoadingProvider);
  /// ```
  const AuthLoadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authLoadingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authLoadingHash();

  @$internal
  @override
  AuthLoading create() => AuthLoading();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$authLoadingHash() => r'92315da9f53142f2fc94b2f0d30c71954e3fa75a';

/// 로딩 상태 Notifier
///
/// **역할**: 로그인/회원가입 등 비동기 작업 중 로딩 UI 표시
/// **패턴**: @riverpod class Notifier<bool>
/// **사용처**: SignInScreen, SignUpScreen
///
/// **사용 예시**:
/// ```dart
/// // 로딩 시작
/// ref.read(authLoadingProvider.notifier).setLoading(true);
///
/// // 로딩 종료
/// ref.read(authLoadingProvider.notifier).setLoading(false);
///
/// // 로딩 상태 감시
/// final isLoading = ref.watch(authLoadingProvider);
/// ```

abstract class _$AuthLoading extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// 에러 메시지 Notifier
///
/// **역할**: 인증 실패 시 에러 메시지 저장 및 UI 표시
/// **패턴**: @riverpod class Notifier<String?>
/// **사용처**: SignInScreen, SignUpScreen, ErrorSnackBar
///
/// **사용 예시**:
/// ```dart
/// // 에러 설정
/// ref.read(authErrorProvider.notifier).setError('Invalid credentials');
///
/// // 에러 초기화
/// ref.read(authErrorProvider.notifier).clear();
///
/// // 에러 메시지 감시
/// final errorMessage = ref.watch(authErrorProvider);
/// if (errorMessage != null) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(errorMessage)),
///   );
/// }
/// ```

@ProviderFor(AuthError)
const authErrorProvider = AuthErrorProvider._();

/// 에러 메시지 Notifier
///
/// **역할**: 인증 실패 시 에러 메시지 저장 및 UI 표시
/// **패턴**: @riverpod class Notifier<String?>
/// **사용처**: SignInScreen, SignUpScreen, ErrorSnackBar
///
/// **사용 예시**:
/// ```dart
/// // 에러 설정
/// ref.read(authErrorProvider.notifier).setError('Invalid credentials');
///
/// // 에러 초기화
/// ref.read(authErrorProvider.notifier).clear();
///
/// // 에러 메시지 감시
/// final errorMessage = ref.watch(authErrorProvider);
/// if (errorMessage != null) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(errorMessage)),
///   );
/// }
/// ```
final class AuthErrorProvider extends $NotifierProvider<AuthError, String?> {
  /// 에러 메시지 Notifier
  ///
  /// **역할**: 인증 실패 시 에러 메시지 저장 및 UI 표시
  /// **패턴**: @riverpod class Notifier<String?>
  /// **사용처**: SignInScreen, SignUpScreen, ErrorSnackBar
  ///
  /// **사용 예시**:
  /// ```dart
  /// // 에러 설정
  /// ref.read(authErrorProvider.notifier).setError('Invalid credentials');
  ///
  /// // 에러 초기화
  /// ref.read(authErrorProvider.notifier).clear();
  ///
  /// // 에러 메시지 감시
  /// final errorMessage = ref.watch(authErrorProvider);
  /// if (errorMessage != null) {
  ///   ScaffoldMessenger.of(context).showSnackBar(
  ///     SnackBar(content: Text(errorMessage)),
  ///   );
  /// }
  /// ```
  const AuthErrorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authErrorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authErrorHash();

  @$internal
  @override
  AuthError create() => AuthError();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$authErrorHash() => r'9374b1a7efc2ad02c2e373521596cc365d894118';

/// 에러 메시지 Notifier
///
/// **역할**: 인증 실패 시 에러 메시지 저장 및 UI 표시
/// **패턴**: @riverpod class Notifier<String?>
/// **사용처**: SignInScreen, SignUpScreen, ErrorSnackBar
///
/// **사용 예시**:
/// ```dart
/// // 에러 설정
/// ref.read(authErrorProvider.notifier).setError('Invalid credentials');
///
/// // 에러 초기화
/// ref.read(authErrorProvider.notifier).clear();
///
/// // 에러 메시지 감시
/// final errorMessage = ref.watch(authErrorProvider);
/// if (errorMessage != null) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(errorMessage)),
///   );
/// }
/// ```

abstract class _$AuthError extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Current User Provider
///
/// **역할**: 현재 로그인한 사용자 정보 조회 (Clean Architecture)
/// **의존성**: GetCurrentUserUseCase
/// **패턴**: FutureProvider.autoDispose
///
/// **Clean Architecture Flow**:
/// ```
/// Presentation → UseCase → Repository → Firebase
/// ```
///
/// **사용 예시**:
/// ```dart
/// final currentUserAsync = ref.watch(currentUserProvider);
///
/// currentUserAsync.when(
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => Text('Error: $error'),
///   data: (user) => user == null ? LoginScreen() : HomeScreen(),
/// );
/// ```

@ProviderFor(currentUser)
const currentUserProvider = CurrentUserProvider._();

/// Current User Provider
///
/// **역할**: 현재 로그인한 사용자 정보 조회 (Clean Architecture)
/// **의존성**: GetCurrentUserUseCase
/// **패턴**: FutureProvider.autoDispose
///
/// **Clean Architecture Flow**:
/// ```
/// Presentation → UseCase → Repository → Firebase
/// ```
///
/// **사용 예시**:
/// ```dart
/// final currentUserAsync = ref.watch(currentUserProvider);
///
/// currentUserAsync.when(
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => Text('Error: $error'),
///   data: (user) => user == null ? LoginScreen() : HomeScreen(),
/// );
/// ```

final class CurrentUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuthUser?>,
          AuthUser?,
          FutureOr<AuthUser?>
        >
    with $FutureModifier<AuthUser?>, $FutureProvider<AuthUser?> {
  /// Current User Provider
  ///
  /// **역할**: 현재 로그인한 사용자 정보 조회 (Clean Architecture)
  /// **의존성**: GetCurrentUserUseCase
  /// **패턴**: FutureProvider.autoDispose
  ///
  /// **Clean Architecture Flow**:
  /// ```
  /// Presentation → UseCase → Repository → Firebase
  /// ```
  ///
  /// **사용 예시**:
  /// ```dart
  /// final currentUserAsync = ref.watch(currentUserProvider);
  ///
  /// currentUserAsync.when(
  ///   loading: () => CircularProgressIndicator(),
  ///   error: (error, stack) => Text('Error: $error'),
  ///   data: (user) => user == null ? LoginScreen() : HomeScreen(),
  /// );
  /// ```
  const CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $FutureProviderElement<AuthUser?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AuthUser?> create(Ref ref) {
    return currentUser(ref);
  }
}

String _$currentUserHash() => r'1dca2a461608e1b15e7383f8d4621f990f188cdb';

/// Current User ID Provider
///
/// **역할**: userId만 필요한 경우 편의 제공
/// **의존성**: currentUserProvider
/// **패턴**: FutureProvider.autoDispose (derived)
///
/// **사용 예시**:
/// ```dart
/// final currentUserId = await ref.read(currentUserIdProvider.future);
/// if (currentUserId == null) {
///   // User not logged in
///   return;
/// }
///
/// // Use userId for business logic
/// await repository.loadUserData(currentUserId);
/// ```

@ProviderFor(currentUserId)
const currentUserIdProvider = CurrentUserIdProvider._();

/// Current User ID Provider
///
/// **역할**: userId만 필요한 경우 편의 제공
/// **의존성**: currentUserProvider
/// **패턴**: FutureProvider.autoDispose (derived)
///
/// **사용 예시**:
/// ```dart
/// final currentUserId = await ref.read(currentUserIdProvider.future);
/// if (currentUserId == null) {
///   // User not logged in
///   return;
/// }
///
/// // Use userId for business logic
/// await repository.loadUserData(currentUserId);
/// ```

final class CurrentUserIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Current User ID Provider
  ///
  /// **역할**: userId만 필요한 경우 편의 제공
  /// **의존성**: currentUserProvider
  /// **패턴**: FutureProvider.autoDispose (derived)
  ///
  /// **사용 예시**:
  /// ```dart
  /// final currentUserId = await ref.read(currentUserIdProvider.future);
  /// if (currentUserId == null) {
  ///   // User not logged in
  ///   return;
  /// }
  ///
  /// // Use userId for business logic
  /// await repository.loadUserData(currentUserId);
  /// ```
  const CurrentUserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserIdHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return currentUserId(ref);
  }
}

String _$currentUserIdHash() => r'b267c3875fa2f2e5393c61f422d2bc179eb83762';
