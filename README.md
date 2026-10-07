# WinOptimizer

Ferramenta gratuita em PowerShell para manutenção, limpeza, reparo e ajustes básicos do Windows.

> Sem ZIP e sem instalador tradicional. O comando baixa a versão atual do projeto diretamente do repositório.

## Instalação

1. Abra o **PowerShell como Administrador**
2. Execute:

```powershell
irm [https://raw.githubusercontent.com/Erbetluan11/WinOptimizer/main/install.ps1](https://raw.githubusercontent.com/Erbetluan11/WinOptimizer/main/install.ps1) | iex
```

## Recursos

- Criar ponto de restauração do sistema
- Limpar arquivos temporários do usuário e do Windows
- Limpar Lixeira
- Limpar cache de download do Windows Update
- Limpar componentes antigos do Windows com DISM
- Verificar e reparar o Windows com DISM e SFC
- Ativar plano de energia Alto desempenho
- Consultar plano de energia ativo
- Aplicar e restaurar ajustes básicos de privacidade
- Consultar CPU, RAM, GPU, discos e informações do Windows
- Criar log de uso em `%TEMP%\WinOptimizer\WinOptimizer.log`

## Requisitos

- Windows 10 ou Windows 11
- Windows PowerShell 5.1 ou posterior
- Conexão com a internet
- Executar como Administrador

## Estrutura

```text
WinOptimizer/
├── index.html   # Site publicado no GitHub Pages
├── install.ps1  # Arquivo chamado por irm ... | iex
├── run.ps1      # Menu e funções principais
└── README.md    # Documentação
```

## Aviso

Este projeto realiza alterações reais no Windows. Leia a descrição de cada opção e crie um ponto de restauração antes de aplicar ajustes de privacidade, energia ou manutenção avançada.

O comando de instalação baixa e executa código remoto. Por isso, use apenas o comando oficial acima e, se quiser auditar o projeto, leia os arquivos `install.ps1` e `run.ps1` antes da execução.

## Licença

Uso pessoal e educacional.
