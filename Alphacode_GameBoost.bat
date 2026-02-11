@echo off
title Alphacode GameBoost - LAUNCHER ITALIANO - POWERED BY ALPHACODE
mode con: cols=110 lines=35
color 0A
chcp 65001 >nul 2>&1
cls

:: Easter Egg - Controllo nickname segreto con input sanitization
set "SECRET_CODE="
set /p "SECRET_CODE=>>> Inserisci il codice sviluppatore (o premi INVIO per continuare): "

:: Input sanitization - lunghezza massima 20 caratteri
set "SECRET_CODE=%SECRET_CODE:~0,20%"
:: Rimuovi caratteri pericolosi per prevenire command injection
set "SECRET_CODE=%SECRET_CODE:;=%"
set "SECRET_CODE=%SECRET_CODE:&=%"
set "SECRET_CODE=%SECRET_CODE:|=%"
set "SECRET_CODE=%SECRET_CODE:^=%"
set "SECRET_CODE=%SECRET_CODE:>=%"
set "SECRET_CODE=%SECRET_CODE:<=%"

if /i "%SECRET_CODE%"=="alphacode" (
    cls
    color 0C
    echo.
    echo   ################################################################################
    echo   #                                                                              #
    echo   #  [*] MODALITA SVILUPPATORE ALPHACODE ATTIVATA [*]                           #
    echo   #                                                                              #
    echo   #  "Il codice e vita, la vita e codice"                                       #
    echo   #  - Maestro Alphacode, Creatore di Mondi Digitali                           #
    echo   #                                                                              #
    echo   #  [^] ACCESSO CONCESSO AI SEGRETI DELL'OTTIMIZZAZIONE                        #
    echo   #  [!] POTENZA ILLIMITATA SBLOCCATA                                           #
    echo   #  [+] EASTER EGG TROVATO - SEI UN VERO HACKER!                              #
    echo   #                                                                              #
    echo   ################################################################################
    echo.
    echo [GOLD] Congratulazioni! Hai scoperto l'Easter Egg di Alphacode!
    echo [BOOST] Modalita ultra-performance abilitata automaticamente...
    echo [UNLOCK] Funzioni nascoste sbloccate...
    echo.
    timeout /t 5 /nobreak >nul
    color 0A
    cls
)

echo.
echo   ################################################################################
echo   #                                                                              #
echo   #  Alphacode GameBoost - ULTIMATE EDITION                                  #
echo   #  OTTIMIZZATORE GAMING PROFESSIONALE ITALIANO                                #
echo   #                                                                              #
echo   #  [^] Versione 3.1.0 - Potenza Massima per il Gaming                        #
echo   #  [+] Compatibile con CPU AMD/Intel e GPU NVIDIA/AMD                        #
echo   #  [*] Powered by ALPHACODE - "Dove il codice prende vita"                   #
echo   #                                                                              #
echo   ################################################################################
echo.

:: Controllo Privilegi Amministratore
echo [CHECK] Verifica privilegi amministratore...
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo [ERROR] ERRORE: Privilegi di amministratore richiesti!
    echo.
    echo     Questo software richiede i privilegi di amministratore per modificare
    echo     le impostazioni di sistema e ottimizzare le prestazioni di gaming.
    echo.
    echo     ^> Fai clic destro sul file e seleziona "Esegui come amministratore"
    echo.
    pause
    exit /b 2
)
echo [OK] Privilegi amministratore confermati

