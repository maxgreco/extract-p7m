#!/bin/bash

################################################################################
# extract-p7m.sh - Strumento robusto per l'estrazione di file .p7m
#
# Questo script estrae il contenuto originale da file firmati digitalmente
# in formato PKCS#7 (.p7m), comunemente usati per la firma digitale in Italia.
#
# Licenza: GPL-3.0
################################################################################

set -euo pipefail

# Versione dello script
VERSION="1.0.0"

# Colori per l'output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color
readonly BOLD='\033[1m'

# Variabili globali
VERBOSE=0
DRY_RUN=0
VERIFY_SIGNATURE=0
SHOW_CERT_INFO=0
RECURSIVE=0
OUTPUT_DIR=""
FORCE_OVERWRITE=0
KEEP_TIMESTAMPS=1
LOG_FILE=""

# Statistiche
TOTAL_FILES=0
SUCCESSFUL_EXTRACTIONS=0
FAILED_EXTRACTIONS=0
SKIPPED_FILES=0

################################################################################
# Funzioni di utilità
################################################################################

# Stampa messaggio colorato
print_color() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

# Stampa errore
error() {
    print_color "$RED" "✗ ERRORE: $*" >&2
}

# Stampa avviso
warning() {
    print_color "$YELLOW" "⚠ AVVISO: $*"
}

# Stampa successo
success() {
    print_color "$GREEN" "✓ $*"
}

# Stampa info
info() {
    print_color "$BLUE" "ℹ $*"
}

# Stampa debug (solo se verbose)
debug() {
    if [[ $VERBOSE -eq 1 ]]; then
        print_color "$CYAN" "→ DEBUG: $*"
    fi
}

