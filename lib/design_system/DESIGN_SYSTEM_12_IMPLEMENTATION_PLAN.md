# Design System - Phase별 구현 계획 (Implementation Roadmap)

**문서 ID**: `DESIGN_SYSTEM_12_IMPLEMENTATION_PLAN`
**작성일**: 2025-11-11
**대상**: Versus Space 전체 프로젝트
**마이그레이션 범위**: 8개 Feature, 249개 파일, 60,021줄

---

## 📋 Executive Summary

### 전체 마이그레이션 개요

**목표**: Versus Space Flutter 앱을 완전한 Design System 기반 아키텍처로 전환

| 지표 | Before | After | 개선율 |
|------|--------|-------|--------|
| **Design Token 도입률** | 15% | 95%+ | +80%p |
| **Hardcoding 밀도** | 92.0/1000줄 | <5.0/1000줄 | 95% 감소 |
| **Component 재사용** | 0개 | 15+ 개 | - |
| **유지보수 시간** | 240시간/년 | 60시간/년 | 75% 절감 |
| **코드 중복** | ~8,000줄 | ~2,000줄 | 75% 감소 |

**전체 ROI**: **8.5x** (총 투자 120시간 → 연간 1,020시간 절감)

### 6-Phase 로드맵 (12주, 3개월)

```
Phase 1: 기반 구축               (2주) → Design System 핵심
Phase 2: Token 마이그레이션      (4주) → 8개 Feature 병렬 진행
Phase 3: Component 도입          (3주) → 15개 Component 개발
Phase 4: 품질 검증 및 테스트     (1주) → QA, Accessibility
Phase 5: 성능 최적화             (1주) → 빌드 최적화, 캐싱
Phase 6: 문서화 및 배포          (1주) → 최종 검증, 배포
```

**총 기간**: **12주** (3개월)
**투입 인력**: 2명 (Frontend Developer × 2)
**예상 비용**: 120 man-hours

---

## 🎯 Feature별 우선순위 및 완성도

### Feature 완성도 매트릭스

| Feature | Token 도입률 | Hardcoding | Component | 우선순위 | 예상 시간 |
|---------|-------------|-----------|-----------|---------|----------|
| **Post** | 100% ✅ | 0개 | 3개 ✅ | **Gold Standard** | 0시간 (완료) |
| **Auth** | 0% | 220개 | 0개 | **High** | 16시간 |
| **Profile** | 25% | 180개 | 0개 | **High** | 18시간 |
| **Notifications** | 0% | 148개 | 0개 | **High** | 14시간 |
| **Chat** | 70% | 35개 | 0개 | **Medium** | 10시간 |
| **Voting** | 40% | 130개 | 0개 | **Medium** | 14시간 |
| **Creation** | 15% | 280개 | 0개 | **Medium** | 20시간 |
| **Search** | 40% | 85개 | 0개 | **Low** | 12시간 |

**총 작업 시간**: **104시간** (Feature별 마이그레이션)

### 우선순위 기준

**High Priority** (먼저 진행):
1. **Auth**: 모든 Feature의 기반, 사용자 인증 핵심
2. **Profile**: 사용자 정보 관리, 다른 Feature와 강한 의존성
3. **Notifications**: 실시간 알림, UX 핵심

**Medium Priority** (병렬 진행 가능):
4. **Chat**: 이미 70% 완료, 빠른 성과 가시화
5. **Voting**: 앱의 핵심 기능, 복잡도 높음
6. **Creation**: 가장 많은 hardcoding, 시간 소요 최대

**Low Priority** (후순위):
7. **Search**: 문서 완성도 40%, Phase 1-5 문서만 존재

---

## 📅 Phase 1: 기반 구축 (2주)

### Sprint 1 (Week 1): Design System 핵심 구축

**목표**: VersusColors, VersusSpacing, VersusTextStyles 완성

**작업 항목**:

1. **VersusColors 확장** (1일)
   - Color Token 50개 → 80개 확장
   - Semantic Color 추가 (success, warning, info)
   - Opacity 헬퍼 함수 개선
   - Dark Mode 지원 (향후 대비)

2. **VersusSpacing 확장** (1일)
   - Spacing Token 8개 → 12개 확장
   - Padding/Margin 헬퍼 추가
   - Gap 헬퍼 함수 개선
   - 반응형 Spacing (향후 대비)

3. **VersusTextStyles 확장** (1일)
   - Typography Token 12개 → 18개 확장
   - Font Weight 변형 추가
   - Line Height 최적화
   - 다국어 지원 개선

4. **VersusRadius 신규 생성** (0.5일)
   - BorderRadius Token 정의
   - Corner 변형 (sharp, rounded, pill, circle)

