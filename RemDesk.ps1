Write-Host "Enable remote desktop on this computer? Empty selection is 'y' (y/n)"
$choice = Read-Host "Enter your choice"
if ($choice.Trim().ToLower() -eq '' -or $choice.Trim().ToLower() -eq 'y') {
    reg add "HKLM\System\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
    net start termservice
    # Действия для выбора "y"
}
if ($choice.ToLower() -eq 'n') {
    exit
    # Действия для выбора "n"
}

Cls

Write-Host "Enable Windows Firewall? (y/n)"
$choice = Read-Host "Enter your choice"
if ($choice.Trim().ToLower() -eq '' -or $choice.Trim().ToLower() -eq 'y') {
    Set-NetFirewallProfile -All -Enabled True
    # Действия для выбора "y"
}

netsh advfirewall firewall set rule group="@FirewallAPI.dll,-28752" new enable=yes

Cls

Write-Host "Enable IP whitelist? (y/n)"
$choice = Read-Host "Enter your choice"
if ($choice.Trim().ToLower() -eq '' -or $choice.Trim().ToLower() -eq 'y') {
    Cls
    # Запрос у пользователя IP-адресов
    $ipAddresses = @()

    do {
        $ip = Read-Host "Enter the IP address (or press Enter to complete)"
        if ($ip -ne "") {
            $ipAddresses += $ip
        }
    } while ($ip -ne "")

    # Формирование строки с IP-адресами
    $ipString = $ipAddresses -join '|RA4='

    # Вставка IP-адресов в команду
    $command = "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules' -Name 'RemoteDesktop-UserMode-In-TCP' -Value 'v2.30|Action=Allow|Active=TRUE|Dir=In|Protocol=6|LPort=3389|RA4=$ipString|App=%SystemRoot%\system32\svchost.exe|Svc=termservice|Name=@FirewallAPI.dll,-28775|Desc=@FirewallAPI.dll,-28756|EmbedCtxt=@FirewallAPI.dll,-28752|'"

    # Выполнение команды
    Invoke-Expression $command
    # Действия для выбора "y"
}

Cls

Write-Host "Enable login with blank password? (y/n)"
$choice = Read-Host "Enter your choice"
if ($choice.Trim().ToLower() -eq '' -or $choice.Trim().ToLower() -eq 'y') {
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v "LimitBlankPasswordUse" /t REG_DWORD /d 0 /f
    # Действия для выбора "y"
}

Set-ExecutionPolicy Restricted -Force
Cls

Write-Host "Login details: "
Write-Host ""
Write-Host "User: $Env:UserName"
Write-Host ""
$ipAddress = ipconfig | Select-String "IPv4" | ForEach-Object { ($_ -split ":")[1].Trim() }
Write-Host "Ipv4 адресс: $ipAddress"
Write-Host ""
Pause