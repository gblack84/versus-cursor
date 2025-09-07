# 📋 Backend Migration Tasks - Phase 2: File Migration
# Backend 마이그레이션 작업 - Phase 2: 파일 이동

> 작성일: 2025-09-07 | Phase 2: Repository Migration  
> 목표: Backend 디렉토리의 파일들을 Feature-First Architecture에 맞게 이동

## 📊 진행 상황
- **전체 진행률**: 0/42 (0%)
- **예상 소요 시간**: 7일 (Week 2)
- **상태**: ⏳ 준비 완료

---

## 🚚 Phase 2.1: Models → Features 이동 (Model Migration)
> 각 모델을 해당 Feature 디렉토리로 이동

### Task 2.1: User 관련 모델 이동
**설명**: backend/models/user/ 디렉토리의 모델들을 features로 이동  
**한국어**: User 모델들을 인증과 프로필 Feature로 분리 이동

**파일 이동 계획**:
```bash
# From → To
backend/models/user/users_model.dart → features/profile/domain/models/users_model.dart
backend/models/user/auth_user.dart → features/auth/domain/models/auth_user.dart (이미 존재)
backend/models/user/premium_users_model.dart → features/profile/domain/models/premium_users_model.dart
backend/models/user/characters_model.dart → features/profile/domain/models/characters_model.dart
```

**실행 명령**:
```bash
mkdir -p lib/features/profile/domain/models/legacy
mv lib/backend/models/user/*.dart lib/features/profile/domain/models/legacy/
```

**검증**: 
- [ ] 파일이 정상적으로 이동됨
- [ ] Import 경로 업데이트 필요 파일 목록 작성
- [ ] 빌드 에러 없음

---

### Task 2.2: Post 관련 모델 이동
**설명**: backend/models/post/ 디렉토리의 모델들을 posts/voting features로 이동  
**한국어**: Post 모델들을 게시물과 투표 Feature로 분리 이동

**파일 이동 계획**:
```bash
backend/models/post/posts_model.dart → features/posts/domain/models/legacy/posts_model.dart
backend/models/post/comments_model.dart → features/posts/domain/models/comments_model.dart
backend/models/post/likes_model.dart → features/posts/domain/models/likes_model.dart
backend/models/post/dislikes_model.dart → features/posts/domain/models/dislikes_model.dart
backend/models/post/ranked_posts_model.dart → features/voting/domain/models/ranked_posts_model.dart
```

---

### Task 2.3: Chat 관련 모델 이동
**설명**: backend/models/chat/ 디렉토리의 모델들을 chat feature로 이동  
**한국어**: Chat 모델들을 채팅 Feature로 이동

**파일 이동 계획**:
```bash
backend/models/chat/chats_model.dart → features/chat/domain/models/chats_model.dart
backend/models/chat/messages_model.dart → features/chat/domain/models/messages_model.dart
backend/models/chat/group_chats_model.dart → features/chat/domain/models/group_chats_model.dart
backend/models/chat/group_messages_model.dart → features/chat/domain/models/group_messages_model.dart
backend/models/chat/chat_history_model.dart → features/chat/domain/models/chat_history_model.dart
```

---

### Task 2.4: Notification 관련 모델 이동
**설명**: backend/models/notification/ 디렉토리의 모델들을 notifications feature로 이동  
**한국어**: Notification 모델들을 알림 Feature로 이동

**파일 이동 계획**:
```bash
backend/models/notification/notifications_model.dart → features/notifications/domain/models/notifications_model.dart
backend/models/notification/notification_model.dart → features/notifications/domain/models/notification_model.dart
```

---

### Task 2.5: Search 관련 모델 이동
**설명**: backend/models/search/ 디렉토리의 모델들을 search feature로 이동  
**한국어**: Search 모델들을 검색 Feature로 이동

**파일 이동 계획**:
```bash
backend/models/search/search_history_model.dart → features/search/domain/models/search_history_model.dart
backend/models/search/searches_model.dart → features/search/domain/models/searches_model.dart
```

---

### Task 2.6: Voting 관련 모델 이동
**설명**: backend/models/vote/ 디렉토리의 모델들을 voting feature로 이동  
**한국어**: Vote 모델들을 투표 Feature로 이동

**파일 이동 계획**:
```bash
backend/models/vote/votes_model.dart → features/voting/domain/models/votes_model.dart
backend/models/vote/votecounts_model.dart → features/voting/domain/models/votecounts_model.dart
backend/models/vote/rankings_model.dart → features/voting/domain/models/rankings_model.dart
backend/models/vote/weights_model.dart → features/voting/domain/models/weights_model.dart
backend/models/vote/vote_expansion_requests_model.dart → features/voting/domain/models/vote_expansion_requests_model.dart
```

