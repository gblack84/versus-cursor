# 📚 Notifications Feature 통합 마이그레이션 가이드

> 모든 마이그레이션 문서를 통합한 실행 가능한 마스터 가이드  
> **최종 업데이트**: 2025-01-09 | **버전**: 1.1.0
> **총 예상 시간**: 7일 (56시간) - MASTER_MIGRATION_GUIDE.md와 동기화
> 
> ⚠️ **Note**: 이 문서는 MASTER_MIGRATION_GUIDE.md의 간략 버전입니다.

## 🎯 전체 목표

notifications feature를 완전한 Clean Architecture로 마이그레이션하여:
- ✅ Domain 순수성 확보 (Firebase 의존성 제거)
- ✅ 레이어별 책임 분리 (Domain/Data/Presentation)
- ✅ 테스트 가능성 극대화 (80%+ 커버리지)
- ✅ 유지보수성 향상 (SOLID 원칙 준수)

## 📋 실행 순서 체크리스트

### ✅ Phase 1: Domain 순수화 & UseCase 생성 (Day 1-2)
**예상 시간**: 16시간 (2일)  
**담당 문서**: 
- [DOMAIN_MIGRATION_GUIDE.md](domain/DOMAIN_MIGRATION_GUIDE.md)

#### 체크리스트
- [ ] 현재 상태 분석 (표준 명령어)
  ```bash
  /spawn inventory-scout "--depth 3 --scope lib/features/notifications --line-threshold 200"
  /spawn import-guardian "--scope notifications --mode detect"
  ```
- [ ] DTO 모델 생성 (`data/models/notification_dto.dart`)
- [ ] Domain 모델 순수화 (Firebase 의존성 제거)
- [ ] Mapper 클래스 구현 (`data/mappers/notification_mapper.dart`)
- [ ] 검증
  ```bash
  /spawn import-guardian "--scope notifications/domain --mode detect"
  # Firebase import가 0이어야 함
  ```

### ✅ Phase 2: Data 레이어 & DTO 패턴 (Day 3-4)
**예상 시간**: 16시간 (2일)  
**담당 문서**: [DTO_MIGRATION_GUIDE.md](data/DTO_MIGRATION_GUIDE.md)

#### 체크리스트
- [ ] DTO 패턴 구현 (표준 명령어)
  ```bash
  /spawn struct-weaver "--task dto --source notifications_model.dart --target notification_dto.dart"
  ```
- [ ] RemoteNotificationDatasource 구현
- [ ] LocalNotificationDatasource 구현
- [ ] PostDatasource 구현 (Cross-feature)
- [ ] DI 바인딩 설정
  ```bash
  /spawn di-binder "--feature notifications --port 'IRemoteNotificationDatasource' --adapter 'RemoteNotificationDatasourceImpl' --deps firestore --mode apply"
  ```
- [ ] 검증
  ```bash
  /spawn build-sentinel "quick"
  ```

### ✅ Phase 3: Presentation 레이어 리팩토링 (Day 5-6 오전)
**예상 시간**: 12시간 (1.5일)  
**담당 문서**: [PRESENTATION_MIGRATION_GUIDE.md](presentation/PRESENTATION_MIGRATION_GUIDE.md)

#### 체크리스트
- [ ] Provider 리팩토링 (표준 명령어)
  ```bash
  /spawn code-surgeon "--decompose app_state.dart --extract NotificationState"
  ```
- [ ] UseCase 주입
  ```bash
  /spawn di-binder "--layer presentation --inject UseCases"
  ```

### ✅ Phase 4: App 레이어 통합 & 검증 (Day 6 오후-7)
**예상 시간**: 12시간 (1.5일)  
**담당 문서**: [APP_LAYER_INTEGRATION.md](APP_LAYER_INTEGRATION.md)

#### 체크리스트
- [ ] DI 추상화 (표준 명령어)
  ```bash
  /spawn di-binder "--module notifications --abstract-only"
  ```
- [ ] AppState 분리
  ```bash
  /spawn struct-weaver "--decompose app_state.dart --by-feature"
  ```
- [ ] 최종 검증
  ```bash
  /spawn import-guardian "--scope notifications --mode detect"
  /spawn build-sentinel "full"
  ```

## 🤖 원클릭 실행 스크립트

