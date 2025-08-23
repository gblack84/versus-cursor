# 👤 Character Detail Page - 캐릭터 선택 바텀시트

> Versus Space 앱의 사용자 프로필 캐릭터(아바타)를 선택하는 바텀시트 컴포넌트입니다. 사전 정의된 캐릭터 목록에서 선택하거나 갤러리/카메라에서 커스텀 이미지를 업로드할 수 있는 인터페이스를 제공합니다.

## 📋 개요

Character Detail Page는 사용자가 프로필 이미지를 변경할 때 표시되는 모달 바텀시트입니다. Firestore의 characters 컬렉션에서 캐릭터 이미지를 실시간으로 가져와 그리드 형태로 표시하며, 사용자가 선택한 캐릭터를 즉시 프로필에 적용할 수 있습니다. 또한 갤러리나 카메라를 통해 커스텀 이미지를 업로드하는 기능도 제공합니다.

### 🎯 주요 목적
- **캐릭터 선택**: 사전 정의된 캐릭터 중 선택
- **커스텀 업로드**: 갤러리/카메라에서 이미지 업로드
- **실시간 적용**: 선택 즉시 프로필 업데이트
- **시각적 피드백**: 선택된 캐릭터 하이라이트

## 🏗️ 디렉토리 구조

```
/lib/pages/user_info/character_detail_page/
├── character_detail_page_widget.dart    # 메인 UI 구현 (317줄)
├── character_detail_page_model.dart     # 상태 관리 모델 (24줄)
└── README.md                            # 문서 파일
```

### 📊 코드 통계
- **총 코드 라인**: 341줄
- **파일 수**: 2개
- **주요 컴포넌트**: CharacterDetailPageWidget
- **의존성**: 10개 (Flutter, Firebase, CachedNetworkImage 등)
- **구현 상태**: 완전 구현됨

## 📐 네이밍 컨벤션

### 파일명
- **패턴**: snake_case (Dart 표준)
- **접미사**: `_widget`, `_model`
- **예시**: `character_detail_page_widget.dart`

### 클래스명
- **패턴**: PascalCase
- **접미사**: `Widget`, `Model`, `State`
- **예시**: `CharacterDetailPageWidget`, `_CharacterDetailPageWidgetState`

### 변수 및 메서드
- **패턴**: camelCase
- **private**: 언더스코어 접두사 (`_`)
- **예시**: `selectedCharacterUrl`, `isDataUploading_userUploadProfileImage`

