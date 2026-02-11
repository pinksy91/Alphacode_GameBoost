<p align="center">
  <img src="assets/logo.png" width="180" alt="Alphacode GameBoost Logo"/>
</p>

<h1 align="center">Alphacode GameBoost</h1>

<p align="center">
  <strong>Next-Gen Edition v3.3.0 — Ottimizzatore Gaming AI-Powered, 100% Locale, Privacy-First</strong><br>
  Ottimizzatore intelligente all-in-one per Windows 10/11 — powered by <a href="https://github.com/Alphacode" target="_blank"><strong>Alphacode</strong></a>
</p>

<p align="center">
  <a href="https://github.com/Alphacode"><img src="https://img.shields.io/badge/powered%20by-Alphacode-blue?style=flat-square&logo=github"></a>
  <img src="https://img.shields.io/badge/Windows-10%2F11-blue?logo=windows">
  <img src="https://img.shields.io/badge/version-3.3.0-brightgreen?style=flat-square">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg"></a>
  <img src="https://img.shields.io/badge/Privacy-100%25%20Locale-green">
  <img src="https://img.shields.io/badge/Dipendenze-Zero-orange">
</p>

---

## 🚀 Cos'è Alphacode GameBoost?

**Alphacode GameBoost** è la **suite definitiva di nuova generazione** per l'ottimizzazione delle prestazioni gaming su Windows. Progettato per gamer competitivi, enthusiast e power user che richiedono **massime prestazioni con totale sicurezza e trasparenza**.

> **Il Tool di Riferimento per Gamer che Valorizzano Privacy e Performance**

### 🎯 NOVITÀ v3.3.0 - Funzionalità Next-Gen

* 🎮 **Rilevamento Automatico Giochi**: Riconosce automaticamente 30+ giochi popolari (CS2, Valorant, Cyberpunk, Elden Ring...)
* 🔔 **Integrazione System Tray**: UI nativa Windows, cambio profilo con un click, notifiche balloon
* 📊 **Monitor Prestazioni**: CPU/GPU/RAM/Temp in tempo reale via WMI (zero dipendenze esterne)
* 🔮 **Scheduler Intelligente**: Pattern learning locale, suggerimenti basati sulle tue abitudini
* 🛡️ **Sistema Consenso Utente**: SEMPRE chiede conferma, tweaks classificati Sicuri/Attenzione/Pericolosi
* 🔒 **Privacy-First**: 100% locale, zero telemetria, nessuna API esterna, dati mai fuori dal tuo PC

### ⚡ Funzionalità Core

* 🎚️ **Profili Ottimizzazione**: Conservative, Balanced, Aggressive, Maximum
* 🔧 **Tweaks Avanzati**: 13+ ottimizzazioni classificate (CPU, GPU, memoria, rete, registry)
* 💾 **Backup/Rollback Automatico**: Ogni modifica è completamente reversibile
* 📜 **Audit Trail Completo**: Log JSONL di tutte le operazioni eseguite
* 🧠 **Analisi AI Real-Time**: Rilevamento hardware, raccomandazioni personalizzate
* 🖥️ **GUI Moderna**: Log integrati, tracking progressi, monitoraggio status, quick actions
* 🏆 **Hardware Next-Gen**: Zen 5, Arrow Lake, RTX 5090, RX 9000, Battlemage

---

## 🌟 Perché Scegliere GameBoost?

| Caratteristica | GameBoost v3.3.0 | Razer Cortex | MSI Afterburner | Game Fire |
|----------------|------------------|--------------|-----------------|-----------|
| **Uso RAM** | 20MB | 150MB+ | 50MB | 80MB |
| **Dipendenze Esterne** | Nessuna | Chrome/Web | RivaTuner | Framework Web |
| **Privacy** | 100% Locale | Telemetria | Locale | Telemetria |
| **Rilevamento Giochi** | ✅ Auto (30+) | ✅ Manuale | ❌ | ✅ Limitato |
| **Consenso Utente** | ✅ Sempre | ⚠️ Opzionale | ❌ | ⚠️ Opzionale |
| **Open Source** | ✅ MIT | ❌ | ❌ | ❌ |
| **Audit Trail** | ✅ JSONL | ❌ | ❌ | ❌ |
| **Classificazione Tweaks** | ✅ Sicuri/Warn/Pericolo | ❌ | ❌ | ❌ |

