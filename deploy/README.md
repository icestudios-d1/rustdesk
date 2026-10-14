# Deploying the agent

Each script installs the agent as a boot-time service and sets the permanent
password, so a machine is reachable without anyone starting anything.

| OS      | Command |
|---------|---------|
| Windows | `.\install-windows.ps1 -Exe .\rustdesk.exe -Password '...'` (elevated PowerShell) |
| Linux   | `sudo ./install-linux.sh ./rustdesk.deb '...'` |
| macOS   | `sudo ./install-macos.sh '...'` (one-time permission grants still need a person) |

Optional trailing arguments set your own ID/relay server and key. Use a
different password per machine, or one per site, then add each machine to the
in-app Phonebook (the add button, or paste many at once with the import
button: one `ID, password, alias, group` per line).
