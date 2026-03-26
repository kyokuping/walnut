# WALNUT
> RTOS-Guarded Network UPS Tool

Milk-V Duo의 듀얼 아키텍처(Linux + RTOS)를 기반으로 하는 전원 관리 시스템. NUT서버를 통한 UPS 모니터링과 RTOS 기반의 호스트 상태 로직이 결합된 UPS 관리 모듈. Linux가 Panic 상태에 빠졌거나 응답 불능 상태가 되는 경우, RTOS가 fail-safe를 수행하여, 물리 제어권을 유지하여 시스템의 안정성을 유지한다.

## Tech Stack
- hardware: Milk-V Duo 256
- OS: Buildroot (Linux Kernal)
- RTOS: FreeRTOS
- Language: C, Rust
- Communication Mailbox IPC

## System Architecture
1. Monitoring: Linux NUT daemon이 APC UPS(USB-HID)에서 상태 수집.
2. IPC 통신: Linux는 2초를 주기로 UPS 상태를 Mailbox IPC를 통해 RTOS로 전송.
3. Guard Logic: 
  - Heartbeat 기반의 watchdog, 비상 상황 시 RTOS가 직접 GPIO(Relay) 제어 및 물리적 shut-down 수행. 
  - 시스템 종료 혹은 비상 상황 발생 시, LED를 점등하여 사용자에게 즉각적 가시 경고 제공.
4. Post-Mortem Reporting: 시스템 복구 후 RTOS 로그 기반의 장애 원인 보고.
