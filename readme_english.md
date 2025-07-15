<p align="center">
  <img src="assets/logo.png" width="180" alt="Alphacode GameBoost Logo"/>
</p>

<h1 align="center">Alphacode GameBoost</h1>

<p align="center">
  <strong>Ultimate Edition v3.1.0 — Professional Gaming Optimization Suite</strong><br>
  All-in-one optimizer for Windows 10/11 — powered by <a href="https://github.com/Alphacode" target="_blank"><strong>Alphacode</strong></a>
</p>

<p align="center">
  <a href="https://github.com/Alphacode"><img src="https://img.shields.io/badge/powered%20by-Alphacode-blue?style=flat-square&logo=github"></a>
  <img src="https://img.shields.io/badge/Windows-10%2F11-blue?logo=windows">
  <img src="https://img.shields.io/badge/version-3.1.0-brightgreen?style=flat-square">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg"></a>
</p>

---

## 🚀 What is Alphacode GameBoost?

**Alphacode GameBoost** is the ultimate modular suite for gaming performance optimization on Windows. Designed for competitive gamers, enthusiasts, content creators, and power users who want to **push every component to the maximum** with safety, backup, and AI analysis.

* 🎮 Profiles: Conservative, Balanced, Aggressive, Maximum
* 🧠 Real-time AI analysis: detection, recommendations, reports
* 🔧 Advanced tweaks: CPU, GPU, memory, network, registry
* 💾 Automatic and selective backup/restore
* 🖥️ Modern GUI with logs, progress, status, and quick actions
* 🏆 Next-gen compatibility: Zen 5, Arrow Lake, RTX 5090, RX 9000, Battlemage

---

## 🖥️ System Requirements

* **OS**: Windows 10 (19041+) or 11 (x64 only)
* **PowerShell**: v5.1+ (v7 recommended)
* **Permissions**: Administrator
* **Space**: 50 MB free (backup/logs)
* **Internet Connection**: only for updates/AI (optional)
* **Antivirus**: Tool folder exclusion recommended

---

## 🏗️ Repository Structure

```text
Alphacode_GameBoost/
├── assets/
│   ├── logo.png           # Main logo
│   ├── gameboost.png      # Alternative GameBoost logo
│   ├── 1.png              # Dashboard UI
│   ├── 2.png              # Optimization status
│   ├── 3.png              # AI Scanner
│   └── 4.png              # Result screen
├── modules/
│   ├── FPS_Suite_Advanced_Gaming_module.ps1
│   └── FPS_Suite_ScanUltimate_AI.ps1
├── Alphacode_GameBoost.bat        # Main launcher
├── README.md                      # This file
└── LICENSE                        # MIT License
```

---

## 🚦 Installation & First Launch

### 1. Download

git clone https://github.com/pinksy91/Alphacode_GameBoost.git or download ZIP and extract the folder wherever you prefer

### 2. Launch

* Go to the extracted folder
* **Right-click on** `Alphacode_GameBoost.bat` → **Run as administrator**
* Follow on-screen instructions: GUI launches and prompts for profile selection (Balanced recommended for first time)

### 3. Safety

* **Automatic backup** before every optimization
* **1-click restore** always available

---

## 📸 Screenshots

<p align="center">
  <img src="assets/1.png" width="340" alt="Main Dashboard"/><br>
  <b>Main Dashboard</b>
</p>
<p align="center">
  <img src="assets/2.png" width="340" alt="Optimization Status"/><br>
  <b>Optimization Status</b>
</p>
<p align="center">
  <img src="assets/3.png" width="340" alt="AI Scanner"/><br>
  <b>AI Scanner</b>
</p>
<p align="center">
  <img src="assets/4.png" width="340" alt="Result Screen"/><br>
  <b>Result Screen</b>
</p>

---

## 🎮 Optimization Profiles

| Profile          | Brief Description                          | Target               | Risk        |
| ---------------- | ------------------------------------------ | -------------------- | ----------- |
| 🛡️ Conservative | Light and safe optimizations               | Beginners, work      | Very low    |
| ⚖️ Balanced      | Balance between performance and stability   | Gaming, daily use    | Low         |
| 🚀 Aggressive    | High performance, acceptable stability      | Competitive gaming   | Moderate    |
| 🔥 Maximum       | Maximum performance, requires monitoring    | Enthusiasts, OC      | High        |

---

## 🧠 AI Analysis and Intelligent Scanner

