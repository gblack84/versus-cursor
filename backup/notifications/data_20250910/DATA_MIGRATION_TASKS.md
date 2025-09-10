# 📋 Notifications Data 레이어 마이그레이션 실행 태스크

> **생성일**: 2025-01-09  
> **최종 수정**: 2025-01-09  
> **버전**: 1.0.0  
> **총 예상 시간**: 16시간 (2일 작업)  
> **우선순위**: HIGH - Domain 레이어 완료 후 필수 진행
> **현재 상태**: 시작 전 ⏳ | Domain 레이어 100% 완료 ✅

## 📌 핵심 요약

### 마이그레이션 범위
- **Data 레이어 구조화**: DTO, Mapper, DataSource, Repository 구현
- **Firebase 격리**: 모든 Firebase 로직을 DataSource로 캡슐화
- **Cross-feature 처리**: Posts와의 의존성 인터페이스화
- **DI 설정**: GetIt을 통한 의존성 주입 구성

### 서브에이전트 활용 전략
```yaml
주요 서브에이전트:
  - inventory-scout: 현재 상태 분석 및 위반 탐지
  - repo-mover: 레거시 코드 이동 및 구조화
  - struct-weaver: 매퍼 생성 및 상태 분리
  - di-binder: DI 바인딩 자동 생성
  - import-guardian: import 위반 검사 및 수정
  - build-sentinel: 빌드 및 테스트 검증
```

## 🔍 현재 상태 분석

### Data 레이어 현황
```yaml
현재 구조:
  lib/features/notifications/data/
  ├── adapters/
  │   ├── global_notification_manager.dart  # 493줄, UI+Data 혼재
  │   ├── notification_service.dart         # 255줄, Firebase 직접 호출
  │   └── target_audience_service.dart      # 272줄, Posts 직접 접근
  ├── repositories/
  │   └── notification_repository_impl.dart # 284줄, 데이터 접근 포함
  └── datasources/
      └── README.md                          # 구현 없음 ⚠️

필요 구조:
  lib/features/notifications/data/
  ├── models/           # DTO 모델
  ├── mappers/          # Domain ↔ DTO 변환
  ├── datasources/      # Firebase 격리
  ├── repositories/     # 조합 로직만
  └── services/         # 비즈니스 로직만
```

### 의존성 분석
- **Firebase 직접 호출**: 15개 위치에서 FirebaseFirestore.instance 사용
- **Cross-feature**: Posts feature에 3개 직접 의존
- **Domain 모델 준비**: ✅ 100% 완료 (NotificationEntity, VoteNotification 등)

---

## 📋 Phase 1: 인벤토리 및 베이스라인 설정 (1시간)

### Task 1.1: 현재 상태 스캔 및 분석 (30분)

#### 1.1.1 Inventory Scout 실행
- [ ] **서브에이전트 실행**:
  ```bash
  /spawn inventory-scout "--depth 3 --scope lib/features/notifications/data --line-threshold 200"
  ```
- [ ] **출력 확인**: 
  - [ ] `reports/inventory.json` 생성 확인
  - [ ] `candidates_decompose.txt` 큰 파일 목록 확인
  - [ ] `violations.txt` 아키텍처 위반 확인
- [ ] **문제 식별**:
  - [ ] Firebase 직접 호출 위치 기록
  - [ ] 300줄 이상 파일 목록화
  - [ ] Cross-feature 의존성 파악

#### 1.1.2 Import Guardian 베이스라인
- [ ] **서브에이전트 실행**:
  ```bash
  /spawn import-guardian "--scope notifications/data --mode detect"
  ```
- [ ] **위반 리포트 분석**:
  - [ ] Firebase imports 개수 확인
  - [ ] Domain 레이어 직접 import 확인  
  - [ ] Cross-feature import 확인
- [ ] **문서화**: 위반 내역을 `reports/baseline_violations.md`에 기록

### Task 1.2: 마이그레이션 계획 수립 (30분)

#### 1.2.1 우선순위 결정
- [ ] **영향도 분석**:
  - [ ] notification_service.dart - HIGH (핵심 서비스)
  - [ ] global_notification_manager.dart - HIGH (UI 의존)
  - [ ] target_audience_service.dart - MEDIUM (Posts 의존)
  - [ ] notification_repository_impl.dart - HIGH (중앙 저장소)
- [ ] **작업 순서 결정**: DTO → DataSource → Repository → Service

