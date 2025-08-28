# 📚 Versus Space 프로젝트 통합 문서화 인덱스

> 전체 프로젝트 문서화 진행 상황을 추적하고 관리하는 중앙 대시보드
> 버전: 2.18.0 | 최종 업데이트: 2025-08-28

## 📊 프로젝트 메타정보

| 항목 | 상태 | 상세 |
|------|------|------|
| **프로젝트명** | Versus Space | Flutter 기반 소셜 미디어 앱 |
| **아키텍처** | Feature-First + Clean | 7개 Feature 모듈 + 4개 전역 레이어 |
| **총 디렉토리 수** | 121개 | /lib 하위 및 프로젝트 인프라 디렉토리 |
| **문서화 완료** | 121개 | 모든 디렉토리 README 작성 완료 |
| **통합 문서** | 3개 | Backend, Services 레이어 통합 규칙 문서 작성 완료 |
| **마이그레이션 문서** | 33개 | App 전체 + Core + Backend + Services 모두 포함 |
| **테스트 문서** | 33개 | App 전체 + Core + Backend + Services 모두 포함 |
| **문서화 진행률** | 100% | (121/121) 🎉 |
| **네이밍 컨벤션** | camelCase | 768개 필드 마이그레이션 완료 |
| **DI 시스템** | GetIt (계획) | 의존성 주입 시스템 구현 예정 |
| **최종 업데이트** | 2025-08-28 | Services 레이어 통합 문서 작성 완료 |

## 🎯 문서화 목표

- ✅ 모든 디렉토리에 정확한 README.md 작성
- ✅ 실제 코드와 100% 일치하는 문서
- ✅ camelCase 네이밍 컨벤션 준수
- ✅ 검증 스크립트 통과 (check_naming.sh, validate_docs.sh)

## 📈 문서화 진행 대시보드

### 범례
- ✅ **완료**: 문서화 완료 및 검증 통과
- 📋 **마이그레이션 계획**: MIGRATION_Part3.md 및 TEST.md 작성 완료
- ⏳ **계획 예정**: 마이그레이션 문서 작성 예정
- ⚡ **필수 인프라**: 핵심 기능 제공 (절대 삭제 금지)
- 🔄 **진행중**: 현재 작업 중
- ⚠️ **업데이트 필요**: snake_case → camelCase 변환 필요
- ❌ **미작업**: 아직 시작하지 않음
- 🗑️ **삭제됨**: 불필요하여 제거된 디렉토리
- ⭐⭐ **낮은 구현율**: 계획 대비 구현 20% 이하

### 프로젝트 루트 레벨 문서
| 문서 | 상태 | 목적 | 최종 업데이트 |
|------|------|------|--------------|
| **README.md** | ✅ | Quick Start 가이드 | 2025-08-27 |
| **ARCHITECTURE.md** | ✅ | 시스템 아키텍처 v3.0.0 | 2025-08-27 |
| **CLAUDE.md** | ✅ | 기술 상세 문서 (Feature-First 구조) | 2025-08-27 |
| **CHANGELOG.md** | ✅ | 변경 이력 v3.0.0 릴리즈 | 2025-08-27 |
| **DEVELOPMENT_RULES.md** | ✅ | 개발 규칙 v2.0.0 | 2025-08-27 |
| **FEATURE_ARCHITECTURE.md** | ✅ | Feature-First 아키텍처 가이드 | 2025-08-27 |
| **GLOBAL_LAYERS.md** | ✅ | 전역 레이어 상세 문서 | 2025-08-27 |
| **index_document.md** | ✅ | 이 파일 - 문서화 추적 대시보드 | 2025-08-27 |

### 🏗️ Feature-First Architecture 모듈
| Feature | 상태 | README | Clean Architecture | 비고 |
|---------|------|--------|-------------------|------|
| `/lib/features/auth` | ✅ | ✅ | ✅ Data/Domain/Presentation | 인증 시스템 |
| `/lib/features/chat` | ✅ | ✅ | ✅ Data/Domain/Presentation | 채팅 시스템 |
| `/lib/features/posts` | ✅ | ✅ | ✅ Data/Domain/Presentation | 게시물 관리 |
| `/lib/features/profile` | ✅ | ✅ | ✅ Data/Domain/Presentation | 사용자 프로필 |
| `/lib/features/voting` | ✅ | ✅ | ✅ Data/Domain/Presentation | 투표 시스템 |
| `/lib/features/notifications` | ✅ | ✅ | ✅ Data/Domain/Presentation | 알림 시스템 |
| `/lib/features/search` | ✅ | ✅ | ✅ Data/Domain/Presentation | 검색 기능 |

### 🌐 전역 레이어 (Global Layers)
| 레이어 | 상태 | README | MIGRATION | TEST | 목적 | 비고 |
|--------|------|--------|-----------|------|------|------|
| `/lib/core` | ✅ | ✅ | 📋 | 📋 | 디자인 시스템, 테마, 유틸리티 | 모든 Feature 공유 |
| `/lib/backend` | ✅ | ✅ | 📋 | 📋 | Firebase, API, 모델 | 데이터 인프라 (Algolia, API, Firebase, Models 완전 문서화) |
| `/lib/services` | ✅ | ✅ | 📋 | 📋 | 캐싱, 검열, 로깅, 알림 | 비즈니스 서비스 |
| `/lib/app` | ✅ | ✅ | ✅ | ✅ | 라우팅, DI(계획), 앱 진입점 | 최상위 설정 |

