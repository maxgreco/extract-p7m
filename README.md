# Extract P7M

![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)
![Version](https://img.shields.io/badge/version-1.0.0-green.svg)
![Bash](https://img.shields.io/badge/bash-5.0+-orange.svg)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey.svg)

Strumento robusto e completo per l'estrazione del contenuto originale da file firmati digitalmente in formato PKCS#7 (.p7m), comunemente utilizzati per la firma digitale in Italia.

**Disponibile per Linux, macOS e Windows!**

## 📋 Caratteristiche

- ✅ **Estrazione robusta**: Gestisce file .p7m in formato DER e PEM
- 🔍 **Verifica firma**: Opzione per verificare la validità della firma digitale
- 📜 **Info certificato**: Visualizza informazioni dettagliate sul certificato di firma
- 📁 **Elaborazione batch**: Processa singoli file o intere directory (anche ricorsivamente)
- 🎨 **Output colorato**: Interfaccia colorata e intuitiva con icone
- 📊 **Statistiche dettagliate**: Report completo delle operazioni eseguite
- 🔧 **Modalità dry-run**: Simula le operazioni senza estrarre realmente i file
- 📝 **Logging**: Salva log dettagliati delle operazioni
- ⚡ **Gestione errori**: Controllo completo degli errori con messaggi informativi
- 🕐 **Preservazione timestamp**: Mantiene le date originali dei file
- 🪟 **Multipiattaforma**: Funziona su Linux, macOS e Windows

## 🚀 Requisiti

### Linux / macOS
- **Bash** 5.0 o superiore
- **OpenSSL** (per l'estrazione e verifica dei file)

### Windows
- **PowerShell** 5.1 o superiore (già incluso in Windows 10/11)
- **OpenSSL** per Windows

### Installazione dipendenze

#### Debian/Ubuntu
```bash
sudo apt-get update
sudo apt-get install openssl
```

#### Fedora/RHEL/CentOS
```bash
sudo dnf install openssl
```

#### macOS
```bash
brew install openssl
```

#### Windows
1. Scarica OpenSSL per Windows da: https://slproweb.com/products/Win32OpenSSL.html
2. Installa la versione "Win64 OpenSSL" (non la versione Light)
3. Durante l'installazione, seleziona l'opzione per aggiungere OpenSSL al PATH di sistema
4. Riavvia il terminale/PowerShell dopo l'installazione

## 📦 Installazione

### Linux / macOS

1. Clona il repository:
```bash
git clone https://github.com/yourusername/extract-p7m.git
cd extract-p7m
```

2. Rendi lo script eseguibile:
```bash
chmod +x extract-p7m.sh
```

3. (Opzionale) Crea un link simbolico per usarlo da qualsiasi posizione:
```bash
sudo ln -s $(pwd)/extract-p7m.sh /usr/local/bin/extract-p7m
```

### Windows

1. Clona il repository o scarica i file:
```powershell
git clone https://github.com/yourusername/extract-p7m.git
cd extract-p7m
```

2. Lo script è già pronto all'uso! Puoi eseguirlo in due modi:
   - **Metodo 1** (consigliato): Usa il file batch
     ```cmd
     extract-p7m.bat documento.pdf.p7m
     ```

   - **Metodo 2**: Esegui direttamente lo script PowerShell
     ```powershell
     .\extract-p7m.ps1 documento.pdf.p7m
     ```

3. (Opzionale) Aggiungi la directory al PATH per usarlo da qualsiasi posizione:
   - Apri "Variabili d'ambiente" dal Pannello di controllo
   - Aggiungi il percorso della cartella extract-p7m alla variabile PATH
   - Riavvia il terminale

## 📖 Utilizzo

### Sintassi base

**Linux / macOS:**
```bash
./extract-p7m.sh [OPZIONI] <input>
```

**Windows (PowerShell):**
```powershell
.\extract-p7m.ps1 [PARAMETRI] <InputPath>
```

**Windows (Batch):**
```cmd
extract-p7m.bat [OPZIONI] <input>
```

### Opzioni disponibili

| Opzione Linux/macOS | Opzione Windows PowerShell | Descrizione |
|---------------------|---------------------------|-------------|
| `-h, --help` | `-Help` | Mostra il messaggio di aiuto |
| `-V, --version` | `-Version` | Mostra la versione dello script |
| `-v, --verbose` | `-VerboseOutput` | Output verboso con informazioni dettagliate |
| `-r, --recursive` | `-Recursive` | Elabora ricorsivamente tutte le sottodirectory |
| `-o, --output DIR` | `-OutputDir DIR` | Specifica la directory di output (default: stessa del file input) |
| `-f, --force` | `-Force` | Sovrascrive i file esistenti senza chiedere conferma |
| `-n, --dry-run` | `-DryRun` | Simula l'operazione senza estrarre realmente i file |
| `-s, --verify-signature` | `-VerifySignature` | Verifica la validità della firma digitale |
| `-c, --cert-info` | `-ShowCertInfo` | Mostra informazioni sul certificato di firma |
| `-l, --log FILE` | `-LogFile FILE` | Salva il log delle operazioni in un file |
| `--no-timestamps` | `-NoTimestamps` | Non preserva i timestamp originali dei file |

**Nota**: Il file batch Windows (`extract-p7m.bat`) accetta le stesse opzioni della versione Linux/macOS.

## 💡 Esempi

### Esempio 1: Estrazione singolo file

**Linux/macOS:**
```bash
./extract-p7m.sh documento.pdf.p7m
```

**Windows (Batch):**
```cmd
extract-p7m.bat documento.pdf.p7m
```

**Windows (PowerShell):**
```powershell
.\extract-p7m.ps1 documento.pdf.p7m
```

Estrae il contenuto da `documento.pdf.p7m` e crea `documento.pdf` nella stessa directory.

### Esempio 2: Estrazione ricorsiva

**Linux/macOS:**
```bash
./extract-p7m.sh -r /percorso/cartella
```

**Windows (Batch):**
```cmd
extract-p7m.bat -r C:\Documenti
```

**Windows (PowerShell):**
```powershell
.\extract-p7m.ps1 -Recursive C:\Documenti
```

Elabora ricorsivamente tutti i file .p7m nella cartella specificata e nelle sue sottodirectory.

### Esempio 3: Verifica firma e informazioni certificato

**Linux/macOS:**
```bash
./extract-p7m.sh -s -c documento.pdf.p7m
```

**Windows (PowerShell):**
```powershell
.\extract-p7m.ps1 -VerifySignature -ShowCertInfo documento.pdf.p7m
```

Estrae il file, verifica la firma digitale e mostra le informazioni del certificato.

### Esempio 4: Output in directory specifica

**Linux/macOS:**
```bash
./extract-p7m.sh -o /tmp/estratti -r /percorso/cartella
```

**Windows (PowerShell):**
```powershell
.\extract-p7m.ps1 -OutputDir C:\Temp\Estratti -Recursive C:\Documenti
```

Estrae tutti i file .p7m nella directory specificata.

### Esempio 5: Dry-run con verbose

**Linux/macOS:**
```bash
./extract-p7m.sh -n -v -r /percorso/cartella
```

**Windows (PowerShell):**
```powershell
.\extract-p7m.ps1 -DryRun -VerboseOutput -Recursive C:\Documenti
```

Simula l'estrazione di tutti i file mostrando cosa verrebbe fatto, senza modificare nulla.

### Esempio 6: Elaborazione con log

**Linux/macOS:**
```bash
./extract-p7m.sh -v -l extraction.log -r /percorso/cartella
```

**Windows (PowerShell):**
```powershell
.\extract-p7m.ps1 -VerboseOutput -LogFile extraction.log -Recursive C:\Documenti
```

Estrae tutti i file salvando un log dettagliato.

### Esempio 7: Batch con sovrascrizione automatica

**Linux/macOS:**
```bash
./extract-p7m.sh -f -r /percorso/cartella
```

**Windows (PowerShell):**
```powershell
.\extract-p7m.ps1 -Force -Recursive C:\Documenti
```

Estrae tutti i file sovrascrivendo automaticamente eventuali file esistenti.

## 🔍 Output dello script

Lo script fornisce un output colorato e intuitivo:

- ✓ **Verde**: Operazioni completate con successo
- ✗ **Rosso**: Errori
- ⚠ **Giallo**: Avvisi
- ℹ **Blu**: Informazioni
- → **Cyan**: Messaggi di debug (solo in modalità verbose)

### Esempio di output

```
╔════════════════════════════════════════════════════════════╗
║          Extract P7M - Estrattore File Firmati            ║
║                    Versione 1.0.0                          ║
╚════════════════════════════════════════════════════════════╝

✓ Dipendenze verificate

ℹ Scansione directory: /documenti
ℹ Trovati 5 file .p7m

ℹ Elaborazione: fattura_2024.pdf.p7m
✓ Estratto: fattura_2024.pdf

ℹ Elaborazione: contratto.docx.p7m
✓ Estratto: contratto.docx

════════════════════════════════════════════════════════════
STATISTICHE
════════════════════════════════════════════════════════════
ℹ File totali processati: 5
✓ Estrazioni riuscite: 5
════════════════════════════════════════════════════════════
```

## 📊 Codici di uscita

| Codice | Descrizione |
|--------|-------------|
| 0 | Operazione completata con successo |
| 1 | Errore generico |
| 2 | Dipendenze mancanti |
| 3 | File di input non valido |
| 4 | Errore durante l'estrazione |

Questi codici possono essere utilizzati negli script di automazione:

```bash
./extract-p7m.sh documento.pdf.p7m
if [ $? -eq 0 ]; then
    echo "Estrazione completata!"
else
    echo "Estrazione fallita!"
fi
```

## 🔐 Formato P7M

I file .p7m sono file firmati digitalmente secondo lo standard PKCS#7 (Public Key Cryptography Standards). Questi file contengono:

- Il documento originale
- La firma digitale
- Il certificato del firmatario
- La catena di certificati (opzionale)

Lo script estrae il documento originale verificando (opzionalmente) la validità della firma.

## 🛠️ Risoluzione problemi

### Linux/macOS

#### Errore "openssl: command not found"

Installa OpenSSL seguendo le istruzioni nella sezione [Requisiti](#-requisiti).

#### File non riconosciuto come valido .p7m

Alcuni file potrebbero:
- Non essere realmente file .p7m
- Essere corrotti
- Utilizzare un formato non standard

Prova a verificare il file con:
```bash
file documento.pdf.p7m
openssl pkcs7 -in documento.pdf.p7m -inform DER -print_certs -noout
```

#### Permessi insufficienti

Assicurati di avere i permessi di lettura sul file di input e di scrittura sulla directory di output:
```bash
chmod +r input.pdf.p7m
chmod +w /percorso/output
```

### Windows

#### OpenSSL non trovato

Se ricevi l'errore "OpenSSL non trovato":
1. Verifica che OpenSSL sia installato: apri PowerShell e digita `openssl version`
2. Se non installato, scaricalo da https://slproweb.com/products/Win32OpenSSL.html
3. Assicurati che OpenSSL sia nel PATH di sistema
4. Riavvia PowerShell dopo l'installazione

Per aggiungere OpenSSL al PATH manualmente:
```powershell
$env:Path += ";C:\Program Files\OpenSSL-Win64\bin"
```

#### Errore "Execution Policy"

Se ricevi errori di execution policy quando esegui lo script PowerShell:

**Soluzione 1** (Consigliata): Usa il file batch
```cmd
extract-p7m.bat documento.pdf.p7m
```

**Soluzione 2**: Esegui con bypass policy
```powershell
powershell -ExecutionPolicy Bypass -File .\extract-p7m.ps1 documento.pdf.p7m
```

**Soluzione 3**: Cambia la policy (richiede amministratore)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Problema con i percorsi con spazi

Se il percorso contiene spazi, racchiudilo tra virgolette:
```powershell
.\extract-p7m.ps1 "C:\Documenti con spazi\file.pdf.p7m"
```

#### Caratteri speciali nel nome file

Windows potrebbe avere problemi con alcuni caratteri. Rinomina il file rimuovendo caratteri speciali se necessario.

## 🤝 Contribuire

I contributi sono benvenuti! Per favore:

1. Fai un fork del repository
2. Crea un branch per la tua feature (`git checkout -b feature/AmazingFeature`)
3. Commit le tue modifiche (`git commit -m 'Add some AmazingFeature'`)
4. Push al branch (`git push origin feature/AmazingFeature`)
5. Apri una Pull Request

## 📝 Changelog

### v1.0.0 (2026-01-05)
- Release iniziale
- Estrazione file .p7m in formato DER e PEM
- Supporto elaborazione batch e ricorsiva
- Verifica firma digitale
- Visualizzazione informazioni certificato
- Modalità dry-run
- Logging dettagliato
- Output colorato
- Gestione completa degli errori
- **Supporto multipiattaforma**: Linux, macOS e Windows
- Script Bash per Linux/macOS (`extract-p7m.sh`)
- Script PowerShell per Windows (`extract-p7m.ps1`)
- File batch wrapper per Windows (`extract-p7m.bat`)

## 📄 Licenza

Questo progetto è rilasciato sotto licenza GPL-3.0. Vedi il file [LICENSE](LICENSE) per i dettagli.

## 👤 Autore

Creato con ❤️ per semplificare la gestione dei file firmati digitalmente.

## 🙏 Ringraziamenti

- OpenSSL per le funzionalità crittografiche
- La community open source

## ⚠️ Disclaimer

Questo strumento è fornito "così com'è", senza garanzie di alcun tipo. L'autore non è responsabile per eventuali danni derivanti dall'uso di questo software. Usalo a tuo rischio.

---

**Nota**: I file .p7m sono comunemente utilizzati in Italia per documenti come fatture elettroniche, contratti firmati digitalmente, e altre comunicazioni ufficiali che richiedono firma digitale.