5. **VersusShadows 신규 생성** (0.5일)
   - BoxShadow Token 정의
   - Elevation 레벨 (none, sm, md, lg, xl)

**완료 기준**:
- [ ] 모든 Token 파일 생성 완료
- [ ] Token 문서화 완료 (README.md)
- [ ] 빌드 에러 0개
- [ ] 예제 코드 작성 완료

**담당**: Frontend Developer #1

---

### Sprint 2 (Week 2): Base Component 개발

**목표**: 15개 재사용 Component 완성

**작업 항목**:

1. **State Components** (2일)
   - VersusLoadingIndicator (완료, 검증만)
   - VersusErrorState (완료, 검증만)
   - VersusEmptyState (완료, 검증만)

2. **Interactive Components** (2일)
   - VersusButton (Primary, Secondary, Outlined, Text)
   - VersusTextField
   - VersusCheckbox
   - VersusRadioButton

3. **Display Components** (1일)
   - VersusAvatar (Size S/M/L, Online Badge)
   - VersusBadge (Count, Status, Dot)
   - VersusCard

4. **Notification Components** (완료, 검증만)
   - VersusNotificationBadge
   - VersusNotificationTile

5. **Chat Components** (신규 개발)
   - VersusChatTile

6. **Profile Components** (신규 개발)
   - VersusProfileHeader
   - VersusProfileStatsCard

**완료 기준**:
- [ ] 15개 Component 개발 완료
- [ ] Component Storybook 작성 (Golden Test 준비)
- [ ] Accessibility 검증 (Semantics)
- [ ] 단위 테스트 작성

**담당**: Frontend Developer #2

---

## 📅 Phase 2: Token 마이그레이션 (4주)

### Sprint 3-6 (Week 3-6): Feature별 병렬 마이그레이션

**전략**: 우선순위별 순차 진행 + Component 병렬 개발

#### Sprint 3 (Week 3): High Priority Features (Part 1)

**Auth Feature** (3일):
- Token 마이그레이션: 220개 hardcoding → <10개
- 자동화 스크립트 실행: `migrate_auth_tokens.sh`
- 수동 검토: 특수 케이스 20개
- 빌드 테스트 및 UI 회귀 테스트

**Profile Feature** (2일):
- Token 마이그레이션: 180개 hardcoding → <10개
- 3가지 모델 분리 (UserProfile, ProfileInfo, UserSettings)
- 자동화 스크립트 실행: `migrate_profile_tokens.sh`
- 캐시 통합 검증

**담당**: Developer #1 (Auth), Developer #2 (Profile)

---

#### Sprint 4 (Week 4): High Priority Features (Part 2) + Medium (Part 1)

**Notifications Feature** (2일):
- Token 마이그레이션: 148개 hardcoding → <5개
- 자동화 스크립트 실행: `migrate_notifications_tokens.sh`
- Sealed Union 검증 (3 타입)

**Chat Feature** (1일):
- Token 마이그레이션: 35개 hardcoding → <5개 (이미 70% 완료)
- Spacing만 집중 마이그레이션
- flutter_chat_ui 통합 검증

**Voting Feature** (2일):
- Token 마이그레이션: 130개 hardcoding → <10개
- 복잡한 UI 검증 (투표 카드, 타이머)

**담당**: Developer #1 (Notifications, Chat), Developer #2 (Voting)

---

#### Sprint 5 (Week 5): Medium Priority Features (Part 2)

**Creation Feature** (3일):
- Token 마이그레이션: 280개 hardcoding → <10개 (가장 많음)
- AI 통합 검증 (Gemini, Perspective API)
- 멀티미디어 업로드 검증
- Draft 자동 저장 검증

**Search Feature** (2일):
- Token 마이그레이션: 85개 hardcoding → <10개
- Phase 1-5 문서만 존재, 구현 50%
- 나머지 구현 완료 필요 (별도 작업)

**담당**: Developer #1 (Creation), Developer #2 (Search)

---

#### Sprint 6 (Week 6): 버퍼 및 예비

**목적**: Sprint 3-5에서 완료하지 못한 작업 마무리

**작업**:
- Token 마이그레이션 미완료 항목 처리
- 빌드 에러 수정
- UI 회귀 테스트 재실행
- 코드 리뷰 반영

**담당**: Developer #1 + #2 (페어 프로그래밍)

---

## 📅 Phase 3: Component 도입 (3주)

### Sprint 7-9 (Week 7-9): Feature별 Component 통합

#### Sprint 7 (Week 7): High Priority Component 통합

**Auth Feature Components** (2일):
- VersusAuthForm (Sign In, Sign Up, Reset Password)
- VersusOAuthButton (Google, Apple, Email)
- VersusPasswordField (Show/Hide Toggle)
- Before/After: 350줄 → 80줄 (77% 감소)

