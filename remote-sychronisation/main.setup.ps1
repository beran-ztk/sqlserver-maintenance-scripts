Write-Host "Starte Projekt-Setup" -Foregroundcolor Magenta

$path = $PSSCRIPTROOT
$folders = @('bin', 'config', 'doc', 'log', 'secret', 'test')

$folders += ($path -match "ps") ? 'module' : $null

foreach ($folder in $folders) {
    New-Item -Path "$path\$folder" -ItemType Directory
}

New-Item -Path "$path\README.md" -ItemType File