### 주요 디렉토리 구조
| 디렉토리 | 상태 | README | 검증 | 비고 |
|----------|------|--------|------|------|
| `/lib` | ✅ | ✅ | ⭐⭐⭐⭐⭐ | Feature-First Architecture 구조 |
| `/firebase` | ✅ | ✅ | ⭐⭐⭐⭐ | Firebase 백엔드 인프라 |
| `/docs` | ✅ | ✅ | ⭐⭐⭐⭐⭐ | 프로젝트 문서 센터 |
| `/scripts` | ✅ | ✅ | ⭐⭐⭐⭐ | 자동화 스크립트 (validate_docs.sh, sync_docs.sh 등) |
| `/mcp-servers` | ⚡ | ✅ | ⭐⭐⭐⭐ | MCP 서버 인프라 - **필수 유지** |
| ~~`/mappings`~~ | 🗑️ | - | - | 2025-08-24 삭제 (채팅 v2 마이그레이션 완료) |
| ~~`/migration_analysis`~~ | 🗑️ | - | - | 2025-08-24 삭제 (네이밍 마이그레이션 완료) |
| ~~`/lib/custom_code`~~ | 🗑️ | - | - | 2025-08-23 삭제 (Native Flutter 통합) |

### 📦 /lib/app 하위 디렉토리
| 디렉토리 | 상태 | README | 구현 상태 | 비고 |
|----------|------|--------|-----------|------|
| `/lib/app` | ✅ | ✅ | ⚠️ 리팩토링 필요 | AppState 분리, 라우팅 모듈화 필요 |
| `/lib/app/di` | ✅ | ✅ | ❌ 미구현 | DI 시스템 계획 + MIGRATION_Part3.md |
| `/lib/app/router` | ✅ | ✅ | ⚠️ 리팩토링 필요 | nav.dart 542줄 분리 필요 + MIGRATION_Part3.md |
| `/lib/app/state` | ✅ | ✅ | ⚠️ 리팩토링 필요 | app_state.dart 555줄 분리 필요 + MIGRATION_Part3.md |
| `/lib/app/models` | ✅ | ✅ | 🔴 미사용 | LatLng, AppPlace - Location Feature로 이동 또는 삭제 필요 |
| `/lib/app/widgets` | ✅ | ✅ | ⚠️ 리팩토링 필요 | index.dart 제거, debug 도구 이동 필요 + MIGRATION_Part3.md |

### /lib 루트 레벨
| 디렉토리 | 상태 | README | 검증 | 비고 |
|----------|------|--------|------|------|
| `/lib/actions` | ✅ | ✅ | ✅ | 2025-08-22 완료 |
| `/lib/auth` | ✅ | ✅ | ✅ | 2025-08-22 완료 |
| `/lib/backend` | ✅ | ✅ | ✅ | 2025-08-22 완료 |
| `/lib/components` | ✅ | ✅ | ✅ | 2025-08-22 완료 |
| `/lib/core` | ✅ | ✅ | ✅ | 2025-08-22 완료 |
| `/lib/createaccount` | ✅ | ✅ | ✅ | 2025-08-23 통합 문서 완료 |
| ~~`/lib/custom_code`~~ | 🗑️ | - | - | 2025-08-23 삭제 (FlutterFlow 레거시) |
| `/lib/design_system` | ✅ | ✅ | ⭐⭐⭐⭐ | 2025-08-24 통합 문서 완료 (616줄) |
| `/lib/etc` | ✅ | ✅ | ⭐⭐⭐ | 2025-08-24 FlutterFlow 레거시 테스트 코드 문서화 완료 |
| `/lib/login` | ✅ | ✅ | ⭐⭐⭐⭐ | 2025-08-23 통합 문서 완료 |
| `/lib/models` | ✅ | ✅ | ⭐⭐⭐⭐ | 2025-08-23 완료 |
| `/lib/pages` | ✅ | ✅ | ⭐⭐⭐ | 2025-08-23 통합 문서 완료 (972줄) |
| `/lib/posts` | ✅ | ✅ | ⭐⭐⭐ | 2025-08-23 통합 문서 완료 (351줄) |
| `/lib/providers` | ✅ | ✅ | ⭐⭐⭐⭐ | 2025-08-23 상태 관리 문서화 (404줄) |
| `/lib/services` | ✅ | ✅ | ⭐⭐⭐⭐ | 2025-08-23 통합 서비스 문서화 |
| `/lib/shared` | ✅ | ✅ | ⭐⭐⭐⭐ | 2025-08-23 통합 레이아웃 시스템 문서화 (321줄) |
| `/lib/testpage_select` | ✅ | ✅ | ⭐⭐⭐⭐ | 2025-08-24 테스트 페이지 네비게이션 허브 문서화 (179줄) |
| `/lib/utils` | ✅ | ✅ | ⭐⭐⭐⭐⭐ | 2025-08-24 유틸리티 함수 라이브러리 문서화 (278줄) |
| `/lib/widgets` | ✅ | ✅ | ⭐⭐⭐⭐⭐ | 2025-08-24 커스텀 위젯 라이브러리 문서화 (235줄) |

### 하위 디렉토리 상세 (52개)

#### /lib/auth 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/auth/firebase_auth` | ✅ | ✅ | ✅ |

