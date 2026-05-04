# WALNUT
> RTOS-Guarded Network UPS Tool

Milk-V Duo의 듀얼 아키텍처(Linux + RTOS)를 기반으로 하는 전원 관리 시스템. NUT서버를 통한 UPS 모니터링과 RTOS 기반의 호스트 상태 로직이 결합된 UPS 관리 모듈. Linux가 Panic 상태에 빠졌거나 응답 불능 상태가 되는 경우, RTOS가 fail-safe를 수행하여, 물리 제어권을 유지하여 시스템의 안정성을 유지한다.

## Tech Stack
- hardware: Milk-V Duo 256
- OS: Buildroot (Linux Kernal)
- RTOS: FreeRTOS
- Language: C, Rust
- Communication: Mailbox IPC

## System Architecture
1. Monitoring: Linux NUT daemon이 APC UPS(USB-HID)를 관리. 시스템은 이를 통해 전원 상태를 조회한다.
2. IPC 통신: Linux는 2초를 주기로 UPS 상태를 Mailbox IPC를 통해 RTOS로 전송.
3. Guard Logic: 
  - Heartbeat 기반의 watchdog, 비상 상황 시 RTOS가 직접 GPIO(Relay) 제어 및 강제 shut-down 수행. 
  - 시스템 종료 혹은 비상 상황 발생 시, LED를 점등하여 사용자에게 즉각적 가시 경고 제공.
4. Post-Mortem Reporting: 시스템 복구 후 RTOS 로그 기반의 장애 원인 보고.

## Structure
```
walnut/
├── configs/
│   └── nut/                # configuration for NUT (ups.conf, upsd.conf etc.)
├── duo-buildroot-sdk-v2/   #SDK submodule
├── justfile
└── ...
```

## Development Environment
일관된 빌드 환경을 유지하기 위해 Docker와 just 커맨드 러너를 사용한다.

1. Prerequisties
- Docker
- just
- Git

2. Setup
프로젝트를 클론 한 후, `just setup` 명령어를 통해 SDK 서브모듈을 동기화하고 빌드 이미지를 준비한다.

3. Menuconfig
`just menuconfig` 명령어를 통해 옵션을 수정한다
`Target packages` -> `System tools` -> `nut` 체크


4. Build
`just build` 명령어를 통해 시스템 이미지를 생성한다.
