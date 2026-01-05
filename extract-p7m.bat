@echo off
REM ============================================================================
REM Extract P7M - Wrapper Batch per Windows
REM
REM Questo file batch facilita l'esecuzione dello script PowerShell su Windows,
REM gestendo automaticamente le policy di esecuzione di PowerShell.
REM
REM Licenza: GPL-3.0
REM ============================================================================

setlocal enabledelayedexpansion

REM Ottieni il percorso della directory dello script
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%extract-p7m.ps1"

REM Verifica che lo script PowerShell esista
if not exist "%PS_SCRIPT%" (
    echo ERRORE: Script PowerShell non trovato: %PS_SCRIPT%
    exit /b 1
)

REM Esegui lo script PowerShell con bypass della execution policy
REM Questo permette l'esecuzione senza modificare le policy di sistema
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%PS_SCRIPT%" %*

REM Passa il codice di uscita dello script PowerShell
exit /b %ERRORLEVEL%