---

### Task 2.7: Media 관련 모델 이동
**설명**: backend/models/media/ 디렉토리의 모델들을 적절한 feature로 이동  
**한국어**: Media 모델들을 관련 Feature로 이동

**파일 이동 계획**:
```bash
backend/models/media/image_moderation_model.dart → features/posts/domain/models/image_moderation_model.dart
backend/models/media/encodings_model.dart → features/posts/domain/models/encodings_model.dart
```

---

### Task 2.8: Migration 관련 모델 이동
**설명**: backend/models/migration/ 디렉토리의 모델들을 core로 이동  
**한국어**: Migration 모델들을 Core 레이어로 이동

**파일 이동 계획**:
```bash
backend/models/migration/model_adapter.dart → core/domain/model_adapter.dart
```

---

### Task 2.9: 기타 모델 이동
**설명**: 분류되지 않은 나머지 모델들 이동  
**한국어**: 기타 모델들을 적절한 Feature로 이동

**파일 이동 계획**:
```bash
backend/models/interest/interest_model.dart → features/profile/domain/models/interest_model.dart
backend/models/interest/jops_category_model.dart → features/profile/domain/models/jops_category_model.dart
backend/models/interest/jops_name_model.dart → features/profile/domain/models/jops_name_model.dart
backend/models/interest/chat_interest_jops_model.dart → features/profile/domain/models/chat_interest_jops_model.dart
```

---

### Task 2.10: Backend 모델 Export 파일 업데이트
**설명**: backend.dart의 모델 export를 새 경로로 업데이트  
**한국어**: backend.dart 파일의 모델 export 경로를 새 위치로 변경

**수정 내용**:
```dart
// Before
export 'models/user/users_model.dart';

// After
export '../features/profile/domain/models/users_model.dart';
```

---

## 🏗️ Phase 2.2: Infrastructure → Core/App 이동
> Firebase와 API 인프라를 Core/App 레이어로 이동

### Task 2.11: Firebase Config 이동
**설명**: backend/firebase/config/ 디렉토리를 app/services/firebase/로 이동  
**한국어**: Firebase 설정 파일들을 App 서비스 레이어로 이동

**파일 이동 계획**:
```bash
backend/firebase/config/firebase_config.dart → app/services/firebase/firebase_config.dart
backend/firebase/config/firebase_init.dart → app/services/firebase/firebase_init.dart
```

---

### Task 2.12: Firebase Firestore Utils 이동
**설명**: backend/firebase/firestore/utils/ 디렉토리를 core/infrastructure/로 이동  
**한국어**: Firestore 유틸리티를 Core 인프라로 이동

**파일 이동 계획**:
```bash
backend/firebase/firestore/utils/firestore_util.dart → core/infrastructure/firestore/firestore_util.dart
backend/firebase/firestore/utils/firestore_serialization.dart → core/infrastructure/firestore/firestore_serialization.dart
```

---

### Task 2.13: API 클라이언트 이동
**설명**: backend/api/ 디렉토리를 app/services/api/로 이동  
**한국어**: API 클라이언트를 App 서비스 레이어로 이동

**파일 이동 계획**:
```bash
backend/api/clients/dio_client.dart → app/services/api/dio_client.dart
backend/api/config/api_config.dart → app/services/api/api_config.dart
backend/api/config/environment.dart → app/services/api/environment.dart
backend/api/interceptors/ → app/services/api/interceptors/
backend/api/services/ → app/services/api/services/
```

---

### Task 2.14: API Core 인터페이스 이동
**설명**: backend/api/core/ 디렉토리를 core/infrastructure/api/로 이동  
**한국어**: API 코어 인터페이스를 Core 인프라로 이동

**파일 이동 계획**:
```bash
backend/api/core/interfaces/i_http_client.dart → core/infrastructure/api/i_http_client.dart
backend/api/core/models/api_response.dart → core/infrastructure/api/api_response.dart
backend/api/core/models/api_exception.dart → core/infrastructure/api/api_exception.dart
```

---

### Task 2.15: Repository 인터페이스 이동
**설명**: backend/repositories/interfaces/ 디렉토리를 features로 분산  
**한국어**: Repository 인터페이스를 각 Feature로 분산 이동

**파일 이동 계획**:
```bash
backend/repositories/interfaces/i_user_repository.dart → features/profile/domain/repositories/i_user_repository.dart
backend/repositories/exceptions/ → core/exceptions/repository/
```

