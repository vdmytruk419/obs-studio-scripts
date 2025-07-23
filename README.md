Run OBS Studio and start recording. If OBS is running then start/resume recording.

### Requirements
Install OBS Studio.
https://obsproject.com/

Get `obs-cmd.exe` and put it along side with script.
https://github.com/grigio/obs-cmd

### Schedule a task

Use Windows Task Scheduler.

Create recurring task.

Importany settings for Actions:
 - "Program/script": `C:\Windows\System32\conhost.exe`;
 - "Add arguments (optional)": `--headless powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File "C:\PATH\TO\YOU\SCRIPT\start-recording.ps1"`.

For Settings, make sure, option "Stop the existing instance" selected.