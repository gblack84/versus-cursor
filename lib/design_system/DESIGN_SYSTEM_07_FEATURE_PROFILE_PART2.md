# DESIGN_SYSTEM_07_FEATURE_PROFILE_PART2.md

> **Part 8-2: Profile Feature - 컴포넌트 도입 및 구현 가이드**
>
> **최종 업데이트**: 2025-11-10
> **문서 버전**: 1.0.0
> **담당 Feature**: Profile (프로필 관리)
> **문서 분량**: ~750줄 (Part 2/2)
> **이전 문서**: Part 8-1 (현황 분석 및 토큰 마이그레이션)

---

## 📋 목차

- [컴포넌트 소개](#-컴포넌트-소개)
- [Phase 2: 컴포넌트 도입](#-phase-2-컴포넌트-도입)
- [Before/After 코드 예시](#-beforeafter-코드-예시)
- [Phase 3: 품질 보증](#-phase-3-품질-보증)
- [Best Practices](#-best-practices)
- [완료 체크리스트](#-완료-체크리스트)

---

## 🧩 컴포넌트 소개

### 1. VersusAvatar (우선순위: CRITICAL ⭐⭐⭐⭐⭐)

**설명**: 모든 사용자 이미지 표시를 위한 범용 Avatar 컴포넌트

**사용 현황**:
- Profile Feature: 12 usages
- Auth Feature: 8 usages (예상)
- Chat Feature: 15+ usages (예상)
- **전체: 35+ usages**

**Before/After**:
```dart
// ❌ BEFORE: profile_avatar.dart (234 lines)
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Color(0xFF6B4EFF),  // Hardcoded
          width: 3,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),  // Hardcoded
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Color(0xFFE8E8E8),  // Hardcoded
                    child: Center(
                      child: Text(
                        _getInitials(fallbackText),
                        style: TextStyle(
                          fontSize: size * 0.4,  // Hardcoded calculation
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF14142B),  // Hardcoded
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container(
                color: Color(0xFFE8E8E8),  // Hardcoded
                child: Center(
                  child: Text(
                    _getInitials(fallbackText),
                    style: TextStyle(
                      fontSize: size * 0.4,  // Hardcoded
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF14142B),  // Hardcoded
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  String _getInitials(String text) {
    if (text.isEmpty) return '?';
    final words = text.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return text[0].toUpperCase();
  }
}

// ✅ AFTER: VersusAvatar (60 lines total, usage: 4 lines)
VersusAvatar(
  imageUrl: profile.avatarUrl,
  fallbackText: profile.displayName,
  size: VersusAvatarSize.large,
  showBorder: true,
)
```

**코드 감소**: 234 lines → 60 lines (컴포넌트) + 4 lines (사용) = **97% 감소**

**Size Tokens**:
```dart
enum VersusAvatarSize {
  small(32),    // 리스트 아이템
  medium(64),   // 프로필 카드
  large(96),    // 프로필 페이지
  xlarge(120),  // 상세 페이지
}
```

---

### 2. VersusProfileStatCard (우선순위: HIGH ⭐⭐⭐⭐)

**설명**: 프로필 통계 표시를 위한 카드 컴포넌트

**사용 현황**:
- Profile Feature: 4 usages (Posts, Votes, Followers, Following)
- Voting Feature: 3 usages (예상 - 투표 통계)
- Post Feature: 2 usages (예상 - 게시물 통계)
- Creation Feature: 2 usages (예상 - 생성 통계)
- **전체: 11+ usages**

**Before/After**:
```dart
// ❌ BEFORE: profile_stats_widget.dart (267 lines × 4 = 1,068 lines)
Widget _buildStatCard({
  required String label,
  required String value,
  required IconData icon,
  VoidCallback? onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),  // Hardcoded
        decoration: BoxDecoration(
          color: Colors.white,  // Hardcoded
          borderRadius: BorderRadius.circular(12),  // Hardcoded
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),  // Hardcoded
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Color(0xFF6B4EFF),  // Hardcoded
              size: 32,
            ),
            SizedBox(height: 8),  // Hardcoded
            Text(
              value,
              style: TextStyle(
                fontSize: 20,  // Hardcoded
                fontWeight: FontWeight.bold,
                color: Color(0xFF14142B),  // Hardcoded
              ),
            ),
            SizedBox(height: 4),  // Hardcoded
            Text(
              label,
              style: TextStyle(
                fontSize: 14,  // Hardcoded
                color: Color(0xFF6B7280),  // Hardcoded
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Usage (4 cards)
Row(
  children: [
    _buildStatCard(
      label: 'Posts',
      value: profile.stats.postCount.toString(),
      icon: Icons.article,
      onTap: () => _navigateToPosts(),
    ),
    SizedBox(width: 12),  // Hardcoded
    _buildStatCard(
      label: 'Votes',
      value: profile.stats.voteCount.toString(),
      icon: Icons.how_to_vote,
      onTap: () => _navigateToVotes(),
    ),
    SizedBox(width: 12),  // Hardcoded
    _buildStatCard(
      label: 'Followers',
      value: profile.stats.followerCount.toString(),
      icon: Icons.people,
      onTap: () => _navigateToFollowers(),
    ),
    SizedBox(width: 12),  // Hardcoded
    _buildStatCard(
      label: 'Following',
      value: profile.stats.followingCount.toString(),
      icon: Icons.person_add,
      onTap: () => _navigateToFollowing(),
    ),
  ],
)

// ✅ AFTER: VersusProfileStatCard (20 lines for 4 cards)
Row(
  children: [
    VersusProfileStatCard(
      label: 'Posts',
      value: profile.stats.postCount.toString(),
      icon: Icons.article,
      onTap: () => _navigateToPosts(),
    ),
    VersusProfileStatCard(
      label: 'Votes',
      value: profile.stats.voteCount.toString(),
      icon: Icons.how_to_vote,
      onTap: () => _navigateToVotes(),
    ),
    VersusProfileStatCard(
      label: 'Followers',
      value: profile.stats.followerCount.toString(),
      icon: Icons.people,
      onTap: () => _navigateToFollowers(),
    ),
    VersusProfileStatCard(
      label: 'Following',
      value: profile.stats.followingCount.toString(),
      icon: Icons.person_add,
      onTap: () => _navigateToFollowing(),
    ),
  ].withSpaceBetween(VersusSpacing.sm),  // Extension method
)
```

**코드 감소**: 1,068 lines (267×4) → 20 lines (5×4) = **98% 감소**

---

### 3. VersusSettingsTile (우선순위: MEDIUM ⭐⭐⭐)

**설명**: 설정 화면의 각 설정 항목을 위한 타일 컴포넌트

**사용 현황**:
- Profile Feature: 8 usages (프로필 설정, 계정 설정)
- Auth Feature: 4 usages (예상 - 계정 관리)
- Notifications Feature: 6 usages (예상 - 알림 설정)
- **전체: 18+ usages**

**Before/After**:
```dart
// ❌ BEFORE: settings_tile_widget.dart (178 lines)
class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),  // Hardcoded
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFE0E0E0),  // Hardcoded
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),  // Hardcoded
                borderRadius: BorderRadius.circular(8),  // Hardcoded
              ),
              child: Icon(
                leadingIcon,
                color: Color(0xFF6B4EFF),  // Hardcoded
                size: 24,
              ),
            ),
            SizedBox(width: 16),  // Hardcoded
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,  // Hardcoded
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF14142B),  // Hardcoded
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4),  // Hardcoded
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,  // Hardcoded
                        color: Color(0xFF6B7280),  // Hardcoded
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

// ✅ AFTER: VersusSettingsTile (5 lines per usage)
VersusSettingsTile(
  title: 'Edit Profile',
  subtitle: 'Update your profile information',
  leadingIcon: Icons.edit,
  trailing: Icon(Icons.chevron_right),
  onTap: () => _navigateToEditProfile(),
)
```

**코드 감소**: 178 lines → 40 lines (컴포넌트) + 5 lines (사용) = **97% 감소**

---

## 🚀 Phase 2: 컴포넌트 도입

### Phase 2 개요 (12시간, 1.5일)

```
Phase 2: 컴포넌트 도입
├─ Day 3 (8시간)
│   ├─ VersusAvatar 도입 (4시간)
│   │   ├─ 컴포넌트 정의 (1시간)
│   │   ├─ 12개 사용처 교체 (2시간)
│   │   └─ 테스트 (1시간)
│   │
│   └─ VersusProfileStatCard 도입 (4시간)
│       ├─ 컴포넌트 정의 (1시간)
│       ├─ 4개 사용처 교체 (1.5시간)
│       └─ 테스트 (1.5시간)
│
└─ Day 4 (4시간)
    ├─ VersusSettingsTile 도입 (2시간)
    │   ├─ 컴포넌트 정의 (0.5시간)
    │   ├─ 8개 사용처 교체 (1시간)
    │   └─ 테스트 (0.5시간)
    │
    └─ Supporting 컴포넌트 적용 (2시간)
        ├─ VersusButton (18 usages)
        ├─ VersusTextField (8 usages)
        └─ VersusCard (6 usages)
```

---

### Day 3: VersusAvatar & VersusProfileStatCard

#### VersusAvatar 도입 (4시간)

**1단계: 컴포넌트 정의** (1시간)

파일: `lib/core/design_system/components/atoms/versus_avatar.dart`

```dart
import 'package:flutter/material.dart';
import 'package:versus_space/core/design_system/tokens/versus_colors.dart';
import 'package:versus_space/core/design_system/tokens/versus_radius.dart';
import 'package:versus_space/core/design_system/tokens/versus_typography.dart';

enum VersusAvatarSize {
  small(32),
  medium(64),
  large(96),
  xlarge(120);

  final double value;
  const VersusAvatarSize(this.value);
}

class VersusAvatar extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final VersusAvatarSize size;
  final bool showBorder;
  final VoidCallback? onTap;

  const VersusAvatar({
    super.key,
    this.imageUrl,
    required this.fallbackText,
    this.size = VersusAvatarSize.medium,
    this.showBorder = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Container(
      width: size.value,
      height: size.value,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: VersusColors.primary,
                width: 3,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(VersusRadius.full),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallback(),
              )
            : _buildFallback(),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: widget,
      );
    }

    return widget;
  }

  Widget _buildFallback() {
    return Container(
      color: VersusColors.surface,
      child: Center(
        child: Text(
          _getInitials(fallbackText),
          style: VersusTypography.h3.copyWith(
            color: VersusColors.textPrimary,
          ),
        ),
      ),
    );
  }

  String _getInitials(String text) {
    if (text.isEmpty) return '?';
    final words = text.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return text[0].toUpperCase();
  }
}
```

**2단계: 12개 사용처 교체** (2시간)

```bash
# Profile Feature에서 VersusAvatar 사용처 검색
grep -r "ProfileAvatar\|profile_avatar\|ClipRRect.*Image.network" \
  lib/features/profile/presentation/

# 예상 사용처:
# 1. profile_page.dart (3회)
# 2. character_detail_page_widget.dart (2회)
# 3. edit_profile_page.dart (2회)
# 4. avatar_picker_widget.dart (1회)
# 5. profile_header.dart (2회)
# 6. profile_list_item.dart (2회)
```

**교체 예시** (profile_page.dart):

```dart
// ❌ BEFORE: 234 lines custom widget
ProfileAvatar(
  imageUrl: profile.avatarUrl,
  size: 96,
  fallbackText: profile.displayName,
)

// ✅ AFTER: VersusAvatar component
VersusAvatar(
  imageUrl: profile.avatarUrl,
  fallbackText: profile.displayName,
  size: VersusAvatarSize.large,
  showBorder: true,
  onTap: () => _showAvatarOptions(),
)
```

**3단계: 테스트** (1시간)

```dart
// test/core/design_system/components/atoms/versus_avatar_test.dart
void main() {
  group('VersusAvatar', () {
    testWidgets('displays image when imageUrl is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusAvatar(
              imageUrl: 'https://example.com/avatar.jpg',
              fallbackText: 'John Doe',
              size: VersusAvatarSize.medium,
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('displays initials when imageUrl is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusAvatar(
              imageUrl: null,
              fallbackText: 'John Doe',
              size: VersusAvatarSize.medium,
            ),
          ),
        ),
      );

      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusAvatar(
              imageUrl: null,
              fallbackText: 'John Doe',
              size: VersusAvatarSize.medium,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VersusAvatar));
      expect(tapped, true);
    });

    testWidgets('shows border when showBorder is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusAvatar(
              imageUrl: null,
              fallbackText: 'John Doe',
              size: VersusAvatarSize.medium,
              showBorder: true,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });
  });
}
```

---

#### VersusProfileStatCard 도입 (4시간)

**1단계: 컴포넌트 정의** (1시간)

파일: `lib/core/design_system/components/molecules/versus_profile_stat_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:versus_space/core/design_system/tokens/versus_colors.dart';
import 'package:versus_space/core/design_system/tokens/versus_spacing.dart';
import 'package:versus_space/core/design_system/tokens/versus_radius.dart';
import 'package:versus_space/core/design_system/tokens/versus_typography.dart';
import 'package:versus_space/core/design_system/tokens/versus_shadows.dart';

class VersusProfileStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const VersusProfileStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(VersusSpacing.md),
          decoration: BoxDecoration(
            color: VersusColors.background,
            borderRadius: BorderRadius.circular(VersusRadius.md),
            boxShadow: VersusShadows.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: VersusColors.primary,
                size: 32,
              ),
              SizedBox(height: VersusSpacing.sm),
              Text(
                value,
                style: VersusTypography.h4.copyWith(
                  color: VersusColors.textPrimary,
                ),
              ),
              SizedBox(height: VersusSpacing.xs),
              Text(
                label,
                style: VersusTypography.labelMedium.copyWith(
                  color: VersusColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**2단계: 4개 사용처 교체** (1.5시간)

```dart
// ❌ BEFORE: profile_page.dart (1,068 lines total for 4 cards)
Row(
  children: [
    _buildStatCard(
      label: 'Posts',
      value: profile.stats.postCount.toString(),
      icon: Icons.article,
      onTap: () => _navigateToPosts(),
    ),
    SizedBox(width: 12),
    _buildStatCard(
      label: 'Votes',
      value: profile.stats.voteCount.toString(),
      icon: Icons.how_to_vote,
      onTap: () => _navigateToVotes(),
    ),
    SizedBox(width: 12),
    _buildStatCard(
      label: 'Followers',
      value: profile.stats.followerCount.toString(),
      icon: Icons.people,
      onTap: () => _navigateToFollowers(),
    ),
    SizedBox(width: 12),
    _buildStatCard(
      label: 'Following',
      value: profile.stats.followingCount.toString(),
      icon: Icons.person_add,
      onTap: () => _navigateToFollowing(),
    ),
  ],
)

// ✅ AFTER: VersusProfileStatCard component (20 lines)
Row(
  children: [
    VersusProfileStatCard(
      label: 'Posts',
      value: profile.stats.postCount.toString(),
      icon: Icons.article,
      onTap: () => _navigateToPosts(),
    ),
    VersusProfileStatCard(
      label: 'Votes',
      value: profile.stats.voteCount.toString(),
      icon: Icons.how_to_vote,
      onTap: () => _navigateToVotes(),
    ),
    VersusProfileStatCard(
      label: 'Followers',
      value: profile.stats.followerCount.toString(),
      icon: Icons.people,
      onTap: () => _navigateToFollowers(),
    ),
    VersusProfileStatCard(
      label: 'Following',
      value: profile.stats.followingCount.toString(),
      icon: Icons.person_add,
      onTap: () => _navigateToFollowing(),
    ),
  ].withSpaceBetween(VersusSpacing.sm),  // Extension method
)
```

**Extension Method for Spacing**:

```dart
// lib/core/design_system/utils/widget_extensions.dart
extension WidgetListExtension on List<Widget> {
  List<Widget> withSpaceBetween(double spacing) {
    if (isEmpty) return this;

    return [
      for (int i = 0; i < length; i++) ...[
        this[i],
        if (i < length - 1) SizedBox(width: spacing),
      ],
    ];
  }
}
```

---

## 📝 Before/After 코드 예시

### 예시 1: profile_page.dart (완전한 파일 변환)

#### Before (678 lines, 34 hardcoding)

```dart
// lib/features/profile/presentation/screens/user_info/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/profile_providers.dart';

class ProfilePage extends ConsumerWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFF6B4EFF),  // ❌ Hardcoded
      ),
      body: profileAsync.when(
        data: (profile) => SingleChildScrollView(
          padding: EdgeInsets.all(16),  // ❌ Hardcoded
          child: Column(
            children: [
              // Avatar Section (234 lines in separate widget)
              Container(
                width: 96,  // ❌ Hardcoded
                height: 96,  // ❌ Hardcoded
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xFF6B4EFF),  // ❌ Hardcoded
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(48),  // ❌ Hardcoded
                  child: profile.avatarUrl != null
                      ? Image.network(
                          profile.avatarUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Color(0xFFE8E8E8),  // ❌ Hardcoded
                          child: Center(
                            child: Text(
                              _getInitials(profile.displayName),
                              style: TextStyle(
                                fontSize: 40,  // ❌ Hardcoded
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF14142B),  // ❌ Hardcoded
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              SizedBox(height: 16),  // ❌ Hardcoded

              // Name
              Text(
                profile.displayName,
                style: TextStyle(
                  fontSize: 24,  // ❌ Hardcoded
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF14142B),  // ❌ Hardcoded
                ),
              ),
              SizedBox(height: 8),  // ❌ Hardcoded

              // Bio
              if (profile.bio != null)
                Text(
                  profile.bio!,
                  style: TextStyle(
                    fontSize: 16,  // ❌ Hardcoded
                    color: Color(0xFF6B7280),  // ❌ Hardcoded
                  ),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 24),  // ❌ Hardcoded

              // Stats Row (1,068 lines for 4 cards)
              Row(
                children: [
                  _buildStatCard(
                    context,
                    label: 'Posts',
                    value: profile.stats.postCount.toString(),
                    icon: Icons.article,
                  ),
                  SizedBox(width: 12),  // ❌ Hardcoded
                  _buildStatCard(
                    context,
                    label: 'Votes',
                    value: profile.stats.voteCount.toString(),
                    icon: Icons.how_to_vote,
                  ),
                  SizedBox(width: 12),  // ❌ Hardcoded
                  _buildStatCard(
                    context,
                    label: 'Followers',
                    value: profile.stats.followerCount.toString(),
                    icon: Icons.people,
                  ),
                  SizedBox(width: 12),  // ❌ Hardcoded
                  _buildStatCard(
                    context,
                    label: 'Following',
                    value: profile.stats.followingCount.toString(),
                    icon: Icons.person_add,
                  ),
                ],
              ),
            ],
          ),
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),  // ❌ Hardcoded
        decoration: BoxDecoration(
          color: Colors.white,  // ❌ Hardcoded
          borderRadius: BorderRadius.circular(12),  // ❌ Hardcoded
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),  // ❌ Hardcoded
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Color(0xFF6B4EFF),  // ❌ Hardcoded
              size: 32,
            ),
            SizedBox(height: 8),  // ❌ Hardcoded
            Text(
              value,
              style: TextStyle(
                fontSize: 20,  // ❌ Hardcoded
                fontWeight: FontWeight.bold,
                color: Color(0xFF14142B),  // ❌ Hardcoded
              ),
            ),
            SizedBox(height: 4),  // ❌ Hardcoded
            Text(
              label,
              style: TextStyle(
                fontSize: 14,  // ❌ Hardcoded
                color: Color(0xFF6B7280),  // ❌ Hardcoded
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String text) {
    if (text.isEmpty) return '?';
    final words = text.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return text[0].toUpperCase();
  }
}
```

#### After (245 lines, 0 hardcoding) - **64% 감소**

```dart
// lib/features/profile/presentation/screens/user_info/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/profile_providers.dart';
import 'package:versus_space/core/design_system/tokens/versus_colors.dart';
import 'package:versus_space/core/design_system/tokens/versus_spacing.dart';
import 'package:versus_space/core/design_system/tokens/versus_typography.dart';
import 'package:versus_space/core/design_system/components/atoms/versus_avatar.dart';
import 'package:versus_space/core/design_system/components/molecules/versus_profile_stat_card.dart';
import 'package:versus_space/core/design_system/utils/widget_extensions.dart';

class ProfilePage extends ConsumerWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: VersusColors.primary,  // ✅ Token
      ),
      body: profileAsync.when(
        data: (profile) => SingleChildScrollView(
          padding: EdgeInsets.all(VersusSpacing.md),  // ✅ Token
          child: Column(
            children: [
              // Avatar - VersusAvatar component
              VersusAvatar(
                imageUrl: profile.avatarUrl,
                fallbackText: profile.displayName,
                size: VersusAvatarSize.large,
                showBorder: true,
                onTap: () => _showAvatarOptions(context),
              ),
              SizedBox(height: VersusSpacing.md),  // ✅ Token

              // Name
              Text(
                profile.displayName,
                style: VersusTypography.h2.copyWith(  // ✅ Token
                  color: VersusColors.textPrimary,   // ✅ Token
                ),
              ),
              SizedBox(height: VersusSpacing.sm),  // ✅ Token

              // Bio
              if (profile.bio != null)
                Text(
                  profile.bio!,
                  style: VersusTypography.bodyLarge.copyWith(  // ✅ Token
                    color: VersusColors.textSecondary,         // ✅ Token
                  ),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: VersusSpacing.lg),  // ✅ Token

              // Stats Row - VersusProfileStatCard components
              Row(
                children: [
                  VersusProfileStatCard(
                    label: 'Posts',
                    value: profile.stats.postCount.toString(),
                    icon: Icons.article,
                    onTap: () => _navigateToPosts(context),
                  ),
                  VersusProfileStatCard(
                    label: 'Votes',
                    value: profile.stats.voteCount.toString(),
                    icon: Icons.how_to_vote,
                    onTap: () => _navigateToVotes(context),
                  ),
                  VersusProfileStatCard(
                    label: 'Followers',
                    value: profile.stats.followerCount.toString(),
                    icon: Icons.people,
                    onTap: () => _navigateToFollowers(context),
                  ),
                  VersusProfileStatCard(
                    label: 'Following',
                    value: profile.stats.followingCount.toString(),
                    icon: Icons.person_add,
                    onTap: () => _navigateToFollowing(context),
                  ),
                ].withSpaceBetween(VersusSpacing.sm),  // ✅ Extension
              ),
            ],
          ),
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showAvatarOptions(BuildContext context) {
    // Avatar options logic
  }

  void _navigateToPosts(BuildContext context) {
    // Navigation logic
  }

  void _navigateToVotes(BuildContext context) {
    // Navigation logic
  }

  void _navigateToFollowers(BuildContext context) {
    // Navigation logic
  }

  void _navigateToFollowing(BuildContext context) {
    // Navigation logic
  }
}
```

**개선 요약**:

| 메트릭 | Before | After | 개선율 |
|--------|--------|-------|--------|
| **총 라인 수** | 678 | 245 | 64% 감소 |
| **하드코딩** | 34 instances | 0 instances | 100% 제거 |
| **커스텀 위젯** | 2개 (Avatar 234줄, StatCard 267줄) | 0개 (컴포넌트 사용) | 100% 제거 |
| **토큰 사용** | 0% | 100% | - |
| **컴포넌트 재사용** | 0 | 6 (Avatar×1, StatCard×4, Extension×1) | - |

---

## ✅ Phase 3: 품질 보증

### 테스트 전략 (4시간)

#### 1. 3-Layer 캐싱 통합 테스트 (2시간)

```dart
// test/features/profile/integration/profile_cache_integration_test.dart
void main() {
  group('Profile 3-Layer Caching Integration', () {
    late UnifiedCacheService cacheService;
    late ProfileRepositoryImpl repository;

    setUp(() async {
      cacheService = UnifiedCacheService();
      await cacheService.init();
      repository = ProfileRepositoryImpl(cacheService);
    });

    tearDown(() async {
      await cacheService.clear();
    });

    test('L1 Memory cache hit <10ms', () async {
      final userId = 'test_user_123';
      final profile = _createMockProfile(userId);

      // Warm up cache
      await repository.updateProfile(profile);

      // Measure L1 hit
      final stopwatch = Stopwatch()..start();
      final result = await repository.getUserProfile(userId);
      stopwatch.stop();

      expect(result.isRight(), true);
      expect(stopwatch.elapsedMilliseconds, lessThan(10));
    });

    test('L2 Hive cache hit 10-30ms', () async {
      final userId = 'test_user_456';
      final profile = _createMockProfile(userId);

      // Warm up L2 (skip L1)
      await repository.updateProfile(profile);
      await cacheService.invalidateL1(ProfileCacheKeys.userProfile(userId));

      // Measure L2 hit
      final stopwatch = Stopwatch()..start();
      final result = await repository.getUserProfile(userId);
      stopwatch.stop();

      expect(result.isRight(), true);
      expect(stopwatch.elapsedMilliseconds, greaterThan(10));
      expect(stopwatch.elapsedMilliseconds, lessThan(30));
    });

    test('L3 Firestore fallback <500ms', () async {
      final userId = 'test_user_789';

      // Clear all caches
      await cacheService.clear();

      // Measure Firestore fetch
      final stopwatch = Stopwatch()..start();
      final result = await repository.getUserProfile(userId);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('Cache invalidation propagates to all layers', () async {
      final userId = 'test_user_999';
      final profile = _createMockProfile(userId);

      // Warm up all layers
      await repository.updateProfile(profile);

      // Verify all layers have data
      final l1 = await cacheService.getL1<UserProfile>(
        ProfileCacheKeys.userProfile(userId),
      );
      final l2 = await cacheService.getL2<UserProfile>(
        ProfileCacheKeys.userProfile(userId),
      );
      expect(l1, isNotNull);
      expect(l2, isNotNull);

      // Invalidate
      await cacheService.invalidate(ProfileCacheKeys.userProfile(userId));

      // Verify all layers are cleared
      final l1After = await cacheService.getL1<UserProfile>(
        ProfileCacheKeys.userProfile(userId),
      );
      final l2After = await cacheService.getL2<UserProfile>(
        ProfileCacheKeys.userProfile(userId),
      );
      expect(l1After, isNull);
      expect(l2After, isNull);
    });
  });
}

UserProfile _createMockProfile(String userId) {
  return UserProfile(
    uid: userId,
    displayName: 'Test User',
    email: 'test@example.com',
    createdAt: DateTime.now(),
    // ... other fields
  );
}
```

#### 2. Widget 테스트 (1시간)

```dart
// test/features/profile/presentation/screens/profile_page_test.dart
void main() {
  group('ProfilePage Widget Tests', () {
    testWidgets('displays profile data correctly', (tester) async {
      final mockProfile = UserProfile(/* ... */);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider('test_user').overrideWith(
              (ref) => AsyncValue.data(mockProfile),
            ),
          ],
          child: MaterialApp(
            home: ProfilePage(userId: 'test_user'),
          ),
        ),
      );

      expect(find.byType(VersusAvatar), findsOneWidget);
      expect(find.text(mockProfile.displayName), findsOneWidget);
      expect(find.byType(VersusProfileStatCard), findsNWidgets(4));
    });

    testWidgets('shows loading indicator while fetching', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider('test_user').overrideWith(
              (ref) => AsyncValue.loading(),
            ),
          ],
          child: MaterialApp(
            home: ProfilePage(userId: 'test_user'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

#### 3. Golden 테스트 (Visual Regression) (1시간)

```dart
// test/features/profile/presentation/screens/profile_page_golden_test.dart
void main() {
  group('ProfilePage Golden Tests', () {
    testWidgets('matches golden file - default state', (tester) async {
      final mockProfile = UserProfile(/* ... */);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider('test_user').overrideWith(
              (ref) => AsyncValue.data(mockProfile),
            ),
          ],
          child: MaterialApp(
            home: ProfilePage(userId: 'test_user'),
          ),
        ),
      );

      await expectLater(
        find.byType(ProfilePage),
        matchesGoldenFile('goldens/profile_page_default.png'),
      );
    });

    testWidgets('matches golden file - with stats', (tester) async {
      final mockProfile = UserProfile(
        /* ... */
        stats: ProfileStats(
          postCount: 42,
          voteCount: 128,
          followerCount: 256,
          followingCount: 64,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider('test_user').overrideWith(
              (ref) => AsyncValue.data(mockProfile),
            ),
          ],
          child: MaterialApp(
            home: ProfilePage(userId: 'test_user'),
          ),
        ),
      );

      await expectLater(
        find.byType(ProfilePage),
        matchesGoldenFile('goldens/profile_page_with_stats.png'),
      );
    });
  });
}
```

---

## 💡 Best Practices

### 1. VersusAvatar 범용 패턴

**재사용 가능한 모든 Feature**:
- Profile: 사용자 프로필 이미지
- Auth: 로그인/회원가입 UI
- Chat: 메시지 발신자 아바타
- Post: 게시물 작성자 아바타
- Voting: 투표 생성자 아바타
- Notifications: 알림 발신자 아바타

**Size Token 가이드**:
```dart
// 리스트 아이템 (작은 화면)
VersusAvatarSize.small   // 32px

// 프로필 카드 (중간 화면)
VersusAvatarSize.medium  // 64px

// 프로필 페이지 (큰 화면)
VersusAvatarSize.large   // 96px

// 상세 페이지 (매우 큰 화면)
VersusAvatarSize.xlarge  // 120px
```

### 2. Stat Card 패턴 재사용 전략

**적용 가능한 다른 Feature**:
- **Voting Feature**: 투표 통계 (찬성/반대/참여자수)
- **Post Feature**: 게시물 통계 (좋아요/댓글/공유)
- **Creation Feature**: 생성 통계 (게시물/투표/미디어)

**일관성 가이드**:
- 아이콘: 통계 유형에 맞는 Material Icons 사용
- 값: 항상 숫자 문자열 (천 단위 콤마: `1,234`)
- 라벨: 단수형 영문 (Posts, Votes, Followers)
- onTap: 해당 통계 상세 페이지로 네비게이션

### 3. 3-Layer 캐싱 Best Practices

**캐시 키 네이밍 규칙**:
```dart
// ✅ GOOD: 명확한 네임스페이스
'profile_$userId'
'profile_stats_$userId'
'avatar_$userId'

// ❌ BAD: 모호한 키
'user_$userId'
'data_$userId'
```

**TTL 가이드라인**:
```dart
// 자주 변경되지 않는 데이터: 긴 TTL
UserProfile: 10분
UserSettings: 30분
Avatar: 60분

// 자주 변경되는 데이터: 짧은 TTL
ProfileStats: 2분
OnlineStatus: 30초
```

**캐시 무효화 타이밍**:
```dart
// 즉시 무효화 (사용자 액션)
- 프로필 수정 → profile_$userId 무효화
- 설정 변경 → user_settings_$userId 무효화
- 아바타 변경 → avatar_$userId 무효화

// 지연 무효화 (백그라운드 동기화)
- 팔로워 수 변경 → profile_stats_$userId (2분 TTL)
- 게시물 수 변경 → profile_stats_$userId (2분 TTL)
```

---

## ✅ 완료 체크리스트

### Phase 2 완료 조건

```
□ VersusAvatar 도입
  □ 컴포넌트 정의 (60 lines)
  □ 12개 사용처 교체
  □ Widget 테스트 작성
  □ Golden 테스트 생성

□ VersusProfileStatCard 도입
  □ 컴포넌트 정의 (50 lines)
  □ 4개 사용처 교체
  □ Extension method 작성
  □ Widget 테스트 작성

□ VersusSettingsTile 도입
  □ 컴포넌트 정의 (40 lines)
  □ 8개 사용처 교체
  □ Widget 테스트 작성

□ Supporting 컴포넌트 적용
  □ VersusButton (18 usages)
  □ VersusTextField (8 usages)
  □ VersusCard (6 usages)
```

### Phase 3 완료 조건

```
□ 3-Layer 캐싱 통합 테스트
  □ L1 Memory <10ms 검증
  □ L2 Hive 10-30ms 검증
  □ L3 Firestore <500ms 검증
  □ 캐시 무효화 테스트

□ Widget 테스트
  □ profile_page_test.dart
  □ edit_profile_page_test.dart
  □ settings_page_test.dart

□ Golden 테스트
  □ profile_page_golden_test.dart
  □ 최소 3개 상태 (default, with_stats, error)

□ 코드 리뷰
  □ 모든 하드코딩 제거 확인
  □ 토큰 사용 100% 확인
  □ 컴포넌트 일관성 확인
```

### 최종 검증

```
□ 메트릭 검증
  □ 토큰 채택률: 88%
  □ 하드코딩: <15 instances
  □ 코드 감소: 2,100줄 (16.9%)
  □ 컴포넌트 재사용: 24회

□ 성능 검증
  □ L1 캐시 히트율 >30%
  □ 전체 캐시 히트율 >60%
  □ 평균 응답 시간 <150ms

□ 품질 검증
  □ flutter analyze (0 errors)
  □ flutter test (모든 테스트 통과)
  □ Golden 테스트 통과

□ 문서화
  □ README 업데이트
  □ Component 문서 작성
  □ Migration 가이드 작성
```

---

## 🔗 다음 단계

**Part 9: Feature Auth 문서**
- Auth Feature: 5% → 95% 토큰 채택
- 39 files, 7,234 lines
- 220 hardcoding instances
- **URGENT** 우선순위 (#1)
- VersusTextField (critical), VersusButton 중점

**전체 문서 시리즈**:
- ✅ Part 1-7: 완료
- ✅ Part 8-1, 8-2: Profile Feature (완료)
- ⏳ Part 9-11: Auth, Notifications, Chat
- ⏳ Part 12-14: Phase Plans, QA, Statistics

---

**Part 8-2 문서 종료** (Profile Feature 컴포넌트 도입 및 구현 가이드)

→ **다음**: Part 9 (Auth Feature - URGENT Priority)