#### /lib/backend 하위
| 디렉토리 | 상태 | README | MIGRATION | TEST | 검증 |
|----------|------|--------|-----------|------|------|
| `/lib/backend/algolia` | ✅ | ✅ | ✅ | ✅ | ⭐⭐ |
| `/lib/backend/api` | ✅ | ✅ | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/backend/api_requests` | ✅ | ✅ | - | - | ✅ |
| `/lib/backend/firebase` | ✅ | ✅ | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/backend/firebase_storage` | ✅ | ✅ | - | - | ✅ |
| `/lib/backend/models` | ✅ | ✅ | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/backend/schema` | ✅ | ✅ | - | - | ✅ |
| `/lib/backend/schema/util` | ✅ | ✅ | - | - | ✅ |

#### /lib/components 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/components/chat` | ✅ | ✅ | ✅ |
| `/lib/components/chat/vote_card` | ✅ | ✅ | ✅ |
| `/lib/components/navigation` | ✅ | ✅ | ✅ |
| `/lib/components/notifications` | ✅ | ✅ | ✅ |
| `/lib/components/notifications/constants` | ✅ | ✅ | ✅ |
| `/lib/components/notifications/models` | ✅ | ✅ | ✅ |
| `/lib/components/notifications/utils` | ✅ | ✅ | ✅ |
| `/lib/components/notifications/widgets` | ✅ | ✅ | ✅ |

#### /lib/core 하위
| 디렉토리 | 상태 | README | MIGRATION | TEST | 검증 |
|----------|------|--------|-----------|------|------|
| `/lib/core/nav` | ✅ | ✅ | - | - | ✅ |
| `/lib/core/actions` | ✅ | ✅ | ✅ | ✅ | ⭐⭐ |
| `/lib/core/animations` | ✅ | ✅ | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/core/constants` | ✅ | ✅ | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/core/design_system` | ✅ | ✅ | ✅ | ✅ | ⭐⭐⭐⭐⭐ |
| `/lib/core/localization` | ✅ | ✅ | ✅ | ✅ | ⭐⭐⭐⭐⭐ |
| `/lib/core/models` | ✅ | ✅ | ✅ | ✅ | ⭐⭐⭐⭐⭐ |
| `/lib/core/theme` | ✅ | ✅ | ✅ | ✅ | ⭐⭐⭐⭐⭐ |
| `/lib/core/utils` | ✅ | ✅ | ✅ | ✅ | ⭐⭐⭐⭐⭐ |
| `/lib/core/widgets` | ✅ | ✅ | ✅ | ✅ | ⭐⭐⭐⭐⭐ |

#### /lib/createaccount 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/createaccount/create_account` | ✅ | ✅ | ✅ |
| `/lib/createaccount/phoneauth` | ✅ | ✅ | ✅ |
| `/lib/createaccount/phoneauth/phone_creat_account` | ✅ | ✅ | ✅ |
| `/lib/createaccount/phoneauth/phonelogeinpincode` | ✅ | ✅ | ✅ |
| `/lib/createaccount/phonemaximum` | ✅ | ✅ | ✅ |
| `/lib/createaccount/popup_timer_email` | ✅ | ✅ | ✅ |

#### ~~lib/custom_code 하위~~ (2025-08-23 삭제됨)
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| ~~`/lib/custom_code/actions`~~ | 🗑️ | - | - |
| ~~`/lib/custom_code/widgets`~~ | 🗑️ | - | - |

#### /lib/design_system 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/design_system/components` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/design_system/tokens` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/design_system/utils` | ✅ | ✅ | ⭐⭐⭐⭐ |

#### /lib/etc 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/etc/blankppp` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/etc/phoneloginpincode` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/etc/tags_labels` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/etc/testalgoria` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/etc/testdivider` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/etc/vsmark` | ✅ | ✅ | ⭐⭐⭐⭐ |

#### /lib/login 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/login/forgot_password` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/login/login_page` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/login/start_page` | ✅ | ✅ | ⭐⭐⭐⭐ |

#### /lib/pages 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/pages/chat` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/pages/chat/ai_chat_v2` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/pages/chat/chat_detail_v2` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/pages/chat/chat_detail_v2/components` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/pages/chat/chat_list` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/pages/chat/chat_search` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/pages/chat/constants` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/pages/chat/friends_list` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/pages/chat/services` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/pages/home` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/pages/image_viewer` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/pages/jop` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/pages/jop/agrred_select` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/pages/jop/expertise_select` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/pages/jop/hobbies_select` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/pages/notifications_list` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/pages/pro_image_editor` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/pages/profile` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/pages/search` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/pages/thumbnail_selection` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/pages/user_info` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/pages/user_info/character_detail_page` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/pages/user_info/language_selector` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/pages/user_info_input` | ✅ | ✅ | ⭐⭐⭐ |

#### /lib/posts 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/posts/in_put_post_image` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/posts/in_put_post_image/components` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/posts/in_put_post_image/constants` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/posts/in_put_post_image/delegates` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/posts/in_put_post_image/helpers` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/posts/in_put_post_image/models` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/posts/in_put_post_image/services` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/posts/in_put_post_image/utils` | ✅ | ✅ | ⭐⭐⭐ |
| `/lib/posts/in_put_post_image/widgets` | ✅ | ✅ | ⭐⭐⭐ |