#### 1.2.2 백업 및 브랜치 생성
- [ ] **Git 브랜치 생성**: `feature/notifications-data-migration`
- [ ] **백업 디렉토리 생성**: `backup/notifications/data/`
- [ ] **현재 파일 백업**:
  ```bash
  cp -r lib/features/notifications/data backup/notifications/data_$(date +%Y%m%d)
  ```

---

## 📋 Phase 2: DTO 모델 및 Mapper 구현 (3시간)

### Task 2.1: DTO 모델 생성 (1시간)

#### 2.1.1 NotificationDto 기본 모델
- [ ] **파일 생성**: `data/models/notification_dto.dart`
- [ ] **구현 내용**:
  ```dart
  class NotificationDto {
    final String? id;
    final String? userId;
    final String? type;
    final Map<String, dynamic>? data;
    final Timestamp? createdAt;  // Firebase Timestamp
    final bool? isRead;
    
    // fromJson, toJson 메서드
    // fromFirestore, toFirestore 팩토리
  }
  ```
- [ ] **검증**: JSON 직렬화 테스트

#### 2.1.2 타입별 DTO 생성
- [ ] **파일 생성**: `data/models/vote_notification_dto.dart`
  - [ ] VoteNotificationDto 구현
  - [ ] targetAudience 필드 포함
  - [ ] voteOptions Map 구조
- [ ] **파일 생성**: `data/models/system_notification_dto.dart`
- [ ] **파일 생성**: `data/models/social_notification_dto.dart`

#### 2.1.3 DTO 유틸리티
- [ ] **파일 생성**: `data/models/dto_extensions.dart`
  - [ ] Timestamp ↔ DateTime 변환
  - [ ] Null safety 처리
  - [ ] Map<String, dynamic> 헬퍼

### Task 2.2: Mapper 구현 (1.5시간)

#### 2.2.1 StructWeaver로 Mapper 생성
- [ ] **서브에이전트 실행**:
  ```bash
  /spawn struct-weaver "--task mapper --mode detect --source lib/features/notifications/data"
  ```
- [ ] **패치 리뷰**: `patches/struct_weaver_mapper.diff` 확인
- [ ] **패치 적용 결정**: 유용한 부분만 선택적 적용

#### 2.2.2 NotificationMapper 구현
- [ ] **파일 생성**: `data/mappers/notification_mapper.dart`
- [ ] **구현 내용**:
  ```dart
  class NotificationMapper {
    static NotificationEntity toDomain(NotificationDto dto) {
      switch(dto.type) {
        case 'votingRequest':
          return _toVoteNotification(dto);
        case 'system':
          return _toSystemNotification(dto);
        case 'social':
          return _toSocialNotification(dto);
        default:
          throw UnknownNotificationTypeException(dto.type);
      }
    }
    
    static NotificationDto toDto(NotificationEntity entity) {
      // Domain → DTO 변환
    }
  }
  ```
- [ ] **단위 테스트 작성**: `test/.../mappers/notification_mapper_test.dart`

#### 2.2.3 타입별 Mapper 구현
- [ ] **VoteNotificationMapper**: targetAudience 변환 로직
- [ ] **SystemNotificationMapper**: priority 매핑
- [ ] **SocialNotificationMapper**: actionType 변환

### Task 2.3: Mapper 검증 (30분)

#### 2.3.1 양방향 변환 테스트
- [ ] **테스트 시나리오**:
  - [ ] Domain → DTO → Domain (데이터 무손실)
  - [ ] Null 값 처리
  - [ ] 날짜 변환 정확성
  - [ ] 중첩 객체 변환
- [ ] **테스트 실행**: `flutter test test/features/notifications/data/mappers`
- [ ] **커버리지 확인**: 80% 이상

---

## 📋 Phase 3: DataSource 레이어 구현 (4시간)

### Task 3.1: DataSource 인터페이스 정의 (30분)

#### 3.1.1 Remote DataSource 인터페이스
- [ ] **파일 생성**: `data/datasources/i_remote_notification_datasource.dart`
- [ ] **메서드 정의**:
  ```dart
  abstract class IRemoteNotificationDatasource {
    Stream<List<Map<String, dynamic>>> watchUserNotifications({
      required String userId,
      String? type,
      bool? unreadOnly,
    });
    Future<Map<String, dynamic>?> getNotification(String id);
    Future<String> createNotification(Map<String, dynamic> data);
    Future<void> updateNotification(String id, Map<String, dynamic> updates);
    Future<void> deleteNotification(String id);
    Future<void> batchUpdate(List<BatchUpdateRequest> requests);
  }
  ```

