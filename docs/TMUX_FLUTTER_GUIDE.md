# iTerm2 + tmux Flutter 멀티 디바이스 개발 가이드

## 🚀 빠른 시작

### 1. 멀티 디바이스 실행 (추천)
```bash
# 모든 연결된 디바이스에서 앱 실행
fdev

# 또는
tmux-flutter
```

### 2. 개발 세션 시작
```bash
# 사전 구성된 개발 환경 실행
tmux-versus
```

## 📱 주요 명령어

### Flutter 관련 명령어
- `fdev` - 모든 디바이스에서 앱 실행 (멀티 디바이스 스크립트)
- `fdevices` - 연결된 디바이스 목록 확인
- `frun` - Flutter 앱 실행
- `frun-device <device-id>` - 특정 디바이스에서 실행
- `frun-all` - 모든 디바이스에서 동시 실행
- `fpubget` - 패키지 업데이트
- `fclean` - Flutter 클린
- `fbuild-ios` - iOS 빌드
- `fbuild-apk` - Android APK 빌드
- `fbuild-web` - 웹 빌드

### tmux 관련 명령어
- `tmux-versus` - Versus Space 개발 세션 시작
- `tmux-flutter` - Flutter 멀티 디바이스 세션 시작
- `tm` - tmux 단축 명령
- `tma <session-name>` - 세션에 연결
- `tmk <session-name>` - 세션 종료
- `tml` - 세션 목록 확인

### 프로젝트 이동
- `versus` - 프로젝트 루트로 이동
- `versus-func` - Firebase Functions 디렉토리로 이동

## ⌨️ tmux 키보드 단축키

모든 명령은 prefix key (`Ctrl+a`) 다음에 입력합니다.

### 기본 조작
- `Ctrl+a d` - 세션에서 분리 (detach)
- `Ctrl+a ?` - 모든 단축키 보기
- `Ctrl+a r` - tmux 설정 다시 로드

### 윈도우 관리
- `Ctrl+a c` - 새 윈도우 생성
- `Ctrl+a 0-9` - 윈도우 0-9로 이동
- `Ctrl+a n` - 다음 윈도우
- `Ctrl+a p` - 이전 윈도우
- `Ctrl+a w` - 윈도우 목록

### 패널 관리
- `Ctrl+a |` - 수평 분할
- `Ctrl+a -` - 수직 분할
- `Ctrl+a 방향키` - 패널 간 이동
- `Alt+방향키` - 패널 간 빠른 이동 (prefix 없이)
- `Ctrl+a H/J/K/L` - 패널 크기 조정 (5칸씩)
- `Ctrl+a x` - 현재 패널 닫기

### 복사 모드
- `Ctrl+a [` - 복사 모드 진입
- `Space` - 선택 시작 (vim 모드)
- `Enter` - 복사 및 종료
- `Ctrl+a ]` - 붙여넣기

## 📋 세션 구조

### versus-dev 세션 (개발용)
```
Window 0: main
├── Pane 0: 메인 터미널 (편집, git 등)
├── Pane 1: Flutter 로그
└── Pane 2: 디바이스 모니터링

Window 1: devices
├── Pane 0-3: 각 디바이스별 Flutter run

Window 2: backend
├── Pane 0: Firebase Functions 개발
└── Pane 1: Firebase 배포

Window 3: testing
├── Pane 0: 유닛 테스트
└── Pane 1: 통합 테스트

Window 4: performance
└── 성능 프로파일링
```

### versus-flutter 세션 (멀티 디바이스 실행용)
```
Window 0: devices
├── 각 연결된 디바이스별 자동 분할
└── 최대 4개 디바이스 표시 (추가 디바이스는 새 윈도우)

Window 1: control
└── 컨트롤 터미널 (git, 편집 등)
```

## 🔥 Flutter Hot Reload/Restart

Flutter 앱이 실행 중인 패널에서:
- `r` - Hot Reload
- `R` - Hot Restart
- `q` - 앱 종료
- `p` - 성능 오버레이 토글
- `o` - iOS/Android 모드 전환
- `h` - 도움말

## 💡 활용 팁

### 1. 첫 실행 시
```bash
# 터미널 재시작 또는 설정 적용
source ~/.zshrc

# iTerm2 실행 후
fdev  # 모든 디바이스에서 앱 실행
```

### 2. 특정 디바이스에서만 실행
```bash
# 디바이스 목록 확인
fdevices

# 특정 디바이스 실행
frun-device iPhone-15-Pro
```

### 3. 기존 세션 재연결
```bash
# 세션 목록 확인
tml

# 세션 연결
tma versus-flutter
```

### 4. 새 디바이스 추가
```bash
# 이미 세션이 있는 상태에서
tmux-flutter-device <device-id> <window-name>
```

## 🛠️ 문제 해결

### tmux 세션이 남아있을 때
```bash
# 모든 tmux 세션 종료
tmux kill-server

# 특정 세션만 종료
tmk versus-flutter
```

### 디바이스가 인식되지 않을 때
```bash
# Flutter 디바이스 재스캔
flutter doctor
flutter devices
```

### 스크립트 권한 문제
```bash
chmod +x /Users/g_black/versus-cursor/scripts/*.sh
```

## 📁 파일 위치

- tmux 설정: `~/.tmux.conf`
- zsh 설정: `~/.zshrc`
- 멀티 디바이스 스크립트: `/Users/g_black/versus-cursor/scripts/flutter_multi_device.sh`
- 세션 템플릿 스크립트: `/Users/g_black/versus-cursor/scripts/tmux_flutter_session.sh`

## 🎯 추천 워크플로우

1. iTerm2 실행
2. `tmux-versus` 실행하여 개발 환경 준비
3. Window 0에서 코드 편집
4. Window 1로 이동 (`Ctrl+a 1`)
5. 각 패널에서 다른 디바이스 실행
6. `Alt+방향키`로 패널 간 빠른 이동
7. Hot Reload (`r`)로 변경사항 즉시 확인

이제 여러 디바이스에서 동시에 Flutter 앱을 개발하고 테스트할 수 있습니다! 🚀