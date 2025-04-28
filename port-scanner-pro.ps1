param(
  [string]$IP, # argumento do IPv4 (string pois os octetos são separados por ".")
  
  [ValidateRange(1,65535)] # validando se é uma porta entre 1 e 65535
  [int]$S_PORT,
  
  [ValidateRange(1,65535)]
  [int]$E_PORT,
  
  [ValidateRange(1,5000)] # timeout limite de 5000
  [int]$TTT, # timeout em milisegundos
  
  [switch]$s # modo silencioso
)

# Setando Write-Host como alias para "wh"
Set-Alias -Name wh -Value Write-Host

# Setando Write-Progress como alias para "wp"
Set-Alias -Name wp -Value Write-Progress


# Verificando se os argumentos foram passados pelo usuário
if (-not $IP -or -not $S_PORT -or -not $E_PORT -or -not $TTT) {
  wh "`nUso:`n.\$($MyInvocation.MyCommand.Name) [IP/Host] [Porta Inicial] [Porta Final] [Timeout em milisegundos] [-s]" -ForegroundColor Gray
  wh "Ex:`n.\$($MyInvocation.MyCommand.Name) 192.168.0.1 20 443 220 -s" -ForegroundColor Gray
  wh "`nOptions:`n-s`t:: Modo silencioso (não exibe portas fechadas)`n" -ForegroundColor Gray
  exit 0
}

# Se o IPv4, range de portas e timeout forem definidos, então começa o script...
if ($IP -ne $null -and $S_PORT -ne $null -and $E_PORT -ne $null -and $TTT -ne $null) {
  # Range de portas será atribuído à variável "ports"
  $ports = $S_PORT..$E_PORT
  $total_PORTS = $ports.Count
  $current_PORT = 0 # para a progress bar

  foreach ($port in $ports) {
    try {
      $client = New-Object System.Net.Sockets.TcpClient
      $task = $client.ConnectAsync($IP, $port)
          
      if ($task.Wait($TTT)) {
        if ($client.Connected) {
          wh "+ Porta '$port' está aberta!" -ForegroundColor Green
        } else {
          if (-not $s) { wh "- Porta '$port' fechada." -ForegroundColor Red }
        }
      } else {
        if (-not $s) { wh "- Porta '$port' fechada/filtrada (timeout)" -ForegroundColor Red }
      }
      $client.Close()
    }
    catch {
      if (-not $s) { wh "x Erro de conexão!" -ForegroundColor Red }
    }

    # Incrementando o valor de portas à barra de progresso com base no foreach
    $current_PORT++
    $percent = [math]::Round(($current_PORT / $total_PORTS) * 100, 0)

    wp -Activity "Progresso: " -Status "$percent% concluído" -PercentComplete $percent
  }
}
