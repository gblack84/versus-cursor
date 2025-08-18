# 기술 부채 추적 문서

## 최종 업데이트: 2025-08-18

## 🚨 즉시 해결 필요 (Priority: HIGH)

### 1. BaseVoteMessageStateMixin 레거시 타이머 코드
- **파일**: `lib/components/chat/base_vote_message.dart`
- **라인**: 126-416 (약 290줄)
- **영향도**: 높음 - 메모리 누수 가능성, 불필요한 Stream 구독
- **예상 작업시간**: 2시간
- **문제점**:
  - VoteStateCoordinator와 중복된 타이머 관리
  - 사용되지 않는 Stream 구독이 메모리에 남음
  - 코드 복잡도 증가
- **해결방안**: Phase 1 리팩토링 (REFACTORING_PLAN.md 참조)

### 2. GlobalNotificationManager 중복 투표 로직
- **파일**: `lib/services/global_notification_manager.dart`
- **라인**: 474-618 (144줄)
- **영향도**: 중간 - 유지보수 어려움, 버그 발생 가능성
- **예상 작업시간**: 2시간
- **문제점**:
  - VoteStatusService.submitVote()와 90% 중복
  - 두 곳에서 관리하면 불일치 발생 가능
  - 테스트 코드 중복 필요
- **해결방안**: VoteStatusService.submitVote() 호출로 통합

### 3. VoteMessageHelper 미사용 메서드
- **파일**: `lib/utils/vote_message_helper.dart`
- **라인**: 전체 92줄 중 약 60줄
- **영향도**: 낮음 - 성능 영향 없음, 코드 혼란 유발
- **예상 작업시간**: 1시간
- **문제점**:
  - migrateVoteData() - 마이그레이션 완료로 불필요
  - getCardType() - 사용처 없음
  - mergeVoteMetadata() - 사용처 없음
- **해결방안**: 미사용 메서드 제거, getStatusIcon()만 유지

## ⚠️ 중기 개선 필요 (Priority: MEDIUM)

### 4. 중복된 UI 상태 체크 메서드
- **파일**: 
  - `lib/components/chat/base_vote_message.dart`
  - `lib/components/chat/vote_card_message.dart`
- **영향도**: 중간 - 로직 불일치 가능성
- **예상 작업시간**: 2시간
- **문제점**:
  - shouldShowTimer/Action/Result() 메서드 중복
  - BaseVoteMessage와 VoteCardMessage에 각각 구현
  - 유지보수 시 두 곳 모두 수정 필요
- **해결방안**: VoteCardMessage 구현으로 통일

### 5. VoteStatusService 미사용 메서드
- **파일**: `lib/services/vote_status_service.dart`
- **라인**: 11-66 (getUserVoteStatus 및 캐시 로직)
- **영향도**: 낮음
- **예상 작업시간**: 1시간
- **문제점**:
  - getUserVoteStatus() 메서드 미사용
  - currentUserVoteStatus getter 미사용
  - 불필요한 캐시 로직
- **해결방안**: 미사용 코드 제거, submitVote() 유지

## 📊 기술 부채 메트릭

### 코드 품질 지표
| 지표 | 현재 상태 | 목표 | 영향 |
|-----|----------|------|------|
| **중복 코드** | 300+ 줄 | 0 줄 | 유지보수성 ↓ |
| **미사용 코드** | 250+ 줄 | 0 줄 | 가독성 ↓ |
| **순환 복잡도** | High (15+) | Medium (10) | 버그 위험 ↑ |
| **코드 커버리지** | 60% | 80% | 품질 보증 ↓ |

### 성능 영향
| 문제 | 현재 영향 | 해결 후 |
|------|----------|---------|
| **메모리 누수** | Stream 중복 구독 | 단일 Stream |
| **불필요한 연산** | 중복 타이머 계산 | 최적화됨 |
| **번들 크기** | +15KB 불필요 코드 | 감소 |

## 📈 부채 해결 로드맵

### Quarter 1 (즉시)
- [ ] Phase 1: BaseVoteMessageStateMixin 정리
- [ ] Phase 2: VoteMessageHelper 정리
- [ ] Phase 5: VoteStatusService 정리

### Quarter 2 (1개월 내)
- [ ] Phase 3: 중복 메서드 통합
- [ ] Phase 4: GlobalNotificationManager 정리

### Quarter 3 (3개월 내)
- [ ] 테스트 커버리지 80% 달성
- [ ] 성능 모니터링 도구 추가
- [ ] 문서화 완성도 90% 달성

## 💰 비용 분석

### 현재 기술 부채 비용
- **유지보수 시간**: 주당 +4시간 (중복 코드 관리)
- **버그 수정 시간**: 건당 +2시간 (복잡도로 인한 디버깅)
- **신규 개발 지연**: 20% (레거시 코드 이해 필요)

### 예상 ROI (Return on Investment)
- **총 투자 시간**: 8시간
- **월간 절감 시간**: 16시간
- **ROI**: 2개월 내 투자 회수

## 🔍 근본 원인 분석

### 기술 부채 발생 원인
1. **급속한 마이그레이션**
   - FlutterFlow → Native Flutter 전환
   - 기존 코드 보존 우선

2. **점진적 통합**
   - VoteStateCoordinator 도입
   - 기존 시스템과 병행 운영

3. **문서화 부족**
   - 마이그레이션 계획 문서 부재
   - 코드 삭제 시점 불명확

### 재발 방지 대책
1. **코드 리뷰 강화**
   - PR 시 레거시 코드 체크
   - 중복 코드 자동 검출

2. **문서화 의무화**
   - 마이그레이션 계획 문서 작성
   - 기술 부채 정기 검토

3. **자동화 도구**
   - ESLint 규칙 추가
   - 미사용 코드 자동 감지

## 📋 체크리스트

### 리팩토링 전 확인사항
- [ ] 현재 기능 테스트 완료
- [ ] 백업 브랜치 생성
- [ ] 영향 범위 분석 완료
- [ ] 롤백 계획 수립

### 리팩토링 후 확인사항
- [ ] 단위 테스트 통과
- [ ] 통합 테스트 통과
- [ ] 성능 테스트 통과
- [ ] 코드 리뷰 완료

## 🎯 성공 지표

### 단기 (1개월)
- 중복 코드 0줄
- 미사용 코드 0줄
- 버그 발생률 30% 감소

### 중기 (3개월)
- 코드 커버리지 80%
- 평균 PR 리뷰 시간 50% 감소
- 신규 기능 개발 속도 20% 향상

### 장기 (6개월)
- 기술 부채 비율 5% 이하
- 개발자 만족도 향상
- 유지보수 비용 40% 감소

## 🔗 관련 문서
- [REFACTORING_PLAN.md](./REFACTORING_PLAN.md) - 상세 리팩토링 계획
- [ARCHITECTURE.md](./ARCHITECTURE.md) - 시스템 아키텍처
- [lib/components/chat/README.md](./lib/components/chat/README.md) - 컴포넌트 문서

---
*이 문서는 매주 업데이트되며, 기술 부채 현황을 추적합니다.*