# WinOptimizer v2.0

Ferramenta modular em PowerShell para manutencao, diagnostico, limpeza, reparo, perfis de energia, rede, privacidade e relatorios no Windows.

## Instalacao

Abra o **PowerShell como Administrador** e execute:

```powershell
irm https://raw.githubusercontent.com/Erbetluan11/WinOptimizer/main/install.ps1 | iex
```

## Estrutura

```text
WinOptimizer/
├── install.ps1
├── run.ps1
├── modules/
│   ├── Core.ps1
│   ├── Diagnostics.ps1
│   ├── Backup.ps1
│   ├── Profiles.ps1
│   ├── Cleanup.ps1
│   ├── Repair.ps1
│   ├── Network.ps1
│   ├── Reports.ps1
│   └── Restore.ps1
└── config/
    └── tweaks.json
```

## Seguranca

- Execute como administrador.
- Leia cada descricao antes de confirmar uma acao.
- Crie um ponto de restauracao antes de ajustes importantes.
- Os logs, backups e relatorios ficam em `C:\ProgramData\WinOptimizer\`.
- O codigo e publico e pode ser revisado antes da execucao.