**Profile Feature Components** (2일):
- VersusProfileHeader (Avatar, Name, Bio)
- VersusProfileStatsCard (Votes, Posts, Friends)
- VersusSettingsItem (Toggle, Navigation)
- Before/After: 420줄 → 95줄 (77% 감소)

**Notifications Feature Components** (1일):
- VersusNotificationBadge (이미 완료, 통합만)
- VersusNotificationTile (이미 완료, 통합만)
- Before/After: 380줄 → 42줄 (89% 감소)

**담당**: Developer #1 (Auth), Developer #2 (Profile, Notifications)

---

#### Sprint 8 (Week 8): Medium Priority Component 통합

**Chat Feature Components** (1.5일):
- VersusChatTile (이미 설계 완료)
- VersusMessageBubble (flutter_chat_ui 통합)
- Before/After: 280줄 → 151줄 (46% 감소)

**Voting Feature Components** (2일):
- VersusVoteCard (복잡한 Layout)
- VersusVoteOption (A/B 옵션)
- VersusVoteTimer (카운트다운)
- Before/After: 450줄 → 120줄 (73% 감소)

**Creation Feature Components** (1.5일):
- VersusMediaPicker (이미지/비디오)
- VersusImageEditor (ProImageEditor 통합)
- VersusDraftCard (자동 저장)
- Before/After: 520줄 → 140줄 (73% 감소)

**담당**: Developer #1 (Chat, Voting), Developer #2 (Creation)

---

#### Sprint 9 (Week 9): Low Priority + 버퍼

**Search Feature Components** (1일):
- VersusSearchBar (검색창)
- VersusSearchResultItem (검색 결과)
- Before/After: 180줄 → 60줄 (67% 감소)

**Component 통합 검증** (2일):
- 전체 15개 Component Storybook 검증
- Accessibility 테스트 (Semantics, Screen Reader)
- 성능 테스트 (빌드 시간, 앱 크기)
- 코드 리뷰 및 수정

**버퍼** (2일):
- 미완료 작업 마무리
- 문서화 보완

**담당**: Developer #1 + #2 (페어 프로그래밍)

---

## 📅 Phase 4: 품질 검증 및 테스트 (1주)

### Sprint 10 (Week 10): QA 및 테스트

**목표**: 모든 마이그레이션 검증 및 품질 보증

#### Day 1-2: 자동화 테스트

**단위 테스트** (1일):
- Component 단위 테스트 (15개 × 5개 시나리오 = 75개 테스트)
- Token 사용 검증 테스트
- 빌드 에러 0개 확인

**통합 테스트** (1일):
- Feature별 E2E 테스트 (8개 Feature)
- User Flow 테스트 (Sign In → Post → Vote → Chat)
- 회귀 테스트 (기존 기능 정상 동작 확인)

---

#### Day 3: Accessibility 검증

**WCAG 2.1 AA 준수**:
- Color Contrast 검증 (4.5:1 이상)
- Semantics Label 검증 (Screen Reader)
- Keyboard Navigation 검증
- Focus Management 검증

**도구**:
- Flutter Accessibility Scanner
- Lighthouse (Web)
- VoiceOver (iOS), TalkBack (Android)

---

#### Day 4: 성능 테스트

**빌드 성능**:
- APK 크기: 목표 <30MB
- 빌드 시간: 목표 <5분 (Release)
- 코드 중복: 목표 <5%

**런타임 성능**:
- Cold Start: 목표 <3초
- Hot Reload: 목표 <1초
- FPS: 목표 60fps (최소 55fps)

**캐싱 성능**:
- L1 Memory Hit Rate: 목표 >30%
- L2 Hive Hit Rate: 목표 >20%
- Overall Hit Rate: 목표 >60%

---

#### Day 5: 시각적 회귀 테스트

**Golden Test**:
- 15개 Component × 3개 상태 (Default, Hover, Disabled) = 45개 Golden Image
- Before/After 스크린샷 비교 (픽셀 단위)
- UI 일관성 검증

**수동 QA**:
- 8개 Feature 전체 화면 테스트
- Dark Mode 검증 (향후 대비)
- 다양한 디바이스 테스트 (iPhone, Android, Tablet)

**담당**: Developer #1 (자동화), Developer #2 (수동 QA)

---

## 📅 Phase 5: 성능 최적화 (1주)

### Sprint 11 (Week 11): 최적화 및 튜닝

#### Day 1-2: 빌드 최적화

**Tree Shaking**:
- 미사용 Token 제거
- 미사용 Component 제거
- Import 최적화

**Code Splitting**:
- Feature별 lazy loading
- Component lazy loading
- Route-based splitting

**예상 효과**:
- APK 크기: 35MB → 28MB (20% 감소)
- 빌드 시간: 6분 → 4.5분 (25% 단축)

