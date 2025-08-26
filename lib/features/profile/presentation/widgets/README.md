# 🧩 /lib/features/profile/presentation/widgets

> Feature-First Architecture - Profile 위젯 컴포넌트

## 📋 개요

프로필 기능의 **Reusable Widgets Layer**를 담당하는 디렉토리입니다. 재사용 가능한 UI 컴포넌트를 구현하여 일관된 사용자 경험을 제공합니다.

### 🎯 목적
- **재사용성**: 여러 화면에서 사용 가능한 컴포넌트
- **일관성**: 통일된 디자인 시스템 구현
- **모듈화**: 독립적이고 테스트 가능한 위젯
- **성능 최적화**: 효율적인 위젯 트리 구성

## 🏗️ 디렉토리 구조

```
widgets/
├── profile_header.dart          # 프로필 헤더
├── avatar_selector.dart         # 아바타 선택기
├── character_card.dart          # 캐릭터 카드
├── stats_display.dart           # 통계 표시
├── points_badge.dart            # 포인트 뱃지
├── ranking_display.dart         # 순위 표시
├── interest_chip.dart           # 관심사 칩
├── job_selector.dart            # 직업 선택기
├── hobby_grid.dart              # 취미 그리드
├── premium_badge.dart           # 프리미엄 뱃지
├── friend_card.dart             # 친구 카드
├── profile_skeleton.dart        # 스켈레톤 로더
└── empty_state.dart             # 빈 상태 표시
```

## 📂 주요 위젯 구현

### ProfileHeader

**역할**: 프로필 헤더 위젯

**주요 기능**:
- 프로필 사진 표시 (Hero 애니메이션 지원)
- 이름, 직업, 소개 표시
- 포인트, 게시물, 순위 통계
- 레벨 뱃지 표시
- 프리미엄 뱃지 (필요 시)
- 편집 버튼 (선택적)

**Props**:
- profile: ProfileModel 인스턴스
- isEditable: 편집 가능 여부
- onEditPressed: 편집 버튼 클릭 핸들러
- onAvatarTap: 아바타 클릭 핸들러

**UI 구성**:
- 그래디언트 배경
- SafeArea 적용
- 하단 둥근 모서리 (24px)
- 통계 아이템 3개 (포인트, 게시물, 순위)

### AvatarSelector

**역할**: 아바타 선택기 위젯

**주요 기능**:
- 프로필 사진 선택 및 표시
- 카메라/갤러리 선택 지원
- 이미지 크기 최적화 (800x800, 85% 품질)
- 로딩 상태 표시
- 사진 삭제 기능

**Props**:
- currentPhotoUrl: 현재 프로필 사진 URL
- onImageSelected: 이미지 선택 콜백 (Uint8List)
- isLoading: 로딩 상태

**UI 구성**:
- 120x120 원형 컨테이너
- 카메라 아이콘 오버레이
- ModalBottomSheet로 선택 옵션 표시

**의존성**:
- ImagePicker 패키지

### InterestChip

**역할**: 관심사 칩 위젯

**주요 기능**:
- 선택 가능한 칩 UI
- 삭제 가능 칩 옵션
- 아이콘 표시 지원
- 선택 상태에 따른 스타일 변경

**Props**:
- label: 칩 텍스트
- isSelected: 선택 상태
- onTap: 클릭 핸들러
- isDeletable: 삭제 가능 여부
- onDeleted: 삭제 핸들러
- color: 커스텀 색상
- icon: 칩 아이콘

### InterestChipList

**역할**: 관심사 칩 목록 위젯

**주요 기능**:
- 여러 관심사 칩 표시
- 최대 선택 개수 제한
- Wrap 레이아웃으로 자동 줄바꿈
- 빈 상태 메시지 표시

**Props**:
- interests: 전체 관심사 목록
- selectedInterests: 선택된 관심사
- onInterestToggled: 관심사 토글 핸들러
- maxSelection: 최대 선택 개수
- emptyMessage: 빈 상태 메시지

