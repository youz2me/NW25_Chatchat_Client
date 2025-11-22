# Socket을 활용한 실시간 채팅 iOS 클라이언트

<br>

## 🚀 프로젝트 소개

> TCP Socket 통신 기반 실시간 채팅 클라이언트 애플리케이션을 구현했습니다.
> Apple의 `Network.framework`를 활용하여 서버와 지속적인 연결을 유지하며, JSON 기반 커스텀 프로토콜로 메시지를 주고받습니다.
> **Clean Architecture**와 **MVVM 패턴**을 적용하여 네트워크 계층과 UI 계층을 명확히 분리했으며, **Combine**을 통해 서버에서 전송되는 PUSH 이벤트를 반응형으로 처리하도록 구현했습니다.

<br>

## 📚 주요 기능

- **실시간 채팅**: TCP Socket 기반 양방향 통신
- **다중 채팅방**: 채팅방 생성, 입장, 퇴장
- **귓속말**: 1:1 비밀 메시지 전송
- **사용자 상태**: 온라인/자리비움/다른용무 상태 관리
- **PUSH 알림**: 서버 이벤트 실시간 수신 (새 메시지, 입퇴장 등)
- **회원 관리**: 회원가입, 로그인, 비밀번호 찾기

<br>

## 🏰 네트워크 아키텍처

```
┌─────────────────────────────────────────────────────────────────┐
│                      Presentation Layer                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │   Views     │──│ ViewModels  │──│  Combine Subscriptions  │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Domain Layer                             │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                      UseCases                            │    │
│  │   Login / Register / SendMessage / JoinRoom / ...        │    │
│  └─────────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                      Entities                            │    │
│  │   UserEntity / MessageEntity / ChatRoomEntity / ...      │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Core Layer                              │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    Repositories                          │    │
│  │   AuthRepository / ChatRepository / RoomRepository       │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                   Protocol Layer                         │    │
│  │   Request Builder / Response Parser / MessageParser      │    │
│  └─────────────────────────────────────────────────────────┘    │
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    Socket Layer                          │    │
│  │         SocketClient (NWConnection 기반)                 │    │
│  │   - TCP 연결 관리                                         │    │
│  │   - 메시지 버퍼링                                         │    │
│  │   - 이벤트 발행 (Combine Publisher)                       │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   TCP Server    │
                    └─────────────────┘
```

<br>

### 📡 Socket Layer

`Network.framework`의 `NWConnection`을 활용한 TCP 소켓 클라이언트입니다.

```swift
final class SocketClient: SocketClientProtocol {
    private let eventSubject = PassthroughSubject<ServerEvent, Never>()
    private var connection: NWConnection?
    private var receiveBuffer = ""

    // 연결 상태 이벤트 발행
    var eventPublisher: AnyPublisher<ServerEvent, Never>

    // 비동기 연결
    func connect(host: String, port: UInt16) async throws

    // 메시지 전송 + 응답 대기
    func sendAndWait(_ message: String, timeout: TimeInterval) async throws -> String
}
```

**핵심 설계 포인트**:

- **비동기 연결 관리**: `async/await`와 `CheckedContinuation`을 활용한 연결 상태 처리
- **메시지 버퍼링**: TCP 스트림 특성상 메시지가 분할/합쳐질 수 있으므로 `\n` 구분자 기반 버퍼링
- **PUSH/Response 분리**: 서버 메시지를 PUSH 이벤트와 요청 응답으로 구분하여 처리
- **Thread Safety**: `NSLock`을 활용한 버퍼 및 연결 상태 동기화

<br>

### 📋 Protocol Layer

JSON 기반 커스텀 프로토콜로 서버와 통신합니다.

**Request 빌더 (Factory Pattern)**:
```swift
struct Request {
    static func login(userId: String, password: String) -> Request
    static func sendMessage(roomId: String, content: String) -> Request
    static func joinRoom(_ roomId: String) -> Request
    // ...
}
```

**Response 파서**:
```swift
enum MessageParser {
    static func parseResponse(_ raw: String) -> RawResponse?
    static func parsePushEvent(_ raw: String) -> PushEvent
    static func parseUserList(from response: RawResponse) -> [UserEntity]
}
```

<br>

### 📦 Repository Layer

Socket 통신을 도메인 로직에서 추상화합니다.

```swift
// Protocol 정의 (Domain Layer)
protocol AuthRepositoryProtocol {
    func login(userId: String, password: String) async throws -> SessionEntity
    func register(...) async throws
    var sessionPublisher: AnyPublisher<SessionEntity?, Never> { get }
}

// 구현체 (Core Layer)
final class AuthRepository: AuthRepositoryProtocol {
    private let socketClient: SocketClientProtocol

    func login(userId: String, password: String) async throws -> SessionEntity {
        let request = Request.login(userId: userId, password: password)
        let response = try await socketClient.sendAndWait(request.rawString)
        // Response 파싱 및 Entity 변환
    }
}
```

