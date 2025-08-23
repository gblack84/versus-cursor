# 🚫 Phone Maximum - 전화번호 인증 초과 알림 페이지

> SMS 인증 시도 횟수 초과 시 표시되는 경고 모달 컴포넌트

## 📋 개요

`phonemaximum` 디렉토리는 Versus Space 앱의 전화번호 인증 시도 횟수 제한 알림 UI를 구현합니다. 사용자가 SMS 인증을 3회 이상 시도했을 때 표시되는 모달 다이얼로그로, 보안을 위한 Rate Limiting 정책을 사용자에게 안내하는 역할을 합니다.

### 주요 기능
- SMS 인증 최대 시도 횟수 초과 알림
- 모달 다이얼로그 형태의 경고 UI
- VS 로고 표시 (VsmarkWidget 통합)
- 전화번호 입력 페이지로 리다이렉션
- 다국어 지원 (i18n)

## 🎯 네이밍 컨벤션

### 파일명
- ✅ **snake_case 사용**: `phonemaximum_widget.dart`, `phonemaximum_model.dart`
- ✅ **위젯/모델 접미사**: 역할을 명확히 구분

### 클래스명
- ✅ **PascalCase 사용**: `PhonemaximumWidget`, `PhonemaximumModel`
- ✅ **Widget/Model 접미사**: 컴포넌트 타입 명시

### 필드 및 메서드
- ✅ **camelCase 사용**: `vsmarkModel`
- ✅ **Model 접미사**: 하위 컴포넌트 모델 참조

참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### 1. PhonemaximumWidget (172줄)

**역할**: SMS 인증 초과 경고 모달 UI 표시

**라우팅 정보**:
- 직접 라우팅 없음 (모달 컴포넌트로 사용)
- `showDialog()` 또는 `showModalBottomSheet()`로 표시

**UI 구조**:
- **컨테이너**: 둥근 모서리 (30px) 배경 컨테이너
- **VS 로고**: VsmarkWidget 통합 (200.46 x 56.5 크기)
- **경고 메시지**: 최대 시도 횟수 초과 안내
- **확인 버튼**: "Ok" 버튼으로 모달 닫기 및 페이지 이동

**주요 위젯 구조**:
```dart
Align(
  alignment: AlignmentDirectional(0.0, 0.0),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30.0),
    ),
    child: Column(
      children: [
        // VS 로고
        VsmarkWidget(),
        // 경고 메시지
        Text('You have exceeded the maximum...'),
        // Ok 버튼
        AppButtonWidget(onPressed: () {...})
      ],
    ),
  ),
)
```

### 2. PhonemaximumModel (22줄)

**역할**: 상태 관리 및 하위 컴포넌트 모델 관리

**상태 필드**:
```dart
// VS 로고 컴포넌트 모델
late VsmarkModel vsmarkModel;
```

**초기화**:
```dart
@override
void initState(BuildContext context) {
  vsmarkModel = createModel(context, () => VsmarkModel());
}
```

## 🔄 사용자 플로우

### 시나리오: SMS 인증 3회 초과
1. **트리거**: phonelogeinpincode 페이지에서 3회 재전송 시도
2. **모달 표시**: PhonemaximumWidget이 다이얼로그로 표시
3. **메시지 확인**: 사용자가 초과 메시지 읽기
4. **Ok 버튼 클릭**: 
   - 현재 모달 닫기 (`Navigator.pop(context)`)
   - 전화번호 입력 페이지로 이동 (`PhoneCreatAccountWidget`)

### 네비게이션 처리
```dart
AppButtonWidget(
  onPressed: () async {
    // 1. 현재 모달 닫기
    Navigator.pop(context);
    
    // 2. 전화번호 입력 페이지로 이동
    context.pushNamed(
      PhoneCreatAccountWidget.routeName,
      queryParameters: {
        'phoneNumberParam': serializeParam('', ParamType.String),
      },
    );
  },
  text: 'Ok',
)
```

## 🎨 UI/UX 특징

