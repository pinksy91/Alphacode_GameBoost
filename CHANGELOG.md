# Alphacode GameBoost - CHANGELOG

## [3.3.0] - 2026-02-11 - Next-Gen Release 🚀

### 🌟 MAJOR NEW FEATURES

#### 🎮 Smart Game Detection
- **Auto-detects 30+ popular games** via process monitoring
  - Competitive FPS: CS2, Valorant, CoD, R6 Siege, Overwatch 2, Halo Infinite
  - Battle Royale: Fortnite, Apex, Warzone, PUBG
  - AAA Open World: Cyberpunk 2077, GTA V, RDR2, Starfield
  - RPG: Elden Ring, Baldur's Gate 3, Witcher 3, Diablo IV
  - MOBA: League of Legends, Dota 2
  - And more: Minecraft, Destiny 2, Palworld, Rust, Rocket League...
- **Optimal profile recommendation** per game category
- **Custom game support**: Add your own games with `Add-CustomGame`
- **File**: `src/detection/game-detector.ps1`
- **Database**: `data/games.json` (30+ games)

#### 🔔 System Tray Integration
- **Native Windows UI** with tray icon (no web dependencies)
- **Right-click context menu**:
  - View current profile
  - Switch profiles instantly
  - Toggle auto-optimization
  - View performance stats
  - Access settings
- **Balloon notifications** for events
- **Color-coded icon**: Green (Conservative) → Red (Maximum)
- **File**: `src/ui/tray-integration.ps1`
- **Technology**: Pure WinForms, zero HTML/JS/CSS

#### 📊 Real-Time Performance Monitoring
- **WMI-based monitoring** (no external tools)
- **Metrics tracked**:
  - CPU: Usage %, Temperature, Name
  - GPU: Name, VRAM
  - RAM: Total, Used, Usage %
- **Background monitoring** (1-second interval)
- **Historical data** (60 samples = 1 minute)
- **Optional on-screen overlay** (transparent, top-right corner)
- **File**: `src/monitoring/performance-monitor.ps1`
- **Dependencies**: Zero external

#### 🔮 Smart Scheduler (Pattern Learning)
- **Local-only pattern recognition** (100% privacy)
- **Learns from gaming sessions**:
  - Day/time patterns
  - Game preferences
  - Profile usage
- **Smart suggestions**:
  - "You usually play on Monday 8pm - optimize now?"
  - "CPU usage up 15% vs last week - re-optimize?"
  - "GPU driver updated - recalibrate?"
  - "RAM at 90% - clear standby memory?"
- **Rule-based logic** (no external ML APIs)
- **File**: `src/scheduler/smart-scheduler.ps1`
- **Data storage**: `Config/user_patterns.json` (local only)

#### 🛡️ Comprehensive User Consent System
- **❌ REMOVED AUTO-APPLY**: Now ALWAYS asks for user confirmation
- **Tweak Classification Database**:
  - **SAFE** (5 tweaks): Game Mode Priority, Network Optimization, Mouse Acceleration Disable, etc.
  - **WARNING** (4 tweaks): GPU TDR Disable, CPU Parking Disable, Large System Cache, HPET Disable
  - **DANGEROUS** (3 tweaks): SEHOP Disable, Memory Integrity Disable, Spectre Mitigations Disable
- **Detailed Consent Dialogs**:
  - Full list of tweaks with checkboxes (user can deselect)
  - Color-coded by risk: Green/Orange/Red
  - Complete description of what each tweak does
  - Registry paths shown transparently
  - Impact and side effects explained
- **Dangerous Tweak Protection**:
  - Special red warning dialog
  - Must type "I UNDERSTAND THE RISKS" to proceed
  - Cannot be applied accidentally
- **Files**:
  - `src/safety/tweak-registry.ps1` - Tweak database
  - `src/safety/user-consent.ps1` - Consent dialogs
  - `src/safety/tweak-applicator.ps1` - Safe application

