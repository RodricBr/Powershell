# No linux utilizamos bastante o curl, aqui utilizamos o Test-NetConnection (TNC como um alias)
# TNC -TraceRoute www.google.com

# Nele podemos utilizar flags como "-TraceRoute" juntamento com "-Hops 2"
# para que a cada vez que os pacotes de rede são passadas para o próximo dispositivo de rede, ocorre um hop.
# No TNC podemos controlar em que hop o pacote será feito, e isso é bem interessante!

# Podemos também fazer análise de portas com o TNC utilizando a flag -Port:
# TNC www.google.com -Port 80
# Podemos utilizar a flag "-WarningAction SilentlyContinue" e "-InformationLevel Quit" para suprimir o output 
# para melhor utilizarmos em scripts.

param(
[string]$IP #, Setando o primeiro parâmetro para variável IP como string pois o ipv4 contém o "." separando os octetos
#[int]$PRT # e para variável porta como integer
)

# Checando se o argumento inicial (ip) foi passado pelo usuário
# Caso não (!) foi...
if (! $IP){
  echo "Uso: .\$($MyInvocation.MyCommand.Name) 10.0.0.1 80"
} else {

  # Range entre porta 20 e 80
  foreach ($PRT in 20..80) {
    if ($PRT) {
    # Executando TNC suprimindo output no ipv4 setado pelo user no stdin
    # e na porta do foreach
    $resp = TNC -ComputerName $IP -Port $PRT -WarningAction SilentlyContinue -InformationLevel Quiet
      if ($resp) {
        # Se o resultado do TNC for True:
        Write-Host "Porta $PRT está aberta!" -ForegroundColor Green
      } else {
        # Se o resultado do TNC for False:
        Write-Host "Porta $PRT está fechada!" -ForegroundColor Red
      }
    }
  }
}

# Porém o TNC é inviável para um port scanner pois ele realiza o 3whs, espera pelo timeout (~4 segundos)
# e é sequencial, ou  seja, vai de porta em porta sem usar paralelismo.
# Vamos dar um revamp nele no script: "port-scanner-pro.ps1"
