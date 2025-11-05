$Path = "HKLM:\Software\Policies\Microsoft\WindowsStore"
$Key = "RequirePrivateStoreOnly" 
$KeyFormat = "dword"
$Value = "1"

New-Item $Path -Force | New-ItemProperty -Name $Key -Value $Value -PropertyType $KeyFormat -Force