#### /lib/services 하위
| 디렉토리 | 상태 | README | MIGRATION | TEST | 검증 |
|----------|------|--------|-----------|------|------|
| `/lib/services/ai_moderation` | ✅ | ✅ | - | - | ⭐⭐⭐⭐ |
| `/lib/services/ai_moderation/constants` | ✅ | ✅ | - | - | ⭐⭐⭐⭐ |
| `/lib/services/ai_moderation/models` | ✅ | ✅ | - | - | ⭐⭐⭐⭐ |
| `/lib/services/ai_moderation/text_moderation` | ✅ | ✅ | - | - | ⭐⭐⭐⭐ |
| `/lib/services/cache` | ✅ | ✅ | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/services/logger` | ✅ | ✅ | ✅ | ✅ | ⭐⭐⭐⭐ |

#### /lib/shared 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/shared/constants` | ✅ | ✅ | ⭐⭐⭐⭐ |
| `/lib/shared/services` | ✅ | ✅ | ⭐⭐⭐⭐ |

## 📝 완료된 문서화 상세

### ✅ /lib/pages/chat (2025-08-23 완료)

#### 분석 결과
| 항목 | 발견 사항 | 조치 |
|------|----------|------|
| **코드 분석** | 8개 하위 디렉토리, 22개 Dart 파일 | 통합 채팅 시스템 문서화 |
| **문서 작성** | README 491줄 작성 | 하위 디렉토리 통합 문서 |
| **네이밍 컨벤션** | 100% camelCase 준수 | ✅ 검증 통과 |

#### 구현된 시스템
- **채팅 시스템 아키텍처**: flutter_chat_ui v2 기반
- **3-Layer 캐싱**: Memory → Hive → Firestore (<10ms 응답)
- **7개 서비스**: 초기화, 메시지 변환, 생명주기, 미디어, 파일, 애니메이션, 스크롤
- **성능 최적화**: 병렬 처리로 60% 빠른 채팅방 진입

#### 검증 결과
```bash
✅ check_naming.sh - PASSED (모든 네이밍 컨벤션 통과)
⭐⭐⭐⭐ validate_docs.sh - PASSED (주요 구성요소 섹션 경고)
```

## 🎉 문서화 완료

모든 120개 디렉토리의 문서화가 100% 완료되었습니다!

### Core Actions 레이어 특별 현황
- **구현율**: 11% (1/9 액션만 구현)
- **문제점**: Core→Features 역방향 의존성
- **필요 작업**: 8개 액션 구현, 인터페이스 분리, DI 통합
- **예상 기간**: 1주일 집중 개발

### 2025-08-24 최종 상태
- ✅ 모든 디렉토리에 README.md 작성 완료
- ✅ 네이밍 컨벤션 100% 준수 (camelCase)
- ✅ 11개 루트 MD 파일 → 5개 핵심 문서로 통합
- ✅ 중복 콘텐츠 40% 제거
- ✅ 문서 구조 재편성 완료

## 🔧 문서 관리 도구

### 검증 스크립트
```bash
# 문서 검증 (빈 README, 중복, 오래된 문서, 깨진 링크)
./scripts/validate_docs.sh

# 네이밍 컨벤션 검사
./scripts/check_naming.sh

# 코드-문서 동기화 확인
./scripts/sync_docs.sh check

# 새 디렉토리에 README 자동 생성
./scripts/sync_docs.sh update
```

### 문서 관리 시나리오
1. **새 기능 개발 후**: `sync_docs.sh update` → CLAUDE.md 업데이트
2. **리팩토링 후**: `sync_docs.sh check` → README 업데이트
3. **주간 루틴**: `validate_docs.sh` → `check_naming.sh`
4. **월간 대청소**: 중복 통합 → archive 이동 → index 업데이트

## 📊 진행 통계

| 구분 | 수량 | 백분율 |
|------|------|--------|
| **전체 디렉토리** | 120 | 100% |
| **✅ 완료** | 120 | 100% |
| **📋 마이그레이션 문서** | 11 | 9.2% |
| **⚡ 필수 인프라** | 3 | 2.5% |
| **🗑️ 삭제됨** | 2 | 1.7% |
| **🔄 진행중** | 0 | 0% |
| **⚠️ 업데이트 필요** | 0 | 0% |
| **❌ 미작업** | 0 | 0% |
| **⭐⭐ 낮은 구현율** | 1 | 0.8% |

## 📅 작업 이력

