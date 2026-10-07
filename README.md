# WinOptimizer v2.1 — Debloat Edition

Ferramenta modular em PowerShell para manutenção, diagnóstico, limpeza, reparo, rede, perfis de energia, privacidade e debloat controlado para Windows 10/11.

## Instalação

Abra o PowerShell como Administrador e execute:

```powershell
irm https://raw.githubusercontent.com/Erbetluan11/WinOptimizer/main/install.ps1 | iex
```

## Debloat

- **Seguro:** sugestões, anúncios, Activity History, Advertising ID, experiências personalizadas e apps claramente opcionais.
- **Performance:** adiciona mais apps opcionais e permite desabilitar serviços Xbox se o usuário confirmar que não usa Xbox/Game Pass.
- **Agressivo:** remove provisionamento dos apps escolhidos, Cortana quando presente, oferece desativar serviços de telemetria e Windows Error Reporting, e desativa tarefas selecionadas de telemetria.

## Proteções

- Pede confirmação antes das ações.
- Cria backup de Registro antes do debloat.
- Tenta criar ponto de restauração.
- Não remove Edge, Microsoft Store, Defender, WebView2, .NET, áudio, rede ou Windows Update.
- Logs, backups e relatórios ficam em `C:\ProgramData\WinOptimizer\`.

## Aviso

Nenhuma ferramenta torna todas as edições do Windows “zero telemetria”. Leia o código e a descrição de cada opção antes de confirmar. Apps removidos podem precisar ser reinstalados pela Microsoft Store ou `winget`.
