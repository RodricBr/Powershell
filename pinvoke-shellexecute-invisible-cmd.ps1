# Explicação completa pode ser encontrada no arquivo "pinvoke-shellexecute.ps1"
# Esse script execute o cmd.exe utilizando a função ShellExecute com um parâmetro de valor 0 (SW_HIDE)
# que nos permite executar o processo de abertura do arquivo "open", "cmd.exe" em segundo plano, porém
# com a janela estando oculta para o usuário.
# O processo, no entanto, ainda estará visível no Gerenciador de Tarefas na lista de processos em execução.

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

# O valor "0" - "oculta a janela e ativa outra janela", como dito na documentação [1]
$SW_SHOWNORMAL = 0

$result = [Shell32]::ShellExecute(
    [IntPtr]::Zero,   # hwnd (NULL)
    "open",           # lpOperation
    "cmd.exe",        # lpFile
    $null,            # lpParameters (NULL)
    $null,            # lpDirectory (NULL)
    $SW_SHOWNORMAL    # nShowCmd (0)
)

if ([int]$result -gt 32){
  Write-Host "+ Cmd.exe invisível aberto com sucesso!" -ForegroundColor Green
} else {
  Write-Host "x Erro ao abrir o CMD. Código: $result" -ForegroundColor Red
}

# [1] - learn.microsoft.com:443/en-us/windows/win32/api/winuser/nf-winuser-showwindow#parameters