### CharacterCard

**역할**: 캐릭터 카드 위젯

**주요 기능**:
- 캐릭터 이미지 표시
- 레벨 및 희귀도 표시
- 잠금/해제 상태 표시
- 프리미엄 뱃지
- 선택 상태 애니메이션
- 그라데이션 오버레이

**Props**:
- character: CharacterModel 인스턴스
- isSelected: 선택 상태
- onTap: 클릭 핸들러
- showLevel: 레벨 표시 여부
- showLock: 잠금 표시 여부

**UI 구성**:
- AnimatedContainer로 부드러운 전환
- Stack으로 레이어 구성
- 하단 그라데이션으로 텍스트 가독성 향상

**희귀도 아이콘**:
- legendary: 주황색 만성
- epic: 보라색 반성
- rare: 파란색 빈성
- common: 회색 원

### ProfileSkeleton

**역할**: 프로필 스켈레톤 로더

**주요 기능**:
- 프로필 로딩 중 표시
- Shimmer 효과로 로딩 애니메이션
- 실제 레이아웃과 동일한 구조

**UI 구성**:
- 헤더 스켈레톤 (250px 높이)
- 통계 카드 스켈레톤 (4개 항목)
- 콘텐츠 리스트 스켈레톤 (5개 항목)

**색상**:
- baseColor: Colors.grey[300]
- highlightColor: Colors.grey[100]

**의존성**:
- shimmer 패키지

## 🎨 위젯 사용 가이드

### 기본 사용법

**ProfileHeader 사용**:
- profile 필수 전달
- isEditable로 편집 버튼 표시 제어
- onEditPressed로 편집 화면 이동
- onAvatarTap으로 아바타 옵션 표시

**InterestChipList 사용**:
- interests: 전체 관심사 목록
- selectedInterests: 현재 선택된 목록
- onInterestToggled: 토글 핸들러
- maxSelection: 최대 선택 개수 제한
- emptyMessage: 빈 상태 메시지

**CharacterCard 사용**:
- GridView.builder와 함께 사용
- crossAxisCount: 3 (3열 그리드)
- childAspectRatio: 0.8 (세로가 약간 길게)
- isSelected로 선택 상태 표시
- showLevel/showLock로 요소 표시 제어

## 🧪 테스트 전략

### Widget 테스트

**테스트 커버리지**:
- 레이베일 표시 확인
- 선택 상태 변경 확인
- 클릭 이벤트 테스트
- 삭제 기능 테스트
- 최대 선택 제한 테스트

**테스트 샘플**:
- InterestChip 테스트: 레이벨 표시, 선택 상태 변경
- CharacterCard 테스트: 잠금 상태, 프리미엄 뱃지
- ProfileHeader 테스트: 통계 표시, Hero 애니메이션

**Mock 객체**:
- MockProfileModel
- MockCharacterModel
- MockImagePicker

## ✅ 체크리스트

### 구현 완료
- [ ] ProfileHeader
- [ ] AvatarSelector
- [ ] CharacterCard
- [ ] InterestChip
- [ ] StatsDisplay
- [ ] PointsBadge
- [ ] RankingDisplay
- [ ] JobSelector
- [ ] HobbyGrid
- [ ] PremiumBadge
- [ ] FriendCard
- [ ] ProfileSkeleton
- [ ] EmptyState

### 구현 예정
- [ ] AchievementBadge
- [ ] LevelProgressBar
- [ ] ProfileShareCard

## 📚 참고 자료

- [Flutter Widgets Catalog](https://flutter.dev/docs/development/ui/widgets)
- [Material Design Components](https://material.io/components)
- [Custom Widgets Best Practices](https://flutter.dev/docs/development/ui/widgets/intro)

---

*이 문서는 Feature-First Architecture의 Profile 기능 위젯 가이드입니다.*
*최종 업데이트: 2025-08-25*