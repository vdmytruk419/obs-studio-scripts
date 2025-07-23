# PowerShell script to start OBS Studio and begin recording,
# but only if OBS is not already running and recording.

# --- Configuration ---
$obsDirectory = "C:\Program Files\obs-studio\bin\64bit" # <--- IMPORTANT: Change this to your actual OBS installation path
$obsExecutable = "obs64.exe" # <--- IMPORTANT: Verify this path
$obsProcessName = "obs64" # Process name for 64-bit OBS

# Path to log file for script actions
$logFile = "$PSScriptRoot\log-$(Get-Date -Format 'yyyy-MM-dd').txt" # Log file includes current date

# Function to log messages
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logEntry = "$timestamp - $Message"
    Add-Content -Path $logFile -Value $logEntry
    Write-Host $logEntry # Also output to console for immediate feedback
}

Write-Log "Script started to check OBS Studio status."

# 1. Check if OBS Studio process is running
$obsProcesses = Get-Process -Name $obsProcessName -ErrorAction SilentlyContinue

if ($obsProcesses) {
    Write-Log "OBS Studio process '$obsProcessName' is running. Checking recording status..."

    # Define the command to run, specifying the current directory for obs-cmd.exe
    # The '.\' indicates that obs-cmd.exe is in the current directory.
    $checkStatusCommand = "$PSScriptRoot\obs-cmd.exe recording status"
    $startRecordingCommand = "$PSScriptRoot\obs-cmd.exe recording start"
    $resumeRecordingCommand = "$PSScriptRoot\obs-cmd.exe recording resume"

    # Execute the command and capture its output
    # You don't necessarily need 'cmd.exe /c' here since you're providing the full path,
    # but it doesn't hurt and can sometimes help with argument parsing for complex commands.
    $output = cmd.exe /c $checkStatusCommand

    # Check if the output contains the search string (case-insensitive)
    if ($output -like "*Recording: true*") {
        if ($output -like "*Paused: true*") {
            Write-Log "⚠️ OBS Recording Status: Active (recording but paused)."
            $flagFile = "$PSScriptRoot\obs-paused-message-shown.flag"
            if (Test-Path $flagFile) {  
                # Message already shown, do nothing
            } else {
                New-Item -Path $flagFile -ItemType File -Force | Out-Null
                try {
                    Add-Type -AssemblyName PresentationFramework
                    [System.Windows.MessageBox]::Show(
                        "OBS Studio запущено, але запис призупинено! Відновіть запис.",
                        "OBS paused",
                        [System.Windows.MessageBoxButton]::OK,
                        [System.Windows.MessageBoxImage]::Warning,
                        [System.Windows.MessageBoxButton]::OK,
                        [System.Windows.MessageBoxOptions]::ServiceNotification
                    )
                } finally {
                    Remove-Item $flagFile -ErrorAction SilentlyContinue
                }
            }
            # cmd.exe /c $resumeRecordingCommand
        } else {
            Write-Log "✅ OBS Recording Status: Active"
        }
    } else {
        Write-Log "❌ OBS Recording Status: Not Active or unexpected output."
        $flagFile = "$PSScriptRoot\obs-not-recording-message-shown.flag"
        if (Test-Path $flagFile) {
            # Message already shown, do nothing
        } else {
            New-Item -Path $flagFile -ItemType File -Force | Out-Null
            try {
                Add-Type -AssemblyName PresentationFramework
                [System.Windows.MessageBox]::Show(
                    "OBS Studio запущено, але не запис не включено! Включіть запис.",
                    "OBS Not Recording",
                    [System.Windows.MessageBoxButton]::OK,
                    [System.Windows.MessageBoxImage]::Error,
                    [System.Windows.MessageBoxButton]::OK,
                    [System.Windows.MessageBoxOptions]::ServiceNotification
                )
            } finally {
                Remove-Item $flagFile -ErrorAction SilentlyContinue
            }
        }
        # cmd.exe /c $startRecordingCommand
    }
} else {
    Write-Log "OBS Studio process '$obsProcessName' is NOT running."
    # Show a modal message box that blocks interaction with other windows until OK is clicked
    $flagFile = "$PSScriptRoot\obs-not-running-message-shown.flag"
    if (Test-Path $flagFile) {
        # Message already shown, do nothing
    } else {
        New-Item -Path $flagFile -ItemType File -Force | Out-Null
        try {
            Add-Type -AssemblyName PresentationFramework
            [System.Windows.MessageBox]::Show(
                "OBS Studio не запущено! Запустіть OBS Studio та почніть запис.",
                "OBS Not Running",
                [System.Windows.MessageBoxButton]::OK,
                [System.Windows.MessageBoxImage]::Error,
                [System.Windows.MessageBoxButton]::OK,
                [System.Windows.MessageBoxOptions]::ServiceNotification
            ) | Out-Null
        } finally {
            Remove-Item $flagFile -ErrorAction SilentlyContinue
        }
    }
    # 3. If OBS is not running, start it
    # Start-Process -WorkingDirectory $obsDirectory -FilePath $obsExecutable -ArgumentList "--startrecording --minimize-to-tray"
    # Write-Log "Command issued: Start-Process -FilePath '$obsExecutable' -ArgumentList '--startrecording --minimize-to-tray'"
}

Write-Log "Script finished."
