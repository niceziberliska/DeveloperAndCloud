# Script to uninstall a program using PowerShell

# Function to uninstall a program by its display name
function Uninstall-Program {
    param (
        [string]$ProgramName
    )

    # Get the program using the registry
    $programs = Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' `
                 | Where-Object { $_.DisplayName -like "*$ProgramName*" }

    if ($programs) {
        foreach ($program in $programs) {
            Write-Host "Uninstalling: $($program.DisplayName)"
            if ($program.UninstallString) {
                # Run the uninstaller
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $program.UninstallString -NoNewWindow -Wait
                Write-Host "$($program.DisplayName) has been uninstalled."
            } else {
                Write-Warning "Uninstall string not found for $($program.DisplayName)."
            }
        }
    } else {
        Write-Warning "No programs found matching: $ProgramName"
    }
}

# Replace 'ProgramName' with the name of the program you want to uninstall
$programToUninstall = "ProgramName"
Uninstall-Program -ProgramName $programToUninstall