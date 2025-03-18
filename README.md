# 📶 RSSI 모니터링 - 라즈베리파이 기반 블루투스 실시간 분석 시스템

## 📖 1. 프로젝트 소개
![RSSI Notion Thumb](https://github.com/user-attachments/assets/8ff7701e-2ad2-4b41-98c4-41184ceac90e)

- 스피치툴스AI에서 진행한 정부 과제 프로젝트입니다.
- 라즈베리파이를 통해 비콘(작은 블루투스 장치)으로부터 블루투스 세기(**rssi**) 측정, 이를 통해 라즈베이파이와 비콘 간 거리를 추정하는 실험입니다.
- 측정된 블루투스 세기값은 리스트로 100개 모아서 데이터베이스 안에 저장되는데, 서버에서 측정된 값을 실시간으로 앱을 통해 모니터링합니다.
- 서버에서는 앱으로 5개의 데이터를 주기적으로 전송하고, 앱에서는 비콘별로 받은 데이터를 보여줍니다.
  
## 🛠️ 2. 개발 환경

### 🔍 1) 프레임워크 및 언어
- Front-end: Flutter (3.29.0), Dart (3.7.0)
- Back-end: Node.js (20.16.0)

### 🔧 2) 개발 도구
- Android Studio: 2024.2.2
- Xcode: 15.2

### 📱 3) 테스트 환경
- iOS 시뮬레이터: iPhone 15 Pro (iOS 17.2)
- iOS 실제 기기: iPhone 11 (iOS 17.3.1) 
- Android 에뮬레이터: API 레벨 34 (Android 14.0)
- Android 실제 기기: API 레벨 28 (Android 9.0)

### 📚 4) 주요 라이브러리 및 API
- web_socket_channel: 2.4.0

### 🔖 5) 버전 및 이슈 관리
- Git: 2.39.3

### 👥 6) 협업 툴
- 커뮤니케이션: Kakaotalk, Email
- 문서 관리: Notion

### ☁️ 7) 서비스 배포 환경
- 백엔드 서버: 자체 WebSocket 서버 (WSS 프로토콜)
- 배포 방식: 자체 호스팅

## ▶️ 3. 프로젝트 실행 방법

### ⬇️ 1) 필수 설치 사항

#### ① 기본 환경
- Flutter SDK (최소 3.2.3 버전 필요)
- Dart SDK (3.2.3 이상)
- Android Studio (최신 버전)
- Android SDK: Flutter, Dart 플러그인
- Xcode (iOS 개발용, macOS 필요)
- CocoaPods (iOS 의존성 관리, macOS 필요)

#### ② 필수 의존성 패키지
- flutter: SDK
- cupertino_icons: 1.0.2
- intl: 0.19.0
- isolate: 2.1.1

### ⿻ 2) 프로젝트 클론 및 설정
- 프로젝트 클론
```bash
git clone https://github.com/sorongosdev/RssiMeasureApp.git
```
- 의존성 설치
```bash
flutter pub get
```
- iOS 의존성 반영
```bash
pod install
```

### 🌐 3) 개발 서버 실행
```bash
# iOS
flutter build ios

# Android
flutter build apk
```

## 🌿 4. 브랜치 전략
- 중대한 변경 사항이 생길 때 브랜치에서 작업, 그 이외에는 main에서 작업

## 📁 5. 프로젝트 구조
```
├── lib
│   ├── constants
│   │   └── rssi_consts.dart # 서버 주소
│   ├── device_data.dart # 서버에서 받아오는 정보에 관한 데이터 클래스
│   ├── main.dart # 서버 통신, 로직 관련 모든 코드
│   └── my_appbar.dart # 앱바 컴포넌트

```

## 🎭 6. 역할
- 실시간 데이터 수신 및 표시
- 비콘별 탭 자동 생성 및 관리
- 사용자가 보고 있는 탭 유지 기능(탭 추가 시에도)
- 데이터 시각화(텍스트 형태로 값 표시)

## 📅 7. 개발 기간
2024.04 ~ 2024.05 (2개월)