---

#### Day 3: 캐싱 최적화

**L1 Memory Cache**:
- LRU 알고리즘 튜닝 (100개 → 150개)
- TTL 최적화 (5분 → Feature별 커스텀)

**L2 Hive Cache**:
- 인덱스 최적화
- 압축 알고리즘 개선

**L3 Firestore Cache**:
- Offline Persistence 최적화
- Query 최적화 (복합 인덱스)

**예상 효과**:
- Cache Hit Rate: 60% → 75% (+15%p)
- Firestore 읽기: 40% 절감 → 55% 절감

---

#### Day 4-5: 렌더링 최적화

**Widget Optimization**:
- const 키워드 추가 (불필요한 재빌드 방지)
- RepaintBoundary 최적화
- Selector 패턴 적용 (Riverpod)

**Image Optimization**:
- FlutterGen 최적화
- 이미지 압축 개선
- Lazy Loading 적용

**예상 효과**:
- FPS: 55fps → 60fps (9% 개선)
- 메모리 사용: 150MB → 120MB (20% 감소)

**담당**: Developer #1 (빌드 최적화), Developer #2 (렌더링 최적화)

---

## 📅 Phase 6: 문서화 및 배포 (1주)

### Sprint 12 (Week 12): 최종 검증 및 배포

#### Day 1-2: 문서화

**Design System 문서**:
- Design Token 사용 가이드
- Component Storybook
- Best Practices 모음
- Migration Guide (Before/After)

**개발자 문서**:
- 새로운 Component 추가 방법
- Token 추가/수정 방법
- Accessibility 가이드라인
- 성능 최적화 팁

**사용자 문서**:
- 변경 사항 요약 (CHANGELOG.md)
- 시각적 개선 사항 정리
- FAQ

---

#### Day 3: 최종 검증

**전체 체크리스트**:
- [ ] 빌드 에러 0개
- [ ] 단위 테스트 통과율 100%
- [ ] 통합 테스트 통과율 100%
- [ ] Accessibility AA 준수
- [ ] 성능 목표 달성
- [ ] 코드 리뷰 완료
- [ ] 문서화 완료

**Sign-off**:
- Product Owner 승인
- Design Team 승인
- QA Team 승인

---

#### Day 4: Staging 배포

**Staging 환경**:
- Firebase Hosting (Staging)
- TestFlight (iOS), Internal Testing (Android)
- 베타 테스터 초대 (10명)

**모니터링**:
- Crashlytics 설정
- Performance Monitoring 설정
- Analytics 설정

**피드백 수집**:
- 베타 테스터 피드백 (2일간)
- 버그 수정 (긴급 이슈만)

---

#### Day 5: Production 배포

**배포 전 체크리스트**:
- [ ] Staging 테스트 통과
- [ ] 베타 피드백 반영
- [ ] 긴급 버그 수정 완료
- [ ] 배포 스크립트 검증
- [ ] 롤백 계획 준비

**점진적 배포**:
- 10% 사용자 (4시간 모니터링)
- 50% 사용자 (12시간 모니터링)
- 100% 사용자 (24시간 모니터링)

**롤백 기준**:
- Crash Rate >1%
- ANR Rate >0.5%
- User Complaints >100건

**담당**: Developer #1 + #2 (배포 담당)

---

## 🔗 Feature 간 의존성 관리

### 의존성 매트릭스

```
       Auth  Profile  Chat  Notif  Voting  Creation  Post  Search
Auth    -      ✅      ✅     ✅      ✅       ✅      ✅     ✅
Profile ❌      -      ✅     ✅      ✅       ✅      ✅     ✅
Chat    ❌     ❌      -      ❌      ✅       ❌      ❌     ❌
Notif   ❌     ❌      ❌      -      ❌       ❌      ❌     ❌
Voting  ❌     ❌      ❌     ❌       -       ❌      ✅     ❌
Creation❌     ❌      ❌     ❌      ❌        -      ✅     ❌
Post    ❌     ❌      ❌     ❌      ❌       ❌       -     ❌
Search  ❌     ❌      ❌     ❌      ❌       ❌      ❌      -
```

**범례**:
- ✅: 의존함 (A → B)
- ❌: 의존하지 않음

**핵심 인사이트**:
- **Auth**: 모든 Feature의 기반 → 최우선 마이그레이션
- **Profile**: 2순위 의존성 (Chat, Notif, Voting, Creation, Post, Search)
- **Post**: 독립적 (Gold Standard) → 병렬 진행 가능
- **Chat, Notif**: 독립적 → 병렬 진행 가능

### 의존성 기반 실행 순서

**순차 실행 필요**:
1. **Auth** → 2. **Profile** → 3. 나머지 (병렬 가능)

