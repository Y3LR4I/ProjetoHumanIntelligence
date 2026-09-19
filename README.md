# Human Intelligence

## Padrão de arquitetura

Este projeto segue uma **arquitetura baseada em features** (*Feature-based
Architecture*): em vez de separar por tipo de arquivo (`scenes/`,
`scripts/`), cada tela/domínio do jogo tem sua própria pasta com cena e
script colocalizados.

Dentro dela, três padrões clássicos (GoF) organizam o código:

| Padrão (GoF)                     | Onde aparece no projeto                                    |
|------------------------------------|--------------------------------------------------------------|
| **Singleton**                     | Autoloads (`GameManager`, `SceneManager`, `AudioManager`)    |
| **Observer**                      | Signals do Godot (`signal health_changed`)                   |
| **Composition over Inheritance**  | Cenas/nós compostos em vez de heranças profundas              |

## Estrutura de pastas

```
ProjetoHumanIntelligence/
├── autoloads/              # Singletons globais (GameManager, SceneManager, AudioManager)
├── features/                # Uma pasta por tela/domínio do jogo
│   ├── boot/                 # tela de abertura
│   │   ├── boot.tscn
│   │   └── boot.gd
│   ├── menu/
│   │   ├── menu.tscn
│   │   └── menu.gd
│   └── game/                 # gameplay principal
│       ├── game.tscn
│       └── game.gd
├── ui/                       # Componentes de UI reutilizáveis entre features
│   └── components/
├── resources/                 # Custom Resources (.tres/.gd)
├── shaders/
└── assets/
	├── fonts/
	├── textures/
	└── audio/
```