# Log su file (se abilitato)
log_to_file() {
    if [[ -n "$LOG_FILE" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
    fi
}

# Stampa banner
print_banner() {
    print_color "$MAGENTA" "╔════════════════════════════════════════════════════════════╗"
    print_color "$MAGENTA" "║          Extract P7M - Estrattore File Firmati            ║"
    print_color "$MAGENTA" "║                    Versione $VERSION                        ║"
    print_color "$MAGENTA" "╚════════════════════════════════════════════════════════════╝"
    echo
}

# Mostra help
show_help() {
    cat << EOF
Uso: $0 [OPZIONI] <input>

Estrae il contenuto originale da file firmati digitalmente in formato .p7m

ARGOMENTI:
    <input>                 File .p7m o directory da processare

OPZIONI:
    -h, --help             Mostra questo messaggio di aiuto
    -v, --verbose          Output verboso con informazioni dettagliate
    -V, --version          Mostra la versione dello script
    -r, --recursive        Elabora ricorsivamente tutte le directory
    -o, --output DIR       Directory di output (default: stessa del file di input)
    -f, --force            Sovrascrive i file esistenti senza chiedere
    -n, --dry-run          Simula l'operazione senza estrarre i file
    -s, --verify-signature Verifica la firma digitale
    -c, --cert-info        Mostra informazioni sul certificato
    -l, --log FILE         Salva il log in un file
    --no-timestamps        Non preserva i timestamp originali dei file

ESEMPI:
    # Estrae un singolo file
    $0 documento.pdf.p7m

    # Estrae tutti i file .p7m in una directory ricorsivamente
    $0 -r /percorso/cartella

    # Estrae con verifica della firma e mostra info certificato
    $0 -s -c documento.pdf.p7m

    # Estrae in una directory specifica con output verboso
    $0 -v -o /tmp/output documento.pdf.p7m

    # Dry-run per vedere cosa verrebbe fatto
    $0 -n -r /percorso/cartella

REQUISITI:
    - openssl (per l'estrazione dei file)

CODICI DI USCITA:
    0 - Successo
    1 - Errore generico
    2 - Dipendenze mancanti
    3 - File di input non valido
    4 - Errore durante l'estrazione

EOF
}

################################################################################
# Funzioni di validazione
################################################################################

# Controlla le dipendenze necessarie
check_dependencies() {
    debug "Controllo dipendenze..."
    local missing_deps=()

    if ! command -v openssl &> /dev/null; then
        missing_deps+=("openssl")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Dipendenze mancanti: ${missing_deps[*]}"
        info "Installale con: sudo apt-get install ${missing_deps[*]}"
        log_to_file "ERRORE: Dipendenze mancanti: ${missing_deps[*]}"
        exit 2
    fi

    debug "Tutte le dipendenze sono presenti"
    log_to_file "Dipendenze verificate con successo"
}

# Verifica se il file è un valido .p7m
is_valid_p7m() {
    local file=$1

    # Controlla estensione
    if [[ ! "$file" =~ \.p7m$ ]]; then
        debug "$file non ha estensione .p7m"
        return 1
    fi

    # Controlla se è leggibile
    if [[ ! -r "$file" ]]; then
        debug "$file non è leggibile"
        return 1
    fi

    # Verifica che sia un file PKCS#7 valido
    if ! openssl pkcs7 -in "$file" -inform DER -print_certs -noout &>/dev/null && \
       ! openssl pkcs7 -in "$file" -inform PEM -print_certs -noout &>/dev/null; then
        debug "$file non è un file PKCS#7 valido"
        return 1
    fi

    return 0
}

################################################################################
# Funzioni di elaborazione
################################################################################

# Determina il formato del file p7m (DER o PEM)
detect_p7m_format() {
    local file=$1

    if openssl pkcs7 -in "$file" -inform DER -print_certs -noout &>/dev/null; then
        echo "DER"
    elif openssl pkcs7 -in "$file" -inform PEM -print_certs -noout &>/dev/null; then
        echo "PEM"
    else
        echo "UNKNOWN"
    fi
}

# Mostra informazioni sul certificato
show_certificate_info() {
    local file=$1
    local format=$2

    info "Informazioni certificato per: $(basename "$file")"
    echo

    # Estrae e mostra le informazioni del certificato
    if openssl pkcs7 -in "$file" -inform "$format" -print_certs -text 2>/dev/null | grep -A 20 "Certificate:"; then
        echo
    else
        warning "Impossibile estrarre le informazioni del certificato"
    fi
}

# Verifica la firma digitale
verify_signature() {
    local file=$1
    local format=$2
    local output_file=$3

    debug "Verifica firma per: $file"

    # Estrae il contenuto firmato e verifica
    if openssl smime -verify -in "$file" -inform "$format" -noverify -out "$output_file" &>/dev/null; then
        success "Firma valida per: $(basename "$file")"
        log_to_file "Firma valida: $file"
        return 0
    else
        # Prova comunque l'estrazione senza verifica
        warning "Impossibile verificare la firma per: $(basename "$file")"
        log_to_file "Verifica firma fallita: $file"
        return 1
    fi
}

# Estrae il contenuto dal file .p7m
extract_p7m() {
    local input_file=$1
    local output_file=$2

    debug "Estrazione da: $input_file -> $output_file"

    # Determina il formato
    local format
    format=$(detect_p7m_format "$input_file")

    if [[ "$format" == "UNKNOWN" ]]; then
        error "Formato non riconosciuto per: $(basename "$input_file")"
        log_to_file "ERRORE: Formato non riconosciuto: $input_file"
        return 1
    fi

    debug "Formato rilevato: $format"

    # Mostra info certificato se richiesto
    if [[ $SHOW_CERT_INFO -eq 1 ]]; then
        show_certificate_info "$input_file" "$format"
    fi

    # Verifica firma se richiesto
    if [[ $VERIFY_SIGNATURE -eq 1 ]]; then
        if ! verify_signature "$input_file" "$format" "$output_file"; then
            # Continua comunque con l'estrazione normale
            :
        fi
    fi

    # Estrae il contenuto
    if openssl smime -verify -in "$input_file" -inform "$format" -noverify -out "$output_file" 2>/dev/null; then
        success "Estratto: $(basename "$output_file")"
        log_to_file "Successo: $input_file -> $output_file"

        # Preserva i timestamp se richiesto
        if [[ $KEEP_TIMESTAMPS -eq 1 ]]; then
            touch -r "$input_file" "$output_file"
            debug "Timestamp preservato"
        fi

        return 0
    else
        error "Estrazione fallita per: $(basename "$input_file")"
        log_to_file "ERRORE: Estrazione fallita: $input_file"
        return 1
    fi
}

# Elabora un singolo file
process_file() {
    local input_file=$1
    ((TOTAL_FILES++))

    info "Elaborazione: $(basename "$input_file")"

    # Valida il file
    if ! is_valid_p7m "$input_file"; then
        warning "File non valido o non .p7m: $(basename "$input_file")"
        log_to_file "AVVISO: File non valido: $input_file"
        ((SKIPPED_FILES++))
        return
    fi

    # Determina il file di output
    local output_file
    if [[ -n "$OUTPUT_DIR" ]]; then
        output_file="$OUTPUT_DIR/$(basename "${input_file%.p7m}")"
    else
        output_file="${input_file%.p7m}"
    fi

    # Controlla se il file di output esiste già
    if [[ -f "$output_file" ]] && [[ $FORCE_OVERWRITE -eq 0 ]]; then
        warning "Il file esiste già: $(basename "$output_file")"
        read -p "Sovrascrivere? (s/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
            info "Saltato: $(basename "$input_file")"
            ((SKIPPED_FILES++))
            return
        fi
    fi

    # Dry-run
    if [[ $DRY_RUN -eq 1 ]]; then
        info "[DRY-RUN] Verrebbe estratto: $input_file -> $output_file"
        log_to_file "DRY-RUN: $input_file -> $output_file"
        ((SUCCESSFUL_EXTRACTIONS++))
        return
    fi

    # Estrae il file
    if extract_p7m "$input_file" "$output_file"; then
        ((SUCCESSFUL_EXTRACTIONS++))

        # Mostra dimensioni file
        if [[ $VERBOSE -eq 1 ]]; then
            local input_size
            local output_size
            input_size=$(du -h "$input_file" | cut -f1)
            output_size=$(du -h "$output_file" | cut -f1)
            debug "Dimensione input: $input_size, output: $output_size"
        fi
    else
        ((FAILED_EXTRACTIONS++))
    fi
}

# Elabora una directory
process_directory() {
    local dir=$1

    info "Scansione directory: $dir"
    log_to_file "Scansione directory: $dir"

    local find_cmd="find \"$dir\" -type f -name \"*.p7m\""
    if [[ $RECURSIVE -eq 0 ]]; then
        find_cmd="find \"$dir\" -maxdepth 1 -type f -name \"*.p7m\""
    fi

    local files
    files=$(eval "$find_cmd" | sort)

    if [[ -z "$files" ]]; then
        warning "Nessun file .p7m trovato in: $dir"
        log_to_file "AVVISO: Nessun file trovato in: $dir"
        return
    fi

    local file_count
    file_count=$(echo "$files" | wc -l)
    info "Trovati $file_count file .p7m"

    echo

    # Elabora ogni file
    while IFS= read -r file; do
        process_file "$file"
        echo
    done <<< "$files"
}

################################################################################
# Funzione principale
################################################################################

main() {
    # Banner
    print_banner

    # Controlla dipendenze
    check_dependencies

    # Parsing argomenti
    local input_path=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -V|--version)
                echo "extract-p7m versione $VERSION"
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=1
                shift
                ;;
            -r|--recursive)
                RECURSIVE=1
                shift
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -f|--force)
                FORCE_OVERWRITE=1
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=1
                shift
                ;;
            -s|--verify-signature)
                VERIFY_SIGNATURE=1
                shift
                ;;
            -c|--cert-info)
                SHOW_CERT_INFO=1
                shift
                ;;
            -l|--log)
                LOG_FILE="$2"
                shift 2
                ;;
            --no-timestamps)
                KEEP_TIMESTAMPS=0
                shift
                ;;
            -*)
                error "Opzione non riconosciuta: $1"
                echo "Usa -h per l'aiuto"
                exit 1
                ;;
            *)
                input_path="$1"
                shift
                ;;
        esac
    done

    # Verifica input
    if [[ -z "$input_path" ]]; then
        error "Nessun file o directory specificato"
        echo "Usa -h per l'aiuto"
        exit 3
    fi

    if [[ ! -e "$input_path" ]]; then
        error "File o directory non esistente: $input_path"
        exit 3
    fi

    # Crea directory di output se specificata
    if [[ -n "$OUTPUT_DIR" ]]; then
        if [[ ! -d "$OUTPUT_DIR" ]]; then
            mkdir -p "$OUTPUT_DIR"
            success "Directory di output creata: $OUTPUT_DIR"
        fi
    fi

    # Inizializza log file
    if [[ -n "$LOG_FILE" ]]; then
        : > "$LOG_FILE"
        log_to_file "=== Inizio elaborazione ==="
        log_to_file "Input: $input_path"
        debug "Log salvato in: $LOG_FILE"
    fi

    # Elabora input
    echo
    if [[ -f "$input_path" ]]; then
        process_file "$input_path"
    elif [[ -d "$input_path" ]]; then
        process_directory "$input_path"
    else
        error "Input non valido: $input_path"
        exit 3
    fi

    # Mostra statistiche
    echo
    print_color "$BOLD" "════════════════════════════════════════════════════════════"
    print_color "$BOLD" "STATISTICHE"
    print_color "$BOLD" "════════════════════════════════════════════════════════════"
    info "File totali processati: $TOTAL_FILES"
    success "Estrazioni riuscite: $SUCCESSFUL_EXTRACTIONS"
    if [[ $FAILED_EXTRACTIONS -gt 0 ]]; then
        error "Estrazioni fallite: $FAILED_EXTRACTIONS"
    fi
    if [[ $SKIPPED_FILES -gt 0 ]]; then
        warning "File saltati: $SKIPPED_FILES"
    fi
    print_color "$BOLD" "════════════════════════════════════════════════════════════"

    # Log statistiche
    if [[ -n "$LOG_FILE" ]]; then
        log_to_file "=== Statistiche ==="
        log_to_file "Totali: $TOTAL_FILES, Successi: $SUCCESSFUL_EXTRACTIONS, Falliti: $FAILED_EXTRACTIONS, Saltati: $SKIPPED_FILES"
        log_to_file "=== Fine elaborazione ==="
    fi

    # Determina codice di uscita
    if [[ $FAILED_EXTRACTIONS -gt 0 ]]; then
        exit 4
    else
        exit 0
    fi
}

# Esegui main
main "$@"