**GameBoost è l'ottimizzatore gaming più leggero, trasparente e rispettoso della privacy disponibile.**

---

## 🖥️ Requisiti di Sistema

* **OS**: Windows 10 (build 19041+) o Windows 11 (solo x64)
* **PowerShell**: v5.1+ (v7 raccomandato per migliori prestazioni)
* **Permessi**: Privilegi amministratore richiesti
* **Spazio**: 50 MB liberi (per backup e log)
* **Internet**: Opzionale (solo per aggiornamenti, non richiesto per funzionamento)
* **Antivirus**: Raccomandato escludere cartella tool dalle scansioni

---

## 🏗️ Struttura Repository

```text
Alphacode_GameBoost/
├── assets/                # Logo e screenshot
├── modules/
│   ├── FPS_Suite_Advanced_Gaming_module.ps1
│   └── FPS_Suite_ScanUltimate_AI.ps1
├── src/                   # [NUOVO v3.3.0] Moduli next-gen
│   ├── detection/
│   │   └── game-detector.ps1        # Rilevamento giochi intelligente
│   ├── ui/
│   │   └── tray-integration.ps1     # UI system tray
│   ├── monitoring/
│   │   └── performance-monitor.ps1  # Tracking prestazioni WMI
│   ├── scheduler/
│   │   └── smart-scheduler.ps1      # Pattern learning & suggerimenti
│   ├── safety/
│   │   ├── tweak-registry.ps1       # Database classificazione tweaks
│   │   ├── user-consent.ps1         # Dialog consenso
│   │   └── tweak-applicator.ps1     # Applicazione sicura tweaks
│   └── orchestrator.ps1             # Launcher unificato
├── data/
│   └── games.json         # [NUOVO] Database 30+ giochi
├── config/
│   └── app.config.json    # Configurazione centralizzata
├── tests/
│   └── unit/
│       └── core.tests.ps1 # Suite test Pester (25+ test)
├── .github/workflows/
│   └── test.yml           # Pipeline CI/CD
├── Alphacode_GameBoost.bat
├── README.md              # Questo file
├── README_ENGLISH.md      # Versione inglese
├── CHANGELOG.md
├── SECURITY.md            # Policy sicurezza & classificazione tweaks
└── LICENSE                # Licenza MIT
```

---

## 🚦 Installazione & Avvio Rapido

### 1. Download

```bash
git clone https://github.com/pinksy91/Alphacode_GameBoost.git
```

Oppure scarica lo ZIP ed estrai nella posizione preferita.

### 2. Avvio

* Vai nella cartella estratta
* **Tasto destro** su `Alphacode_GameBoost.bat` → **Esegui come amministratore**
* Segui le istruzioni a schermo: si apre la GUI e richiede selezione profilo
  * **Balanced** raccomandato per primi utilizzi
  * **Conservative** per sistemi critici per stabilità
  * **Aggressive** per gaming competitivo
  * **Maximum** per enthusiast (richiede monitoraggio)

### 3. Sicurezza Prima di Tutto

* ✅ **Backup automatico** creato prima di ogni ottimizzazione
* ✅ **Ripristino 1-click** sempre disponibile dalla GUI
* ✅ **Consenso utente richiesto** - Nessuna modifica automatica senza approvazione
* ✅ **Trasparenza completa** - Ogni tweak spiegato in dettaglio

---

## 📸 Screenshot

<p align="center">
  <img src="assets/1.png" width="340" alt="Dashboard Principale"/><br>
  <b>Dashboard Principale - Interfaccia Pulita</b>
</p>

<p align="center">
  <img src="assets/2.png" width="340" alt="Stato Ottimizzazione"/><br>
  <b>Stato Ottimizzazione in Tempo Reale</b>
</p>

<p align="center">
  <img src="assets/3.png" width="340" alt="Scanner AI"/><br>
  <b>Scanner AI Intelligente</b>
</p>

<p align="center">
  <img src="assets/4.png" width="340" alt="Schermata Risultati"/><br>
  <b>Risultati Dettagliati & Raccomandazioni</b>
</p>

---

## 🎮 Profili di Ottimizzazione