* **Auto-detection**: CPU, GPU, RAM, compatibility
* **Conflicts**: Reports incompatible or risky optimizations
* **Suggestions**: Ideal profile, recommended tweaks
* **Reports**: Log export, backup, advanced comparison
* **JSON Export**: Raw data for troubleshooting/analysis

---

## 🔧 Available Optimizations

### Gaming & System

* **GPU/CPU Priority**: Scheduling and performance boost
* **System Responsiveness**: Minimal latency
* **GameDVR Off**, Hardware Scheduling On, DWM Tweaks, TDR Level

### Memory & Storage

* **Paging Executive**, **Large System Cache**
* **Memory Compression Off**, **Prefetch Tuning**

### CPU & Process

* **Processor Parking Off**, **Priority Separation**
* **Interrupt Handling**, **High-resolution timers**

### Network

* **TCP Optimizations** (CTCP, ECN)
* **Network Throttling Off**
* **DNS Caching, QoS Gaming**

### Backup and Restore

* **Automatic and timestamped**
* **Total/selective restore**
* **Backup integrity verification**

---

## 🧬 Hardware Compatibility

CPU:

* AMD Ryzen 5000/7000/8000/9000 (Zen 3/4/5/X3D)
* Intel 12/13/14 Gen, Arrow Lake (K, HX, H)

GPU:

* NVIDIA RTX 30/40/50 (Blackwell included)
* AMD Radeon RX 6000/7000/9000 (including Navi 44)
* Intel ARC Alchemist, Battlemage

RAM:

* DDR4 & DDR5 

Other:

* PCIe 5.0, USB4, Wi-Fi 6E, desktop, laptop, and AIO systems

---

## ❓ FAQ

**Are changes reversible?** Yes, every operation is preceded by automatic backup with immediate restore.

**Is AI really useful?** The AI module identifies critical issues, conflicts, suggests profiles, and compares performance — useful for those seeking efficiency without risks.

**Is the tool safe?** Everything is open source, no telemetry, no tracking. Inspect every script freely.

**Does it support latest generation hardware?** Yes, validated on Zen 5, Arrow Lake, RTX 5090, RX 9000, Battlemage.

---

## 🛠️ Troubleshooting & Logs

* **Execution Policy**: Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned` from PowerShell as admin
* **Antivirus**: Add exclusion for the tool folder
* **Logs**: `%LOCALAPPDATA%\FPSSuitePro\Logs` Backup in `%LOCALAPPDATA%\FPSSuitePro\Backups`
* **Restore**: Always accessible from GUI and CLI

---

## ⚠️ Warnings, Disclaimer and Limitations

**Warning:** This tool applies advanced optimizations and deep system modifications. Some tweaks are powerful and should only be used if aware of the risks: improper use can cause instability, incompatibility, or data loss.

**You use the tool at your own risk.** Neither the developer, collaborators, nor the community are responsible for any damage, malfunctions, or data loss resulting from the use of Alphacode GameBoost. Before applying changes, it's always recommended to make complete backups and test on non-critical systems.

* Always create backups before important changes
* Test more aggressive optimizations before critical sessions
* The tool is designed only for Windows 10/11 x64
* Some optimizations are hardware-dependent

---

## 🤝 Contributing

How to contribute:

1. Fork the repo
2. Create a branch for your feature/patch
3. Test on multiple systems
4. Document and submit a pull request

**Bug reports**: Open an Issue on GitHub, attach logs, system info, and steps to reproduce.

---

## 📄 License

Distributed under MIT License.
See [LICENSE](LICENSE) for details.

* Commercial use: Allowed with attribution
* Modification and redistribution: Free, without warranties

---

## 👨‍💻 Credits

* **Alphacode** — Development, architecture, GUI, AI modules
* **Community** — Testing, suggestions, feedback
* **Microsoft** — Windows API documentation, PowerShell
* **Special Thanks**: Beta testers & contributors (add the names you want)

---

**Real power. Total control. Conscious optimization. Only with Alphacode GameBoost.**

---

## ⭐️ Support the Project

If the tool is useful to you, leave a ⭐ on GitHub: https://github.com/pinksy91/Alphacode_GameBoost Share and help us improve with feedback!

---

## Useful Links

* **Official Repository**: https://github.com/pinksy91/Alphacode_GameBoost
* **Alphacode Profile**: https://github.com/Alphacode
* **Report Issues/Bugs**: https://github.com/pinksy91/Alphacode_GameBoost/issues
* **MIT License**: LICENSE