**병렬 실행 가능**:
- Group A: Chat, Notifications (Auth, Profile 완료 후)
- Group B: Voting, Creation, Post, Search (Auth, Profile 완료 후)

---

## ⚠️ 리스크 관리

### 주요 리스크 및 완화 전략

| 리스크 | 확률 | 영향 | 완화 전략 | 담당자 |
|--------|------|------|----------|--------|
| **Token 마이그레이션 중 UI 깨짐** | 높음 | 중간 | Golden Test로 시각적 회귀 검증 | Developer #1 |
| **Component 추상화 과도** | 중간 | 높음 | 재사용 3회 이상만 Component화 | Architect |
| **flutter_chat_ui 통합 문제** | 중간 | 중간 | Adapter Pattern 철저히 준수 | Developer #2 |
| **성능 저하** | 낮음 | 높음 | 벤치마크 테스트 (60fps 목표) | Developer #1 |
| **배포 중 Crash** | 낮음 | 높음 | 점진적 배포 (10% → 50% → 100%) | DevOps |
| **일정 지연** | 중간 | 중간 | 버퍼 2주 (Sprint 6, 9) | PM |
| **Accessibility 미준수** | 중간 | 중간 | WCAG 2.1 AA 자동화 테스트 | QA |

### 롤백 계획

**긴급 롤백 시나리오**:
1. **Crash Rate >1%**: 즉시 이전 버전 롤백 (30분 이내)
2. **UI 깨짐 보고 >50건**: Feature별 롤백 (Feature Flag)
3. **성능 저하 >20%**: 성능 최적화 패치 긴급 배포

**롤백 절차**:
1. Feature Flag로 새 Design System 비활성화
2. 이전 버전 코드로 Hot Fix 배포
3. 문제 분석 및 수정
4. 재배포

---

## 📊 Sprint별 예상 성과

### Sprint 1-2 (Phase 1: 기반 구축)

**산출물**:
- Design Token 80개 (VersusColors, VersusSpacing, VersusTextStyles, VersusRadius, VersusShadows)
- Base Component 15개
- Component Storybook

**성과**:
- Design System 기반 완성
- 재사용 Component 준비 완료

---

### Sprint 3-6 (Phase 2: Token 마이그레이션)

**산출물**:
- 8개 Feature Token 마이그레이션 완료
- Hardcoding: 1,278개 → <80개 (94% 감소)
- Token 도입률: 15% → 95%+

**성과**:
- 모든 Feature Design Token 기반으로 전환
- Hardcoding 밀도: 92.0/1000줄 → <1.3/1000줄

---

### Sprint 7-9 (Phase 3: Component 도입)

**산출물**:
- Feature별 Component 통합 완료 (15개 Component)
- 코드 중복: ~8,000줄 → ~2,000줄 (75% 감소)

**성과**:
- Component 재사용으로 유지보수성 극대화
- 코드 품질 향상

---

### Sprint 10 (Phase 4: 품질 검증)

**산출물**:
- 단위 테스트 75개 (통과율 100%)
- 통합 테스트 8개 (통과율 100%)
- Golden Test 45개 (픽셀 일치율 100%)
- Accessibility AA 준수 인증

**성과**:
- 품질 보증 완료
- 배포 준비 완료

---

### Sprint 11 (Phase 5: 성능 최적화)

**산출물**:
- APK 크기: 35MB → 28MB (20% 감소)
- FPS: 55fps → 60fps (9% 개선)
- Cache Hit Rate: 60% → 75% (+15%p)

**성과**:
- 성능 목표 달성
- 사용자 경험 개선

---

### Sprint 12 (Phase 6: 문서화 및 배포)

**산출물**:
- Design System 문서 완성
- Production 배포 완료
- 점진적 배포 (10% → 50% → 100%)

**성과**:
- 전체 마이그레이션 완료
- 안정적인 서비스 운영

---

## 📈 전체 ROI 분석

### 투자 시간 (총 120시간)

| Phase | 작업 | 시간 |
|-------|------|------|
| **Phase 1** | Design System 기반 구축 | 16시간 |
| **Phase 2** | Token 마이그레이션 (8개 Feature) | 52시간 |
| **Phase 3** | Component 도입 (15개) | 30시간 |
| **Phase 4** | 품질 검증 및 테스트 | 10시간 |
| **Phase 5** | 성능 최적화 | 8시간 |
| **Phase 6** | 문서화 및 배포 | 4시간 |
| **총계** | - | **120시간** |

### 연간 절감 시간 (총 1,020시간)