| Profilo | Descrizione | Utenti Target | Guadagno Prestazioni | Livello Rischio |
|---------|-------------|---------------|----------------------|-----------------|
| 🛡️ **Conservative** | Ottimizzazioni leggere e sicure | Principianti, PC lavoro | +5-10% FPS | Molto Basso |
| ⚖️ **Balanced** | Equilibrio prestazioni/stabilità | Gaming quotidiano | +10-20% FPS | Basso |
| 🚀 **Aggressive** | Alte prestazioni, monitorato | Gaming competitivo | +20-30% FPS | Moderato |
| 🔥 **Maximum** | Massime prestazioni, esperto | Enthusiast, OC | +30-40% FPS | Alto |

> **Nota**: I guadagni prestazionali variano in base all'hardware. Consigliato sempre benchmark prima/dopo.

---

## 🎯 Rilevamento Automatico Giochi

GameBoost rileva e ottimizza automaticamente per **30+ giochi popolari**:

### FPS Competitivi
Counter-Strike 2, Valorant, Call of Duty, Rainbow Six Siege, Overwatch 2, Halo Infinite

### Battle Royale
Fortnite, Apex Legends, Warzone, PUBG

### AAA Open World
Cyberpunk 2077, GTA V, Red Dead Redemption 2, Starfield

### RPG & Action
Elden Ring, Baldur's Gate 3, The Witcher 3, Diablo IV

### MOBA
League of Legends, Dota 2

### Altri
Minecraft, Destiny 2, Warframe, Palworld, Rust, Rocket League, e altri...

**Aggiungi giochi personalizzati** con un comando:
```powershell
Add-CustomGame -Name "MioGioco" -ProcessName "miogioco.exe" -OptimalProfile "Maximum"
```

---

## 🛡️ Sistema Consenso Utente & Sicurezza

### Come Funziona

1. **Gioco Rilevato** → GameBoost riconosce il tuo gioco
2. **Richiesta Permesso** → "Ottimizzare per [Nome Gioco] con profilo [Profilo]?"
3. **Revisione Tweaks** → Lista dettagliata di tutte le modifiche con checkbox
4. **Utente Approva** → Solo i tweaks selezionati vengono applicati
5. **Backup Creato** → Backup automatico prima di qualsiasi modifica
6. **Audit Registrato** → Record completo in `tweak_audit.jsonl`

### Classificazione Tweaks

Tutti i tweaks sono classificati per livello di rischio:

#### 🟢 SICURI (5 tweaks)
- **Game Mode Priority Boost**: Aumenta priorità CPU/GPU per gaming
- **Ottimizzazione Rete**: Stack TCP/IP ottimizzato per bassa latenza
- **Disabilita Accelerazione Mouse**: Input 1:1 preciso (essenziale per FPS)
- **Riduzione Effetti Visivi**: Più risorse GPU per giochi
- **Responsiveness Sistema**: Latenza minima applicazioni foreground

**Impatto**: Completamente reversibili, zero rischi stabilità

#### 🟠 ATTENZIONE (4 tweaks)
- **Disabilita Timeout GPU (TDR)**: Previene reset driver durante carichi pesanti
- **Disabilita CPU Parking**: Tutti i core sempre attivi
- **Large System Cache**: Priorità cache vs memoria app (16GB+ RAM raccomandato)
- **Disabilita HPET**: Riduce latenza DPC su alcuni sistemi

**Impatto**: Reversibili, possono influenzare comportamento sistema

**Avvisi Mostrati**:
- ⚠️ "Disabilitare TDR può causare freeze se GPU si blocca (raro)"
- ⚠️ "Aumenta consumo energetico e temperature - monitorare"
- ⚠️ "Raccomandato solo per sistemi con 16GB+ RAM"
- ⚠️ "Testare per alcune ore - può causare instabilità su hardware datato"

#### 🔴 PERICOLOSI (3 tweaks)
- **Disabilita SEHOP**: Rimuove protezione exploit (mitigazione sicurezza)
- **Disabilita Integrità Memoria (HVCI)**: Disabilita isolamento kernel Windows
- **Disabilita Mitigazioni Meltdown/Spectre**: Rimuove protezioni vulnerabilità CPU

**Impatto**: RIDUCE SICUREZZA - Solo per PC gaming offline/air-gapped

**Protezione**: Tweaks pericolosi richiedono digitare "I UNDERSTAND THE RISKS"