#### 3.1.2 Local DataSource 인터페이스
- [ ] **파일 생성**: `data/datasources/i_local_notification_datasource.dart`
- [ ] **캐싱 메서드 정의**:
  - [ ] getCachedNotifications
  - [ ] cacheNotifications
  - [ ] clearCache
  - [ ] getLastCacheTime

### Task 3.2: Remote DataSource 구현 (2시간)

#### 3.2.1 Firebase DataSource 구현
- [ ] **파일 생성**: `data/datasources/remote/firebase_notification_datasource.dart`
- [ ] **RepoMover로 코드 이동**:
  ```bash
  /spawn repo-mover "--feature notifications --mode dry-run --include firebase"
  ```
- [ ] **패치 리뷰 후 적용**:
  ```bash
  /spawn repo-mover "--feature notifications --mode apply --include firebase"
  ```

#### 3.2.2 Firebase 로직 이동
- [ ] **notification_service.dart에서 이동**:
  - [ ] _notificationListener 메서드 → watchUserNotifications
  - [ ] createVoteRequestMessage → createNotification
  - [ ] updateVoteMessageStatus → updateNotification
- [ ] **repository_impl.dart에서 이동**:
  - [ ] Firebase 직접 호출 부분 추출
  - [ ] Query 빌더 로직 이동

#### 3.2.3 Stream 관리 구현
- [ ] **StreamController 설정**
- [ ] **에러 처리 로직**
- [ ] **자동 재연결 메커니즘**
- [ ] **메모리 누수 방지 (dispose)**

### Task 3.3: Local DataSource 구현 (1시간)

#### 3.3.1 SharedPreferences DataSource
- [ ] **파일 생성**: `data/datasources/local/shared_prefs_notification_datasource.dart`
- [ ] **구현**:
  - [ ] JSON 직렬화 저장
  - [ ] 만료 시간 기반 캐시
  - [ ] 사용자별 키 관리
  - [ ] 최대 캐시 크기 제한

#### 3.3.2 Hive DataSource (선택)
- [ ] **파일 생성**: `data/datasources/local/hive_notification_datasource.dart`
- [ ] **Hive 어댑터 생성**
- [ ] **박스 초기화 로직**
- [ ] **압축 및 암호화 설정**

### Task 3.4: Cross-feature DataSource (30분)

#### 3.4.1 Post DataSource 인터페이스
- [ ] **파일 생성**: `data/datasources/cross/i_post_datasource.dart`
- [ ] **Posts feature 접근 격리**:
  ```dart
  abstract class IPostDatasource {
    Future<Map<String, dynamic>?> getPost(String postId);
    Future<void> updatePostNotificationStatus(String postId, bool sent);
  }
  ```
- [ ] **구현체는 Posts feature에서 제공하도록 설계**

---

## 📋 Phase 4: Repository 리팩토링 (3시간)

### Task 4.1: Repository 구현체 리팩토링 (2시간)

#### 4.1.1 기존 Repository 분석
- [ ] **코드 분석**:
  ```bash
  /spawn inventory-scout "--file lib/features/notifications/data/repositories/notification_repository_impl.dart"
  ```
- [ ] **Firebase 직접 호출 제거 대상 식별**
- [ ] **싱글톤 패턴 제거 계획**

#### 4.1.2 새 Repository 구현
- [ ] **파일 수정**: `data/repositories/notification_repository_impl.dart`
- [ ] **의존성 주입 생성자 추가**:
  ```dart
  class NotificationRepositoryImpl implements INotificationRepository {
    final IRemoteNotificationDatasource _remoteDatasource;
    final ILocalNotificationDatasource _localDatasource;
    final NotificationMapper _mapper;
    
    NotificationRepositoryImpl({
      required IRemoteNotificationDatasource remoteDatasource,
      required ILocalNotificationDatasource localDatasource,
      required NotificationMapper mapper,
    });
  }
  ```

#### 4.1.3 메서드 구현
- [ ] **watchNotifications 구현**:
  - [ ] DataSource Stream 구독
  - [ ] DTO → Domain 변환
  - [ ] 캐시 업데이트
- [ ] **getNotification 구현**:
  - [ ] 캐시 우선 확인
  - [ ] Remote 폴백
  - [ ] 에러 처리
- [ ] **markAsRead 구현**:
  - [ ] Remote 업데이트
  - [ ] Local 캐시 동기화

### Task 4.2: 캐싱 전략 구현 (30분)

#### 4.2.1 캐시 정책 정의
- [ ] **캐시 TTL**: 30분
- [ ] **캐시 크기**: 사용자당 최대 100개
- [ ] **캐시 키 전략**: `notifications_${userId}_${type}`
- [ ] **무효화 정책**: 쓰기 시 자동 무효화