### 디자인 스타일
- **배경색**: `secondaryBackground` (테마 기반)
- **모서리**: 전체 둥근 모서리 30px
- **정렬**: 중앙 정렬 (AlignmentDirectional.center)
- **패딩**: 각 섹션별 8-12px 패딩

### 버튼 스타일
```dart
AppButtonOptions(
  width: 80.0,
  height: 40.0,
  color: primaryText,
  textStyle: titleSmall (white),
  borderRadius: 8.0,
  hoverColor: #E0E3E7,
)
```

### 텍스트 스타일
- **메시지 폰트**: Plus Jakarta Sans
- **폰트 크기**: 20px
- **폰트 두께**: 800 (Extra Bold)
- **정렬**: 중앙 정렬

## 🌍 국제화 (i18n)

### 번역 키
```dart
'3dcoy1cp' - "You have exceeded the maximum number of attempts..."
'vgyx5a8r' - "Ok"
```

### 지원 언어
- **English (en)**: 기본 언어
- **German (de)**: 번역 키 준비

## 📱 위젯 트리 구조

```
Align (center)
└── Container (rounded 30px)
    └── Column
        ├── Container (VS Logo)
        │   └── VsmarkWidget
        ├── Container (Message)
        │   └── Text (경고 메시지)
        └── AppButtonWidget (Ok 버튼)
```

## 🔗 연관 페이지 및 네비게이션

### 진입 경로
- `/phonelogeinpincode` → 3회 재전송 시도 시 모달로 표시

### 이동 경로
- Ok 버튼 → `/phoneCreatAccount` (전화번호 입력 페이지)

## 🛡️ 보안 고려사항

### Rate Limiting
- **목적**: SMS 남용 방지 및 비용 절감
- **제한**: 3회 시도 후 차단
- **재시도**: 처음부터 다시 시작 필요
- **시간 제한**: 세션 기반 또는 시간 기반 리셋

### 사용자 경험
- **명확한 안내**: 초과 이유 설명
- **다음 단계 제시**: Ok 버튼으로 재시작 유도
- **간단한 UI**: 혼란 최소화

## 🐛 알려진 이슈 및 개선사항

### 현재 이슈
1. **하드코딩된 크기**: VS 로고 크기 하드코딩 (200.46 x 56.5)
2. **빈 전화번호 전달**: phoneNumberParam에 빈 문자열 전달
3. **중복 스타일 속성**: fontWeight, fontStyle 중복 설정

### 개선 제안
1. **쿨다운 타이머**: 재시도 가능 시간 표시
2. **대체 인증 방법**: 이메일 인증 등 대안 제시
3. **고객 지원 링크**: 문제 지속 시 도움 요청 방법
4. **세부 정보**: 남은 시간, 차단 해제 조건 등 추가 정보

## 📊 사용 시나리오

### 정상 플로우
1. 사용자가 SMS 코드 입력 실패
2. "Re Code" 버튼으로 재전송 (1-2회)
3. 3회째 시도 시 PhonemaximumWidget 표시
4. Ok 클릭 후 전화번호 재입력

### 예외 상황
- **네트워크 오류**: SMS 발송 실패도 카운트에 포함
- **잘못된 번호**: 유효하지 않은 번호도 카운트
- **시스템 오류**: 내부 오류도 사용자 관점에서는 동일 처리

## 💡 모범 사례

### 사용 방법
```dart
// 모달로 표시
showDialog(
  context: context,
  barrierDismissible: false,  // 배경 클릭 방지
  builder: (context) => PhonemaximumWidget(),
);
```

### 상태 관리
- 재전송 카운트는 상위 컴포넌트에서 관리
- PhonemaximumWidget은 순수 UI 컴포넌트
- 네비게이션 로직만 포함

## 📝 변경 이력

- **2025-08-23**: README 전면 재작성 (코드 분석 기반)
- **2025-08-22**: 초기 생성
- **2025-07-03**: FlutterFlow에서 Native Flutter로 마이그레이션

---

**문서 버전**: 2.0.0  
**최종 업데이트**: 2025-08-23  
**작성**: AI Assistant