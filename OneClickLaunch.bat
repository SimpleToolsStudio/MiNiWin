@echo off
:: ============================================================
::  MiniWin One-Click Launcher v8.0 (Read-Write Hard Disk Edition)
::  Functions: compile, create hard disk image, launch, clean, check deps
::  Dependencies: nasm, qemu-system-x86_64
::  Data persistence: all Ctrl+S saves go to hd.img
:: ============================================================

setlocal enabledelayedexpansion

:: Set code page (UTF-8 → GBK fallback)
chcp 65001 >nul 2>&1
if errorlevel 1 chcp 936 >nul 2>&1

title MiniWin Launcher v8.0
color 0A

:: Get script directory (handles paths with spaces)
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%" 2>nul

:menu
cls
echo ============================================================
echo                    MiniWin Launcher v8.0
echo ============================================================
echo.
echo   [1] Compile + Launch (QEMU hard disk mode, read-write)
echo   [2] Compile + Launch (QEMU standard mode, memory only)
echo   [3] Compile + Launch (with USB mouse, memory only)
echo   [4] Compile only (no launch)
echo   [5] Launch only (use existing image)
echo   [6] Clean (delete generated files)
echo   [7] Check dependencies (nasm, qemu availability)
echo   [0] Exit
echo.
echo ============================================================
set /p choice="Please choose [0-7]: "

:: Handle empty input
if "%choice%"=="" goto menu

:: Option jumps
if "%choice%"=="1" goto compile_and_run_hd
if "%choice%"=="2" goto compile_and_run_mem
if "%choice%"=="3" goto compile_and_run_usb
if "%choice%"=="4" goto compile_only
if "%choice%"=="5" goto run_only
if "%choice%"=="6" goto clean
if "%choice%"=="7" goto check_deps
if "%choice%"=="0" goto exit_script

:: Invalid input
echo [Error] Invalid option, please choose again!
timeout /t 2 /nobreak >nul 2>&1 || ping -n 3 127.0.0.1 >nul 2>&1
goto menu

:exit_script
endlocal
exit /b 0

:: ============================================================
::  [1] Compile + Launch (hard disk mode, read-write)
:: ============================================================
:compile_and_run_hd
cls
echo ============================================================
echo  Mode: Compile + Launch (hard disk mode, read-write)
echo ============================================================
echo.
echo  Note: all Ctrl+S saved data will be written to hd.img
echo.
call :compile
if errorlevel 1 goto menu
call :create_hd_image
if errorlevel 1 goto menu
call :run_hd
goto menu

:: ============================================================
::  [2] Compile + Launch (standard mode, memory only)
:: ============================================================
:compile_and_run_mem
cls
echo ============================================================
echo  Mode: Compile + Launch (standard mode, memory only)
echo ============================================================
echo.
call :compile
if errorlevel 1 goto menu
call :run_mem
goto menu

:: ============================================================
::  [3] Compile + Launch (with USB mouse, memory only)
:: ============================================================
:compile_and_run_usb
cls
echo ============================================================
echo  Mode: Compile + Launch (with USB mouse, memory only)
echo ============================================================
echo.
call :compile
if errorlevel 1 goto menu
call :run_usb
goto menu

:: ============================================================
::  [4] Compile only
:: ============================================================
:compile_only
cls
echo ============================================================
echo  Mode: Compile only
echo ============================================================
echo.
call :compile
echo.
pause
goto menu

:: ============================================================
::  [5] Launch only (let user choose launch method)
:: ============================================================
:run_only
cls
echo ============================================================
echo  Mode: Launch only
echo ============================================================
echo.

:: Check which images are available
set "has_hd=0"
set "has_bin=0"
if exist "hd.img" set "has_hd=1"
if exist "MiniWin.bin" set "has_bin=1"

if "%has_hd%"=="0" if "%has_bin%"=="0" (
    echo [Error] No MiniWin.bin or hd.img found, please compile first!
    echo.
    pause
    goto menu
)

:: Show available options
echo  Available launch methods:
if "%has_hd%"=="1" echo     [A] Hard disk image hd.img (read-write mode)
if "%has_bin%"=="1" echo     [B] Boot sector MiniWin.bin (memory mode)
echo.
set /p boot_choice="Please choose launch method [A/B]: "