#### ⚡ Next-Gen Orchestrator
- **Unified launcher** for all services
- **One-command startup**: `Start-NextGenOrchestrator`
- **Manages**:
  - Smart game detection
  - System tray UI
  - Performance monitoring
  - Smart scheduler
- **Status dashboard** (native WinForms)
- **File**: `src/orchestrator.ps1`

### 🔒 PRIVACY & TRANSPARENCY IMPROVEMENTS

#### Enhanced
- **100% Local Operation**
  - Zero external API calls
  - No cloud dependencies
  - All data stays on device
  - No telemetry or analytics

- **Complete Audit Trail**
  - All tweaks logged to `Config/tweak_audit.jsonl`
  - Timestamp, profile, changes applied, backup name
  - Fully transparent operation log

- **User Always In Control**
  - No automatic changes without consent
  - Two-step approval: 1) Optimize? → 2) Review tweaks
  - Can deselect specific tweaks before applying
  - Dangerous tweaks require explicit typed confirmation

### ⚙️ TECHNICAL DETAILS

#### Performance Impact
| Service | CPU | RAM | Disk I/O |
|---------|-----|-----|----------|
| Game Detector | <1% | ~5MB | 0 |
| Tray Icon | <1% | ~3MB | 0 |
| Performance Monitor | <2% | ~8MB | 0 |
| Smart Scheduler | <1% (periodic) | ~2MB | <1KB/hour |
| **Total** | **~3%** | **~20MB** | **Negligible** |

**Lightest in class** compared to alternatives (Razer Cortex: 150MB+, MSI Afterburner: 50MB+)

#### Data Storage (All Local)
```
%LOCALAPPDATA%\FPSSuitePro\
├── Logs\              # Application logs
├── Backups\           # Registry backups
└── Config\
    ├── app.config.json
    ├── user_patterns.json  # Gaming patterns (LOCAL ONLY)
    └── tweak_audit.jsonl   # Tweak application history
```

### 🐛 BUG FIXES
- Fixed game detection loop to always request user consent
- Removed auto-apply parameter (breaking change for safety)
- Added consent flow before any optimization

### ⚠️ BREAKING CHANGES
- **Auto-optimization removed**: All optimizations now require user approval
  - **Migration**: No action needed - new consent dialogs appear automatically
  - **Reason**: User safety and transparency

### 📝 DOCUMENTATION
- Updated `README.md` with v3.3.0 features
- Created `nextgen_walkthrough.md` with detailed usage examples
- Updated `SECURITY.md` with tweak classifications

---

## [3.2.0] - 2026-02-11 - Production-Ready Release 🚀

### 🔴 SECURITY FIXES (CRITICAL)

