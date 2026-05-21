---
name: systemd
description: Systemd service management for applications. Unit files, timers, journalctl, and troubleshooting. Use when creating systemd services for Go binaries, debugging failed units, writing .service or .timer files, configuring service dependencies, hardening services with security directives, managing Docker Compose stacks via systemd, setting up scheduled tasks as timers (cron replacement), or analyzing logs with journalctl. Trigger on mentions of systemd, systemctl, journalctl, unit files, .service files, .timer files, or service management on Linux.
---

# Systemd Service Management for Go Applications

Act as a Linux systems administrator specializing in systemd service management for Go applications. Write correct unit files, debug service failures, and configure timers and dependencies.

## Core Behaviors

**Always:**
- Use `systemctl` for service management (not `service` command)
- Write unit files with proper security hardening
- Use `journalctl` for log inspection
- Set appropriate restart policies
- Document service dependencies

**Never:**
- Run services as root when unnecessary
- Skip `After=` and `Wants=` dependency declarations
- Use `Type=simple` for forking daemons
- Ignore `systemctl daemon-reload` after unit file changes
- Disable SELinux/AppArmor to fix permission issues

## Unit File Patterns

### Basic Go Service

```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My Go Application
After=network.target
Wants=network.target

[Service]
Type=simple
User=appuser
Group=appgroup
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/myapp
Restart=on-failure
RestartSec=5
StartLimitBurst=3
StartLimitIntervalSec=60

# Environment
EnvironmentFile=/opt/myapp/.env
Environment=GOMAXPROCS=4
Environment=GIN_MODE=release

# Logging (Go apps should log to stderr)
StandardOutput=journal
StandardError=journal
SyslogIdentifier=myapp

[Install]
WantedBy=multi-user.target
```

### Security Hardened Go Service

```ini
[Service]
# Run as non-root
User=appuser
Group=appgroup

# Filesystem restrictions
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/myapp/data /var/log/myapp
PrivateTmp=true
NoNewPrivileges=true

# Network restrictions
PrivateNetwork=false
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX

# System call filtering
SystemCallFilter=@system-service
SystemCallErrorNumber=EPERM

# Capabilities (e.g., bind to port <1024 without root)
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE

# Other hardening
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
RestrictRealtime=true
RestrictSUIDSGID=true
LockPersonality=true
```

Note: Omit `MemoryDenyWriteExecute=true` if the Go binary uses cgo or plugins, as the Go runtime may need W+X memory.

### Go Service with Graceful Shutdown

```ini
[Service]
Type=simple
ExecStart=/opt/myapp/myapp
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
TimeoutStopSec=30
```

The Go app should handle `SIGTERM` for graceful shutdown:
```go
ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGTERM, syscall.SIGINT)
defer stop()
```

### Docker Compose Service

```ini
# /etc/systemd/system/mystack.service
[Unit]
Description=My Docker Compose Stack
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=true
WorkingDirectory=/opt/mystack
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
ExecReload=/usr/bin/docker compose up -d --force-recreate

[Install]
WantedBy=multi-user.target
```

### Timer (Cron Replacement)

```ini
# /etc/systemd/system/cleanup.timer
[Unit]
Description=Run cleanup every 6 hours

[Timer]
OnCalendar=*-*-* 00/6:00:00
Persistent=true
RandomizedDelaySec=300

[Install]
WantedBy=timers.target

# /etc/systemd/system/cleanup.service
[Unit]
Description=Cleanup job

[Service]
Type=oneshot
ExecStart=/opt/myapp/cleanup
User=appuser
```

## Essential Commands

```bash
# Service management
systemctl start|stop|restart|reload myapp
systemctl enable|disable myapp          # auto-start on boot
systemctl status myapp                  # current state + recent logs
systemctl is-active myapp               # quick check
systemctl is-enabled myapp

# After editing unit files
systemctl daemon-reload

# List services
systemctl list-units --type=service --state=running
systemctl list-units --type=service --state=failed
systemctl list-timers

# Dependencies
systemctl list-dependencies myapp
systemctl list-dependencies --reverse myapp  # who depends on me?

# Resource usage
systemctl show myapp -p MemoryCurrent,CPUUsageNSec
systemd-cgtop  # live resource usage
```

## Journalctl Patterns

```bash
# View logs for a service
journalctl -u myapp                     # all logs
journalctl -u myapp -f                  # follow (tail)
journalctl -u myapp --since "1 hour ago"
journalctl -u myapp --since "2024-01-15 10:00" --until "2024-01-15 11:00"
journalctl -u myapp -p err              # errors only
journalctl -u myapp -n 50              # last 50 lines
journalctl -u myapp --output json-pretty  # structured output

# Across services
journalctl -u myapp -u nginx --since today

# Boot logs
journalctl -b                           # current boot
journalctl -b -1                        # previous boot
journalctl --list-boots

# Disk usage
journalctl --disk-usage
journalctl --vacuum-size=500M           # trim to 500MB
journalctl --vacuum-time=30d            # keep 30 days
```

## Troubleshooting Failed Services

```bash
# 1. Check status
systemctl status myapp

# 2. Read full logs
journalctl -u myapp -n 100 --no-pager

# 3. Check unit file syntax
systemd-analyze verify /etc/systemd/system/myapp.service

# 4. Check security restrictions
systemd-analyze security myapp

# 5. Test binary manually as the service user
sudo -u appuser /opt/myapp/myapp

# 6. Common failures
# "code=exited, status=217/USER"      → User doesn't exist
# "code=exited, status=226/NAMESPACE" → Security restriction too tight
# "code=exited, status=203/EXEC"      → Binary not found or not executable
# "code=exited, status=200/CHDIR"     → WorkingDirectory doesn't exist
```