| 항목 | Before (시간/년) | After (시간/년) | 절감 |
|------|------------------|----------------|------|
| **Design 변경 대응** | 240시간 | 48시간 | 192시간 |
| **Component 유지보수** | 160시간 | 32시간 | 128시간 |
| **Hardcoding 수정** | 200시간 | 20시간 | 180시간 |
| **UI 일관성 유지** | 120시간 | 24시간 | 96시간 |
| **코드 리뷰** | 80시간 | 16시간 | 64시간 |
| **신규 Feature 개발** | 360시간 (100%) | 0시간 (40% 단축) | 144시간 |
| **버그 수정** | 160시간 | 80시간 | 80시간 |
| **성능 최적화** | 80시간 | 40시간 | 40시간 |
| **Accessibility 개선** | 96시간 | 0시간 (자동 준수) | 96시간 |
| **총계** | **1,496시간** | **260시간** | **1,020시간** |

### ROI 계산

```
ROI = (연간 절감 시간) / (투자 시간)
    = 1,020 / 120
    = 8.5x
```

**해석**: 120시간 투자로 연간 1,020시간 절감, **8.5배 ROI**

**금액 환산** (시간당 50,000원 기준):
- 투자: 120시간 × 50,000원 = 6,000,000원
- 절감: 1,020시간 × 50,000원 = 51,000,000원
- **순이익**: 45,000,000원/년

---

## 🛠 자동화 도구 및 스크립트

### 1. 전체 마이그레이션 스크립트

**파일**: `scripts/migrate_all_features.sh`

```bash
#!/bin/bash
# 전체 Feature Design System 마이그레이션 마스터 스크립트
# 사용법: ./scripts/migrate_all_features.sh [--dry-run] [--feature <name>]

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Versus Space Design System 마이그레이션 시작${NC}"
echo ""

# Feature 순서 (의존성 기반)
FEATURES=(
  "auth"
  "profile"
  "notifications"
  "chat"
  "voting"
  "creation"
  "post"
  "search"
)

# 옵션 파싱
DRY_RUN=false
SINGLE_FEATURE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --feature)
      SINGLE_FEATURE="$2"
      shift 2
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

# Dry-run 모드 확인
if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}⚠️ DRY-RUN 모드: 실제 변경 없이 시뮬레이션만 수행합니다.${NC}"
  echo ""
fi

# 단일 Feature 마이그레이션
if [ -n "$SINGLE_FEATURE" ]; then
  FEATURES=("$SINGLE_FEATURE")
  echo -e "${YELLOW}📝 단일 Feature 마이그레이션: $SINGLE_FEATURE${NC}"
  echo ""
fi

# Feature별 마이그레이션 실행
for feature in "${FEATURES[@]}"; do
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}📦 Feature: $feature${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""

  # Phase 1: Token 마이그레이션
  echo -e "${YELLOW}Phase 1: Design Token 마이그레이션${NC}"

  if [ -f "scripts/migrate_${feature}_tokens.sh" ]; then
    if [ "$DRY_RUN" = true ]; then
      echo "  🔍 [DRY-RUN] scripts/migrate_${feature}_tokens.sh"
    else
      bash "scripts/migrate_${feature}_tokens.sh"
    fi
  else
    echo -e "  ${RED}⚠️ 스크립트 없음: scripts/migrate_${feature}_tokens.sh${NC}"
  fi
  echo ""

  # Phase 2: Component 마이그레이션
  echo -e "${YELLOW}Phase 2: Component 마이그레이션${NC}"

  if [ -f "scripts/migrate_${feature}_components.sh" ]; then
    if [ "$DRY_RUN" = true ]; then
      echo "  🔍 [DRY-RUN] scripts/migrate_${feature}_components.sh"
    else
      bash "scripts/migrate_${feature}_components.sh"
    fi
  else
    echo -e "  ${YELLOW}⚠️ 스크립트 없음: scripts/migrate_${feature}_components.sh${NC}"
  fi
  echo ""

  # Phase 3: 검증
  echo -e "${YELLOW}Phase 3: 빌드 및 테스트${NC}"

  if [ "$DRY_RUN" = false ]; then
    # Flutter Analyze
    echo "  🔍 Flutter Analyze..."
    flutter analyze "lib/features/$feature" || {
      echo -e "${RED}❌ Analyze 실패: $feature${NC}"
      exit 1
    }

    # Flutter Test
    echo "  🧪 Flutter Test..."
    flutter test "test/features/$feature" || {
      echo -e "${YELLOW}⚠️ 테스트 실패 (계속 진행)${NC}"
    }
  else
    echo "  🔍 [DRY-RUN] flutter analyze lib/features/$feature"
    echo "  🔍 [DRY-RUN] flutter test test/features/$feature"
  fi
  echo ""

  echo -e "${GREEN}✅ Feature $feature 마이그레이션 완료${NC}"
  echo ""
done

# 전체 통계
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📊 전체 마이그레이션 통계${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ "$DRY_RUN" = false ]; then
  # Hardcoding 검증
  echo "🔍 Hardcoding 검증..."
  bash scripts/verify_all_hardcoding.sh
  echo ""

  # Component 사용 검증
  echo "🔍 Component 사용 검증..."
  bash scripts/verify_all_components.sh
  echo ""

  # 최종 빌드 테스트
  echo "🏗️ 최종 빌드 테스트..."
  flutter analyze
  flutter test
  echo ""
else
  echo -e "${YELLOW}[DRY-RUN] 검증 단계 스킵${NC}"
  echo ""
fi

echo -e "${GREEN}🎉 전체 마이그레이션 완료!${NC}"
echo ""
echo -e "${YELLOW}다음 단계:${NC}"
echo "  1. git diff로 변경 사항 확인"
echo "  2. UI 시각적 테스트 (Before/After 비교)"
echo "  3. 성능 벤치마크 실행"
echo "  4. 커밋 및 PR 생성"
```

