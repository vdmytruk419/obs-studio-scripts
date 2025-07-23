# PowerShell script to start OBS Studio and begin recording,
# but only if OBS is not already running and recording.

# --- Configuration ---
$obsDirectory = "C:\Program Files\obs-studio\bin\64bit" # <--- IMPORTANT: Change this to your actual OBS installation path
$obsExecutable = "obs64.exe" # Binnary name
$obsProcessName = "obs64" # Process name for 64-bit OBS

# Path to log file for script actions
$logFile = "log.txt" # <--- IMPORTANT: Change this to your desired log file

# Function to log messages
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
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
    $checkStatusCommand = ".\obs-cmd.exe recording status"
    $startRecordingCommand = ".\obs-cmd.exe recording start"
    $resumeRecordingCommand = ".\obs-cmd.exe recording resume"

    # Execute the command and capture its output
    # You don't necessarily need 'cmd.exe /c' here since you're providing the full path,
    # but it doesn't hurt and can sometimes help with argument parsing for complex commands.
    $output = cmd.exe /c $checkStatusCommand # Using the call operator '&' is often cleaner for direct execution

    # Check if the output contains the search string (case-insensitive)
    if ($output -like "*Recording: true*") {
        if ($output -like "*Paused: true*") {
            Write-Log "⚠️ OBS Recording Status: Active (recording but paused), resuming recording..."
            cmd.exe /c $resumeRecordingCommand
        } else {
            Write-Log "✅ OBS Recording Status: Active"
        }
    } else {
        Write-Log "❌ OBS Recording Status: Not Active or unexpected output."
        cmd.exe /c $startRecordingCommand
    }
} else {
    Write-Log "OBS Studio process '$obsProcessName' is NOT running. Starting OBS Studio with recording parameter..."
    # 3. If OBS is not running, start it
    Start-Process -WorkingDirectory $obsDirectory -FilePath $obsExecutable -ArgumentList "--startrecording --minimize-to-tray"
    Write-Log "Command issued: Start-Process -FilePath '$obsExecutable' -ArgumentList '--startrecording --minimize-to-tray'"
}

Write-Log "Script finished."