> 참조: [프로젝트 전체 네이밍 컨벤션](../../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소

### 1. CharacterDetailPageWidget - 메인 바텀시트 위젯 👤

**캐릭터 선택을 위한 모달 바텀시트 StatefulWidget입니다.**

#### UI 구조
- **높이**: 450px 고정
- **배경색**: #ECECEC (연한 회색)
- **모서리**: 상단 30px 둥근 모서리
- **패딩**: 6px 전체 패딩

#### 위젯 계층
```dart
Container(
  height: 450,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(30),
      topRight: Radius.circular(30),
    ),
  ),
  child: Column(
    // 캐릭터 그리드
    // Apply 버튼
    // Gallery/Camera 버튼
  ),
)
```

### 2. 캐릭터 그리드 시스템 🎭

**Firestore에서 캐릭터를 가져와 표시하는 GridView입니다.**

```dart
StreamBuilder<List<CharactersModel>>(
  stream: queryCharactersModel(),
  builder: (context, snapshot) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,           // 4열 그리드
        crossAxisSpacing: 10.0,       // 가로 간격
        mainAxisSpacing: 10.0,        // 세로 간격
        childAspectRatio: 1.0,        // 정사각형 비율
      ),
      itemBuilder: (context, index) {
        // 캐릭터 아이템 빌드
      },
    );
  },
)
```

#### 그리드 특징
- **열 개수**: 4개 고정
- **아이템 크기**: 정사각형 (1:1 비율)
- **스크롤**: 세로 스크롤 가능
- **컨테이너 크기**: 380x300 픽셀

### 3. 캐릭터 아이템 컴포넌트 🖼️

**개별 캐릭터를 표시하는 원형 아이템입니다.**

```dart
Container(
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
      color: _model.selectedCharacterUrl == 
             gridViewCharactersModel.charactersImageUrl
        ? Color(0xFF6E6E6E)  // 선택됨
        : Color(0x00FFFFFF), // 선택 안됨
    ),
  ),
  child: InkWell(
    onTap: () async {
      _model.selectedCharacterUrl = 
        gridViewCharactersModel.charactersImageUrl;
      setState(() {});
    },
    child: CachedNetworkImage(
      imageUrl: gridViewCharactersModel.charactersImageUrl,
      fit: BoxFit.cover,
    ),
  ),
)
```

#### 특징
- **모양**: 원형 (CircleAvatar 스타일)
- **선택 표시**: 회색 테두리 (#6E6E6E)
- **이미지 로딩**: CachedNetworkImage 사용
- **애니메이션**: 500ms fade in/out

### 4. Apply 버튼 시스템 ✅

**선택한 캐릭터를 프로필에 적용하는 버튼입니다.**

```dart
AppButtonWidget(
  onPressed: () async {
    await currentUserReference!.update(createUsersModelData(
      photoUrl: _model.selectedCharacterUrl,
    ));
    Navigator.pop(context);
  },
  text: 'Apply',
  options: AppButtonOptions(
    height: 40.0,
    color: Colors.black,
    textStyle: Colors.white,
    borderRadius: BorderRadius.circular(8.0),
  ),
)
```

#### 동작 과정
1. 선택된 캐릭터 URL 가져오기
2. Firestore 사용자 문서 업데이트
3. 바텀시트 닫기
4. 프로필 이미지 즉시 반영

### 5. Gallery/Camera 업로드 시스템 📸

**커스텀 이미지를 업로드하는 기능입니다.**

```dart
AppButtonWidget(
  onPressed: () async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      maxWidth: 800.00,
      maxHeight: 800.00,
      imageQuality: 70,
      allowPhoto: true,
    );
    
    // 이미지 업로드 처리
    if (selectedMedia != null) {
      // Firebase Storage 업로드
      downloadUrls = await uploadData(m.storagePath, m.bytes);
      
      // 프로필 업데이트
      await currentUserReference!.update(createUsersModelData(
        photoUrl: uploadedFileUrl,
      ));
    }
  },
)
```

#### 업로드 설정
- **최대 크기**: 800x800 픽셀
- **이미지 품질**: 70%
- **소스**: 갤러리 또는 카메라
- **파일 형식**: 이미지만 허용

### 6. CharacterDetailPageModel - 상태 관리 📊

**위젯의 상태를 관리하는 모델 클래스입니다.**

```dart
class CharacterDetailPageModel extends AppModel<CharacterDetailPageWidget> {
  // 선택된 캐릭터 URL
  String selectedCharacterUrl = '\" \"';
  
  // 업로드 상태
  bool isDataUploading_userUploadProfileImage = false;
  AppUploadedFile uploadedLocalFile_userUploadProfileImage;
  String uploadedFileUrl_userUploadProfileImage = '';
}
```

#### 상태 필드
- **selectedCharacterUrl**: 현재 선택된 캐릭터 URL
- **isDataUploading**: 업로드 진행 상태
- **uploadedLocalFile**: 로컬 업로드 파일
- **uploadedFileUrl**: Firebase Storage URL

## 💡 사용 가이드

### 바텀시트 호출
```dart
// 프로필 페이지에서 호출
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => CharacterDetailPageWidget(),
);
```

### 캐릭터 선택 플로우
1. 바텀시트 열기
2. 캐릭터 그리드에서 원하는 캐릭터 탭
3. 선택된 캐릭터에 테두리 표시
4. Apply 버튼 클릭
5. 프로필 업데이트 및 바텀시트 닫기

### 커스텀 이미지 업로드 플로우
1. Gallery/Camera 버튼 클릭
2. 소스 선택 (갤러리 또는 카메라)
3. 이미지 선택/촬영
4. 자동 크기 조정 (800x800)
5. Firebase Storage 업로드
6. 프로필 자동 업데이트

## 🎨 디자인 시스템

### 색상 팔레트
- **배경**: `#ECECEC` (연한 회색)
- **테두리**: `#989EA7` (중간 회색)
- **선택 테두리**: `#6E6E6E` (진한 회색)
- **버튼 배경**: `Colors.black`
- **버튼 텍스트**: `Colors.white`

### 간격 및 크기
- **바텀시트 높이**: 450px
- **그리드 컨테이너**: 380x300px
- **그리드 간격**: 10px
- **버튼 높이**: 40px
- **모서리 반경**: 30px (바텀시트), 8px (버튼)

### 애니메이션
- **이미지 페이드**: 500ms
- **선택 피드백**: 즉시 반영
- **바텀시트 슬라이드**: 기본 Material 애니메이션

## 🚀 성능 최적화

### 이미지 캐싱
- **CachedNetworkImage**: 네트워크 이미지 캐싱
- **메모리 캐시**: 자동 메모리 관리
- **디스크 캐시**: 영구 저장소 캐싱

### 스트림 최적화
- **단일 스트림**: characters 컬렉션 실시간 감시
- **자동 정리**: dispose()에서 스트림 해제
- **로딩 표시**: SpinKitRing 로딩 인디케이터

### 업로드 최적화
- **이미지 압축**: 70% 품질로 압축
- **크기 제한**: 800x800 최대 크기
- **병렬 처리**: Future.wait으로 동시 업로드

## 📚 의존성

### 현재 의존성
```dart
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/backend/firebase_storage/storage.dart';
import '/core/app_theme.dart';
import '/core/app_utils.dart';
import '/core/app_widgets.dart';
import '/core/upload_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
```

### 핵심 의존성
- **Firebase Auth**: 사용자 인증
- **Firestore**: 캐릭터 데이터 및 프로필 저장
- **Firebase Storage**: 커스텀 이미지 업로드
- **CachedNetworkImage**: 이미지 캐싱
- **FlutterSpinKit**: 로딩 애니메이션

## 🔧 개선 사항 (TODO)

### 우선순위 높음
1. **디자인 시스템 적용**: VersusDesign System으로 마이그레이션
2. **에러 처리**: 업로드 실패 시 에러 메시지 표시
3. **이미지 검증**: 부적절한 이미지 필터링

### 우선순위 중간
4. **애니메이션 개선**: 선택 시 스케일 효과
5. **검색 기능**: 캐릭터 검색 필터
6. **카테고리**: 캐릭터 카테고리별 분류

### 우선순위 낮음
7. **커스텀 편집**: 이미지 크롭/필터 기능
8. **최근 선택**: 최근 사용한 캐릭터 표시
9. **즐겨찾기**: 자주 사용하는 캐릭터 저장

## 🐛 알려진 이슈

### 현재 이슈
1. **AppTheme 사용**: 구형 테마 시스템 사용 중
   - VersusDesign System으로 마이그레이션 필요
   
2. **초기값 문제**: selectedCharacterUrl 초기값이 '\" \"'
   - 빈 문자열로 변경 필요

3. **스네이크케이스 사용**: 일부 변수명이 스네이크케이스
   - isDataUploading_userUploadProfileImage → isDataUploadingUserUploadProfileImage

### 해결 방법
- 디자인 시스템 전면 적용
- 초기값 로직 개선
- 네이밍 컨벤션 통일

## 📅 변경 이력

| 날짜 | 버전 | 변경 내용 | 작업자 |
|------|------|----------|--------|
| 2025-08-23 | v1.0.0 | README 문서 작성 완료 | AI Assistant |
| 2025-08-22 | v0.1.0 | 초기 페이지 생성 | 개발팀 |

## 🔗 관련 문서

- [전체 Pages 구조](../../README.md)
- [사용자 정보 페이지](../README.md)
- [프로필 페이지](../../profile/README.md)
- [Firebase 백엔드](../../../backend/README.md)
- [네이밍 컨벤션](../../../NAMING_CONVENTION.md)

## 📌 구현 예제

### 커스텀 캐릭터 그리드
```dart
class CustomCharacterGrid extends StatelessWidget {
  final List<String> characterUrls;
  final String? selectedUrl;
  final Function(String) onSelect;
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,  // 5열로 변경
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: characterUrls.length,
      itemBuilder: (context, index) {
        final isSelected = selectedUrl == characterUrls[index];
        return GestureDetector(
          onTap: () => onSelect(characterUrls[index]),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(characterUrls[index]),
            ),
          ),
        );
      },
    );
  }
}
```

### 프로필 업데이트 서비스
```dart
class ProfileImageService {
  static Future<void> updateProfileImage(String imageUrl) async {
    try {
      await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({'photoUrl': imageUrl});
      
      // 로컬 캐시 업데이트
      UserCacheService.updateUserImage(imageUrl);
      
      // UI 리프레시
      ProfileProvider.refresh();
    } catch (e) {
      throw Exception('프로필 이미지 업데이트 실패: $e');
    }
  }
}
```

---

*이 문서는 Versus Space 앱의 캐릭터 선택 바텀시트 구현을 상세히 설명합니다.*
*최종 업데이트: 2025-08-23*