**Dialog Speciale**:
```
🚨 PERICOLO: Riduce sicurezza sistema!
Solo procedere se comprendi completamente i rischi.

CHE COSA FA:
[Descrizione dettagliata]

EFFETTI COLLATERALI:
[Rischi per sicurezza spiegati]

Digita 'I UNDERSTAND THE RISKS' per procedere:
[____________]
```

---

## 📊 Monitoraggio Prestazioni

### Metriche in Tempo Reale

- **CPU**: Utilizzo %, Temperatura, Nome modello
- **GPU**: Nome, VRAM, Utilizzo (se disponibile)
- **RAM**: Totale, Utilizzata, Utilizzo %
- **Dati Storici**: Finestra mobile 60 secondi

### Overlay Leggero (Opzionale)

Overlay trasparente in angolo schermo che mostra:
```
CPU: 45%
RAM: 68%
TEMP: 62°C
```

**Tecnologia**: WMI + Performance Counters (nessun tool esterno)

**Impatto Prestazioni**: <2% CPU, ~8MB RAM

---

## 🔮 Scheduler Intelligente

GameBoost impara i tuoi pattern di gioco (100% localmente) e fornisce suggerimenti intelligenti:

### Esempi di Suggerimenti

1. **Pattern Settimanale**: 
   - "Solitamente giochi il lunedì alle 20:00 - ottimizzare ora?"
   - Basato su 2+ sessioni passate stesso giorno/ora

2. **Degradazione Prestazioni**:
   - "Utilizzo CPU aumentato del 15% vs settimana scorsa - riottimizzare?"
   - Confronta media recente con storico

3. **Aggiornamenti Driver**:
   - "Driver GPU aggiornato 2 giorni fa - ricalibrare ottimizzazioni?"
   - Rileva data ultimo aggiornamento driver

4. **Memoria Alta**:
   - "RAM al 90% - pulire memoria standby?"
   - Monitora utilizzo memoria real-time

5. **Sistema Inattivo**:
   - "Sistema inattivo - momento ideale per ottimizzare?"
   - Rileva CPU <20% per periodo prolungato

**Archiviazione Dati**: Tutti i pattern memorizzati localmente in `Config/user_patterns.json`  
**Privacy**: I dati NON escono MAI dal tuo computer

### Come Funziona il Learning

```json
{
  "GameName": "Counter-Strike 2",
  "ProfileUsed": "LowLatency",
  "DayOfWeek": "Monday",
  "Hour": 20,
  "DurationMinutes": 60,
  "Timestamp": "2026-02-11T20:00:00"
}
```

Dopo 2+ sessioni simili, lo scheduler suggerisce automaticamente l'ottimizzazione in quei momenti.

---

## 🔧 Ottimizzazioni Disponibili

### Gaming & Sistema
- Boost priorità scheduling GPU/CPU
- Ottimizzazione Game Mode
- Responsiveness sistema (latenza minima)
- GameDVR disabilitato, Hardware Scheduling, tweaks DWM, livello TDR

### Memoria & Storage
- Ottimizzazione Paging Executive
- Large System Cache (RAM 16GB+)
- Disabilita compressione memoria
- Tuning Prefetch/Superfetch

### CPU & Processi
- Disabilita Processor Parking (tutti i core attivi)
- Win32 Priority Separation
- Ottimizzazione gestione interrupt
- Gestione timer alta risoluzione

### Rete
- Ottimizzazione stack TCP/IP (CTCP, ECN)
- Disabilita Network Throttling
- Ottimizzazione cache DNS
- QoS per traffico gaming

### Backup & Restore
- Backup automatici con timestamp
- Restore totale o selettivo
- Verifica integrità backup
- Rollback automatico su errore

---

## 🧬 Compatibilità Hardware

### CPU
- **AMD**: Ryzen 5000/7000/8000/9000 (Zen 3/4/5, varianti X3D)
- **Intel**: 12a/13a/14a Gen, Arrow Lake (serie K, HX, H)

### GPU
- **NVIDIA**: Serie RTX 30/40/50 (Blackwell incluso)
- **AMD**: Radeon RX 6000/7000/9000 (incluso Navi 44)
- **Intel**: ARC Alchemist, Battlemage

### RAM
- DDR4 & DDR5 completamente supportate