| 날짜 | 디렉토리 | 작업자 | 상태 | 비고 |
|------|----------|--------|------|------|
| 2025-08-28 | `/lib/services` | AI Assistant | ✅ 완료 | **Services 레이어 통합 문서 작성 완료**: README.md 전역 인프라 서비스 통합 문서, MIGRATION_SERVICE_ORDER_RULES.md 4주 통합 마이그레이션 규칙 (Phase 1 긴급: API 키 보안), TEST.md 85% 목표 통합 테스트 전략. 백엔드 통합 문서 형식에 따라 Services 레이어 전체 통합 문서 3개 작성 완료 |
| 2025-08-28 | `/lib/services/image` | AI Assistant | ✅ 완료 | Services Image 레이어 포괄적 문서화 완료: README.md 통합 이미지 캐싱 서비스 분석 (261줄, UnifiedImageCacheService 싱글톤), MIGRATION_Part3.md 2주 마이그레이션 계획 (Feature-First Media 모듈 구축, 네트워크 최적화, AI 기반 프리로드), TEST.md 90% 목표 커버리지 테스트 전략. 주요 개선: 3-Layer 캐싱 아키텍처, 우선순위 기반 캐싱, Progressive Loading, 네트워크 상태별 최적화 |
| 2025-08-28 | `/lib/services/content` | AI Assistant | ✅ 완료 | Services Content 레이어 포괄적 문서화 완료: README.md 콘텐츠 필터링 시스템 분석 (180줄, FilterResult/ContentFilter), MIGRATION_Part3.md 2주 마이그레이션 계획 (통합 검열 Feature 구축, AI 기반 고도화, 다국어 지원), TEST.md 90% 목표 커버리지 테스트 전략. 주요 개선: Perspective API/Gemini AI 통합 계획, 이미지/비디오 검열 통합, 실시간 정책 업데이트, 컨텍스트 기반 분석 |
| 2025-08-28 | `/lib/backend/models` | AI Assistant | ✅ 완료 | Backend Models 레이어 포괄적 문서화 완료: README.md 데이터 모델 분석 (17개 모델 파일, users/posts/messages 주요 모델), MIGRATION_Part3.md 5일 마이그레이션 계획 (Feature별 모델 분리, 단일 책임 원칙 적용, Repository 패턴 구현), TEST.md 80% 목표 커버리지 테스트 전략. 주요 개선: PostsModel 60개 필드를 Post/Vote/PostStats로 분리, Map<String,dynamic> → 타입 안전한 Value Objects, Feature-First 구조 적용 |
| 2025-08-28 | `/lib/backend/firebase` | AI Assistant | ✅ 완료 | Backend Firebase 레이어 포괄적 문서화 완료: README.md Firebase 인프라 분석 (264줄 코드), MIGRATION_Part3.md 5일 마이그레이션 계획 (환경 변수, DI 패턴, 서비스 추상화), TEST.md 80% 목표 커버리지 테스트 전략. 주요 개선: API 키 환경 변수화, 역방향 의존성 해결, Firebase Emulator 테스트 환경 |
| 2025-08-28 | `/lib/backend/api` | AI Assistant | ✅ 완료 | Backend API 레이어 포괄적 문서화 완료: README.md API 통합 시스템 분석 (싱글톤 패턴, 캐싱, EncoderGroup, SearchAlgoliaCall), MIGRATION_Part3.md 5일 마이그레이션 계획 (Dio 클라이언트 전환, DI 패턴 적용, 인터셉터 구현), TEST.md 85% 목표 커버리지 테스트 전략. 주요 개선: 싱글톤 제거, API 키 환경 변수화, Feature DataSource 분리 |
| 2025-08-28 | `/lib/backend/repositories` | AI Assistant | ✅ 완료 | Backend Repositories 레이어 포괄적 문서화 완료: README.md Repository 패턴 설계 분석 (4개 파일 모두 TODO 상태), MIGRATION_Part3.md 2주 구현 계획 (UserRepository, PostRepository, ChatRepository, MediaRepository), TEST.md 85% 목표 커버리지 테스트 전략. 주요 개선: Repository 패턴 구현, 의존성 역전 원칙 적용, 3-Layer 캐싱 통합, Feature별 Repository 분리 |
| 2025-08-28 | `/lib/core/utils` | AI Assistant | ✅ 완료 | Core Utils 레이어 포괄적 문서화 완료: README.md 유틸리티 시스템 분석 (633줄 코드), MIGRATION_Part3.md 5일 마이그레이션 계획 (도메인별 분리, DI 패턴 적용), TEST.md 95% 목표 커버리지 테스트 전략. 주요 개선: app_utils.dart 497줄을 도메인별 분리, export 문 제거, 타이머 시스템 Feature로 이동 |
| 2025-08-28 | `/lib/core/localization` | AI Assistant | ✅ 완료 | Core Localization 레이어 포괄적 문서화 완료: README.md 다국어 지원 시스템 분석 (1,889줄), MIGRATION_Part3.md 2주 마이그레이션 계획 (JSON 기반 번역 시스템, 타입 안전 번역 키), TEST.md 95% 목표 커버리지 테스트 전략. 주요 개선: JSON 기반 번역 시스템 구축, UI 컴포넌트 shared로 이동, 독일어 번역 완성 계획 |
| 2025-08-28 | `/lib/core/design_system` | AI Assistant | ✅ 완료 | Core Design System 레이어 포괄적 문서화 완료: README.md 디자인 토큰 및 컴포넌트 분석 (1,717줄), MIGRATION_Part3.md 2주 마이그레이션 계획 (Theme Extension 전환, 컴포넌트 shared 이동, Material 3 통합), TEST.md 95% 목표 커버리지 테스트 전략. 주요 개선: 토큰 시스템 Theme Extension 전환, 컴포넌트 shared/widgets로 이동, 테마 시스템 구현 |
| 2025-08-28 | `/lib/core/constants` | AI Assistant | ✅ 완료 | Core Constants 레이어 포괄적 문서화 완료: README.md 레이아웃 상수 시스템 분석 (214줄), MIGRATION_Part3.md 1주 마이그레이션 계획 (타입 안전성 강화, Design System 통합), TEST.md 90% 목표 커버리지 테스트 전략. 주요 개선: ContainerType enum 도입, 디렉토리 구조화, Feature별 상수 확장 |
| 2025-08-28 | `/lib/core/animations` | AI Assistant | ✅ 완료 | Core Animations 레이어 포괄적 문서화 완료: README.md 113줄 파일 분석, 애니메이션 프리셋 시스템 설계, MIGRATION_Part3.md 1주 마이그레이션 계획 (효과 라이브러리 확장, 성능 최적화), TEST.md 85% 목표 커버리지 테스트 전략. 주요 개선: 20개+ 효과 추가, 컨트롤러 풀 구현, 접근성 지원 |
| 2025-08-28 | `/lib/core/actions` | AI Assistant | ✅ 완료 | Core Actions 레이어 포괄적 문서화 완료: README.md 298줄 (현재 구현 11% 분석), MIGRATION_Part3.md 1주 마이그레이션 계획, TEST.md 83% 목표 커버리지 테스트 전략. 주요 문제: Core→Features 역방향 의존성, 8개 액션 미구현, 에러 처리 부재 |
| 2025-08-28 | `/lib/app/widgets` | AI Assistant | ✅ 완료 | App Widgets 레이어 분석 및 Feature-First 리팩토링 가이드 작성, index.dart feature 의존성 제거 계획, debug 도구 이동 계획, MIGRATION_Part3.md 2일 마이그레이션 계획 |
| 2025-08-28 | `/lib/app/state` | AI Assistant | ✅ 완료 | App State 시스템 분석 및 Feature-First 리팩토링 가이드 작성, app_state.dart 555줄을 5개 Provider로 분리 계획, MIGRATION_Part3.md 2주 점진적 마이그레이션 계획 |
| 2025-08-28 | `/lib/app/router` | AI Assistant | ✅ 완료 | Router 시스템 분석 및 Feature-First 리팩토링 가이드 작성, nav.dart 542줄 분리 계획, serialization_util.dart 270줄 분석 추가, MIGRATION_Part3.md 6단계 마이그레이션 계획 |
| 2025-08-27 | `/lib/app/models` | AI Assistant | ✅ 완료 | 미사용 위치 모델 분석, Location Feature 마이그레이션 계획, MIGRATION_Part3.md 작성 |
| 2025-08-27 | `/lib/app/di` | AI Assistant | ✅ 완료 | DI 시스템 구현 계획 수립, GetIt 기반 5단계 마이그레이션 계획, MIGRATION_Part3.md 작성 |
| 2025-08-24 | `/firebase/functions/scripts` | AI Assistant | ✅ 완료 | 마이그레이션 스크립트 문서화, 385줄 README 작성, ⭐⭐⭐⭐⭐ 검증 통과 - **스키마 마이그레이션 도구** |
| 2025-08-24 | `/firebase/functions/functions/firestore` | AI Assistant | ✅ 완료 | Firestore 트리거 함수 문서화, 337줄 README 작성, ⭐⭐⭐⭐⭐ 검증 통과 - **핵심 비즈니스 로직** |
| 2025-08-24 | `/firebase/functions/functions/auth` | AI Assistant | ✅ 완료 | Firebase Auth 트리거 함수 문서화, 255줄 README 작성, ⭐⭐⭐⭐⭐ 검증 통과 - **사용자 삭제 처리** |
| 2025-08-24 | `/firebase/functions/docs` | AI Assistant | ✅ 완료 | 기술 문서 저장소 문서화, 300줄 README 작성, ⭐⭐⭐⭐⭐ 검증 통과 - **투표 시스템 문서** |
| 2025-08-24 | `/firebase/functions/config` | AI Assistant | ⚡ 완료 | Firebase Functions 설정 관리 시스템 문서화, 331줄 README 작성, ⭐⭐⭐⭐⭐ 검증 통과 - **필수 인프라** |
| 2025-08-24 | `/mcp-servers` | AI Assistant | ⚡ 완료 | MCP 서버 인프라 문서화, 208줄 README 작성, ⭐⭐⭐⭐ 검증 통과 - **필수 유지** |
| 2025-08-24 | `/mappings` | AI Assistant | 🗑️ 삭제 | 마이그레이션 매핑 문서화 후 삭제 - 채팅 v2 마이그레이션 100% 완료 |
| 2025-08-24 | `/lib` | AI Assistant | ✅ 완료 | 프로젝트 루트 통합 문서화, 298줄 README 작성, ⭐⭐⭐⭐⭐ 검증 통과 |
| 2025-08-24 | `/lib/widgets` | AI Assistant | ✅ 완료 | 커스텀 위젯 라이브러리 문서화, 235줄 README 작성, ⭐⭐⭐⭐⭐ 검증 통과 |
| 2025-08-24 | `/lib/utils` | AI Assistant | ✅ 완료 | 유틸리티 함수 라이브러리 문서화, 278줄 README 작성, ⭐⭐⭐⭐⭐ 검증 통과 |
| 2025-08-24 | `/lib/testpage_select` | AI Assistant | ✅ 완료 | 테스트 페이지 네비게이션 허브 문서화, 179줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-24 | `/lib/design_system` | AI Assistant | ✅ 완료 | 디자인 시스템 통합 문서화, 616줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-24 | `/lib/design_system/utils` | AI Assistant | ✅ 완료 | 유틸리티 시스템 문서화, 440줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-24 | `/lib/design_system/tokens` | AI Assistant | ✅ 완료 | 디자인 토큰 시스템 문서화, 530줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-24 | `/lib/design_system/components` | AI Assistant | ✅ 완료 | UI 컴포넌트 라이브러리 문서화, 525줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-24 | `/lib/etc` | AI Assistant | ✅ 완료 | FlutterFlow 레거시 테스트 코드 문서화, 290줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-24 | `/lib/etc/blankppp` | AI Assistant | ✅ 완료 | 로그인 페이지 템플릿 문서화, 122줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-24 | `/lib/etc/phoneloginpincode` | AI Assistant | ✅ 완료 | 전화번호 PIN 인증 문서화, 108줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-24 | `/lib/etc/testalgoria` | AI Assistant | ✅ 완료 | Algolia 검색 테스트 문서화, 120줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-24 | `/lib/etc/testdivider` | AI Assistant | ✅ 완료 | 구분선 컴포넌트 테스트 문서화, 97줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-24 | `/lib/etc/tags_labels` | AI Assistant | ✅ 완료 | 태그/라벨 UI 테스트 문서화, 102줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-24 | `/lib/etc/vsmark` | AI Assistant | ✅ 완료 | VS 브랜드 마크 문서화, 105줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/services` | AI Assistant | ✅ 완료 | 통합 서비스 레이어 문서화, 476줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-28 | `/lib/services/logger` | AI Assistant | ✅ 완료 | Services Logger 레이어 포괄적 문서화 완료: README.md 로깅 시스템 분석 (305줄, AppLogger 메모리 캐시, FileLogger 파일 저장), MIGRATION_Part3.md 3단계 마이그레이션 계획 (Services Layer 유지하며 Clean Architecture 적용, 통합 LoggingService 구축), TEST.md 90% 목표 커버리지 테스트 전략. 주요 개선: 로그 레벨 시스템, 카테고리별 필터링, 배치 처리, 원격 로깅 통합 계획 |
| 2025-08-28 | `/lib/services/moderation` | AI Assistant | ✅ 완료 | Services Moderation 레이어 포괄적 문서화 완료: README.md 콘텐츠 검열 시스템 분석 (609줄 코드, Perspective API/Cloud Vision API/Firestore 통합), MIGRATION_Part3.md 2주 마이그레이션 계획 (Phase 1 긴급: API 키 보안, DI 패턴 적용, Clean Architecture 유지), TEST.md 90% 목표 커버리지 테스트 전략. 주요 개선: 하드코딩된 API 키 환경 변수화, 정적 메서드 제거, 캐싱 시스템 구축, 병렬 처리 최적화 |
| 2025-08-28 | `/lib/services/ui` | AI Assistant | ✅ 완료 | Services UI 레이어 포괄적 문서화 완료: README.md 반응형 UI 서비스 분석 (721줄 코드, ResponsiveBreakpoints/UnifiedBoxCalculator), MIGRATION_Part3.md 4주 마이그레이션 계획 (Phase 1 긴급: 역방향 의존성 제거, DI 패턴 적용, 캐싱 구현), TEST.md 90% 목표 커버리지 테스트 전략. 주요 개선: AspectRatioAnalyzer 의존성 제거, MediaQuery 캐싱, 빌더 패턴 구현, 설정 기반 브레이크포인트 시스템 |
| 2025-08-23 | `/lib/services/cache` | AI Assistant | ✅ 완료 | 3-Layer 캐싱 시스템 문서화, 510줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/shared/constants` | AI Assistant | ✅ 완료 | 레이아웃 상수 시스템 문서화, 315줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/shared/services` | AI Assistant | ✅ 완료 | 통합 박스 계산 서비스 문서화, 376줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/shared` | AI Assistant | ✅ 완료 | 통합 레이아웃 시스템 문서화, 321줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/services/ai_moderation` | AI Assistant | ✅ 완료 | 통합 AI 검열 시스템 문서화, 456줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/services/ai_moderation/text_moderation` | AI Assistant | ✅ 완료 | AI 텍스트 검증 서비스 문서화, 330줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/services/ai_moderation/models` | AI Assistant | ✅ 완료 | AI 검열 데이터 모델 문서화, 422줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/services/ai_moderation/constants` | AI Assistant | ✅ 완료 | AI 검열 설정 모듈 문서화, 376줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/providers` | AI Assistant | ✅ 완료 | Provider 상태 관리 문서화, 404줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/posts` | AI Assistant | ✅ 완료 | Posts 모듈 통합 문서화, 351줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/posts/in_put_post_image` | AI Assistant | ✅ 완료 | 통합 모듈 문서화, 507줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/posts/in_put_post_image/widgets` | AI Assistant | ✅ 완료 | 위젯 컴포넌트 문서화, 541줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/posts/in_put_post_image/widgets/dialogs` | AI Assistant | ✅ 완료 | 다이얼로그 컴포넌트 문서화, 464줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/posts/in_put_post_image/widgets/dialogs/target_audience_steps` | AI Assistant | ✅ 완료 | 타겟 오디언스 UI 문서화, 560줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/posts/in_put_post_image/utils` | AI Assistant | ✅ 완료 | 유틸리티 문서화, 353줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/posts/in_put_post_image/services` | AI Assistant | ✅ 완료 | 서비스 레이어 문서화, 564줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/posts/in_put_post_image/models` | AI Assistant | ✅ 완료 | 타겟 오디언스 모델 문서화, 388줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/posts/in_put_post_image/helpers` | AI Assistant | ✅ 완료 | 헬퍼 클래스 문서화, 423줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/posts/in_put_post_image/delegates` | AI Assistant | ✅ 완료 | 델리게이트 패턴 문서화, 322줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/posts/in_put_post_image/constants` | AI Assistant | ✅ 완료 | 상수 관리 시스템 문서화, 340줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/posts/in_put_post_image/components` | AI Assistant | ✅ 완료 | 재사용 가능한 UI 컴포넌트 문서화, 360줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/pages/search` | AI Assistant | ✅ 완료 | 검색 페이지 문서화, 342줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/pages/profile` | AI Assistant | ✅ 완료 | 사용자 프로필 페이지 문서화, 364줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/pages/pro_image_editor` | AI Assistant | ✅ 완료 | 고급 이미지 편집 페이지 문서화, 345줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/pages/notifications_list` | AI Assistant | ✅ 완료 | 알림 목록 페이지 문서화, 331줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/pages/jop` | AI Assistant | ✅ 완료 | 통합 온보딩 시스템 문서화, 287줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/pages/jop/hobbies_select` | AI Assistant | ✅ 완료 | 취미 선택 페이지 문서화, 289줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/pages/image_viewer` | AI Assistant | ✅ 완료 | 이미지 뷰어 문서화, 324줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/pages/home` | AI Assistant | ✅ 완료 | 메인 피드 화면 문서화, 309줄 README 작성, ⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/pages/chat` | AI Assistant | ✅ 완료 | 통합 채팅 시스템 문서화, 491줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/pages/chat/services` | AI Assistant | ✅ 완료 | 7개 서비스 문서화, 331줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/pages/chat/friends_list` | AI Assistant | ✅ 완료 | 친구 목록 문서화, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/pages/chat/constants` | AI Assistant | ✅ 완료 | 채팅 상수 문서화, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/pages/chat/chat_search` | AI Assistant | ✅ 완료 | 채팅 검색 문서화, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/pages/chat/chat_list` | AI Assistant | ✅ 완료 | 채팅 목록 문서화, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/pages/chat/chat_detail_v2/components` | AI Assistant | ✅ 완료 | 채팅 상세 컴포넌트 문서화, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/pages/chat/chat_detail_v2` | AI Assistant | ✅ 완료 | 메인 채팅 화면 문서화, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/pages/chat/ai_chat_v2` | AI Assistant | ✅ 완료 | AI 채팅 문서화, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/models` | AI Assistant | ✅ 완료 | 데이터 모델 레이어 문서화, 365줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/login/start_page` | AI Assistant | ✅ 완료 | 시작 페이지 문서화, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/login/login_page` | AI Assistant | ✅ 완료 | 로그인 페이지 문서화, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/login/forgot_password` | AI Assistant | ✅ 완료 | 비밀번호 재설정 페이지 문서화, 372줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/login` | AI Assistant | ✅ 완료 | 통합 로그인 시스템 문서화, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/createaccount` | AI Assistant | ✅ 완료 | 통합 계정 생성 시스템 문서화, 382줄 README 작성, ⭐⭐⭐⭐ 검증 통과 |
| 2025-08-23 | `/lib/custom_code` | AI Assistant | 🗑️ 삭제 | FlutterFlow 레거시 코드, 사용처 없음 확인 후 완전 삭제 |
| 2025-08-22 | `/lib/core` | AI Assistant | ✅ 완료 | 핵심 유틸리티 라이브러리 통합 문서화, 474줄 README 작성 |
| 2025-08-22 | `/lib/components` | AI Assistant | ✅ 완료 | 컴포넌트 라이브러리 통합 문서화, 452줄 README 작성 |
| 2025-08-22 | `/lib/backend` | AI Assistant | ✅ 완료 | 백엔드 통합 레이어 문서화, 475줄 README 작성 |
| 2025-08-22 | `/lib/auth` | AI Assistant | ✅ 완료 | 통합 인증 시스템 문서화, 372줄 README 작성 |
| 2025-08-22 | `/lib/actions` | AI Assistant | ✅ 완료 | 문서-코드 불일치 해결, camelCase 적용 |
| 2025-08-28 | `/lib/core/models` | AI Assistant | ✅ 완료 | 포괄적 문서화, MIGRATION_Part3.md 및 TEST.md 작성 |

## 📌 핵심 문서 위치

| 문서 | 경로 | 용도 |
|------|------|------|
| **프로젝트 소개** | `/README.md` | Quick Start 가이드 |
| **시스템 구조** | `/ARCHITECTURE.md` | 아키텍처 및 Functions |
| **기술 상세** | `/CLAUDE.md` | 상세 기술 문서 |
| **변경 이력** | `/CHANGELOG.md` | 버전별 변경사항 |
| **네이밍 가이드** | `/docs/guides/NAMING_CONVENTION.md` | camelCase 표준 |
| **문서 가이드** | `/docs/DOCUMENTATION_GUIDE.md` | 문서 작성 가이드 |

---

*이 문서는 프로젝트 문서화 진행 상황을 추적하는 마스터 인덱스입니다.*

**최종 업데이트**: 2025-08-28  
**문서 버전**: 2.18.0  
**상태**: ✅ 문서화 100% 완료 + 마이그레이션 계획 진행중