:: Handle user choice
if /i "!boot_choice!"=="A" (
    if "%has_hd%"=="1" (
        call :run_hd
        goto menu
    ) else (
        echo [Error] hd.img does not exist!
        timeout /t 2 /nobreak >nul 2>&1 || ping -n 3 127.0.0.1 >nul 2>&1
        goto menu
    )
)
if /i "!boot_choice!"=="B" (
    if "%has_bin%"=="1" (
        call :run_mem
        goto menu
    ) else (
        echo [Error] MiniWin.bin does not exist!
        timeout /t 2 /nobreak >nul 2>&1 || ping -n 3 127.0.0.1 >nul 2>&1
        goto menu
    )
)

:: Invalid input
echo [Error] Invalid choice, please enter A or B
timeout /t 2 /nobreak >nul 2>&1 || ping -n 3 127.0.0.1 >nul 2>&1
goto menu

:: ============================================================
::  [6] Clean (enhanced)
:: ============================================================
:clean
cls
echo ============================================================
echo  Mode: Clean
echo ============================================================
echo.
echo The following files will be deleted:
echo   - MiniWin.bin (boot sector)
echo   - MiniWin.lst (listing file)
if exist "MiniWin.map" echo   - MiniWin.map (symbol map)
if exist "MiniWin.sym" echo   - MiniWin.sym (symbol table)
if exist "MiniWin.err" echo   - MiniWin.err (error log)
if exist "MiniWin.hex" echo   - MiniWin.hex (temporary hex)
if exist "hd.img" echo   - hd.img (hard disk image, contains all saved data!)
if exist "floppy.img" echo   - floppy.img (floppy image)
echo.
set /p confirm="Confirm deletion? [Y/N]: "
if /i not "%confirm%"=="Y" (
    echo Operation cancelled.
    pause
    goto menu
)

set "deleted_count=0"

if exist "MiniWin.bin" (
    del /f /q "MiniWin.bin" 2>nul
    if exist "MiniWin.bin" (
        echo [Failed] Could not delete MiniWin.bin (file may be in use)
    ) else (
        echo [OK] Deleted MiniWin.bin
        set /a deleted_count+=1
    )
) else (
    echo [Info] MiniWin.bin does not exist
)

if exist "MiniWin.lst" (
    del /f /q "MiniWin.lst" 2>nul
    echo [OK] Deleted MiniWin.lst
    set /a deleted_count+=1
)

if exist "MiniWin.map" (
    del /f /q "MiniWin.map" 2>nul
    echo [OK] Deleted MiniWin.map
    set /a deleted_count+=1
)

if exist "MiniWin.sym" (
    del /f /q "MiniWin.sym" 2>nul
    echo [OK] Deleted MiniWin.sym
    set /a deleted_count+=1
)

if exist "MiniWin.err" (
    del /f /q "MiniWin.err" 2>nul
    echo [OK] Deleted MiniWin.err
    set /a deleted_count+=1
)

if exist "MiniWin.hex" (
    del /f /q "MiniWin.hex" 2>nul
    echo [OK] Deleted MiniWin.hex
    set /a deleted_count+=1
)

if exist "hd.img" (
    del /f /q "hd.img" 2>nul
    echo [OK] Deleted hd.img
    set /a deleted_count+=1
) else (
    echo [Info] hd.img does not exist
)

if exist "floppy.img" (
    del /f /q "floppy.img" 2>nul
    echo [OK] Deleted floppy.img
    set /a deleted_count+=1
)

echo.
if !deleted_count! gtr 0 (
    echo [OK] Cleaned up !deleted_count! file(s) in total
) else (
    echo [Info] No files need cleaning
)
echo.
pause
goto menu

:: ============================================================
::  [7] Check dependencies
:: ============================================================
:check_deps
cls
echo ============================================================
echo  Check Dependencies
echo ============================================================
echo.
set "all_ok=1"

echo [1] Checking NASM...
where nasm >nul 2>&1
if errorlevel 1 (
    echo   [x] NASM not found! Please install NASM and add it to PATH
    echo       Download: https://www.nasm.us/pub/nasm/releasebuilds/
    set "all_ok=0"
) else (
    for /f "delims=" %%i in ('nasm -v 2^>^&1 ^| findstr /i "version"') do echo   [OK] %%i
)

echo.
echo [2] Checking QEMU...
where qemu-system-x86_64 >nul 2>&1
if errorlevel 1 (
    echo   [x] QEMU not found! Please install QEMU and add it to PATH
    echo       Download: https://www.qemu.org/download/#windows
    set "all_ok=0"
) else (
    for /f "delims=" %%i in ('qemu-system-x86_64 -version 2^>^&1 ^| findstr /i "version"') do echo   [OK] %%i
)