#### 4.2.2 캐시 로직 구현
- [ ] **Read-through 캐시**
- [ ] **Write-through 캐시**
- [ ] **Background sync**
- [ ] **Offline 지원**

### Task 4.3: Repository 테스트 (30분)

#### 4.3.1 Mock DataSource 생성
- [ ] **파일 생성**: `test/.../mocks/mock_datasources.dart`
- [ ] **Mockito 설정**
- [ ] **기본 동작 정의**

#### 4.3.2 Repository 테스트
- [ ] **캐시 히트/미스 테스트**
- [ ] **에러 처리 테스트**
- [ ] **동시성 테스트**
- [ ] **메모리 누수 테스트**

---

## 📋 Phase 5: Service/Adapter 정리 (2시간)

### Task 5.1: NotificationService 리팩토링 (1시간)

#### 5.1.1 Firebase 직접 호출 제거
- [ ] **Import Guardian 실행**:
  ```bash
  /spawn import-guardian "--file lib/features/notifications/data/adapters/notification_service.dart --mode fix"
  ```
- [ ] **패치 리뷰**: `patches/import_guardian_notification_service.diff`
- [ ] **패치 적용**

#### 5.1.2 Repository 사용으로 변경
- [ ] **파일 수정**: `data/adapters/notification_service.dart`
- [ ] **변경 내용**:
  - [ ] Firebase imports 제거
  - [ ] Repository 주입
  - [ ] Stream 변환 로직
  - [ ] 비즈니스 로직만 유지

### Task 5.2: GlobalNotificationManager 분리 (1시간)

#### 5.2.1 StructWeaver로 분해
- [ ] **서브에이전트 실행**:
  ```bash
  /spawn struct-weaver "--task state --source lib/features/notifications/data/adapters/global_notification_manager.dart"
  ```
- [ ] **분리 계획 확인**: UI 로직과 데이터 로직 분리

#### 5.2.2 Presentation으로 UI 로직 이동
- [ ] **UI 관련 코드 추출**:
  - [ ] showDialog 로직
  - [ ] Widget 빌드 로직
  - [ ] Navigation 로직
- [ ] **파일 생성**: `presentation/managers/notification_ui_manager.dart`
- [ ] **Data 레이어에는 비즈니스 로직만 유지**

---

## 📋 Phase 6: DI 설정 및 통합 (2시간)

### Task 6.1: DI Binder 설정 (1시간)

#### 6.1.1 DataSource 바인딩
- [ ] **서브에이전트 실행**:
  ```bash
  /spawn di-binder "--feature notifications --port 'IRemoteNotificationDatasource' --adapter 'FirebaseNotificationDatasource' --deps 'FirebaseFirestore' --mode detect"
  ```
- [ ] **패치 리뷰 및 적용**

#### 6.1.2 Repository 바인딩
- [ ] **서브에이전트 실행**:
  ```bash
  /spawn di-binder "--feature notifications --port 'INotificationRepository' --adapter 'NotificationRepositoryImpl' --deps 'IRemoteNotificationDatasource,ILocalNotificationDatasource,NotificationMapper' --mode apply"
  ```

#### 6.1.3 Service 바인딩
- [ ] **NotificationService DI 설정**
- [ ] **Mapper 싱글톤 등록**
- [ ] **Cross-feature 의존성 설정**

### Task 6.2: 통합 테스트 (1시간)

#### 6.2.1 Build Sentinel 실행
- [ ] **Quick 빌드 테스트**:
  ```bash
  /spawn build-sentinel "quick"
  ```
- [ ] **에러 수정**:
  - [ ] Import 에러
  - [ ] 타입 불일치
  - [ ] Null safety 이슈

#### 6.2.2 Full 테스트
- [ ] **전체 테스트 실행**:
  ```bash
  /spawn build-sentinel "full"
  ```
- [ ] **테스트 통과 확인**:
  - [ ] Unit tests
  - [ ] Widget tests
  - [ ] Integration tests

---

## 📋 Phase 7: 검증 및 마무리 (1시간)

### Task 7.1: Import Guardian 최종 검증 (30분)

#### 7.1.1 전체 스캔
- [ ] **서브에이전트 실행**:
  ```bash
  /spawn import-guardian "--scope notifications --mode detect"
  ```
- [ ] **위반 사항 확인**: 0 violations 목표

#### 7.1.2 위반 수정
- [ ] **자동 수정 적용**:
  ```bash
  /spawn import-guardian "--scope notifications --mode fix --apply"
  ```