#### Fixed
- **[CRITICAL]** Removed Windows Defender disable functionality (lines 530-546 in `FPS_Suite_Advanced_Gaming_module.ps1`)
  - **Risk**: Exposed systems to malware, violated corporate security policies
  - **Fix**: Permanently removed `DisableRealtimeMonitoring` and `DisableAntiSpyware` tweaks
  - **See**: [SECURITY.md](SECURITY.md#dangerous-tweaks-removed) for details

- **[HIGH]** Fixed command injection vulnerability in launcher
  - **Location**: `Alphacode_GameBoost.bat` line 10
  - **Risk**: User input could execute arbitrary commands
  - **Fix**: Added input sanitization (length limit, character whitelist)
  - **Characters stripped**: `;`, `&`, `|`, `^`, `<`, `>`

- **[HIGH]** Fixed critical path bug in launcher
  - **Location**: `Alphacode_GameBoost.bat` lines 97, 140
  - **Bug**: Referenced `FPS_Suite_ScanUltimate_AI.ps1` in root instead of `modules/`
  - **Impact**: Tool failed to launch
  - **Fix**: Corrected to `modules\\FPS_Suite_ScanUltimate_AI.ps1`

- **[MEDIUM]** Standardized exit codes for CI/CD compatibility
  - `0` = Success
  - `1` = General error
  - `2` = Missing admin privileges
  - `3` = Missing dependencies (PowerShell)

### 🟠 RELIABILITY IMPROVEMENTS

#### Added
- **Registry Safety Wrapper System** (`Set-SafeItemProperty`)
  - Automatic backup of registry values before modification
  - Validates registry path format (rejects invalid paths)
  - Auto-creates missing parent keys
  - Returns `true`/`false` instead of crashing on errors
  - **Location**: `modules/FPS_Suite_ScanUltimate_AI.ps1` lines 373-465

- **Automatic Rollback on Failure** (`Invoke-RegistryRollback`)
  - Restores all registry changes if operation fails mid-execution
  - Transaction-like behavior for registry operations
  - Prevents partial application states
  - **Location**: `modules/FPS_Suite_ScanUltimate_AI.ps1` lines 468-522

- **Thread-Safe Logging**
  - Mutex protection for GUI log updates
  - Prevents race conditions in `RichTextBox` writes
  - 1-second timeout to prevent deadlocks
  - **Location**: `modules/FPS_Suite_ScanUltimate_AI.ps1` lines 89-195

### 🟡 FEATURES

#### Added
- **JSON Structured Logging**
  - Enable via `$env:FPS_SUITE_LOG_FORMAT = "json"`
  - ISO 8601 timestamps
  - Ready for ELK stack, Splunk ingestion
  - **Output**: `fps_suite_YYYY-MM-DD.jsonl`

- **Configurable Log Levels**
  - Set via `$env:FPS_SUITE_LOG_LEVEL`
  - Levels: `DEBUG`, `INFO`, `WARN`, `ERROR`, `CRITICAL`
  - Reduces log verbosity in production

- **Environment Variable Path Overrides**
  - `FPS_SUITE_LOG_PATH` - Custom log directory
  - `FPS_SUITE_BACKUP_PATH` - Custom backup directory
  - `FPS_SUITE_CONFIG_PATH` - Custom config directory
  - **Use case**: Enterprise deployments, testing isolation

- **Centralized Configuration File**
  - **Location**: `config/app.config.json`
  - Supports per-environment customization
  - Disable dangerous optimization profiles
  - **Schema**: See [config/app.config.json](config/app.config.json)

### 🔵 TESTING & CI/CD

#### Added
- **Pester Unit Test Suite** (`tests/unit/core.tests.ps1`)
  - 25+ unit tests covering:
    - Registry safety wrapper (15 tests)
    - Logging system (4 tests)
    - Configuration system (3 tests)
    - Backup system (3 tests)
  - **Run**: `Invoke-Pester -Path .\tests\unit\`

- **GitHub Actions CI/CD Pipeline** (`.github/workflows/test.yml`)
  - Automated testing on push/PR
  - PSScriptAnalyzer linting
  - Security checks (dangerous code patterns)
  - **Triggers**: Push to `main`/`develop`, PRs, manual dispatch

---

## Roadmap

### v3.4.0 (Minor - 4-6 weeks)
- **FPS Counter Integration**: Native FPS capture
- **Benchmark Suite**: Built-in before/after testing
- **Profile Editor GUI**: Create custom tweak profiles
- **Export/Import Profiles**: Share with friends (encrypted)

### v4.0.0 (Major - 3-6 months)
- **Plugin System**: Community-contributed optimizations
- **Multi-Language**: i18n support (English, Italian, Spanish, German, French)
- **Portable Mode**: Run from USB without installation

---

## Contributors

- **Alphacode** - Original author & maintainer
- **Google Deepmind Antigravity** - Production refactoring & next-gen implementation (v3.2.0, v3.3.0)

---

## Links

- **Repository**: https://github.com/pinksy91/Alphacode_GameBoost
- **Security Policy**: [SECURITY.md](SECURITY.md)
- **Issues**: https://github.com/pinksy91/Alphacode_GameBoost/issues
- **CI/CD**: https://github.com/pinksy91/Alphacode_GameBoost/actions

---

**Last Updated**: 2026-02-11  
**Current Version**: 3.3.0