<br>

## 📑 프로토콜 설계

### Request Format

```json
{
    "command": "LOGIN",
    "data": {
        "userId": "user123",
        "password": "password"
    }
}
```

**지원 명령어**:

| 카테고리 | 명령어 | 설명 |
|---------|--------|------|
| 인증 | `REGISTER`, `CHECK_ID`, `LOGIN`, `LOGOUT`, `FIND_PW` | 회원 관리 |
| 사용자 | `STATUS`, `USER_LIST` | 상태 변경, 사용자 목록 |
| 채팅 | `MSG`, `WHISPER`, `TYPING` | 메시지, 귓속말, 타이핑 |
| 채팅방 | `ROOM_CREATE`, `ROOM_LIST`, `ROOM_JOIN`, `ROOM_LEAVE`, `ROOM_USERS` | 채팅방 관리 |

### Response Format

```json
{
    "status": "OK",
    "message": "LOGIN_SUCCESS",
    "data": {
        "sessionToken": "abc123",
        "userName": "홍길동"
    }
}
```

**상태 코드**:

| Status | 설명 |
|--------|------|
| `OK` | 요청 성공 |
| `FAIL` | 요청 실패 (message에 에러 코드) |
| `PUSH` | 서버 푸시 이벤트 |

### PUSH Event

서버에서 클라이언트로 일방적으로 전송하는 실시간 이벤트입니다.

```json
{
    "status": "PUSH",
    "message": "NEW_MSG",
    "data": {
        "roomId": "room1",
        "senderId": "user2",
        "senderName": "김철수",
        "content": "안녕하세요!",
        "timestamp": "2025-11-22 14:30:00"
    }
}
```

**PUSH 이벤트 종류**:

| 이벤트 | 설명 |
|--------|------|
| `NEW_MSG` | 새 메시지 수신 |
| `WHISPER` | 귓속말 수신 |
| `USER_JOINED` | 사용자 입장 |
| `USER_LEFT` | 사용자 퇴장 |
| `TYPING` | 타이핑 상태 변경 |
| `STATUS_CHANGED` | 사용자 상태 변경 |
| `ROOM_CREATED` | 새 채팅방 생성 |

<br>

## 🤔 설계 주요 포인트

### 1. Clean Architecture 적용

계층별 명확한 책임 분리로 테스트 용이성과 유지보수성을 확보했습니다.

```
Presentation → Domain ← Core
     ↓            ↓        ↓
  ViewModel    UseCase  Repository
     ↓            ↓        ↓
    View       Entity   SocketClient
```

- **Domain Layer**: 비즈니스 로직 (UseCase, Entity, Repository Protocol)
- **Core Layer**: 인프라 구현 (Socket, Repository 구현체, DTO)
- **Presentation Layer**: UI (SwiftUI View, ViewModel)

### 2. Combine을 활용한 PUSH 이벤트 처리

서버에서 전송하는 PUSH 이벤트를 Combine Publisher로 구독하여 반응형으로 처리합니다.

```swift
// SocketClient에서 이벤트 발행
eventSubject.send(.messageReceived(socketMessage))

// Repository에서 필터링하여 재발행
socketClient.eventPublisher
    .compactMap { event -> PushEvent? in
        guard case .messageReceived(let msg) = event else { return nil }
        return MessageParser.parsePushEvent(msg.raw)
    }
    .sink { pushEvent in
        // 이벤트 타입별 처리
    }

// ViewModel에서 UI 업데이트
chatRepository.messagePublisher
    .receive(on: DispatchQueue.main)
    .sink { [weak self] message in
        self?.messages.append(message)
    }
```

### 3. Request/Response 분리 처리

TCP 소켓은 요청-응답 매칭이 보장되지 않아 FIFO 큐를 활용하여 응답을 대기 중인 요청에 전달합니다.

```swift
// 요청 전송 시 Continuation을 큐에 추가
func sendAndWait(_ message: String) async throws -> String {
    try send(message)
    return try await waitForResponse()  // Continuation 등록
}

// 응답 수신 시 PUSH/Response 구분
private func processMessage(_ message: String) {
    if isPushMessage(message) {
        eventSubject.send(.messageReceived(socketMessage))  // PUSH → 이벤트 발행
    } else {
        deliverResponse(message)  // Response → 대기 중인 요청에 전달
    }
}
```

### 4. DI Container를 통한 의존성 관리

앱 시작 시 Assembler를 통해 의존성을 등록하고, ViewModel에서 주입받아 사용합니다.

