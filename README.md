# PDF Tools

A lightweight Windows PDF utility suite that adds PDF compression and password-removal options directly to the Windows Explorer context menu.

The project is designed for users who frequently work with PDF documents and want quick access to common PDF operations without opening separate applications.

---

## Features

### PDF Compression

Compress PDF files directly from the Windows right-click menu using three compression modes:

#### 1. Basic Compression

* Moderate file size reduction
* Better visual quality
* Suitable for general document sharing
* Uses higher image resolution and larger output size

#### 2. Standard Compression

* Stronger compression
* Smaller output files
* Suitable for email attachments and uploads
* Balanced quality-to-size ratio

#### 3. Auto-Adaptive Compression (Below 1 MB)

* Automatically adjusts compression settings
* Iteratively reduces image quality and dimensions
* Attempts to generate a PDF under the target size limit
* Useful for government forms, portals, and websites with strict upload limits

---

### PDF Password Removal

Remove passwords from encrypted PDF files using QPDF.

Features:

* Detects encrypted PDFs automatically
* Supports password-protected documents
* Allows up to three password attempts
* Generates a new unlocked PDF file
* Prevents accidental modification of original documents

---

## How It Works

### Compression Workflow

The compression process follows these steps:

1. Verify the PDF is not encrypted
2. Extract each PDF page as an image using MuPDF
3. Optimize generated images
4. Rebuild the PDF using ImageMagick
5. Save the compressed output
6. Clean temporary files

Pipeline:

PDF
↓
MuPDF (Page Extraction)
↓
JPEG Images
↓
Image Optimization
↓
ImageMagick
↓
Compressed PDF

---

### Password Removal Workflow

The password-removal process uses QPDF:

Encrypted PDF
↓
Password Verification
↓
QPDF Decryption
↓
Unlocked PDF

The original file remains unchanged.

---

## Technology Stack

### MuPDF (mutool)

Used for:

* PDF page extraction
* PDF inspection
* Encryption detection

Purpose:

Converts PDF pages into image files that can later be recompressed.

---

### ImageMagick

Used for:

* Image optimization
* Resizing
* JPEG quality adjustment
* PDF reconstruction

Purpose:

Generates smaller PDFs from optimized page images.

---

### QPDF

Used for:

* PDF decryption
* Password validation
* Encryption detection

Purpose:

Removes passwords from protected PDF files.

---

### Windows Batch Scripts

Used for:

* Automation
* User interaction
* File handling
* Workflow orchestration

Purpose:

Provides a lightweight solution without requiring a custom desktop application.

---

## Project Structure

```text
Pdf-Tools/
│
├── Add Pdf Tools.reg
├── Remove Pdf Tools.reg
│
└── C/
    └── Pdf Tools/
        │
        ├── Compress-Pdf-Basic.bat
        ├── Compress-Pdf-Standard.bat
        ├── Compress-Pdf-1024Kb.bat
        ├── Remove-Pass.bat
        │
        ├── mutool/
        ├── ImageMagick/
        ├── qpdf/
        └── ffmpeg/
```

---

## Compression Modes

| Mode       | Quality  | Compression | Use Case             |
| ---------- | -------- | ----------- | -------------------- |
| Basic      | High     | Moderate    | General sharing      |
| Standard   | Medium   | High        | Email and uploads    |
| Below 1 MB | Adaptive | Maximum     | Strict upload limits |

---

## Installation

### Method 1: Portable Installation

#### Step 1

Copy the entire folder:

```text
C:\Pdf Tools\
```

The folder must contain:

```text
Compress-Pdf-Basic.bat
Compress-Pdf-Standard.bat
Compress-Pdf-1024Kb.bat
Remove-Pass.bat
mutool\*.*
ImageMagick\*.*
qpdf\*.*
```

#### Step 2

Run:

```text
Add Pdf Tools.reg
```

#### Step 3

Accept the Windows Registry prompt.

#### Step 4

Right-click any PDF file.

You should now see:

```text
Compress PDF
├── 01 Basic
├── 02 Standard
└── 03 1024 KB or 1 MB

Remove PDF Passwords
```

---

## Uninstallation

Run:

```text
Remove Pdf Tools.reg
```

Then delete:

```text
C:\Pdf Tools\
```

---

## Output Naming

### Compression

```text
Original.pdf

↓

Original_Compressed_Basic.pdf
Original_Compressed_Standard.pdf
Original_Compressed_Below_1MB.pdf
```

### Password Removal

```text
Original.pdf

↓

Original_ID_XXXXX_Unlocked.pdf
```

---

## Safety Features

* Original PDFs are never overwritten
* Temporary working directories are removed automatically
* Encrypted PDFs are detected before compression
* Password attempts are limited
* Compression is skipped for very small PDFs to avoid unnecessary quality loss

---

## Requirements

* Windows 10 or Windows 11
* Administrator permission for registry installation
* MuPDF (Included)
* ImageMagick (Included)
* QPDF (Included)

Bundled binaries can be included inside the project folder.
