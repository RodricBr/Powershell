# Utilizando o PInvoke no Powershell simulando técnicas que realmente costumam ser usadas por códigos maliciosos.

# P/Invoke significa "Platform Invoke".
# Ele é a forma para um código gerenciável (ou seja, que roda em cima do CLR)
# executar um código não-gerenciável (nativo).

# Utilizando a função "ShellExecute" que está na DLL nativa "Shell32.dll"
# para abrir a calculadora:

# "Add-Type" adiciona uma classe .NET a uma sessão PowerShell
# Abaixo temos código C# que será "traduzido para powershell" na função ShellExecute
# Botando o código em "here-string" (@" "@) para declarar blocos de texto da forma como estão escritas.
# Os argumentos dessa função e todas opção possíveis: [1]
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Shell32 {
  [DllImport("shell32.dll", CharSet = CharSet.Auto)]
  public static extern IntPtr ShellExecute(
    IntPtr hwnd,
    string lpOperation,
    string lpFile,
    string lpParameters,
    string lpDirectory,
    int nShowCmd
  );
}
"@

# Definindo variável que será utilizada no ShellExecute e explicada na linha 40
$SW_SHOWNORMAL = 1

# Função ShellExecute:
# "[IntPtr]::Zero" se a operação não estiver associada a nenhuma janela especificamente, como dito na documentação.
# "open" pois é a opção para abrir um arquivo.
# "calc.exe" sendo o arquivo que queremos abrir.
# "$null" no quarto e no quinto parâmetro porque não vou usar nenhum parâmetro na
# inicialização da Calculadora e nem definir o diretório que a ação deve ser executada.
# No final, um int "1" que significa "Mostre a tela normal, com tamanho e posição original" [2]
# Experimente trocar o valor da variável para "0" e troque o "calc.exe" por "cmd.exe",
# e rodando o código ele abrirá um novo "cmd" invisível ao usuário!
$result = [Shell32]::ShellExecute(
    [IntPtr]::Zero,   # hwnd (NULL)
    "open",           # lpOperation
    "calc.exe",       # lpFile
    $null,            # lpParameters (NULL)
    $null,            # lpDirectory (NULL)
    $SW_SHOWNORMAL    # nShowCmd (1)
)

# Verifica o resultado (um valor maior que 32 indica sucesso)
# Na documentação da função ShellExecute diz que "se a função for bem sucedida, retornará um valor maior que 32" [3]
if ([int]$result -gt 32){
  Write-Host "+ Calculadora aberta com sucesso!" -ForegroundColor Green
} else {
  Write-Host "x Erro ao abrir a calculadora. Código: $result" -ForegroundColor Red
}


# Fontes:
# [1] - learn.microsoft.com:443/en-us/windows/win32/api/shellapi/nf-shellapi-shellexecutea
# [2] - learn.microsoft.com:443/en-us/windows/win32/api/winuser/nf-winuser-showwindow
# [3] - learn.microsoft.com:443/en-us/windows/win32/api/shellapi/nf-shellapi-shellexecutea
