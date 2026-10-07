# WinOptimizer

Otimizador de Windows via PowerShell (sem instalador, sem ZIP).

## Uso

Abra o **PowerShell como Administrador** e execute:

```powershell
irm https://raw.githubusercontent.com/Erbetluan11/WinOptimizer/main/install.ps1 | iex
```

## O que ele faz?

- Remove bloatware
- Ajusta configurações de sistema para desempenho
- Aplica configurações de privacidade

*(Edite conforme o que seu script realmente faz.)*

## Requisitos

- Windows 10/11
- PowerShell 5.1+
- Executar como Administrador

## Estrutura

- `install.ps1` – ponto de entrada (irm ... | iex)
- `run.ps1` – lógica principal de otimização
- `scripts/` – (opcional) scripts auxiliares
