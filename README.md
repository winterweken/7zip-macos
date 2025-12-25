# 7-Zip for macOS

A native macOS port of 7-Zip with automated build scripts for both Intel and Apple Silicon.

## Features

- ✅ Native macOS compilation from official 7-Zip source (v24.09)
- ✅ Universal binary support (Intel x86_64 and Apple Silicon ARM64)
- ✅ Full format support: 7z, ZIP, GZIP, BZIP2, TAR, XZ, and more
- ✅ Automated build and installation scripts
- ✅ Comprehensive test suite
- ✅ No dependencies on legacy p7zip

## Quick Start

```bash
# 1. Download 7-Zip source code
./download-source.sh

# 2. Build for your architecture
./build.sh

# 3. Test the build
./test.sh

# 4. Install system-wide (optional)
sudo ./install.sh
```

## Requirements

- macOS 10.13 or later
- Xcode Command Line Tools: `xcode-select --install`
- curl or wget (for downloading source)

## Usage

After building, binaries are available in `build/bin/`:

```bash
# Create a 7z archive
./build/bin/7zz a archive.7z file1.txt file2.txt

# Extract an archive
./build/bin/7zz x archive.7z

# List archive contents
./build/bin/7zz l archive.7z

# Create with maximum compression
./build/bin/7zz a -mx=9 archive.7z folder/

# Create password-protected archive
./build/bin/7zz a -pMyPassword secure.7z sensitive.txt
```

## Architecture Support

The build script automatically detects your Mac's architecture:

- **Apple Silicon (M1/M2/M3)**: Builds ARM64 native binaries
- **Intel Macs**: Builds x86_64 native binaries

## Installation

### Manual Installation

```bash
sudo ./install.sh
```

This installs binaries to `/usr/local/bin/`.

### Homebrew (Coming Soon)

A Homebrew formula will be available for easier installation and updates.

## Project Structure

```
7zip-macos/
├── download-source.sh    # Downloads official 7-Zip source
├── build.sh             # Compiles for macOS
├── install.sh           # Installs to /usr/local/bin
├── test.sh              # Comprehensive test suite
├── source/              # 7-Zip source code (after download)
├── build/               # Compiled binaries
│   └── bin/            # Final executables
└── README.md           # This file
```

## Why This Project?

While `p7zip` has been the traditional Unix/Linux port of 7-Zip, it's no longer actively maintained. This project builds directly from the official 7-Zip source code, ensuring:

- Latest compression algorithms and improvements
- Better compatibility with Windows 7-Zip archives
- Native macOS optimizations
- Active upstream development

## Supported Formats

**Compression/Decompression:**

- 7z, XZ, BZIP2, GZIP, TAR, ZIP, WIM

**Decompression Only:**

- AR, ARJ, CAB, CHM, CPIO, CramFS, DMG, EXT, FAT, GPT, HFS, IHEX, ISO, LZH, LZMA, MBR, MSI, NSIS, NTFS, QCOW2, RAR, RPM, SquashFS, UDF, UEFI, VDI, VHD, VMDK, WIM, XAR, Z

## Performance

7-Zip typically achieves:

- 2-10% better compression than ZIP
- 30-70% better compression than GZIP
- Multi-threaded compression on multi-core systems

## Troubleshooting

### Build fails with "clang: command not found"

Install Xcode Command Line Tools:

```bash
xcode-select --install
```

### "Source code not found" error

Run the download script first:

```bash
./download-source.sh
```

### Permission denied when running scripts

Make scripts executable:

```bash
chmod +x *.sh
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This project uses the official 7-Zip source code, which is licensed under:

- GNU LGPL (for most code)
- BSD 3-clause License (for some code)
- unRAR license restriction (for RAR decompression)

See the [official 7-Zip license](https://www.7-zip.org/license.txt) for details.

## Credits

- [7-Zip](https://www.7-zip.org/) by Igor Pavlov
- Build scripts and macOS integration by this project

## Links

- [Official 7-Zip Website](https://www.7-zip.org/)
- [7-Zip SourceForge](https://sourceforge.net/projects/sevenzip/)
- [7-Zip Documentation](https://documentation.help/7-Zip/)