---

## 🗄️ Phase 2.3: Legacy 코드 아카이브
> 사용하지 않는 코드를 아카이브로 이동

### Task 2.16: Legacy 디렉토리 생성
**설명**: 아카이브 디렉토리 구조 생성  
**한국어**: Legacy 코드 보관을 위한 아카이브 디렉토리 생성

**실행 명령**:
```bash
mkdir -p lib/backend/legacy/$(date +%Y%m%d)
mkdir -p archive/backend/$(date +%Y%m%d)
```

---

### Task 2.17: 사용하지 않는 파일 식별
**설명**: Import Guardian으로 사용하지 않는 파일 찾기  
**한국어**: 더 이상 사용되지 않는 파일들을 식별

**검증 도구**: Import Guardian 실행
```bash
# 사용되지 않는 파일 목록 생성
```

---

### Task 2.18: Legacy 파일 아카이브
**설명**: 식별된 legacy 파일들을 아카이브로 이동  
**한국어**: Legacy 파일들을 아카이브 디렉토리로 이동

**파일 이동**:
```bash
# 사용하지 않는 파일들을 archive로 이동
mv lib/backend/legacy_file.dart archive/backend/$(date +%Y%m%d)/
```

---

## 🔄 Phase 2.4: Import 경로 업데이트
> 이동된 파일들의 import 경로를 모두 업데이트

### Task 2.19: User 모델 Import 업데이트
**설명**: UsersModel 관련 import 경로 업데이트  
**한국어**: 사용자 모델 import 경로를 새 위치로 변경

**변경 패턴**:
```dart
// Before
import '/backend/models/user/users_model.dart';

// After
import '/features/profile/domain/models/users_model.dart';
```

---

### Task 2.20: Post 모델 Import 업데이트
**설명**: PostsModel 관련 import 경로 업데이트  
**한국어**: 게시물 모델 import 경로를 새 위치로 변경

---

### Task 2.21: Chat 모델 Import 업데이트
**설명**: ChatsModel 관련 import 경로 업데이트  
**한국어**: 채팅 모델 import 경로를 새 위치로 변경

---

### Task 2.22: Firebase Import 업데이트
**설명**: Firebase 관련 import 경로 업데이트  
**한국어**: Firebase import 경로를 새 위치로 변경

---

### Task 2.23: API Import 업데이트
**설명**: API 클라이언트 관련 import 경로 업데이트  
**한국어**: API 클라이언트 import 경로를 새 위치로 변경

---

### Task 2.24: Repository Import 업데이트
**설명**: Repository 관련 import 경로 업데이트  
**한국어**: Repository import 경로를 새 위치로 변경

---

### Task 2.25: Backend.dart Export 정리
**설명**: backend.dart의 모든 export 경로 정리  
**한국어**: backend.dart 파일의 export 경로 전체 정리

---

## ✅ Phase 2.5: 테스트 및 검증
> 마이그레이션 후 전체 시스템 검증

### Task 2.26: 컴파일 테스트
**설명**: Flutter 빌드 성공 확인  
**한국어**: Flutter 프로젝트 빌드 테스트

**실행 명령**:
```bash
flutter clean
flutter pub get
flutter build apk --debug
flutter build ios --debug
```

---

### Task 2.27: Import 에러 검증
**설명**: Import Guardian으로 모든 import 에러 해결  
**한국어**: Import 에러가 없는지 검증

---

### Task 2.28: 단위 테스트 실행
**설명**: 모든 단위 테스트 통과 확인  
**한국어**: 단위 테스트 전체 실행

**실행 명령**:
```bash
flutter test
```

---

### Task 2.29: 통합 테스트 실행
**설명**: 주요 기능 통합 테스트 실행  
**한국어**: 통합 테스트로 기능 검증

---

### Task 2.30: 성능 테스트
**설명**: 마이그레이션 후 성능 저하 없음 확인  
**한국어**: 앱 성능 측정 및 비교

---

### Task 2.31: 롤백 계획 검증
**설명**: 문제 발생 시 롤백 가능 확인  
**한국어**: 롤백 절차 문서화 및 테스트

**롤백 명령**:
```bash
git checkout checkpoint/backend-phase1-complete
```

---

### Task 2.32: 코드 리뷰
**설명**: 이동된 파일들의 구조 검토  
**한국어**: 코드 구조 및 품질 검토

---

## 🔍 Phase 2.6: 추가 정리 작업
> 마이그레이션 완료 후 추가 정리

