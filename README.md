# Extract P7M

![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)
![Version](https://img.shields.io/badge/version-1.0.0-green.svg)
![Bash](https://img.shields.io/badge/bash-5.0+-orange.svg)

Strumento robusto e completo per l'estrazione del contenuto originale da file firmati digitalmente in formato PKCS#7 (.p7m), comunemente utilizzati per la firma digitale in Italia.

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

## 🚀 Requisiti

- **Bash** 5.0 o superiore
- **OpenSSL** (per l'estrazione e verifica dei file)

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

## 📦 Installazione

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

## 📖 Utilizzo

### Sintassi base

```bash
./extract-p7m.sh [OPZIONI] <input>
```

### Opzioni disponibili

| Opzione | Descrizione |
|---------|-------------|
| `-h, --help` | Mostra il messaggio di aiuto |
| `-V, --version` | Mostra la versione dello script |
| `-v, --verbose` | Output verboso con informazioni dettagliate |
| `-r, --recursive` | Elabora ricorsivamente tutte le sottodirectory |
| `-o, --output DIR` | Specifica la directory di output (default: stessa del file input) |
| `-f, --force` | Sovrascrive i file esistenti senza chiedere conferma |
| `-n, --dry-run` | Simula l'operazione senza estrarre realmente i file |
| `-s, --verify-signature` | Verifica la validità della firma digitale |
| `-c, --cert-info` | Mostra informazioni sul certificato di firma |
| `-l, --log FILE` | Salva il log delle operazioni in un file |
| `--no-timestamps` | Non preserva i timestamp originali dei file |

## 💡 Esempi

### Esempio 1: Estrazione singolo file

```bash
./extract-p7m.sh documento.pdf.p7m
```

Estrae il contenuto da `documento.pdf.p7m` e crea `documento.pdf` nella stessa directory.

### Esempio 2: Estrazione ricorsiva

```bash
./extract-p7m.sh -r /percorso/cartella
```

Elabora ricorsivamente tutti i file .p7m nella cartella specificata e nelle sue sottodirectory.

### Esempio 3: Verifica firma e informazioni certificato

```bash
./extract-p7m.sh -s -c documento.pdf.p7m
```

Estrae il file, verifica la firma digitale e mostra le informazioni del certificato.

### Esempio 4: Output in directory specifica

```bash
./extract-p7m.sh -o /tmp/estratti -r /percorso/cartella
```

Estrae tutti i file .p7m in `/tmp/estratti`.

### Esempio 5: Dry-run con verbose

```bash
./extract-p7m.sh -n -v -r /percorso/cartella
```

Simula l'estrazione di tutti i file mostrando cosa verrebbe fatto, senza modificare nulla.

### Esempio 6: Elaborazione con log

```bash
./extract-p7m.sh -v -l extraction.log -r /percorso/cartella
```

Estrae tutti i file salvando un log dettagliato in `extraction.log`.

### Esempio 7: Batch con sovrascrizione automatica

```bash
./extract-p7m.sh -f -r /percorso/cartella
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

### Errore "openssl: command not found"

Installa OpenSSL seguendo le istruzioni nella sezione [Requisiti](#-requisiti).

### File non riconosciuto come valido .p7m

Alcuni file potrebbero:
- Non essere realmente file .p7m
- Essere corrotti
- Utilizzare un formato non standard

Prova a verificare il file con:
```bash
file documento.pdf.p7m
openssl pkcs7 -in documento.pdf.p7m -inform DER -print_certs -noout
```

### Permessi insufficienti

Assicurati di avere i permessi di lettura sul file di input e di scrittura sulla directory di output:
```bash
chmod +r input.pdf.p7m
chmod +w /percorso/output
```

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