```swift
// 의존성 등록 (AppAssembler)
container.register(SocketClient(), for: SocketClientProtocol.self)
container.register(AuthRepository(socketClient: socketClient), for: AuthRepositoryProtocol.self)
container.register(LoginUseCase(authRepository: authRepository), for: LoginUseCaseProtocol.self)

// 의존성 주입 (ViewModelFactory)
func makeLoginViewModel() -> LoginViewModel {
    LoginViewModel(loginUseCase: container.resolve(LoginUseCaseProtocol.self))
}
```

### 5. 메시지 버퍼링

TCP 스트림 특성상 메시지가 분할되거나 합쳐질 수 있으므로, `\n` 구분자 기반 버퍼링을 구현했습니다.

```swift
private func handleReceivedData(_ data: Data) {
    receiveBuffer += String(data: data, encoding: .utf8) ?? ""

    // 줄바꿈으로 메시지 분리
    while let range = receiveBuffer.range(of: "\n") {
        let message = String(receiveBuffer[..<range.lowerBound])
        receiveBuffer = String(receiveBuffer[range.upperBound...])
        processMessage(message)
    }
}
```

<br>

## 📁 프로젝트 구조

```
Chatchat/
├── Sources/
│   ├── App/
│   │   ├── ChatchatApp.swift          # 앱 진입점
│   │   ├── AppDelegate.swift          # DI 초기화
│   │   └── RootView.swift             # 인증 상태 기반 화면 분기
│   │
│   ├── Core/
│   │   ├── Common/
│   │   │   ├── Constants.swift        # 프로토콜 상수
│   │   │   └── ServerConfig.swift     # 서버 설정
│   │   │
│   │   ├── DI/
│   │   │   ├── DependencyContainer.swift
│   │   │   ├── DependencyAssembler.swift
│   │   │   └── ViewModelFactory.swift
│   │   │
│   │   └── Network/
│   │       ├── Socket/
│   │       │   ├── SocketClient.swift        # TCP 클라이언트
│   │       │   ├── SocketClientProtocol.swift
│   │       │   ├── SocketError.swift
│   │       │   └── SocketMessage.swift
│   │       │
│   │       ├── Protocol/
│   │       │   ├── Request.swift             # 요청 빌더
│   │       │   ├── Response.swift            # 응답 타입
│   │       │   ├── MessageParser.swift       # JSON 파서
│   │       │   └── ChatProtocol.swift
│   │       │
│   │       ├── DTO/
│   │       │   ├── AuthDTO.swift
│   │       │   ├── ChatDTO.swift
│   │       │   ├── RoomDTO.swift
│   │       │   └── ...
│   │       │
│   │       └── Repository/
│   │           ├── AuthRepository.swift
│   │           ├── ChatRepository.swift
│   │           └── RoomRepository.swift
│   │
│   ├── Domain/
│   │   ├── Entity/
│   │   │   ├── UserEntity.swift
│   │   │   ├── MessageEntity.swift
│   │   │   ├── ChatRoomEntity.swift
│   │   │   └── SessionEntity.swift
│   │   │
│   │   ├── UseCase/
│   │   │   ├── Auth/
│   │   │   ├── Chat/
│   │   │   └── Room/
│   │   │
│   │   └── RepositoryProtocol/
│   │       ├── AuthRepositoryProtocol.swift
│   │       ├── ChatRepositoryProtocol.swift
│   │       └── RoomRepositoryProtocol.swift
│   │
│   └── Presentation/
│       ├── DesignSystem/
│       │   ├── Colors.swift
│       │   ├── Fonts.swift
│       │   └── Components/
│       │
│       ├── Auth/
│       │   ├── Login/
│       │   ├── Register/
│       │   └── FindPassword/
│       │
│       └── Chat/
│           ├── RoomList/
│           └── ChatRoom/
│
└── Resources/
    └── Font/
```

<br>

## 🛠 기술 스택

| 구분 | 기술 |
|------|------|
| Language | Swift 5.9+ |
| UI | SwiftUI |
| Architecture | Clean Architecture + MVVM |
| Networking | Network.framework (NWConnection) |
| Reactive | Combine |
| DI | Custom DI Container |
| Build | Tuist |

<br>

## 🚀 실행 방법

1. **프로젝트 클론**
   ```bash
   git clone https://github.com/youz2me/NW25_Chatchat_Client.git
   cd NW25_Chatchat_Client
   ```

2. **Tuist 설치** (미설치 시)
   ```bash
   curl -Ls https://install.tuist.io | bash
   ```

3. **프로젝트 생성**
   ```bash
   tuist generate
   ```

4. **서버 설정**
   - `ServerConfig.swift`에서 서버 주소와 포트 설정
   ```swift
   static let host = "your-server-host"
   static let port: UInt16 = 9000
   ```

5. **Xcode에서 실행**
   - `Chatchat.xcworkspace` 열기
   - 시뮬레이터 또는 실제 기기에서 실행