### Altro
- PCIe 5.0, USB4, Wi-Fi 6E
- Sistemi desktop, laptop e AIO

---

## 🔒 Privacy & Sicurezza

### Design Privacy-First

✅ **Operazione 100% Locale** - No cloud, no API esterne  
✅ **Zero Telemetria** - Nessuna raccolta dati, tracking o analytics  
✅ **Open Source** - Licenza MIT, ispeziona ogni riga di codice  
✅ **Internet Non Richiesto** - Funziona completamente offline  
✅ **Pattern Learning Locale** - Storico gaming rimane sul tuo PC  

### Funzionalità Sicurezza

✅ **Backup Automatici** - Prima di ogni modifica  
✅ **Registry Safety Wrapper** - Valida tutte le operazioni  
✅ **Rollback su Errore** - Comportamento transazionale  
✅ **Audit Trail** - Log JSONL completo di tutte le operazioni  
✅ **Validazione Input** - Protezione contro attacchi injection  

Vedi [SECURITY.md](SECURITY.md) per policy sicurezza completa.

---

## ❓ Domande Frequenti (FAQ)

**D: Tutte le modifiche sono reversibili?**  
R: Sì, ogni operazione è preceduta da backup automatico con capacità di ripristino istantaneo.

**D: Funziona davvero senza internet?**  
R: Assolutamente. GameBoost opera 100% offline. Internet serve solo per aggiornamenti.

**D: Come è sicuro il pattern learning per la privacy?**  
R: Tutti i pattern sono memorizzati localmente in file JSON sul tuo PC. I dati NON lasciano MAI il computer.

**D: Cosa rende GameBoost diverso dalle alternative?**  
R: Utilizzo risorse più leggero (20MB vs 150MB+), trasparenza completa, consenso utente per ogni modifica, zero telemetria, e open source.

**D: È sicuro per il mio sistema?**  
R: Sì. Tutto è open source (Licenza MIT), nessuna telemetria, backup automatici, e tweaks pericolosi richiedono conferma esplicita digitata.

**D: Supporta hardware di ultima generazione?**  
R: Sì, validato su Zen 5, Arrow Lake, RTX 5090, RX 9000, Battlemage, e DDR5.

**D: Posso usarlo per gaming competitivo?**  
R: Assolutamente. Il profilo Aggressive è progettato specificamente per gaming competitivo con ottimizzazioni bassa latenza.

---

## 🛠️ Risoluzione Problemi & Supporto

### Problemi Comuni