```bash
#!/bin/bash
# notifications_migration.sh

echo "🚀 Starting Notifications Feature Migration..."

# Phase 1: Domain 순수화 & UseCase 생성
echo "📊 Phase 1: Domain purification..."
/spawn inventory-scout "--depth 3 --scope lib/features/notifications --line-threshold 200"
/spawn import-guardian "--scope notifications --mode detect" > reports/initial_violations.txt
/spawn struct-weaver "--task dto --source notifications_model.dart --target notification_dto.dart"
echo "Review patches and apply if correct"
read -p "Apply patches? (y/n) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git apply patches/struct_weaver_notifications.diff
fi

# Phase 2: Data 레이어 & DTO 패턴
echo "🔄 Phase 2: Data layer implementation..."
/spawn struct-weaver "--task dto --source notifications_model.dart --target notification_dto.dart"
/spawn di-binder "--feature notifications --port 'IRemoteNotificationDatasource' --adapter 'RemoteNotificationDatasourceImpl' --deps firestore --mode apply"
/spawn di-binder "--feature notifications --port 'ILocalNotificationDatasource' --adapter 'LocalNotificationDatasourceImpl' --deps shared_preferences,hive --mode apply"

# Phase 3: Presentation 레이어 리팩토링
echo "🎨 Phase 3: Presentation layer refactoring..."
/spawn code-surgeon "--decompose app_state.dart --extract NotificationState"
/spawn di-binder "--layer presentation --inject UseCases"

# Phase 4: App 레이어 통합 & 검증
echo "🔌 Phase 4: App layer integration..."
/spawn di-binder "--module notifications --abstract-only"
/spawn struct-weaver "--decompose app_state.dart --by-feature"

# Phase 5: Import cleanup & validation
echo "🧹 Phase 5: Cleaning up and validating..."
/spawn import-guardian "--scope notifications --mode fix --apply false"
echo "Review patches/import_guardian_fix.diff"
read -p "Apply import fixes? (y/n) " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git apply patches/import_guardian_fix.diff
fi

# Phase 6: Final validation
echo "✅ Phase 6: Final validation..."
/spawn import-guardian "--scope notifications --mode detect" > reports/final_violations.txt
/spawn build-sentinel "full"

echo "🎉 Migration complete! Check reports/ directory for results."
```

## 📊 진행 상황 추적

### 메트릭 대시보드
| Phase | 작업 | 예상 시간 | 실제 시간 | 상태 | 담당자 |
|-------|------|-----------|-----------|------|--------|
| 1 | Domain 순수화 & UseCase | 16h (2일) | - | ⏳ | - |
| 2 | Data 레이어 & DTO | 16h (2일) | - | ⏳ | - |
| 3 | Presentation 리팩토링 | 12h (1.5일) | - | ⏳ | - |
| 4 | App 레이어 통합 | 12h (1.5일) | - | ⏳ | - |

### 성공 지표
| 지표 | 현재 | 목표 | 달성률 |
|------|------|------|--------|
| Firebase 의존성 (Domain) | 23 | 0 | 0% |
| 테스트 커버리지 | 0% | 80%+ | 0% |
| 아키텍처 준수율 | 35% | 100% | 35% |
| Import 위반 | 107 | 0 | 0% |

## 🔗 관련 문서 링크

### 마이그레이션 가이드
1. [DTO_MIGRATION_GUIDE.md](data/DTO_MIGRATION_GUIDE.md) - DTO 패턴 구현
2. [DOMAIN_PURIFICATION_GUIDE.md](domain/models/DOMAIN_PURIFICATION_GUIDE.md) - Domain 순수화
3. [DATASOURCE_MIGRATION_GUIDE.md](data/datasources/DATASOURCE_MIGRATION_GUIDE.md) - Datasource 레이어
4. [REPOSITORY_MIGRATION_GUIDE.md](data/repositories/REPOSITORY_MIGRATION_GUIDE.md) - Repository 패턴
5. [MIGRATION_GUIDE.md](data/adapters/MIGRATION_GUIDE.md) - Adapter 정리

### 참고 자료
- [SUBAGENTS_MANUAL.md](/docs/SUBAGENTS_MANUAL.md) - 서브에이전트 사용법
- [ARCHITECTURE_RULES.md](/lib/ARCHITECTURE_RULES.md) - 아키텍처 원칙
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) - Uncle Bob

## ⚠️ 주의사항 및 팁

### 마이그레이션 중 주의사항
1. **백업 필수**: 각 Phase 시작 전 git branch/stash
2. **점진적 진행**: 한 번에 모든 것을 바꾸지 말 것
3. **테스트 우선**: 변경 전 테스트 작성
4. **팀 공유**: 각 Phase 완료 시 PR 및 리뷰

### 일반적인 함정
1. **Timestamp 변환**: Firebase Timestamp ↔ DateTime
2. **Null 처리**: Firestore null vs Dart null
3. **Stream 관리**: dispose() 에서 subscription cancel
4. **Query 타입**: Firebase Query를 Domain에 노출하지 않기

### 롤백 전략
```bash
# Phase별 롤백
git stash  # 현재 작업 저장
git checkout HEAD~1  # 이전 커밋으로
# 또는
git revert <commit-hash>  # 특정 커밋 되돌리기
```

## 🎯 예상 효과

### 정량적 효과
- **코드 중복**: 45% → 5% (90% 감소)
- **테스트 커버리지**: 0% → 80%+ (증가)
- **Import 위반**: 107개 → 0개
- **빌드 시간**: 15% 단축 예상
- **번들 크기**: 10-15% 감소

### 정성적 효과
- **유지보수성**: 크게 향상 (레이어 분리)
- **확장성**: Firebase 외 백엔드 지원 가능
- **팀 생산성**: 명확한 구조로 온보딩 용이
- **코드 품질**: SOLID 원칙 100% 준수
- **기술 부채**: 70% 감소

## 📞 지원 및 문의

### 문제 발생 시
1. 에러 로그와 함께 스크린샷 캡처
2. 현재 Phase와 Step 명시
3. 아키텍처 팀에 문의

### 추가 자료 요청
- 특정 Phase 상세 설명
- 코드 예제 추가
- 페어 프로그래밍 세션

---

*이 통합 가이드는 notifications feature의 완전한 Clean Architecture 마이그레이션을 위한 마스터 문서입니다.*  
*모든 개별 가이드를 순서대로 실행하면 성공적인 마이그레이션이 보장됩니다.*  
*문의: Architecture Team*