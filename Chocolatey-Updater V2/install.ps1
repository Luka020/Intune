$PackageName = "choco-upgrade"
$Version = "1"

$AppInfo = Get-Content -Raw -Path "AppInfo.json" | ConvertFrom-Json
Start-Transcript -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\$($AppInfo.Name)-install.log" -Force

if(!(test-path "C:\ProgramData\chocolatey\choco.exe")){
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

C:\ProgramData\chocolatey\choco.exe list

C:\ProgramData\chocolatey\choco.exe feature enable -n=useRememberedArgumentsForUpgrades

## Detection Key
$Path = $($AppInfo.detection.keyPath).replace("HKEY_LOCAL_MACHINE","HKLM:")
$Key = $($AppInfo.detection.Registry.Name)
$KeyFormat = $($AppInfo.detection.Registry.Type)
$Value = $($AppInfo.detection.Registry.Value)

if(!(Test-Path $Path)){New-Item -Path $Path -Force}
if(!$Key){Set-Item -Path $Path -Value $Value
}else{Set-ItemProperty -Path $Path -Name $Key -Value $Value -Type $KeyFormat}

# Scheduled Task for "choco upgrade -y"
$schtaskName = "Chocolatey Upgrade All"
$schtaskDescription = "Upgade der mit Chocolaty verwalteten Paketen. V$($Version)"
$trigger1 = New-ScheduledTaskTrigger -AtStartup
$trigger2 = New-ScheduledTaskTrigger -Weekly -WeeksInterval 1 -DaysOfWeek Wednesday -At 8pm
$principal= New-ScheduledTaskPrincipal -UserId 'SYSTEM'
$action = New-ScheduledTaskAction -Execute "C:\ProgramData\chocolatey\choco.exe" -Argument 'upgrade all -y'
$settings= New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName $schtaskName -Trigger $trigger1,$trigger2 -Action $action -Principal $principal -Settings $settings -Description $schtaskDescription -Force

Stop-Transcript



