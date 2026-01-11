# Running download-missing-sources.ps1 Script

## Problem

PowerShell execution policy prevents running scripts by default on Windows.

## Solutions

### Option 1: Bypass Execution Policy (Recommended - One-time)

Run PowerShell with bypass for this script only:

```powershell
PowerShell -ExecutionPolicy Bypass -File .\download-missing-sources.ps1
```

### Option 2: Change Execution Policy for Current Session

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\download-missing-sources.ps1
```

### Option 3: Change Execution Policy for Current User (Persistent)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\download-missing-sources.ps1
```

**Note**: `RemoteSigned` allows local scripts but requires signed scripts from remote sources.

### Option 4: Run Script Content Directly

Copy and paste the script content into PowerShell, or use:

```powershell
Get-Content .\download-missing-sources.ps1 | Invoke-Expression
```

## Recommended Approach

**For one-time use:**
```powershell
PowerShell -ExecutionPolicy Bypass -File .\download-missing-sources.ps1
```

**For persistent use:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\download-missing-sources.ps1
```

## Security Note

- `Bypass` - No restrictions (use only for trusted scripts)
- `RemoteSigned` - Local scripts OK, remote scripts must be signed (safer)
- `Unrestricted` - All scripts allowed (not recommended)

## Alternative: Manual Download

If you prefer not to change execution policy, you can manually download the files using the commands listed in `DOWNLOADS_ANALYSIS.md`.