echo.
echo [3] Checking qemu-img (recommended tool)...
where qemu-img >nul 2>&1
if errorlevel 1 (
    echo   [x] qemu-img not found (optional, but recommended)
    echo       Select the qemu-img component when installing QEMU
) else (
    for /f "delims=" %%i in ('qemu-img --version 2^>^&1 ^| findstr /i "qemu-img"') do echo   [OK] %%i
)

echo.
echo [4] Checking source file...
if exist "MiniWin.asm" (
    echo   [OK] MiniWin.asm exists
    call :getsize "MiniWin.asm"
) else (
    echo   [x] MiniWin.asm does not exist! Please make sure it is in the same directory
    set "all_ok=0"
)

echo.
echo [5] Checking compiled files...
if exist "MiniWin.bin" (
    echo   [OK] MiniWin.bin exists
    call :getsize "MiniWin.bin"
) else (
    echo   [x] MiniWin.bin does not exist (compile required)
)

if exist "hd.img" (
    echo   [OK] hd.img exists (read-write hard disk image)
    call :getsize "hd.img"
) else (
    echo   [x] hd.img does not exist (option 1 will create it automatically)
)

echo.
if "%all_ok%"=="1" (
    echo [OK] All key dependencies are ready. You can start using it!
) else (
    echo [x] Some key dependencies are missing. Please install them and try again.
)
echo.
pause
goto menu

:: ============================================================
::  Subroutine: compile
:: ============================================================
:compile
if not exist "MiniWin.asm" (
    echo [Error] MiniWin.asm does not exist!
    echo.
    pause
    exit /b 1
)

echo [1/3] Compiling MiniWin.asm ...
nasm -f bin -Ox "MiniWin.asm" -o "MiniWin.bin" -l "MiniWin.lst" 2>&1
if errorlevel 1 (
    echo.
    echo [Error] Compilation failed! Please check MiniWin.asm.
    echo.
    pause
    exit /b 1
)

:: Show compiled size (any size allowed, just needs to be >= 512 bytes)
for %%A in ("MiniWin.bin") do set "bin_size=%%~zA"
if !bin_size! LSS 512 (
    echo [Warning] MiniWin.bin is only !bin_size! bytes, may not be a valid boot image!
    echo           Please confirm MiniWin.asm contains complete multi-stage boot code.
    echo.
    set /p continue="Continue? [Y/N]: "
    if /i not "!continue!"=="Y" (
        echo Operation cancelled.
        pause
        exit /b 1
    )
) else (
    echo [OK] Compilation complete! File size: !bin_size! bytes
)
echo.
exit /b 0

:: ============================================================
::  Subroutine: create hard disk image (16MB)
:: ============================================================
:create_hd_image
echo [2/3] Creating 16MB read-write hard disk image...

:: If hd.img already exists, ask whether to keep it
if exist "hd.img" (
    echo [Info] hd.img already exists (contains previously saved data)
    set /p keep="Keep existing data? [Y/N]: "
    if /i "!keep!"=="Y" (
        echo [Info] Keeping existing hard disk image
        exit /b 0
    )
    :: User chose not to keep, delete old file
    del /f /q "hd.img" 2>nul
)

:: ========================================
::  Method 1: qemu-img (most reliable, official QEMU tool)
:: ========================================
qemu-img create -f raw hd.img 16M >nul 2>&1
if not errorlevel 1 (
    echo [OK] Hard disk image created using qemu-img!
    goto :write_boot_sector
)

:: ========================================
::  Method 2: dd (Git Bash / Cygwin / MSYS2)
:: ========================================
echo [Info] qemu-img unavailable, trying dd...
dd if=/dev/zero of=hd.img bs=512 count=32768 2>nul
if not errorlevel 1 (
    echo [OK] Hard disk image created using dd!
    goto :write_boot_sector
)

:: ========================================
::  Method 3: fsutil (Windows native)
:: ========================================
echo [Info] dd unavailable, using fsutil...
fsutil file createnew hd.img 16777216 >nul 2>&1
if errorlevel 1 (
    echo [Error] All creation methods failed!
    echo         Please install QEMU (includes qemu-img) or dd
    exit /b 1
)
echo [OK] Hard disk image created using fsutil!
goto :write_boot_sector_fsutil

:: ============================================================
::  Subroutine: write full MiniWin.bin to hard disk image (for qemu-img and dd)
::  Change: write the full file, not just 512 bytes
:: ============================================================
:write_boot_sector
echo [Info] Writing full MiniWin.bin to hard disk image...

:: Get MiniWin.bin size
for %%A in ("MiniWin.bin") do set "bin_size=%%~zA"
set /a "sectors=!bin_size! / 512"
if !sectors! equ 0 set sectors=1
echo [Info] Will write !sectors! sector(s) (!bin_size! bytes)