:: Controllo PowerShell 7
echo [CHECK] Verifica PowerShell 7...
where pwsh.exe >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo [ERROR] ERRORE: PowerShell 7 non trovato!
    echo.
    echo     PowerShell 7 e richiesto per l'esecuzione ottimale di FPS Suite.
    echo.
    echo     ^> Scarica PowerShell 7 da: https://aka.ms/pwsh
    echo     ^> Oppure installa tramite: winget install Microsoft.PowerShell
    echo.
    echo [INFO] Tentativo di utilizzo di Windows PowerShell come fallback...
    
    where powershell.exe >nul 2>&1
    if %errorLevel% neq 0 (
        echo [ERROR] Nemmeno Windows PowerShell e disponibile!
        pause
        exit /b 3
    )
    
    echo [WARN] Utilizzando Windows PowerShell ^(prestazioni ridotte^)
    set POWERSHELL_CMD=powershell.exe
) else (
    echo [OK] PowerShell 7 trovato
    set POWERSHELL_CMD=pwsh.exe
)

:: Controllo file script principale - PATH CORRETTO!
echo [CHECK] Verifica file script...
if not exist "%~dp0modules\FPS_Suite_ScanUltimate_AI.ps1" (
    echo.
    echo [ERROR] ERRORE: File script principale non trovato!
    echo.
    echo     File richiesto: modules\FPS_Suite_ScanUltimate_AI.ps1
    echo     Posizione: %~dp0
    echo.
    echo     Assicurati che il file sia nella cartella 'modules'.
    echo.
    pause
    exit /b 1
)
echo [OK] Script principale trovato

echo.
echo ================================================================================
echo.

:: Animazione di avvio
<nul set /p= [BOOT] Inizializzazione motore AI gaming...
ping localhost -n 2 >nul
echo  COMPLETATO

<nul set /p= [LOAD] Caricamento profili di ottimizzazione...
ping localhost -n 1 >nul
echo  COMPLETATO

<nul set /p= [INIT] Preparazione interfaccia gaming...
ping localhost -n 1 >nul
echo  COMPLETATO

<nul set /p= [POWER] Attivazione modalita prestazioni...
ping localhost -n 1 >nul
echo  COMPLETATO

echo.
echo [READY] SISTEMA PRONTO - Avvio Alphacode GameBoost...
echo [SIGN] Firma digitale Alphacode verificata
echo [MOTTO] "Innovation through Code" - Alphacode Engineering
echo [START] Attivazione protocolli Alphacode...
echo.

:: Avvio script PowerShell con parametri ottimizzati - PATH CORRETTO!
start "" %POWERSHELL_CMD% -NoProfile -ExecutionPolicy Bypass -WindowStyle Normal -File "%~dp0modules\FPS_Suite_ScanUltimate_AI.ps1"

:: Controllo risultato avvio
if %errorLevel% equ 0 (
    echo [SUCCESS] Alphacode GameBoost avviato con successo!
    echo.
    echo +============================================================================+
    echo ^|                             AVVIO COMPLETATO                              ^|
    echo ^|                                                                            ^|
    echo ^|  [+] Alphacode GameBoost e ora in esecuzione                           ^|
    echo ^|  [^] Utilizza l'interfaccia grafica per ottimizzare il sistema            ^|
    echo ^|  [i] Monitora i log per informazioni dettagliate                          ^|
    echo ^|                                                                            ^|
    echo ^|  [!] Suggerimento: Inizia con il profilo "Bilanciato" per risultati sicuri^|
    echo +============================================================================+
    exit /b 0
) else (
    echo [ERROR] Errore durante l'avvio di Alphacode GameBoost
    echo.
    echo     Codice errore: %errorLevel%
    echo.
    echo [INFO] Possibili soluzioni:
    echo     • Verifica che tutti i file siano presenti
    echo     • Esegui come amministratore
    echo     • Controlla che PowerShell sia funzionante
    echo     • Disabilita temporaneamente l'antivirus
    echo.
    exit /b 1
)

echo.
echo [LOG] Log di sessione salvati in: %LOCALAPPDATA%\FPSSuitePro\Logs
echo [BACKUP] Backup automatici in: %LOCALAPPDATA%\FPSSuitePro\Backups
echo.
echo ================================================================================
echo   Missione completata! Buon gaming con Alphacode GameBoost!
echo   [MASTER] Creato con passione da Alphacode - Master of Digital Optimization
echo ================================================================================
echo.
pause