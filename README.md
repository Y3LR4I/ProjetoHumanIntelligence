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
├── autoloads/
│   ├── game_manager.gd
│   ├── scene_manager.gd
│   └── audio_manager.gd
│
├── features/
│   ├── boot/
│   │   ├── boot.tscn
│   │   └── boot.gd
│   │
│   ├── menu/
│   │   ├── menu.tscn
│   │   └── menu.gd
│   │
│   ├── game/
│   │   ├── game.tscn
│   │   └── game.gd
│   │
│   ├── scoreboard/
│   │   ├── scoreboard.tscn
│   │   └── scoreboard.gd
│   │
│   └── credits/
│       ├── credits.tscn
│       └── credits.gd
│
├── ui/
│   └── components/
│
├── resources/
│
├── shaders/
│
└── assets/
    ├── fonts/
    ├── textures/
    └── audio/
```
