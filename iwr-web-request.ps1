# Invoke-WebRequest (alias: iwr) por padrão utiliza o método GET para fazer requisições web
# Com a flag "-Method" podemos definir qual o método http será utilizado
# Use: "Get-Help iwr" para mais informações

# iwr retorna um objeto do tipo "Microsoft.PowerShell.Commands.HtmlWebResponseObject"
# esse objeto possui propriedades builtin como:
# .statuscode --> (200, 403, 404, etc)
# .statusdescription --> ("Not Found","OK", etc)
# .headers, .content, .rawcontent, .forms, .links e etc...

# Para utilizar em linha de comando basta utilizar o parentesis no comando base
# dessa forma: (iwr www.google.com).statuscode
# O parentesis "( )" força a "order of execution" / ordem de execução como também existe no shell do linux.
# Sem os parentesis o powershell pode pensar que é parte da url: "iwr www.google.com.statuscode"

# Dessa forma, podemos, por exemplo, extrair apenas links de uma url sem utilizar regex (porém não tão efeitivo quanto):
# (iwr www.google.com).links
# Assim o iwr irá retornar um output com tags que possuem links, e utilizando a propriedade "href" filtramos
# só pelo conteúdo contido nesses hrefs:
# (iwr www.google.com).links.href

# Seguindo essa lógica, podemos utilizar a propriedade "headers":
# (iwr www.google.com).headers
# E obter esse resultado:

# Key                                 Value
# ---                                 -----
# Date                                {Mon, 28 Apr 2025 21:54:21 GMT}
# Cache-Control                       {max-age=0, private}
# Content-Security-Policy-Report-Only {object-src 'none';base-uri 'self';script-src 'nonce-LQERFGCxahMV0elQDj401x' 'stri…
# P3P                                 {CP="This is not a P3P policy! See g.co/p3phelp for more info."}
# Server                              {gws}
# X-XSS-Protection                    {0}
# X-Frame-Options                     {SAMEORIGIN}
# Set-Cookie                          {AEC=OXcko2eJFRaM7ToV_1oskJHT6U5pKe_FOdmX0_FNJEfL9nkAz0QY7HmQVP3; expires=Sat, 25-…
# Expires                             {-1}
# Content-Type                        {text/html; charset=UTF-8}

# O Date, Server, Expires e etc são os "hashtable (key-value pairs)" e eles podem ser 
# acessados usando o nome da chave. Por exemplo:
# (iwr www.google.com).Headers["Content-Type"]
# Ou, se o hashtable for um nome simples tipo "Server":
# (iwr www.google.com).headers.Server

# Dentro de um script, por outro lado, iremos fazer de um jeito diferente:

# Definindo o parâmetro para a uri
param(
[string]$URI
)

# Primeiramente, setando Write-Host como wh para facilitar a vida
Set-Alias -Name wh -Value Write-Host

$WEB = iwr -Uri "$URI" -Method Options
wh "`n- Status code: " -ForegroundColor Green
$WEB.StatusCode

wh "`n- O servidor roda em: " -ForegroundColor Green
$WEB.Headers.Server

wh "`n- O servidor aceita os seguintes métodos HTTP: " -ForegroundColor Green
$WEB.Headers.Allow

$WEB2 = iwr -Uri "$URI"
wh "`n- Encontrados os seguintes links: " -ForegroundColor Green
$WEB2.Links.Href | sls "http://" -Raw # utilizando a flag "-Raw" para um output mais limpo
wh ""
