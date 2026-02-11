# Security Policy

## Supported Versions

| Version | Supported         |
| ------- | ------------------ |
| 3.2.x   | ✅ Full support    |
| 3.1.x   | ⚠️ Security fixes only |
| < 3.0   | ❌ No longer supported |

## Reporting a Vulnerability

**DO NOT** open public issues for security vulnerabilities.

Instead, email: **security@alphacode-gameboost.local** (placeholder - update with actual contact)

Include:
- Description of vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

Expected response time: **72 hours**

---

## Known Security Considerations

### ⚠️ Administrator Privileges Required

This tool **REQUIRES** administrator privileges to modify system registry.

**Never run untrusted versions of this software with admin rights.**

### Registry Modifications

All registry changes are:
- ✅ **Backed up** before application via `Set-Safe ItemProperty`
- ✅ **Reversible** via built-in restore function (`Invoke-RegistryRollback`)
- ✅ **Logged** in `%LOCALAPPDATA%\FPSSuitePro\Logs`
- ✅ **Validated** for path format and existence

### Dangerous Tweaks Removed in v3.2.0

The following tweaks have been **PERMANENTLY REMOVED** for security compliance:

| Removed Tweak | Reason | Risk Level |
|--------------|--------|-----------|
| **Windows Defender Real-Time Protection Disable** | Exposes system to malware | 🔴 CRITICAL |
| **Windows Defender Anti-Spyware Disable** | Violates corporate security policies | 🔴 CRITICAL |

**If you need to disable Windows Defender for performance testing:**
1. Do it **manually** via Windows Security settings
2. **Understand the security risks**
3. **Re-enable immediately** after testing

### High-Risk Tweaks (Still Present - Use with Caution)

The following tweaks are **flagged as high-risk** and require explicit confirmation:

| Tweak | Location | Risk | Mitigation |
|-------|----------|------|-----------|
| **TDR Level 0** (GPU timeout disable) | Advanced Module | Can cause system freezes | Only for stable, tested systems |
| **SEHOP Disabled** (Security mitigation) | Advanced Module | Reduces exploit protection | Not recommended |
| **Processor Parking Manipulation** | Advanced Module | thermal instability | Monitor temperatures |

### Input Validation (v3.2.0+)

All user inputs are now sanitized:
- ✅ Maximum length limits (20 characters for codes)
- ✅ Character whitelist (alphanumeric + safe chars only)
- ✅ Command injection prevention (`;`, `&`, `|`, `^`, `<`, `>` stripped)

### Thread Safety (v3.2.0+)

- ✅ Mutex-protected GUI updates prevent race conditions
- ✅ Registry backup stack is transaction-safe
- ✅ Log file writes are serialized

---

## Security Audit History

- **2026-02-11**: Comprehensive security audit completed
- **2026-02-11**: Removed Windows Defender disable functionality
- **2026-02-11**: Added input validation for all user inputs
- **2026-02-11**: Implemented registry safety wrappers (`Set-SafeItemProperty`)
- **2026-02-11**: Thread-safe logging with mutex
- **2026-02-11**: Configurable paths via environment variables

---

## User Responsibility

By using this software, you acknowledge that:

- ✅ You understand the **risks** of system optimization
- ✅ You have created a **Windows restore point**
- ✅ You accept **full responsibility** for any system instability
- ✅ You will **not hold the developers liable** for any damage

---

## Secure Configuration

### Recommended Environment Variables

For enhanced security and portability, configure custom paths:

```powershell
# PowerShell
$env:FPS_SUITE_LOG_PATH = "D:\SecureLogs\GameBoost"
$env:FPS_SUITE_BACKUP_PATH = "D:\SecureBackups\GameBoost"
$env:FPS_SUITE_LOG_LEVEL = "INFO"  # or "WARN" for less verbose
```

```batch
REM Batch
set FPS_SUITE_LOG_PATH=D:\SecureLogs\GameBoost
set FPS_SUITE_BACKUP_PATH=D:\SecureBackups\GameBoost
set FPS_SUITE_LOG_LEVEL=INFO
```

### Dry-Run Mode (Planned - v3.3.0)

Future versions will support `--dry-run` flag to preview changes without applying them.

---

## Code Audit

The codebase follows these security practices:

- ✅ **No hardcoded credentials** (zero found in audit)
- ✅ **No external network calls** (air-gapped operation)
- ✅ **Input validation** on all user-provided data
- ✅ **Registry path validation** (format checking)
- ✅ **Automatic rollback** on operation failures
- ✅ **Comprehensive logging** for audit trail
- ⚠️ **Admin privileges required** (unavoidable for registry access)

---

## Compliance

### Data Privacy

Alphacode GameBoost:
- ❌ Does **NOT** collect telemetry
- ❌ Does **NOT** transmit data over the network
- ❌ Does **NOT** phone home
- ✅ **All operations are local-only**

### Open Source

This project is open-source. You can:
- ✅ Audit the code yourself
- ✅ Modify for personal use
- ✅ Report security issues responsibly

---

## Contact

For security concerns: **[Update with actual contact method]**

For general issues: https://github.com/pinksy91/Alphacode_GameBoost/issues

---

**Last Updated**: 2026-02-11  
**Security Version**: 3.2.0
