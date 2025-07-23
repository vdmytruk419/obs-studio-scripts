Automate ~~starting or resuming~~ check status of recording in OBS Studio using a PowerShell script and obs-cmd.exe.

### Requirements
Install OBS Studio.
https://obsproject.com/

Get `obs-cmd.exe` and put it along side with script.
https://github.com/grigio/obs-cmd

### Schedule a task

Use Windows Task Scheduler.

Create recurring task.

Important settings for Actions:
 - "Program/script": `C:\Windows\System32\conhost.exe`;
 - "Add arguments (optional)": `--headless powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File "C:\PATH\TO\YOUR\SCRIPT\check-recording-status.ps1"`.

For Settings, make sure, option "Stop the existing instance" selected.

PS: run script through conhost to hide console window. Because parameter `-WindowStyle Hidden` shows window for a moment still.