# CLAUDE.MD - Project Context for AI Assistants

## Project Overview

**Extract P7M** is a robust, cross-platform utility for extracting original content from digitally signed PKCS#7 (.p7m) files, commonly used in Italy for digital signatures on official documents like electronic invoices, digitally signed contracts, and official communications.

### Purpose
- Extract original documents from .p7m signed files
- Verify digital signatures (optional)
- Display certificate information
- Support batch and recursive processing
- Provide user-friendly, colorful CLI interface

### Version
Current version: 1.0.0

## Architecture

### Multi-Platform Design

The project implements the same functionality across three platforms:

1. **Linux/macOS**: Bash script (`extract-p7m.sh`)
2. **Windows PowerShell**: PowerShell script (`extract-p7m.ps1`)
3. **Windows Batch**: Wrapper script (`extract-p7m.bat`)

All three implementations provide identical functionality with platform-appropriate syntax and conventions.

### Core Technology

**OpenSSL** is the foundation of this tool, used for:
- Extracting content from PKCS#7 containers
- Verifying digital signatures
- Displaying certificate information
- Handling both DER and PEM formats

### File Structure

```
extract-p7m/
├── extract-p7m.sh      # Bash script (Linux/macOS)
├── extract-p7m.ps1     # PowerShell script (Windows)
├── extract-p7m.bat     # Batch wrapper (Windows)
├── README.md           # User documentation (Italian)
├── CLAUDE.MD           # This file - AI assistant context
├── LICENSE             # GPL-3.0 license
└── .gitignore          # Git ignore rules
```

## Technical Implementation

### Bash Script (extract-p7m.sh)

**Key Features:**
- Strict error handling: `set -euo pipefail`
- Color-coded output using ANSI escape codes
- Comprehensive argument parsing
- Dry-run mode for safe testing
- Statistics tracking
- Log file support
- Timestamp preservation

**Main Functions:**
- `print_banner()`: Display script header
- `show_help()`: Display usage information
- `check_dependencies()`: Verify OpenSSL installation
- `extract_p7m()`: Core extraction logic
- `process_file()`: Process individual .p7m files
- `process_directory()`: Batch processing
- `show_statistics()`: Display operation summary

**OpenSSL Operations:**
```bash
# Extract content (DER format)
openssl pkcs7 -in file.p7m -inform DER -print_certs -out output

# Verify signature
openssl smime -verify -in file.p7m -inform DER

# Show certificate info
openssl pkcs7 -in file.p7m -inform DER -print_certs -text
```

### PowerShell Script (extract-p7m.ps1)

**Key Features:**
- PowerShell parameter binding with aliases
- Write-Host with colored output
- Pipeline-friendly design
- Error handling with try-catch blocks
- Same feature parity as Bash version

**Main Functions:**
- `Write-ColorOutput`: Colored console output
- `Show-Banner`: Display script header
- `Show-Help`: Display usage information
- `Test-Dependencies`: Verify OpenSSL installation
- `Extract-P7MFile`: Core extraction logic
- `Process-P7MFile`: Process individual files
- `Process-Directory`: Batch processing
- `Show-Statistics`: Display operation summary

### Batch Wrapper (extract-p7m.bat)

**Purpose:**
- Provides easier execution on Windows (no execution policy issues)
- Translates Unix-style arguments to PowerShell parameters
- Forwards all arguments to PowerShell script

## Feature Set

### Core Features

1. **Single File Extraction**
   - Extracts original content from .p7m files
   - Preserves original file extension
   - Maintains timestamps (optional)

2. **Batch Processing**
   - Process entire directories
   - Recursive subdirectory scanning
   - Custom output directory support

3. **Digital Signature Verification**
   - Optional signature validation
   - Certificate chain verification
   - Detailed certificate information display

4. **Safety Features**
   - Dry-run mode (simulation without changes)
   - Confirmation prompts for overwrites
   - Force mode for automation
   - Comprehensive error handling

5. **User Experience**
   - Color-coded output (success/error/warning/info)
   - Unicode symbols for visual feedback
   - Detailed statistics summary
   - Optional verbose logging
   - Log file support

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Generic error |
| 2 | Missing dependencies (OpenSSL) |
| 3 | Invalid input file |
| 4 | Extraction error |

## Development Guidelines

### Code Style

**Bash:**
- Use lowercase for local variables
- Use UPPERCASE for constants and global variables
- Always quote variables: `"$variable"`
- Use `[[ ]]` for conditionals (not `[ ]`)
- Include function documentation comments