- [ ] **수동 수정 필요 항목 처리**

### Task 7.2: 문서화 및 정리 (30분)

#### 7.2.1 마이그레이션 보고서 작성
- [ ] **파일 생성**: `reports/data_migration_complete.md`
- [ ] **내용 포함**:
  - [ ] 변경된 파일 목록
  - [ ] 삭제된 파일 목록
  - [ ] 새로 생성된 파일 목록
  - [ ] 테스트 커버리지
  - [ ] 성능 개선 지표

#### 7.2.2 README 업데이트
- [ ] **Data 레이어 README 업데이트**
- [ ] **아키텍처 다이어그램 추가**
- [ ] **사용 예제 추가**

---

## 🔍 검증 체크리스트

### 서브에이전트 검증
- [ ] **inventory-scout**: 큰 파일 0개 (300줄 이하)
- [ ] **import-guardian**: 위반 0개
- [ ] **build-sentinel**: 모든 테스트 통과
- [ ] **struct-weaver**: 매퍼 정상 동작

### 코드 품질 검증
- [ ] Firebase import가 DataSource에만 존재
- [ ] Repository에 비즈니스 로직 없음
- [ ] Service에 데이터 접근 로직 없음
- [ ] 모든 의존성 주입 사용
- [ ] 테스트 커버리지 70% 이상

### 아키텍처 준수
- [ ] Clean Architecture 레이어 분리
- [ ] 의존성 방향 (Data → Domain)
- [ ] 인터페이스 통한 의존성 역전
- [ ] Cross-feature 격리

---

## 📊 진행 상황 추적

### Phase별 진행률
```yaml
Phase 1 (인벤토리): [ ] 0%
Phase 2 (DTO/Mapper): [ ] 0%
Phase 3 (DataSource): [ ] 0%
Phase 4 (Repository): [ ] 0%
Phase 5 (Service): [ ] 0%
Phase 6 (DI 통합): [ ] 0%
Phase 7 (검증): [ ] 0%

전체 진행률: 0% / 100%
```

### 일일 작업 계획
```yaml
Day 1 (8시간):
  오전: 
    [ ] Phase 1 완료 (1시간)
    [ ] Phase 2 시작 (3시간)
  오후:
    [ ] Phase 3 완료 (4시간)

Day 2 (8시간):
  오전:
    [ ] Phase 4 완료 (3시간)
    [ ] Phase 5 시작 (1시간)
  오후:
    [ ] Phase 5 완료 (1시간)
    [ ] Phase 6 완료 (2시간)
    [ ] Phase 7 완료 (1시간)
```

---

## 🚀 Quick Start

### 즉시 시작할 수 있는 작업
1. **Phase 1.1.1**: Inventory Scout 실행으로 현재 상태 파악
2. **Phase 2.1.1**: NotificationDto 모델 생성 (Domain 모델 참조)
3. **Phase 3.1.1**: DataSource 인터페이스 정의

### 병렬 작업 가능 항목
- DTO 모델과 Mapper는 독립적으로 개발 가능
- Local/Remote DataSource는 병렬 구현 가능
- 테스트는 각 컴포넌트 완성 즉시 작성

---

## 📚 참고 자료

- [DTO_MIGRATION_GUIDE.md](./DTO_MIGRATION_GUIDE.md) - DTO 구현 상세 가이드
- [DATASOURCE_MIGRATION_GUIDE.md](./datasources/DATASOURCE_MIGRATION_GUIDE.md) - DataSource 구현 가이드
- [REPOSITORY_MIGRATION_GUIDE.md](./repositories/REPOSITORY_MIGRATION_GUIDE.md) - Repository 리팩토링 가이드
- [SUBAGENTS_MANUAL.md](/docs/SUBAGENTS_MANUAL.md) - 서브에이전트 사용법
- [Domain 레이어 문서](../domain/README.md) - 완성된 Domain 모델 참조

---

## 🎯 성공 지표

### 정량적 지표
- **테스트 커버리지**: 70% 이상
- **파일 크기**: 모든 파일 300줄 이하
- **위반 사항**: 0개
- **빌드 시간**: 기존 대비 동일 이하

### 정성적 지표
- Firebase 완전 격리
- 명확한 레이어 분리
- 테스트 가능한 구조
- 유지보수성 향상

---

*이 문서는 서브에이전트를 활용한 체계적인 Data 레이어 마이그레이션을 위한 실행 계획입니다.*
*각 체크박스를 완료하면서 진행 상황을 추적하세요.*