:: Prefer dd to write the full file
dd if=MiniWin.bin of=hd.img bs=512 conv=notrunc 2>nul
if not errorlevel 1 (
    echo [OK] Full image written using dd!
    exit /b 0
)

:: dd failed, try dd chunked write (boot sector first, then the rest)
echo [Info] Trying chunked write...
dd if=MiniWin.bin of=hd.img bs=512 count=1 conv=notrunc 2>nul
if not errorlevel 1 (
    dd if=MiniWin.bin of=hd.img bs=512 skip=1 seek=1 conv=notrunc 2>nul
    if not errorlevel 1 (
        echo [OK] Full image written using chunked dd!
        exit /b 0
    )
)

:: dd failed, try PowerShell (write full file)
echo [Info] dd write failed, trying PowerShell...
powershell -command "$bytes=[IO.File]::ReadAllBytes('MiniWin.bin'); $fs=[IO.File]::Open('hd.img','Open','Write'); $fs.SetLength($bytes.Length); $fs.Write($bytes,0,$bytes.Length); $fs.Close()" 2>nul
if not errorlevel 1 (
    echo [OK] Full image written using PowerShell!
    exit /b 0
)

echo [Error] All write methods failed!
echo         Please manually write MiniWin.bin to hd.img
echo         You can use: dd if=MiniWin.bin of=hd.img bs=512 conv=notrunc
exit /b 1

:: ============================================================
::  Subroutine: write full MiniWin.bin to hard disk image (for fsutil)
::  Change: write the full file, not just 512 bytes
:: ============================================================
:write_boot_sector_fsutil
echo [Info] Writing full MiniWin.bin to hard disk image...

:: Use PowerShell to write the full file (most reliable)
powershell -command "$bytes=[IO.File]::ReadAllBytes('MiniWin.bin'); $fs=[IO.File]::Open('hd.img','Open','Write'); $fs.SetLength($bytes.Length); $fs.Write($bytes,0,$bytes.Length); $fs.Close()" 2>nul
if not errorlevel 1 (
    echo [OK] Full image written using PowerShell!
    exit /b 0
)

:: PowerShell failed, try copy /b (simple concatenation)
echo [Info] PowerShell failed, trying copy /b...
copy /b "MiniWin.bin" "hd.img" >nul 2>&1
if not errorlevel 1 (
    echo [OK] Full image written using copy command!
    exit /b 0
)

echo [Error] Failed to write full image!
echo         Please manually write MiniWin.bin to hd.img
exit /b 1

:: ============================================================
::  Subroutine: get file size
:: ============================================================
:getsize
if not exist "%~1" exit /b 0
echo        File size: %~z1 bytes
exit /b 0

:: ============================================================
::  Subroutine: launch QEMU (hard disk mode, read-write)
:: ============================================================
:run_hd
if not exist "hd.img" (
    echo [Error] hd.img does not exist, please create the hard disk image first!
    echo.
    pause
    exit /b 1
)
echo [3/3] Launching QEMU virtual machine (hard disk mode)...
echo.
echo Note: press Ctrl+Alt to release the mouse when captured
echo       type quit in the QEMU monitor to exit
echo.
qemu-system-x86_64 -drive file=hd.img,format=raw,if=ide,cache=unsafe -m 128 -vga std -cpu qemu64 -machine pc -monitor stdio
exit /b 0

:: ============================================================
::  Subroutine: launch QEMU (standard mode, memory only)
:: ============================================================
:run_mem
if not exist "MiniWin.bin" (
    echo [Error] MiniWin.bin does not exist, please compile first!
    echo.
    pause
    exit /b 1
)
echo [2/2] Launching QEMU virtual machine (memory mode)...
echo Note: click the window to capture the mouse, press Ctrl+Alt to release
echo.
qemu-system-x86_64 -drive format=raw,file="MiniWin.bin",if=floppy -m 128 -vga std -cpu qemu64 -machine pc
exit /b 0

:: ============================================================
::  Subroutine: launch QEMU (with USB mouse, memory only)
:: ============================================================
:run_usb
if not exist "MiniWin.bin" (
    echo [Error] MiniWin.bin does not exist, please compile first!
    echo.
    pause
    exit /b 1
)
echo [2/2] Launching QEMU virtual machine (with USB mouse, memory mode)...
echo Note: USB mouse may be smoother than PS/2 mouse
echo.
qemu-system-x86_64 -drive format=raw,file="MiniWin.bin",if=floppy -m 128 -vga std -cpu qemu64 -machine pc -usb -device usb-mouse
exit /b 0