**PowerShell:**
- Use PascalCase for function names
- Use camelCase for variable names
- Include parameter documentation
- Use approved verbs (Get-, Set-, Show-, etc.)
- Proper error handling with try-catch

### Adding New Features

When adding features, ensure:

1. **Cross-platform consistency**: Implement in both Bash and PowerShell
2. **Backward compatibility**: Don't break existing functionality
3. **Documentation**: Update README.md (Italian) and help text
4. **Error handling**: Graceful degradation and clear error messages
5. **Testing**: Test on all platforms (Linux, macOS, Windows)

### Testing Checklist

- [ ] Single file extraction
- [ ] Directory processing
- [ ] Recursive processing
- [ ] Signature verification
- [ ] Certificate info display
- [ ] Dry-run mode
- [ ] Force overwrite
- [ ] Custom output directory
- [ ] Log file creation
- [ ] Timestamp preservation
- [ ] Error handling (missing files, corrupted .p7m, etc.)
- [ ] Cross-platform compatibility

## Important Context for AI Assistants

### Language Considerations

- **Documentation**: All user-facing documentation is in **Italian**
- **Code comments**: Mix of Italian and English (prefer Italian for consistency)
- **Variable names**: English (standard coding practice)
- **Output messages**: Italian

### Italian Terminology

- `.p7m` → "file firmato digitalmente" (digitally signed file)
- Extract → "estrazione" or "estrarre"
- Signature → "firma" or "firma digitale"
- Certificate → "certificato"
- Success → "successo" or "riuscito"
- Error → "errore"
- Warning → "avviso"

### PKCS#7 Format Context

P7M files are PKCS#7 containers that include:
- Original document (embedded)
- Digital signature
- Signer's certificate
- Certificate chain (optional)
- Timestamp (optional)

Common in Italy for:
- Electronic invoices (fatture elettroniche)
- Signed contracts (contratti firmati)
- Official government documents
- Legal communications

### Dependencies

**Required:**
- OpenSSL (command-line tool)

**Platform-specific:**
- Linux/macOS: Bash 5.0+
- Windows: PowerShell 5.1+ (included in Windows 10/11)

### Common Issues

1. **OpenSSL not found**: User needs to install OpenSSL
2. **Permission errors**: Check file permissions
3. **Corrupted .p7m files**: Some files may not be valid PKCS#7
4. **Format variations**: Some .p7m files use PEM instead of DER
5. **Windows execution policy**: Solved by batch wrapper

### Repository Information

- **License**: GPL-3.0
- **Primary language**: Shell/Bash + PowerShell
- **Documentation language**: Italian
- **Target audience**: Italian users handling digitally signed documents

## Commit Message Guidelines

When making commits, use clear, descriptive messages in English or Italian:

**English examples:**
- "Add support for PEM format .p7m files"
- "Fix timestamp preservation on Windows"
- "Improve error handling for corrupted files"

**Italian examples:**
- "Aggiunto supporto per file .p7m in formato PEM"
- "Corretto problema con preservazione timestamp su Windows"
- "Migliorata gestione errori per file corrotti"

## Future Enhancement Ideas

Potential features to consider (not yet implemented):

- [ ] Batch signature verification with summary report
- [ ] Support for .p7s (detached signatures)
- [ ] GUI wrapper for non-technical users
- [ ] Integration with email clients
- [ ] Support for multiple signature verification
- [ ] Automatic format detection (DER vs PEM)
- [ ] Progress bar for large batch operations
- [ ] Configuration file support
- [ ] Docker container version

## Quick Reference

### Extract single file
```bash
# Linux/macOS
./extract-p7m.sh documento.pdf.p7m

# Windows (batch)
extract-p7m.bat documento.pdf.p7m

# Windows (PowerShell)
.\extract-p7m.ps1 documento.pdf.p7m
```

### Recursive extraction with verification
```bash
# Linux/macOS
./extract-p7m.sh -r -s -v /path/to/folder

# Windows (PowerShell)
.\extract-p7m.ps1 -Recursive -VerifySignature -VerboseOutput C:\Documents
```

### Dry-run before actual extraction
```bash
# Linux/macOS
./extract-p7m.sh -n -v -r /path/to/folder

# Windows (PowerShell)
.\extract-p7m.ps1 -DryRun -VerboseOutput -Recursive C:\Documents
```

---

**Note for AI Assistants**: This project prioritizes reliability, user-friendliness, and cross-platform compatibility. When suggesting changes, always consider the impact on all three platforms and maintain the Italian language in user-facing text.