### Task 2.33: 빈 디렉토리 제거
**설명**: Backend 디렉토리의 빈 폴더들 제거  
**한국어**: 비어있는 디렉토리 정리

**실행 명령**:
```bash
find lib/backend -type d -empty -delete
```

---

### Task 2.34: 중복 파일 제거
**설명**: 중복된 모델 파일 정리  
**한국어**: 중복 파일 식별 및 제거

---

### Task 2.35: TypeDef 업데이트
**설명**: 호환성을 위한 typedef 추가  
**한국어**: 타입 별칭 추가로 호환성 유지

```dart
// core/compatibility/type_aliases.dart
typedef LegacyUsersModel = UserProfile;
typedef LegacyPostsModel = Post;
```

---

### Task 2.36: Documentation 업데이트
**설명**: 마이그레이션 관련 문서 업데이트  
**한국어**: README 및 개발 문서 업데이트

---

### Task 2.37: Git Commit 체크포인트
**설명**: Phase 2 완료 체크포인트 생성  
**한국어**: Git 태그로 마이그레이션 체크포인트 생성

**실행 명령**:
```bash
git add .
git commit -m "feat: Phase 2 - Backend file migration to Feature-First Architecture"
git tag -a checkpoint/backend-phase2-migration -m "Phase 2 migration complete"
```

---

## 📊 Phase 2.7: 최종 검증
> Phase 2 완료 확인

### Task 2.38: Backend 디렉토리 구조 확인
**설명**: Backend 디렉토리가 정리되었는지 확인  
**한국어**: Backend 디렉토리 구조 최종 확인

---

### Task 2.39: Feature 디렉토리 구조 확인
**설명**: 모든 Feature가 올바른 구조를 가지는지 확인  
**한국어**: Feature 디렉토리 구조 검증

---

### Task 2.40: Import 경로 최종 검증
**설명**: 모든 import 경로가 올바른지 최종 확인  
**한국어**: Import 경로 전체 검증

---

### Task 2.41: CI/CD 파이프라인 테스트
**설명**: CI/CD 파이프라인이 정상 작동하는지 확인  
**한국어**: 자동화 빌드 및 배포 테스트

---

### Task 2.42: Phase 2 완료 보고
**설명**: Phase 2 마이그레이션 완료 문서 작성  
**한국어**: Phase 2 완료 보고서 작성

---

## 📈 진행 상황 추적

### 체크리스트
- [ ] Phase 2.1: Models → Features 이동 (Task 2.1-2.10)
- [ ] Phase 2.2: Infrastructure → Core/App 이동 (Task 2.11-2.15)
- [ ] Phase 2.3: Legacy 코드 아카이브 (Task 2.16-2.18)
- [ ] Phase 2.4: Import 경로 업데이트 (Task 2.19-2.25)
- [ ] Phase 2.5: 테스트 및 검증 (Task 2.26-2.32)
- [ ] Phase 2.6: 추가 정리 작업 (Task 2.33-2.37)
- [ ] Phase 2.7: 최종 검증 (Task 2.38-2.42)

### 일별 목표
- **Day 1**: Task 2.1-2.6 (User, Post, Chat 모델 이동)
- **Day 2**: Task 2.7-2.10 (나머지 모델 이동)
- **Day 3**: Task 2.11-2.15 (인프라 이동)
- **Day 4**: Task 2.16-2.18 (Legacy 아카이브)
- **Day 5**: Task 2.19-2.25 (Import 경로 업데이트)
- **Day 6**: Task 2.26-2.32 (테스트 및 검증)
- **Day 7**: Task 2.33-2.42 (정리 및 완료)

### 위험 관리
| 위험 요소 | 확률 | 영향도 | 대응 방안 |
|----------|-----|-------|----------|
| Import 경로 누락 | 높음 | 중간 | Import Guardian 사용 |
| 빌드 실패 | 중간 | 높음 | 단계별 테스트 |
| 성능 저하 | 낮음 | 중간 | 성능 모니터링 |
| 파일 손실 | 낮음 | 높음 | Git 체크포인트 |

### 성공 기준
- ✅ 모든 파일이 올바른 위치로 이동
- ✅ Import 에러 0개
- ✅ 모든 테스트 통과
- ✅ 빌드 성공 (iOS, Android, Web, macOS)
- ✅ 성능 저하 없음
- ✅ 롤백 가능한 상태 유지

---

*이 문서는 Phase 2: Backend File Migration의 상세 작업 계획입니다.*  
*작성일: 2025-09-07*