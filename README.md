# MiniWin Operating System

A single-file miniature operating system written entirely in assembly language, suitable for learning OS principles and practicing assembly programming.

---

## 📁 Project Files

| File | Description |
|------|-------------|
| `MiniWin.asm` | Single-file miniature OS kernel written purely in assembly, developed by Bilibili creator **TnRSYWlzZUhhcmRF** |
| `OneClickLaunch.bat` | Multi-function automated build script provided by **SimpleTools Studio**, integrating compilation, image creation, launching, and cleanup |

---

## 🚀 Quick Start

### 1. Install Dependencies

Before running the script, make sure the following tools are installed and added to your environment variables:

| Dependency | Purpose | Download |
|------------|---------|----------|
| **NASM** | Assembly compiler | https://www.nasm.us/pub/nasm/releasebuilds/ |
| **QEMU** | System emulator | https://www.qemu.org/download/ |

> 💡 **Tip**: After installation, run `nasm -version` and `qemu-system-i386 -version` in the command line to verify configuration.

### 2. Run the Script

Double-click `OneClickLaunch.bat` and choose an operation from the menu:

| Option | Function |
|--------|----------|
| `1` | Compile `MiniWin.asm` and generate hard disk image `hd.img` |
| `2` | Launch `MiniWin.bin` or `hd.img` (run in QEMU) |
| `3` | Clean up all build artifacts and image files |
| `4` | Check whether the development dependencies are complete |

### 3. Run the System

After selecting launch, QEMU will emulate an x86 environment and boot the MiniWin operating system.

---

## 🧹 Cleanup File List

The script automatically cleans up the following build artifacts:
MiniWin.bin MiniWin.lst MiniWin.map
MiniWin.sym MiniWin.err MiniWin.hex
hd.img floppy.img

---

## 🛠️ FAQ

### Q: The script says "nasm is not recognized as an internal or external command"
**A**: Please install NASM and make sure its installation path has been added to the system `PATH` environment variable.

### Q: QEMU shows a black screen or does not respond after launch
**A**: Please check whether QEMU is installed correctly, or try running the script as administrator.

### Q: The script reports an error midway
**A**: Please select `4` first to check the dependency environment, and make sure all tools are available before compiling.

---

## 🙏 Acknowledgements

- **Original Author**: Bilibili creator [TnRSYWlzZUhhcmRF](https://space.bilibili.com/42488829?spm_id_from=333.337.0.0), thanks for sharing this assembly OS implementation
- **Script Tool**: Automated build support provided by **SimpleTools Studio**

---

## 🔗 Related Links

- **SimpleTools Studio GitHub**: [SimpleToolsStudio](https://github.com/SimpleToolsStudio)
- **SimpleTools Studio Official Website**: [SimpleTools.cc](https://SimpleTools.cc)

---

## 📄 License

This project is licensed under the **MIT License**.

- `MiniWin.asm` is developed by Bilibili creator [TnRSYWlzZUhhcmRF](https://space.bilibili.com/42488829), with MIT authorization from the original author
- `OneClickLaunch.bat` and other scripts are developed by **SimpleTools Studio** under the MIT License

---

## 📸 Screenshot

![Screenshot](./screenshot.png)