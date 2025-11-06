# Profile Feature - Riverpod 3.x Migration (Phase 3-7)

> **작성일**: 2025-11-06
> **기준 코드**: Phase 1-2 완료 후
> **참조 문서**: Voting Feature Riverpod 3.x Migration, Post Feature (완료)
> **목표**: Widget Integration → Testing → Cleanup → Documentation

---

## 📋 목차

- [Phase 3: Widget Integration](#phase-3-widget-integration)
  - [3.1 ProfilePageWidget Updates](#31-profilepagewidget-updates)
  - [3.2 ref.watch() Patterns](#32-refwatch-patterns)
  - [3.3 ref.read() Patterns (Actions)](#33-refread-patterns-actions)
  - [3.4 ref.listen() Patterns (Side Effects)](#34-reflisten-patterns-side-effects)
  - [3.5 Complete Example: ProfileEditScreen](#35-complete-example-profileeditscreen)
- [Phase 4: Code Generation](#phase-4-code-generation)
  - [4.1 Execution](#41-execution)
  - [4.2 Verify Generated Files](#42-verify-generated-files)
  - [4.3 Common Build Errors](#43-common-build-errors)
- [Phase 5: Testing & Verification](#phase-5-testing--verification)
  - [5.1 Static Analysis](#51-static-analysis)
  - [5.2 Manual Testing Scenarios](#52-manual-testing-scenarios)
  - [5.3 Automated Testing](#53-automated-testing)
- [Phase 6: Legacy Code Cleanup](#phase-6-legacy-code-cleanup)
  - [6.1 Remove Legacy Imports](#61-remove-legacy-imports)
  - [6.2 Deprecate profile_providers.dart](#62-deprecate-profile_providersdart)
  - [6.3 Update Imports in Widgets](#63-update-imports-in-widgets)
  - [6.4 Clean Up Unused Code](#64-clean-up-unused-code)
- [Phase 7: Documentation](#phase-7-documentation)
  - [7.1 Update Feature README](#71-update-feature-readme)
  - [7.2 Add Migration Log](#72-add-migration-log)
  - [7.3 Update Presentation Layer README](#73-update-presentation-layer-readme)
- [Appendix C: Reference Materials](#appendix-c-reference-materials)
- [Appendix D: Final Checklist](#appendix-d-final-checklist)

---

## Phase 3: Widget Integration

### 3.1 ProfilePageWidget Updates

**현재 상태**: ✅ ProfilePageWidget은 이미 `ConsumerStatefulWidget`을 사용 중

**필요한 변경사항**: Provider 참조만 업데이트

#### Before (profile_providers.dart 사용)

```dart
class ProfilePageWidget extends ConsumerStatefulWidget {
  final String userId;

  const ProfilePageWidget({
    required this.userId,
    super.key,
  });

  @override
  ConsumerState<ProfilePageWidget> createState() => _ProfilePageWidgetState();
}

class _ProfilePageWidgetState extends ConsumerState<ProfilePageWidget> {
  @override
  Widget build(BuildContext context) {
    // ❌ Old: 개별 Provider watching
    final isLoading = ref.watch(profileLoadingProvider);
    final error = ref.watch(profileErrorProvider);

    // ❌ Old: StreamProvider with params object
    final profileAsync = ref.watch(profileStreamProvider(
      ProfileStreamParams(
        userId: widget.userId,
        keepAlive: true,
      ),
    ));

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : profileAsync.when(
                  data: (profile) {
                    if (profile == null) {
                      return const Center(child: Text('Profile not found'));
                    }
                    return ProfileContent(profile: profile);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Error: $error'),
                  ),
                ),
    );
  }
}
```

#### After (profile_notifiers.dart 사용)

```dart
class ProfilePageWidget extends ConsumerStatefulWidget {
  final String userId;

  const ProfilePageWidget({
    required this.userId,
    super.key,
  });

  @override
  ConsumerState<ProfilePageWidget> createState() => _ProfilePageWidgetState();
}

class _ProfilePageWidgetState extends ConsumerState<ProfilePageWidget> {
  @override
  Widget build(BuildContext context) {
    // ✅ New: 통합된 UI state
    final uiState = ref.watch(profileUIProvider);

    // ✅ New: Stream with named parameters
    final profileAsync = ref.watch(profileStreamProvider(
      widget.userId,
      keepAlive: true,
    ));

    // Error listening (side effect)
    ref.listen(profileUIProvider.select((s) => s.error), (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (uiState.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Profile not found'),
                ],
              ),
            );
          }

          return ProfileContent(
            profile: profile,
            isLoading: uiState.isLoading,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Refresh provider
                  ref.invalidate(profileStreamProvider(widget.userId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**주요 변경사항**:

1. **StateProvider 통합**: `isLoading`, `error` → `uiState.isLoading`, `uiState.error`
2. **StreamProvider 간소화**: `ProfileStreamParams` 제거, named parameters 사용
3. **ref.listen 추가**: Error 발생 시 SnackBar 표시 (사용자 피드백)
4. **Loading indicator 개선**: AppBar에 표시하여 UX 향상

---

### 3.2 ref.watch() Patterns

`ref.watch()`는 Provider의 값이 변경될 때 Widget을 rebuild합니다.

#### Pattern 1: Direct State Watching

**전체 State 가져오기**:

```dart
// ✅ 전체 UI state
final uiState = ref.watch(profileUIProvider);

// Access properties
if (uiState.isLoading) { /* ... */ }
if (uiState.error != null) { /* ... */ }

// ✅ 전체 upload state
final uploadState = ref.watch(imageUploadProvider);
final progress = uploadState.progress; // 0.0 to 1.0
final isUploading = uploadState.isUploading;
```

**장점**: 간단하고 명확
**단점**: State의 어떤 값이 변경되어도 rebuild (성능 영향 있을 수 있음)

---

#### Pattern 2: Selective Watching (성능 최적화)

**특정 값만 watching** (해당 값 변경 시에만 rebuild):

```dart
// ✅ isLoading만 watching
final isLoading = ref.watch(
  profileUIProvider.select((state) => state.isLoading),
);

// ✅ error만 watching
final error = ref.watch(
  profileUIProvider.select((state) => state.error),
);

// ✅ upload progress만 watching
final progress = ref.watch(
  imageUploadProvider.select((state) => state.progress),
);
```

**언제 사용?**

- 특정 값이 자주 변경되는 경우
- Widget이 큰 경우 (rebuild 비용이 높음)
- 성능 최적화가 필요한 경우

**예시: Progress Bar**:

```dart
class UploadProgressBar extends ConsumerWidget {
  const UploadProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ progress만 watching (다른 필드 변경 시 rebuild 안 됨)
    final progress = ref.watch(
      imageUploadProvider.select((s) => s.progress),
    );

    return LinearProgressIndicator(value: progress);
  }
}
```

---

#### Pattern 3: Stream Watching

**AsyncValue 패턴**:

```dart
// ✅ Profile stream watching
final profileAsync = ref.watch(profileStreamProvider(userId));

// AsyncValue.when() - 모든 상태 처리
profileAsync.when(
  data: (profile) {
    if (profile == null) return Text('Not found');
    return ProfileWidget(profile: profile);
  },
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);

// AsyncValue.maybeWhen() - 일부 상태만 처리
profileAsync.maybeWhen(
  data: (profile) => ProfileWidget(profile: profile!),
  orElse: () => CircularProgressIndicator(),
);

// AsyncValue 직접 접근
if (profileAsync.hasValue) {
  final profile = profileAsync.value; // UserProfile?
}
if (profileAsync.hasError) {
  final error = profileAsync.error; // Object
}
if (profileAsync.isLoading) {
  // Show loading
}
```

---

#### Pattern 4: Multiple Providers Watching

```dart
class ProfileScreen extends ConsumerWidget {
  final String userId;

  const ProfileScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ 여러 Provider를 동시에 watching
    final uiState = ref.watch(profileUIProvider);
    final profileAsync = ref.watch(profileStreamProvider(userId));
    final uploadState = ref.watch(imageUploadProvider);
    final postsAsync = ref.watch(profileUserPostsStreamProvider(userId));

    // 모든 state를 기반으로 UI 구성
    return Scaffold(
      body: profileAsync.when(
        data: (profile) => Column(
          children: [
            ProfileHeader(
              profile: profile!,
              isUploading: uploadState.isUploading,
              uploadProgress: uploadState.progress,
            ),
            Expanded(
              child: postsAsync.when(
                data: (posts) => PostList(posts: posts),
                loading: () => CircularProgressIndicator(),
                error: (e, s) => ErrorWidget(error: e),
              ),
            ),
          ],
        ),
        loading: () => CircularProgressIndicator(),
        error: (e, s) => ErrorWidget(error: e),
      ),
    );
  }
}
```

---

### 3.3 ref.read() Patterns (Actions)

`ref.read()`는 Provider의 현재 값을 **한 번만** 가져옵니다. **Action을 실행할 때** 사용합니다.

#### Pattern 1: Profile Update Action

```dart
class ProfileEditScreen extends ConsumerStatefulWidget {
  final String userId;

  const ProfileEditScreen({required this.userId, super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ ref.read()로 Notifier action 실행
    await ref.read(profileNotifierProvider.notifier).updateProfile(
      userId: widget.userId,
      updates: {
        'displayName': _nameController.text,
        'bio': _bioController.text,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // UI state는 ref.watch()
    final uiState = ref.watch(profileUIProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
            ElevatedButton(
              onPressed: uiState.isLoading ? null : _handleSave,
              child: uiState.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
```

---

#### Pattern 2: Image Upload Action

```dart
class ProfileImagePicker extends ConsumerWidget {
  final String userId;

  const ProfileImagePicker({required this.userId, super.key});

  Future<void> _pickAndUploadImage(WidgetRef ref) async {
    // Image picker (외부 패키지)
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    // ✅ ref.read()로 upload action 실행
    await ref.read(profileNotifierProvider.notifier).uploadProfileImage(
      userId: userId,
      imagePath: image.path,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(imageUploadProvider);

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          child: uploadState.isUploading
              ? CircularProgressIndicator(value: uploadState.progress)
              : const Icon(Icons.person),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: uploadState.isUploading
              ? null
              : () => _pickAndUploadImage(ref),
          child: const Text('Upload Image'),
        ),
        if (uploadState.isUploading)
          Text('${(uploadState.progress * 100).toStringAsFixed(0)}%'),
      ],
    );
  }
}
```

---

#### Pattern 3: Follow/Unfollow Actions

```dart
class FollowButton extends ConsumerWidget {
  final String currentUserId;
  final String targetUserId;
  final bool isFollowing;

  const FollowButton({
    required this.currentUserId,
    required this.targetUserId,
    required this.isFollowing,
    super.key,
  });

  Future<void> _handleFollowToggle(WidgetRef ref) async {
    final notifier = ref.read(profileNotifierProvider.notifier);

    if (isFollowing) {
      await notifier.unfollowUser(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );
    } else {
      await notifier.followUser(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(profileUIProvider);

    return ElevatedButton(
      onPressed: uiState.isLoading ? null : () => _handleFollowToggle(ref),
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? Colors.grey : Colors.blue,
      ),
      child: Text(isFollowing ? 'Unfollow' : 'Follow'),
    );
  }
}
```

---

#### Pattern 4: Settings Update Action

```dart
class NotificationSettingsToggle extends ConsumerWidget {
  final String userId;
  final UserSettings settings;

  const NotificationSettingsToggle({
    required this.userId,
    required this.settings,
    super.key,
  });

  Future<void> _toggleNotifications(WidgetRef ref, bool value) async {
    final updatedSettings = settings.copyWith(
      notificationsEnabled: value,
    );

    await ref.read(profileNotifierProvider.notifier).updateSettings(
      userId: userId,
      settings: updatedSettings,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsUIProvider);

    return SwitchListTile(
      title: const Text('Enable Notifications'),
      value: settings.notificationsEnabled,
      onChanged: settingsState.isLoading
          ? null
          : (value) => _toggleNotifications(ref, value),
    );
  }
}
```

---

### 3.4 ref.listen() Patterns (Side Effects)

`ref.listen()`은 Provider 값 변경 시 **side effect**를 실행합니다 (SnackBar, Navigation 등).

#### Pattern 1: Error Notification

```dart
class ProfileScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // ✅ Error 발생 시 SnackBar 표시
    ref.listen(
      profileUIProvider.select((state) => state.error),
      (previous, next) {
        if (next != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Dismiss',
                onPressed: () {
                  ref.read(profileUIProvider.notifier).clearError();
                },
              ),
            ),
          );
        }
      },
    );

    // Widget tree
    return Scaffold(/* ... */);
  }
}
```

---

#### Pattern 2: Success Navigation

```dart
class ProfileEditScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  @override
  Widget build(BuildContext context) {
    // ✅ 성공 시 이전 화면으로 이동
    ref.listen(
      profileUIProvider,
      (previous, next) {
        // Loading → Not Loading + No Error = Success
        if (previous?.isLoading == true &&
            next.isLoading == false &&
            next.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      },
    );

    // Widget tree
    return Scaffold(/* ... */);
  }
}
```

---

#### Pattern 3: Upload Complete Notification

```dart
class ImageUploadWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Upload 완료 시 알림
    ref.listen(
      imageUploadProvider.select((state) => state.uploadedUrl),
      (previous, next) {
        if (next != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Reset upload state after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            ref.read(imageUploadProvider.notifier).reset();
          });
        }
      },
    );

    // Widget tree
    return Container(/* ... */);
  }
}
```

---

#### Pattern 4: Multiple Listeners

```dart
class ProfileManagementScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfileManagementScreen> createState() =>
      _ProfileManagementScreenState();
}

class _ProfileManagementScreenState
    extends ConsumerState<ProfileManagementScreen> {
  @override
  Widget build(BuildContext context) {
    // ✅ Profile errors
    ref.listen(
      profileUIProvider.select((s) => s.error),
      (previous, next) {
        if (next != null) {
          _showErrorDialog(context, 'Profile Error', next);
        }
      },
    );

    // ✅ Settings errors
    ref.listen(
      settingsUIProvider.select((s) => s.error),
      (previous, next) {
        if (next != null) {
          _showErrorDialog(context, 'Settings Error', next);
        }
      },
    );

    // ✅ Upload errors
    ref.listen(
      imageUploadProvider.select((s) => s.error),
      (previous, next) {
        if (next != null) {
          _showErrorDialog(context, 'Upload Error', next);
        }
      },
    );

    return Scaffold(/* ... */);
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

---

### 3.5 Complete Example: ProfileEditScreen

**전체 화면 구현 예시** (ref.watch, ref.read, ref.listen 모두 사용):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_notifiers.dart';
import '../../domain/entities/user_profile.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  final String userId;

  const ProfileEditScreen({
    required this.userId,
    super.key,
  });

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _websiteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _websiteController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ ref.read() for action
    await ref.read(profileNotifierProvider.notifier).updateProfile(
      userId: widget.userId,
      updates: {
        'displayName': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'website': _websiteController.text.trim(),
      },
    );
  }

  void _initializeControllers(UserProfile profile) {
    _nameController.text = profile.displayName;
    _bioController.text = profile.bio ?? '';
    _websiteController.text = profile.website ?? '';
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ref.watch() for state
    final profileAsync = ref.watch(profileStreamProvider(widget.userId));
    final uiState = ref.watch(profileUIProvider);

    // ✅ ref.listen() for side effects

    // Listen for errors
    ref.listen(
      profileUIProvider.select((s) => s.error),
      (previous, next) {
        if (next != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Dismiss',
                onPressed: () {
                  ref.read(profileUIProvider.notifier).clearError();
                },
              ),
            ),
          );
        }
      },
    );

    // Listen for success
    ref.listen(
      profileUIProvider,
      (previous, next) {
        if (previous?.isLoading == true &&
            next.isLoading == false &&
            next.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (uiState.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile not found'));
          }

          // Initialize controllers with current data
          if (_nameController.text.isEmpty) {
            _initializeControllers(profile);
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile Image
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: profile.photoURL != null
                            ? NetworkImage(profile.photoURL!)
                            : null,
                        child: profile.photoURL == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 18),
                            color: Colors.white,
                            onPressed: () {
                              // TODO: Implement image picker
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Display Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    hintText: 'Enter your name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Bio
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    hintText: 'Tell us about yourself',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  maxLength: 150,
                ),
                const SizedBox(height: 16),

                // Website
                TextFormField(
                  controller: _websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Website',
                    hintText: 'https://example.com',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final uri = Uri.tryParse(value);
                      if (uri == null || !uri.hasScheme) {
                        return 'Please enter a valid URL';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Save Button
                ElevatedButton(
                  onPressed: uiState.isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: uiState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(profileStreamProvider(widget.userId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**주요 포인트**:

1. **ref.watch()**: `profileAsync`, `uiState` - UI 상태 반영
2. **ref.read()**: `updateProfile()` - Action 실행
3. **ref.listen()**: Error/Success 처리 - Side effects
4. **Form validation**: Flutter 기본 validation 사용
5. **Loading states**: Button, AppBar에 loading indicator 표시
6. **Error handling**: SnackBar로 사용자 피드백

---

## Phase 4: Code Generation

### 4.1 Execution

모든 코드 작성이 완료되면 build_runner를 실행하여 `.g.dart` 파일을 생성합니다.

```bash
# Step 1: 이전 빌드 정리
flutter clean
flutter pub get

# Step 2: 코드 생성 실행
dart run build_runner build --delete-conflicting-outputs

# 예상 소요 시간: 10-30초
# 예상 생성 파일: 4개 (.g.dart x2, .freezed.dart x1)
```

**Watch 모드** (개발 중 자동 재생성):

```bash
# 파일 변경 시 자동으로 코드 재생성
dart run build_runner watch --delete-conflicting-outputs

# Watch 모드 중지: Ctrl+C
```

**예상 출력**:

```
[INFO] Generating build script completed, took 412ms
[INFO] Reading cached asset graph completed, took 89ms
[INFO] Checking for updates since last build completed, took 657ms
[INFO] Running build completed, took 5.2s
[INFO] Caching finalized dependency graph completed, took 54ms
[INFO] Succeeded after 5.3s with 6 outputs (12 actions)

Generated files:
  lib/features/profile/presentation/providers/profile_notifiers.g.dart
  lib/features/profile/presentation/providers/profile_notifiers.freezed.dart
  lib/features/profile/presentation/providers/usecase_providers.g.dart
```

---

### 4.2 Verify Generated Files

```bash
# 생성된 파일 확인
ls -la lib/features/profile/presentation/providers/

# 예상 출력:
# profile_notifiers.dart           (NEW: ~200줄)
# profile_notifiers.freezed.dart   (GENERATED: ~300줄)
# profile_notifiers.g.dart         (GENERATED: ~100줄)
# usecase_providers.dart           (NEW: ~100줄)
# usecase_providers.g.dart         (GENERATED: ~100줄)
# profile_post_providers.dart      (EXISTING)
# profile_post_providers.g.dart    (EXISTING)
# profile_providers.dart           (DEPRECATED)
```

**생성된 파일 내용 확인**:

```bash
# profile_notifiers.g.dart 일부 확인
head -n 50 lib/features/profile/presentation/providers/profile_notifiers.g.dart
```

**예상 내용** (profile_notifiers.g.dart):

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_notifiers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileUIHash() => r'...';

/// See also [ProfileUI].
@ProviderFor(ProfileUI)
final profileUIProvider =
    AutoDisposeNotifierProvider<ProfileUI, ProfileUIState>.internal(
  ProfileUI.new,
  name: r'profileUIProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$profileUIHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProfileUI = AutoDisposeNotifier<ProfileUIState>;
// ... (more generated code)
```

---

### 4.3 Common Build Errors

#### Error 1: Missing Part Directive

**Error Message**:

```
[SEVERE] riverpod_generator on lib/features/profile/presentation/providers/profile_notifiers.dart:

Please add `part 'profile_notifiers.g.dart';` to the top of this file
```

**Solution**:

```dart
// profile_notifiers.dart 상단에 추가
part 'profile_notifiers.g.dart';
part 'profile_notifiers.freezed.dart'; // Freezed 사용 시
```

---

#### Error 2: Conflicting Outputs

**Error Message**:

```
[SEVERE] build_runner:build_runner on ...:

Conflicting outputs were detected and the build is unable to proceed.
```

**Solution**:

```bash
# --delete-conflicting-outputs 플래그 사용
dart run build_runner build --delete-conflicting-outputs
```

---

#### Error 3: Import Not Found

**Error Message**:

```
Error: Not found: 'package:riverpod_annotation/riverpod_annotation.dart'
```

**Solution**:

```bash
# pubspec.yaml 확인 후 의존성 설치
flutter pub get

# 의존성 확인
flutter pub deps | grep riverpod
```

---

#### Error 4: Freezed Class Name Conflict

**Error Message**:

```
Error: 'ProfileUIState' is already defined.
```

**Solution**:

```dart
// Freezed 클래스 이름 변경
@freezed
class ProfileUIState with _$ProfileUIState { // ✅ Unique name
  // ...
}

// 또는 private factory 사용
@freezed
class ProfileUIState with _$ProfileUIState {
  const factory ProfileUIState({ // ✅ Use 'const factory'
    @Default(false) bool isLoading,
  }) = _ProfileUIState; // ✅ Private implementation class
}
```

---

#### Error 5: Build Runner Stuck

**Symptom**: build_runner가 진행되지 않고 멈춤

**Solution**:

```bash
# Step 1: 프로세스 종료
# Ctrl+C or kill the terminal

# Step 2: 캐시 삭제
flutter clean
rm -rf .dart_tool

# Step 3: 의존성 재설치
flutter pub get

# Step 4: 다시 실행
dart run build_runner build --delete-conflicting-outputs
```

---

## Phase 5: Testing & Verification

### 5.1 Static Analysis

```bash
# 전체 코드 분석
flutter analyze

# Profile Feature만 분석
flutter analyze lib/features/profile/

# 예상: No issues found!
```

**허용 가능한 Warning**:

- `unused_import` (사용하지 않는 import) - 제거 가능
- `prefer_const_constructors` (const 생성자 권장) - 선택사항

**반드시 수정해야 할 Error**:

- `undefined_class` - 클래스 정의 없음
- `invalid_annotation_target` - @riverpod 잘못된 위치
- `missing_required_param` - 필수 파라미터 누락

---

### 5.2 Manual Testing Scenarios

다음 시나리오들을 **수동으로 테스트**하여 마이그레이션이 성공했는지 확인합니다.

#### Test 1: Profile View

**목적**: 프로필 데이터가 정상적으로 로드되는지 확인

**Steps**:
1. [ ] 앱 실행
2. [ ] 프로필 화면 이동
3. [ ] 프로필 데이터 확인 (이름, 사진, bio 등)
4. [ ] Loading indicator 표시 확인
5. [ ] 네트워크 끄고 에러 처리 확인
6. [ ] 네트워크 켜고 재시도 버튼 동작 확인

**Expected**:
- ✅ 프로필 데이터가 올바르게 표시됨
- ✅ Loading state가 정상 동작
- ✅ Error state가 정상 동작
- ✅ Retry 버튼이 동작함

---

#### Test 2: Profile Edit

**목적**: 프로필 수정 기능이 정상 동작하는지 확인

**Steps**:
1. [ ] Edit Profile 화면 이동
2. [ ] 이름 변경
3. [ ] Bio 변경
4. [ ] Website 입력 (유효한 URL)
5. [ ] Save 버튼 클릭
6. [ ] Success 메시지 확인
7. [ ] 이전 화면으로 자동 이동 확인
8. [ ] 변경된 데이터가 반영되었는지 확인

**Expected**:
- ✅ Form validation 동작 (필수 필드, URL 형식)
- ✅ Loading state 표시 (버튼에 spinner)
- ✅ Success SnackBar 표시
- ✅ 자동으로 이전 화면 이동
- ✅ 프로필 데이터가 실시간 업데이트됨

---

#### Test 3: Image Upload

**목적**: 프로필 이미지 업로드가 정상 동작하는지 확인

**Steps**:
1. [ ] 프로필 화면에서 이미지 선택 버튼 클릭
2. [ ] 갤러리에서 이미지 선택
3. [ ] Upload progress bar 확인
4. [ ] Progress 퍼센트 표시 확인 (0% → 100%)
5. [ ] 업로드 완료 후 이미지 표시 확인
6. [ ] 큰 파일 업로드 시 에러 처리 확인

**Expected**:
- ✅ Progress bar가 0%에서 100%까지 증가
- ✅ Progress 텍스트가 업데이트됨 ("45%")
- ✅ 업로드 완료 시 이미지가 즉시 반영됨
- ✅ 에러 발생 시 에러 메시지 표시

---

#### Test 4: Follow/Unfollow

**목적**: 팔로우/언팔로우 기능이 정상 동작하는지 확인

**Steps**:
1. [ ] 다른 사용자 프로필 이동
2. [ ] Follow 버튼 클릭
3. [ ] 팔로우 수 증가 확인
4. [ ] 버튼이 "Unfollow"로 변경되는지 확인
5. [ ] Unfollow 버튼 클릭
6. [ ] 팔로우 수 감소 확인
7. [ ] 버튼이 다시 "Follow"로 변경되는지 확인

**Expected**:
- ✅ Follow/Unfollow가 즉시 반영됨
- ✅ 팔로우 카운트가 실시간 업데이트됨
- ✅ 버튼 상태가 올바르게 변경됨
- ✅ 에러 발생 시 SnackBar 표시

---

#### Test 5: Settings

**목적**: 사용자 설정이 정상적으로 저장되는지 확인

**Steps**:
1. [ ] Settings 화면 이동
2. [ ] Notification 토글 변경
3. [ ] 자동 저장 확인
4. [ ] 앱 종료 후 재시작
5. [ ] 설정이 유지되는지 확인

**Expected**:
- ✅ 토글 변경 시 즉시 저장됨
- ✅ Loading indicator 표시
- ✅ Success 피드백 제공
- ✅ 앱 재시작 후에도 설정 유지됨

---

### 5.3 Automated Testing

**Unit Test 예시** (profile_notifier_test.dart):

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versus_cursor/features/profile/presentation/providers/profile_notifiers.dart';

void main() {
  group('ProfileUI Notifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is correct', () {
      final state = container.read(profileUIProvider);

      expect(state.isLoading, false);
      expect(state.error, null);
    });

    test('setLoading updates isLoading', () {
      final notifier = container.read(profileUIProvider.notifier);

      notifier.setLoading(true);
      expect(container.read(profileUIProvider).isLoading, true);

      notifier.setLoading(false);
      expect(container.read(profileUIProvider).isLoading, false);
    });

    test('setError updates error', () {
      final notifier = container.read(profileUIProvider.notifier);

      notifier.setError('Test error');
      expect(container.read(profileUIProvider).error, 'Test error');
    });

    test('clearError clears error', () {
      final notifier = container.read(profileUIProvider.notifier);

      notifier.setError('Test error');
      expect(container.read(profileUIProvider).error, 'Test error');

      notifier.clearError();
      expect(container.read(profileUIProvider).error, null);
    });

    test('reset returns to initial state', () {
      final notifier = container.read(profileUIProvider.notifier);

      notifier.setLoading(true);
      notifier.setError('Error');
      expect(container.read(profileUIProvider).isLoading, true);
      expect(container.read(profileUIProvider).error, 'Error');

      notifier.reset();
      expect(container.read(profileUIProvider).isLoading, false);
      expect(container.read(profileUIProvider).error, null);
    });
  });

  group('ImageUpload Notifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is correct', () {
      final state = container.read(imageUploadProvider);

      expect(state.isUploading, false);
      expect(state.progress, 0.0);
      expect(state.error, null);
      expect(state.uploadedUrl, null);
    });

    test('setProgress updates progress', () {
      final notifier = container.read(imageUploadProvider.notifier);

      notifier.setProgress(0.5);
      expect(container.read(imageUploadProvider).progress, 0.5);

      notifier.setProgress(1.0);
      expect(container.read(imageUploadProvider).progress, 1.0);
    });

    test('setProgress clamps value between 0 and 1', () {
      final notifier = container.read(imageUploadProvider.notifier);

      notifier.setProgress(-0.5);
      expect(container.read(imageUploadProvider).progress, 0.0);

      notifier.setProgress(1.5);
      expect(container.read(imageUploadProvider).progress, 1.0);
    });

    test('setUploadedUrl sets URL and completes upload', () {
      final notifier = container.read(imageUploadProvider.notifier);

      notifier.setUploading(true);
      notifier.setProgress(0.5);

      notifier.setUploadedUrl('https://example.com/image.jpg');

      final state = container.read(imageUploadProvider);
      expect(state.uploadedUrl, 'https://example.com/image.jpg');
      expect(state.isUploading, false);
      expect(state.progress, 1.0);
      expect(state.error, null);
    });
  });
}
```

**테스트 실행**:

```bash
# 단위 테스트 실행
flutter test test/features/profile/presentation/providers/profile_notifier_test.dart

# 모든 Profile 테스트 실행
flutter test test/features/profile/

# 커버리지 포함
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Phase 6: Legacy Code Cleanup

### 6.1 Remove Legacy Imports

**모든 파일에서 legacy import 제거**:

```bash
# 1. legacy import 검색
grep -r "flutter_riverpod/legacy.dart" lib/features/profile/

# 2. 파일에서 제거 (수동)
# ❌ Remove
import 'package:flutter_riverpod/legacy.dart';

# ✅ Keep
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
```

---

### 6.2 Deprecate profile_providers.dart

**Option 1: 파일 삭제** (권장):

```bash
# profile_providers.dart 삭제
rm lib/features/profile/presentation/providers/profile_providers.dart

# Git에서 제거
git rm lib/features/profile/presentation/providers/profile_providers.dart
git commit -m "refactor(profile): Remove legacy profile_providers.dart after Riverpod 3.x migration"
```

**Option 2: Deprecation 마킹** (전환 기간 필요 시):

```dart
// profile_providers.dart
// ignore_for_file: deprecated_member_use_from_same_package

/// **DEPRECATED**: This file has been migrated to Riverpod 3.x.
///
/// Use the following files instead:
/// - [profile_notifiers.dart] for state management and actions
/// - [usecase_providers.dart] for UseCase dependency injection
/// - [profile_post_providers.dart] for post-related providers (already 3.x)
///
/// **Migration Date**: 2025-11-06
/// **Removal Date**: 2025-12-01 (estimated)
@Deprecated('Use profile_notifiers.dart and usecase_providers.dart instead')
library profile_providers_deprecated;

// Keep existing code for reference during transition period
```

---

### 6.3 Update Imports in Widgets

**Widget 파일들의 import 업데이트**:

```bash
# 1. profile_providers.dart import 검색
grep -r "profile_providers.dart" lib/features/profile/presentation/

# 2. 각 파일에서 import 교체
```

**Before**:

```dart
import '../providers/profile_providers.dart'; // ❌ Legacy
```

**After**:

```dart
import '../providers/profile_notifiers.dart'; // ✅ State + Actions
import '../providers/usecase_providers.dart'; // ✅ UseCases (필요시)
```

**일괄 변경 스크립트** (선택사항):

```bash
# macOS/Linux
find lib/features/profile/presentation/ -name "*.dart" -type f -exec sed -i '' \
  's|../providers/profile_providers.dart|../providers/profile_notifiers.dart|g' {} \;

# 확인
grep -r "profile_providers.dart" lib/features/profile/presentation/
```

---

### 6.4 Clean Up Unused Code

**제거할 항목들**:

1. **ProfileActions 클래스** - ProfileNotifier로 대체됨
2. **ProfileStreamParams 클래스** - Named parameters로 대체됨
3. **Helper 클래스** (사용하지 않는 경우)

**확인 방법**:

```bash
# 사용하지 않는 클래스 검색
flutter analyze lib/features/profile/ | grep "unused"

# 특정 클래스 사용처 검색
grep -r "ProfileActions" lib/features/profile/
grep -r "ProfileStreamParams" lib/features/profile/
```

---

## Phase 7: Documentation

### 7.1 Update Feature README

**File**: `lib/features/profile/README.md`

**추가할 섹션**:

```markdown
## Riverpod 3.x Migration (Completed 2025-11-06)

### Migration Summary

Profile Feature has been successfully migrated from Riverpod 2.x (manual providers) to Riverpod 3.x (code-generated providers) following Clean Architecture v4.0 patterns.

**Benefits**:
- ✅ 30% code reduction (560줄 → ~400줄 수동 작성)
- ✅ Type-safe providers with code generation
- ✅ Better state management with Freezed classes
- ✅ Improved developer experience with @riverpod annotation

### Provider Structure

#### State Management Notifiers (profile_notifiers.dart)

**ProfileUI** - Profile UI state management
- `ProfileUIState`: Freezed state with `isLoading`, `error`
- Methods: `setLoading(bool)`, `setError(String?)`, `clearError()`, `reset()`
- Usage: `ref.watch(profileUIProvider)` or `ref.watch(profileUIProvider.select((s) => s.isLoading))`

**SettingsUI** - Settings UI state management
- `SettingsUIState`: Freezed state with `isLoading`, `error`
- Methods: Similar to ProfileUI
- Usage: `ref.watch(settingsUIProvider)`

**ImageUpload** - Image upload progress tracking
- `ImageUploadState`: Freezed state with `isUploading`, `progress`, `error`, `uploadedUrl`
- Methods: `setUploading(bool)`, `setProgress(double)`, `setError(String?)`, `setUploadedUrl(String)`, `reset()`
- Usage: `ref.watch(imageUploadProvider)`

**ProfileNotifier** - Profile action handler
- Methods:
  - `updateProfile({userId, updates})` - Update user profile
  - `uploadProfileImage({userId, imagePath})` - Upload profile image with progress
  - `followUser({currentUserId, targetUserId})` - Follow a user
  - `unfollowUser({currentUserId, targetUserId})` - Unfollow a user
  - `deleteAccount({userId})` - Delete user account
  - `updateSettings({userId, settings})` - Update user settings
- Usage: `ref.read(profileNotifierProvider.notifier).updateProfile(...)`

#### Data Stream Providers (profile_notifiers.dart)

**profileStream** - Real-time profile updates
- Parameters: `userId` (required), `keepAlive` (optional, default: false)
- Returns: `Stream<UserProfile?>`
- Usage: `ref.watch(profileStreamProvider(userId, keepAlive: true))`

**settingsStream** - Real-time settings updates
- Parameters: `userId` (required)
- Returns: `Stream<UserSettings?>`
- Usage: `ref.watch(settingsStreamProvider(userId))`

#### UseCase Providers (usecase_providers.dart)

13 UseCase providers for dependency injection:
- `getUserProfileUseCase` - Get user profile once
- `updateUserProfileUseCase` - Update profile data
- `watchUserProfileUseCase` - Watch profile changes
- `uploadProfileImageUseCase` - Upload profile image
- `deleteProfileImageUseCase` - Delete profile image
- `getFollowersUseCase` - Get followers list
- `getFollowingUseCase` - Get following list
- `followUserUseCase` - Follow user
- `unfollowUserUseCase` - Unfollow user
- `checkFollowStatusUseCase` - Check if following
- `updateUserSettingsUseCase` - Update settings
- `getUserSettingsUseCase` - Get settings
- `deleteAccountUseCase` - Delete account

Usage: `ref.read(getUserProfileUseCaseProvider)`

### Usage Examples

#### Watching Profile

```dart
class ProfileScreen extends ConsumerWidget {
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileStreamProvider(userId));

    return profileAsync.when(
      data: (profile) => ProfileWidget(profile: profile!),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

#### Updating Profile

```dart
Future<void> updateProfile(WidgetRef ref) async {
  await ref.read(profileNotifierProvider.notifier).updateProfile(
    userId: 'user123',
    updates: {'displayName': 'New Name'},
  );
}
```

#### Tracking Upload Progress

```dart
class UploadProgressWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(imageUploadProvider);

    if (!uploadState.isUploading) return SizedBox.shrink();

    return LinearProgressIndicator(value: uploadState.progress);
  }
}
```

#### Error Handling

```dart
class ProfileScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // Listen for errors
    ref.listen(
      profileUIProvider.select((s) => s.error),
      (previous, next) {
        if (next != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next)),
          );
        }
      },
    );

    return Scaffold(/* ... */);
  }
}
```

### Migration References

- [Phase 1-2 Documentation](./RIVERPOD_3X_MIGRATION_PHASE_1_2.md) - Provider transformation
- [Phase 3-7 Documentation](./RIVERPOD_3X_MIGRATION_PHASE_3_7.md) - Widget integration & testing
- [Creation Feature](../creation/) - Similar migration completed 2025-11-06
- [Post Feature](../post/) - Phase 5 Extension Pattern reference
```

---

### 7.2 Add Migration Log

**File**: Create `lib/features/profile/MIGRATION_LOG.md`

```markdown
# Profile Feature - Riverpod 3.x Migration Log

## Timeline

- **Start Date**: 2025-11-06
- **Completion Date**: 2025-11-06
- **Duration**: 1 day (planned)
- **Sprint**: Profile Riverpod 3.x Migration

## Changes Summary

### Phase 1-2: Provider Migration

**StateProvider → Notifier (6 → 3)**:
- `profileLoadingProvider` + `profileErrorProvider` → `ProfileUIState`
- `settingsLoadingProvider` + `settingsErrorProvider` → `SettingsUIState`
- `imageUploadLoadingProvider` + `imageUploadProgressProvider` → `ImageUploadState`

**Provider<UseCase> → @riverpod function (13)**:
- Converted all 13 UseCase providers to `@riverpod` getter functions
- Moved to separate file: `usecase_providers.dart`

**StreamProvider → @riverpod Stream (2)**:
- `profileStreamProvider` (with ProfileStreamParams) → `profileStream(userId, keepAlive)`
- `settingsStreamProvider` → `settingsStream(userId)`

**ProfileActions → ProfileNotifier**:
- Converted 6 static methods to ProfileNotifier instance methods
- Removed WidgetRef parameter (use internal `ref`)

### Phase 3-4: Widget Integration

**Updated Widgets**:
- ProfilePageWidget - Provider references updated
- ProfileEditScreen - Full migration with ref.watch/read/listen
- ProfileImagePicker - Upload progress tracking
- FollowButton - Follow/Unfollow actions
- NotificationSettingsToggle - Settings update

**Code Generation**:
- Generated `profile_notifiers.g.dart` (~100줄)
- Generated `profile_notifiers.freezed.dart` (~300줄)
- Generated `usecase_providers.g.dart` (~100줄)

### Phase 5-7: Testing & Cleanup

**Tests Added**:
- ProfileUI Notifier unit tests (5 test cases)
- ImageUpload Notifier unit tests (5 test cases)
- Manual testing scenarios (5 scenarios)

**Code Cleanup**:
- Removed `flutter_riverpod/legacy.dart` imports
- Deprecated/Removed `profile_providers.dart`
- Removed `ProfileActions` class
- Removed `ProfileStreamParams` class

**Documentation Updated**:
- README.md (Provider structure, usage examples)
- MIGRATION_LOG.md (this file)
- Presentation layer README

## Performance Impact

### Code Metrics

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Manual code | 560줄 | ~400줄 | -30% |
| Generated code | 0줄 | ~500줄 | +500줄 |
| Total files | 1 file | 2 files + 3 generated | +4 files |
| Provider count | 23 manual | ~20 code-gen | -3 providers |

### Performance

- **Build time**: No significant change (~5-10s for code generation)
- **Runtime performance**: Improved (better caching, selective rebuilds)
- **Developer experience**: Significantly improved (type safety, auto-completion)

### Quality

- **Type safety**: ✅ Improved (build_runner generates types)
- **Maintainability**: ✅ Improved (separated concerns, Freezed states)
- **Testability**: ✅ Improved (easier to mock Notifiers)
- **Code readability**: ✅ Improved (declarative @riverpod pattern)

## Issues Encountered

### None

The migration went smoothly thanks to:
1. **profile_post_providers.dart** already being 3.x (used as internal template)
2. **Creation Feature** completed 2025-11-06 (same patterns applied)
3. **Voting Feature** migration docs (comprehensive transformation guides)

## Lessons Learned

1. **File separation is valuable**: Splitting state management (Notifiers) and dependency injection (UseCases) into separate files improves maintainability.

2. **Freezed is powerful**: Using Freezed for state classes reduces boilerplate and ensures immutability with copyWith.

3. **ref.listen is essential**: Using ref.listen() for side effects (SnackBar, Navigation) keeps widget build methods clean.

4. **Selective watching improves performance**: Using `.select()` prevents unnecessary rebuilds when only specific state fields change.

5. **Code generation is worth it**: Initial setup takes time, but long-term benefits (type safety, auto-completion) are significant.

## References

### Documentation
- [Phase 1-2 Migration Guide](./RIVERPOD_3X_MIGRATION_PHASE_1_2.md)
- [Phase 3-7 Migration Guide](./RIVERPOD_3X_MIGRATION_PHASE_3_7.md)
- [Profile Feature README](./README.md)

### Completed Migrations
- **Creation Feature** (2025-11-06): Similar structure, successful migration
- **Post Feature** (Phase 5 complete): Extension pattern reference
- **Chat Feature** (Phase 5 complete): Idempotency + Extension patterns
- **Notifications Feature** (Phase 5 complete): Real-time updates patterns

### External Resources
- [Riverpod 3.x Documentation](https://riverpod.dev/docs/introduction/getting_started)
- [Riverpod Generator](https://pub.dev/packages/riverpod_generator)
- [Freezed Package](https://pub.dev/packages/freezed)

---

**Migration Status**: ✅ Complete
**Verified By**: [Developer Name]
**Approved By**: [Reviewer Name]
**Date**: 2025-11-06
```

---

### 7.3 Update Presentation Layer README

**File**: `lib/features/profile/presentation/README.md`

**Providers 섹션 업데이트**:

```markdown
## Providers (Riverpod 3.x)

### State Management Notifiers (`profile_notifiers.dart`)

#### ProfileUI (`profile_notifiers.dart:XX`)
Manages loading and error states for profile operations.

**State**:
```dart
@freezed
class ProfileUIState with _$ProfileUIState {
  const factory ProfileUIState({
    @Default(false) bool isLoading,
    @Default(null) String? error,
  }) = _ProfileUIState;
}
```

**Methods**:
- `setLoading(bool isLoading)` - Update loading state
- `setError(String? error)` - Set error message
- `clearError()` - Clear error state
- `reset()` - Reset to initial state

**Usage**:
```dart
// Watch entire state
final uiState = ref.watch(profileUIProvider);

// Watch specific field (performance optimization)
final isLoading = ref.watch(profileUIProvider.select((s) => s.isLoading));
```

---

#### SettingsUI (`profile_notifiers.dart:XX`)
Manages settings UI state.

**State**: Same structure as ProfileUIState

**Usage**:
```dart
final settingsState = ref.watch(settingsUIProvider);
```

---

#### ImageUpload (`profile_notifiers.dart:XX`)
Tracks image upload progress and status.

**State**:
```dart
@freezed
class ImageUploadState with _$ImageUploadState {
  const factory ImageUploadState({
    @Default(false) bool isUploading,
    @Default(0.0) double progress, // 0.0 to 1.0
    @Default(null) String? error,
    @Default(null) String? uploadedUrl,
  }) = _ImageUploadState;
}
```

**Methods**:
- `setUploading(bool)` - Start/stop upload
- `setProgress(double)` - Update progress (0.0-1.0, clamped)
- `setError(String?)` - Set error and stop upload
- `setUploadedUrl(String)` - Mark upload complete with URL
- `reset()` - Reset to initial state

**Usage**:
```dart
final uploadState = ref.watch(imageUploadProvider);
if (uploadState.isUploading) {
  return LinearProgressIndicator(value: uploadState.progress);
}
```

---

### Action Notifiers (`profile_notifiers.dart`)

#### ProfileNotifier (`profile_notifiers.dart:XX`)
Contains all profile-related actions.

**Methods**:

**`updateProfile({userId, updates})`**
- Updates user profile fields
- Updates ProfileUI loading/error states
- Returns: `Future<void>`

**`uploadProfileImage({userId, imagePath})`**
- Uploads profile image with progress tracking
- Updates ImageUpload state with progress
- Returns: `Future<void>`

**`followUser({currentUserId, targetUserId})`**
- Follows a user
- Updates ProfileUI error state on failure
- Returns: `Future<void>`

**`unfollowUser({currentUserId, targetUserId})`**
- Unfollows a user
- Updates ProfileUI error state on failure
- Returns: `Future<void>`

**`deleteAccount({userId})`**
- Deletes user account (requires re-authentication)
- Updates ProfileUI loading/error states
- Returns: `Future<void>`

**`updateSettings({userId, settings})`**
- Updates user settings
- Updates SettingsUI loading/error states
- Returns: `Future<void>`

**Usage**:
```dart
// Update profile
await ref.read(profileNotifierProvider.notifier).updateProfile(
  userId: 'user123',
  updates: {'displayName': 'New Name'},
);

// Upload image
await ref.read(profileNotifierProvider.notifier).uploadProfileImage(
  userId: 'user123',
  imagePath: '/path/to/image.jpg',
);
```

---

### Data Stream Providers (`profile_notifiers.dart`)

#### profileStream (`profile_notifiers.dart:XX`)
Real-time profile data stream.

**Parameters**:
- `userId` (String, required) - User ID to watch
- `keepAlive` (bool, optional, default: false) - Keep provider alive

**Returns**: `Stream<UserProfile?>`

**Usage**:
```dart
final profileAsync = ref.watch(profileStreamProvider(userId));

profileAsync.when(
  data: (profile) => ProfileWidget(profile: profile!),
  loading: () => CircularProgressIndicator(),
  error: (e, s) => Text('Error: $e'),
);
```

---

#### settingsStream (`profile_notifiers.dart:XX`)
Real-time settings data stream.

**Parameters**:
- `userId` (String, required) - User ID to watch

**Returns**: `Stream<UserSettings?>`

**Usage**:
```dart
final settingsAsync = ref.watch(settingsStreamProvider(userId));
```

---

### UseCase Providers (`usecase_providers.dart`)

13 UseCase providers for dependency injection. All follow the same pattern:

```dart
@riverpod
UseCaseType useCaseName(Ref ref) {
  return getIt<UseCaseType>();
}
```

**Available UseCases**:
1. `getUserProfileUseCase` - Get user profile once
2. `updateUserProfileUseCase` - Update profile
3. `watchUserProfileUseCase` - Watch profile changes
4. `uploadProfileImageUseCase` - Upload image
5. `deleteProfileImageUseCase` - Delete image
6. `getFollowersUseCase` - Get followers
7. `getFollowingUseCase` - Get following
8. `followUserUseCase` - Follow user
9. `unfollowUserUseCase` - Unfollow user
10. `checkFollowStatusUseCase` - Check follow status
11. `updateUserSettingsUseCase` - Update settings
12. `getUserSettingsUseCase` - Get settings
13. `deleteAccountUseCase` - Delete account

**Usage**:
```dart
final useCase = ref.read(getUserProfileUseCaseProvider);
final result = await useCase.execute(userId: 'user123');
```

---

## Widget Integration Patterns

### ref.watch() - State Observation

Use `ref.watch()` to rebuild widget when provider value changes:

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch entire state
    final uiState = ref.watch(profileUIProvider);

    // Watch specific field (optimized)
    final isLoading = ref.watch(profileUIProvider.select((s) => s.isLoading));

    return Text(isLoading ? 'Loading...' : 'Ready');
  }
}
```

### ref.read() - One-time Access

Use `ref.read()` for actions (button callbacks, lifecycle methods):

```dart
Future<void> handleSave() async {
  await ref.read(profileNotifierProvider.notifier).updateProfile(...);
}
```

### ref.listen() - Side Effects

Use `ref.listen()` for side effects (SnackBar, Navigation):

```dart
@override
Widget build(BuildContext context) {
  // Listen for errors
  ref.listen(
    profileUIProvider.select((s) => s.error),
    (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next)),
        );
      }
    },
  );

  return Scaffold(...);
}
```

---

## File Structure

```
presentation/
├── providers/
│   ├── profile_notifiers.dart           # State + Actions
│   ├── profile_notifiers.freezed.dart   # Generated
│   ├── profile_notifiers.g.dart         # Generated
│   ├── usecase_providers.dart           # UseCases
│   ├── usecase_providers.g.dart         # Generated
│   └── profile_post_providers.dart      # Posts (existing 3.x)
│
├── screens/
│   ├── profile_page.dart
│   ├── profile_edit_screen.dart
│   └── settings_screen.dart
│
└── widgets/
    ├── profile_header.dart
    ├── profile_stats.dart
    └── follow_button.dart
```

---

## Migration Notes

- **Migrated**: 2025-11-06
- **From**: Riverpod 2.x (manual providers)
- **To**: Riverpod 3.x (code-generated)
- **Pattern**: Clean Architecture v4.0
- **Code Reduction**: ~30% (560줄 → ~400줄)

See [RIVERPOD_3X_MIGRATION_PHASE_1_2.md](./RIVERPOD_3X_MIGRATION_PHASE_1_2.md) for details.
```

---

## Appendix C: Reference Materials

### Completed Migrations (Templates)

1. **Creation Feature** (2025-11-06) ✅
   - Similar provider structure
   - 3.x patterns demonstrated
   - Located: `lib/features/creation/`
   - Refer to for: File organization, Notifier patterns

2. **Post Feature** (Phase 5 completed) ✅
   - Extension pattern examples
   - Idempotency implementation
   - Located: `lib/features/post/`
   - Refer to for: Data layer patterns

3. **profile_post_providers.dart** (Already 3.x) ✅
   - Best internal reference
   - Same feature, already migrated
   - Located: `lib/features/profile/presentation/providers/`
   - Refer to for: Stream provider patterns

### External References

- **Riverpod Documentation**: https://riverpod.dev/
- **Riverpod 3.x Migration Guide**: https://riverpod.dev/docs/migration/0.14.0_to_1.0.0
- **Riverpod Generator**: https://pub.dev/packages/riverpod_generator
- **Freezed Documentation**: https://pub.dev/packages/freezed
- **Flutter State Management**: https://docs.flutter.dev/data-and-backend/state-mgmt/options

### Internal Documentation

- **Voting Feature Migration Docs**: `lib/features/voting/RIVERPOD_3X_MIGRATION_*.md`
- **Clean Architecture v4.0**: `CLAUDE.md` (project root)
- **Profile Feature README**: `lib/features/profile/README.md`
- **Phase 1-2 Migration**: `lib/features/profile/RIVERPOD_3X_MIGRATION_PHASE_1_2.md`

---

## Appendix D: Final Checklist

### Pre-Migration

- [x] Read Phase 1-2 documentation
- [x] Understand transformation patterns
- [x] Review profile_post_providers.dart structure
- [x] Create Git backup branch

### Migration Execution

#### Phase 1: Preparation
- [ ] Verify dependencies (pubspec.yaml)
- [ ] Create backup branch (feature/profile-riverpod-3x)
- [ ] Commit current state

#### Phase 2: Provider Transformation
- [ ] Create profile_notifiers.dart with part directives
- [ ] Define 3 Freezed state classes (ProfileUI, SettingsUI, ImageUpload)
- [ ] Implement 3 State Notifiers
- [ ] Implement ProfileNotifier with 6 action methods
- [ ] Implement 2 Stream providers
- [ ] Create usecase_providers.dart with part directive
- [ ] Convert 13 UseCase providers to @riverpod functions
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`
- [ ] Verify generated files exist (*.g.dart, *.freezed.dart)
- [ ] Remove legacy.dart imports

#### Phase 3: Widget Integration
- [ ] Update ProfilePageWidget imports and provider references
- [ ] Update ProfileEditScreen with ref.watch/read/listen patterns
- [ ] Update other widgets (FollowButton, ImagePicker, etc.)
- [ ] Test ref.listen() for SnackBar/Navigation

#### Phase 4: Code Generation
- [ ] Run `flutter clean && flutter pub get`
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`
- [ ] Verify all .g.dart and .freezed.dart files generated
- [ ] Run `flutter analyze` - no errors

#### Phase 5: Testing & Verification
- [ ] Run `flutter analyze lib/features/profile/` - pass
- [ ] Manual Test 1: Profile View (load, error, retry)
- [ ] Manual Test 2: Profile Edit (save, validation, success)
- [ ] Manual Test 3: Image Upload (progress, complete, error)
- [ ] Manual Test 4: Follow/Unfollow (toggle, count update)
- [ ] Manual Test 5: Settings (toggle, persist)
- [ ] Run unit tests: `flutter test test/features/profile/`
- [ ] Verify test coverage ≥80%

#### Phase 6: Legacy Code Cleanup
- [ ] Remove legacy.dart imports from all files
- [ ] Delete or deprecate profile_providers.dart
- [ ] Update widget imports (profile_providers → profile_notifiers)
- [ ] Remove ProfileActions class
- [ ] Remove ProfileStreamParams class
- [ ] Clean up unused helper classes

#### Phase 7: Documentation
- [ ] Update lib/features/profile/README.md (Provider structure section)
- [ ] Create lib/features/profile/MIGRATION_LOG.md
- [ ] Update lib/features/profile/presentation/README.md (Providers section)
- [ ] Document any issues encountered
- [ ] Add usage examples to README

### Post-Migration Verification

- [ ] All tests pass (`flutter test`)
- [ ] No flutter analyze errors (`flutter analyze`)
- [ ] App runs without crashes (`flutter run`)
- [ ] Profile features work as before (manual testing)
- [ ] Performance is same or better (loading times, responsiveness)
- [ ] Documentation is complete and accurate
- [ ] Git commit with descriptive message
- [ ] Create pull request with migration summary

### Final Sign-off

- [ ] Code review completed
- [ ] QA testing completed
- [ ] Documentation reviewed
- [ ] Migration log updated
- [ ] Merge to main branch

---

**Migration Guide Version**: 1.0
**Last Updated**: 2025-11-06
**Author**: Claude Code
**Previous Document**: [RIVERPOD_3X_MIGRATION_PHASE_1_2.md](./RIVERPOD_3X_MIGRATION_PHASE_1_2.md)