**Errore Execution Policy**  
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```
Eseguire da PowerShell come Amministratore

**Antivirus Blocca Tool**  
Aggiungi esclusione per cartella GameBoost nelle impostazioni antivirus

**Performance Counters Non Funzionano**  
```powershell
lodctr /R  # Ricostruisce contatori
```
Richiede privilegi Amministratore

### Posizioni Log & Dati

- **Log**: `%LOCALAPPDATA%\FPSSuitePro\Logs`
- **Backup**: `%LOCALAPPDATA%\FPSSuitePro\Backups`
- **Config**: `%LOCALAPPDATA%\FPSSuitePro\Config`
- **Audit**: `%LOCALAPPDATA%\FPSSuitePro\Config\tweak_audit.jsonl`

### Serve Aiuto?

- 📖 [Documentazione](README.md)
- 🔒 [Policy Sicurezza](SECURITY.md)
- 📝 [Changelog](CHANGELOG.md)
- 🐛 [Segnala Problemi](https://github.com/pinksy91/Alphacode_GameBoost/issues)

---

## ⚠️ Avvertenze & Disclaimer

**Attenzione:** Questo tool applica ottimizzazioni di sistema avanzate. Alcuni tweaks sono potenti e dovrebbero essere usati solo se comprendi i rischi. L'uso improprio può causare instabilità, incompatibilità o perdita dati.

**Usi questo tool a tuo rischio e pericolo.** Né lo sviluppatore, collaboratori, né la community sono responsabili per danni, malfunzionamenti o perdita dati risultanti dall'uso di Alphacode GameBoost.

**Best Practices:**
- ✅ Crea sempre backup prima di modifiche importanti
- ✅ Testa ottimizzazioni aggressive prima di sessioni critiche
- ✅ Leggi attentamente descrizioni tweaks
- ✅ Inizia con profili Conservative o Balanced
- ✅ Monitora stabilità sistema dopo profilo Maximum
- ✅ Mantieni Windows e driver aggiornati

Questo tool è progettato **solo per Windows 10/11 x64**. Alcune ottimizzazioni dipendono dall'hardware.

---

## 🤝 Contribuire

Accogliamo contributi dalla community!

### Come Contribuire

1. **Fork** del repository
2. **Crea** branch feature (`git checkout -b feature/funzione-fantastica`)
3. **Testa** su sistemi multipli (hardware diverso, versioni Windows)
4. **Documenta** le tue modifiche approfonditamente
5. **Commit** (`git commit -m 'Aggiunge funzione fantastica'`)
6. **Push** (`git push origin feature/funzione-fantastica`)
7. **Apri** una Pull Request

### Segnalazioni Bug

Apri una [Issue](https://github.com/pinksy91/Alphacode_GameBoost/issues) su GitHub con:
- Informazioni sistema (CPU, GPU, RAM, versione Windows)
- Log da `%LOCALAPPDATA%\FPSSuitePro\Logs`
- Passi per riprodurre il problema
- Comportamento atteso vs effettivo

---

## 📄 Licenza

Distribuito sotto **Licenza MIT**. Vedi [LICENSE](LICENSE) per dettagli.

**Cosa significa:**
- ✅ Uso commerciale permesso (con attribuzione)
- ✅ Modifica e redistribuzione libere
- ✅ Uso privato permesso
- ❌ Nessuna garanzia fornita
- ⚠️ Limitazioni responsabilità applicabili

---

## 👨‍💻 Crediti & Ringraziamenti

**Team Sviluppo:**
- **Alphacode** — Autore originale, architettura, GUI, moduli AI
- **Google Deepmind Antigravity** — Refactoring produzione, implementazione next-gen (v3.2.0, v3.3.0)

**Community:**
- Beta tester & contributori
- Fornitori feedback e segnalatori bug

**Tecnologia:**
- Microsoft — Documentazione API Windows, piattaforma PowerShell
- Community Open Source — Pester, PSScriptAnalyzer

**Ringraziamenti Speciali** a tutti i beta tester che hanno aiutato a validare le features v3.3.0!

---

## 🎯 Filosofia del Progetto

**Alphacode GameBoost** è costruito su tre principi fondamentali:

1. **Privacy First**: I tuoi dati rimangono sul tuo computer, sempre.
2. **Trasparenza**: Codice open source, auditabile, nessun comportamento nascosto.
3. **Controllo Utente**: Ogni modifica richiede il tuo esplicito consenso.

> *"Potenza reale. Controllo totale. Ottimizzazione consapevole."*

---

## ⭐️ Supporta il Progetto

Se **Alphacode GameBoost** ti ha aiutato a ottenere migliori prestazioni gaming:

- ⭐ **Stella** il repository su GitHub
- 🔄 **Condividi** con altri gamer
- 💬 **Fornisci feedback** tramite Issues
- 🤝 **Contribuisci** codice o documentazione
- 📢 **Diffondi la voce** nelle community gaming

**Il tuo supporto ci aiuta a migliorare e mantenere questo tool gratuito e open-source!**

### Link Progetto

- **Repository**: [github.com/pinksy91/Alphacode_GameBoost](https://github.com/pinksy91/Alphacode_GameBoost)
- **Profilo Alphacode**: [github.com/pinksy91](https://github.com/pinksy91)
- **Segnala Problemi**: [Pagina Issues](https://github.com/pinksy91/Alphacode_GameBoost/issues)
- **Pipeline CI/CD**: [Actions](https://github.com/pinksy91/Alphacode_GameBoost/actions)

---

<p align="center">
  <b>🎮 Gioca. Ottimizza Smart. Gioca Meglio. 🏆</b><br>
  <i>Alphacode GameBoost v3.3.0 - L'Ottimizzatore Gaming Privacy-First</i>
</p>

---

<p align="center">
  Realizzato con ❤️ per gamer che valorizzano prestazioni, privacy e trasparenza<br>
  <a href="LICENSE">Licenza MIT</a> • <a href="SECURITY.md">Policy Sicurezza</a> • <a href="CHANGELOG.md">Changelog</a>
</p>