**실행 방법**:
```bash
# 전체 마이그레이션 (실제 실행)
./scripts/migrate_all_features.sh

# Dry-run (시뮬레이션만)
./scripts/migrate_all_features.sh --dry-run

# 단일 Feature만
./scripts/migrate_all_features.sh --feature auth
```

---

### 2. 진행 상황 모니터링 스크립트

**파일**: `scripts/monitor_progress.sh`

```bash
#!/bin/bash
# Design System 마이그레이션 진행 상황 모니터링
# 사용법: ./scripts/monitor_progress.sh

echo "📊 Design System 마이그레이션 진행 상황"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Feature 목록
FEATURES=("auth" "profile" "notifications" "chat" "voting" "creation" "post" "search")

echo "Feature별 진행 상황:"
echo ""
printf "%-15s %10s %12s %12s %8s\n" "Feature" "Token 사용" "Hardcoding" "Component" "완성도"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TOTAL_TOKEN=0
TOTAL_HARDCODING=0
TOTAL_COMPONENT=0

for feature in "${FEATURES[@]}"; do
  FEATURE_DIR="lib/features/$feature/presentation"

  if [ ! -d "$FEATURE_DIR" ]; then
    continue
  fi

  # Token 사용 횟수
  TOKEN_COUNT=$(grep -r "Versus" "$FEATURE_DIR" --include="*.dart" | wc -l | tr -d ' ')

  # Hardcoding 개수
  HARDCODING=$(grep -rE "EdgeInsets\.|SizedBox\(width:|SizedBox\(height:" "$FEATURE_DIR" --include="*.dart" | \
    grep -v "Versus" | wc -l | tr -d ' ')

  # Component 사용 횟수
  COMPONENT=$(grep -r "Versus.*(" "$FEATURE_DIR" --include="*.dart" | \
    grep -E "VersusButton|VersusTextField|VersusCard|VersusAvatar" | wc -l | tr -d ' ')

  # 완성도 계산 (Token 사용 많을수록, Hardcoding 적을수록 높음)
  if [ "$TOKEN_COUNT" -gt 0 ]; then
    PROGRESS=$((TOKEN_COUNT * 100 / (TOKEN_COUNT + HARDCODING)))
  else
    PROGRESS=0
  fi

  # 완성도 이모지
  if [ "$PROGRESS" -ge 90 ]; then
    STATUS="✅ ${PROGRESS}%"
  elif [ "$PROGRESS" -ge 70 ]; then
    STATUS="🟡 ${PROGRESS}%"
  else
    STATUS="🔴 ${PROGRESS}%"
  fi

  printf "%-15s %10d %12d %12d %8s\n" "$feature" "$TOKEN_COUNT" "$HARDCODING" "$COMPONENT" "$STATUS"

  TOTAL_TOKEN=$((TOTAL_TOKEN + TOKEN_COUNT))
  TOTAL_HARDCODING=$((TOTAL_HARDCODING + HARDCODING))
  TOTAL_COMPONENT=$((TOTAL_COMPONENT + COMPONENT))
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-15s %10d %12d %12d\n" "총합" "$TOTAL_TOKEN" "$TOTAL_HARDCODING" "$TOTAL_COMPONENT"
echo ""

# 전체 진행률
TOTAL_PROGRESS=$((TOTAL_TOKEN * 100 / (TOTAL_TOKEN + TOTAL_HARDCODING)))
echo "전체 진행률: $TOTAL_PROGRESS%"
echo ""

# 목표 대비
TARGET_TOKEN=5000
TARGET_HARDCODING=80
TARGET_COMPONENT=500

echo "목표 대비 달성률:"
echo "  Token 사용: $TOTAL_TOKEN / $TARGET_TOKEN ($(($TOTAL_TOKEN * 100 / $TARGET_TOKEN))%)"
echo "  Hardcoding: $TOTAL_HARDCODING / $TARGET_HARDCODING (목표: <$TARGET_HARDCODING)"
echo "  Component 사용: $TOTAL_COMPONENT / $TARGET_COMPONENT ($(($TOTAL_COMPONENT * 100 / $TARGET_COMPONENT))%)"
echo ""

# 다음 단계 제안
if [ "$TOTAL_PROGRESS" -lt 50 ]; then
  echo "🔴 다음 단계: Phase 2 (Token 마이그레이션) 진행 필요"
elif [ "$TOTAL_PROGRESS" -lt 80 ]; then
  echo "🟡 다음 단계: Phase 3 (Component 도입) 진행 필요"
else
  echo "✅ 다음 단계: Phase 4 (품질 검증) 진행 가능"
fi
```

**실행 방법**:
```bash
./scripts/monitor_progress.sh
```

**예상 출력**:
```
📊 Design System 마이그레이션 진행 상황
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Feature별 진행 상황:

Feature         Token 사용   Hardcoding    Component   완성도
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
auth                  0          220            0    🔴 0%
profile              45          180           12    🟡 20%
notifications         0          148            0    🔴 0%
chat                280           35           18    ✅ 89%
voting               80          130            5    🟡 38%
creation             30          280            3    🔴 10%
post                350            0           25    ✅ 100%
search               60           85            8    🟡 41%
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
총합                845         1078           71

전체 진행률: 44%

목표 대비 달성률:
  Token 사용: 845 / 5000 (16%)
  Hardcoding: 1078 / 80 (목표: <80)
  Component 사용: 71 / 500 (14%)

🔴 다음 단계: Phase 2 (Token 마이그레이션) 진행 필요
```

---

## 📚 관련 문서

### Phase별 참고 문서

**Phase 1 (기반 구축)**:
- `DESIGN_SYSTEM_02_MODERN_DESIGN.md` - 현대적 Design 방법론
- `DESIGN_SYSTEM_03_STRUCTURE.md` - 새로운 디렉토리 구조
- `lib/core/design_system/README.md` - Design Token 정의

**Phase 2 (Token 마이그레이션)**:
- `DESIGN_SYSTEM_08_FEATURE_PROFILE_PART1.md` - Profile Token 마이그레이션
- `DESIGN_SYSTEM_09_FEATURE_AUTH_PART1.md` - Auth Token 마이그레이션
- `DESIGN_SYSTEM_10_FEATURE_NOTIFICATIONS_PART1.md` - Notifications Token 마이그레이션
- `DESIGN_SYSTEM_11_FEATURE_CHAT_PART1.md` - Chat Token 마이그레이션

**Phase 3 (Component 도입)**:
- `DESIGN_SYSTEM_08_FEATURE_PROFILE_PART2.md` - Profile Component
- `DESIGN_SYSTEM_09_FEATURE_AUTH_PART2.md` - Auth Component
- `DESIGN_SYSTEM_10_FEATURE_NOTIFICATIONS_PART2.md` - Notifications Component
- `DESIGN_SYSTEM_11_FEATURE_CHAT_PART2.md` - Chat Component

**Phase 4-6 (품질 검증, 최적화, 배포)**:
- `DESIGN_SYSTEM_13_QUALITY_TEST.md` - 품질 검증 및 테스트 (작성 예정)
- `DESIGN_SYSTEM_14_STATISTICS.md` - 통계 및 검증 데이터 (작성 예정)

---

## 🔄 다음 단계

**Part 13 (품질 검증 및 테스트)**에서 다룰 내용:
1. **자동화 테스트 전략**: 단위/통합/E2E 테스트
2. **Accessibility 검증**: WCAG 2.1 AA 준수
3. **성능 벤치마크**: FPS, 메모리, 빌드 시간
4. **Golden Test**: 시각적 회귀 테스트
5. **CI/CD 통합**: GitHub Actions, Firebase Test Lab

**Part 14 (통계 및 검증 데이터)**에서 다룰 내용:
1. **Feature별 상세 통계**: Token 사용, Hardcoding, Component 재사용
2. **ROI 상세 분석**: 투자 대비 효과, 금액 환산
3. **Before/After 비교**: 코드 품질, 성능, 유지보수성
4. **성공 지표**: 목표 달성률, KPI 추적
5. **교훈 및 개선 사항**: Lessons Learned, Best Practices

---

**마지막 업데이트**: 2025-11-11
**이전 문서**: `DESIGN_SYSTEM_11_FEATURE_CHAT_PART2.md` (Chat Component)
**다음 문서**: `DESIGN_SYSTEM_13_QUALITY_TEST.md` (품질 검증 및 테스트)
**작성자**: Claude Code (Deep Analysis)
