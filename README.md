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
│
├── assets/
│   └── textures/
│       ├── robozin.svg
│       ├── fabrica-new.svg
│       ├── [sprites dos inimigos]
│       └── [outras imagens]
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
│   └── game/
│       ├── game.tscn
│       ├── game.gd
│       │
│       ├── entities/
│       │   │
│       │   ├── player/
│       │   │   ├── player.tscn
│       │   │   └── player.gd
│       │   │
│       │   ├── enemies/
│       │   │   └── maintenance_robot/
│       │   │       ├── maintenance_robot.tscn
│       │   │       └── maintenance_robot.gd
│       │   │
│       │   └── projectiles/
│       │       ├── laser/
│       │       │   ├── laser.tscn
│       │       │   └── laser.gd
│       │       │
│       │       └── wrench/
│       │           ├── wrench.tscn
│       │           └── wrench.gd
│       │
│       └── components/
│           ├── movement/
│           │   ├── horizontal-movement/
│           │   │   ├── horizontal-movement.tscn
│           │   │   └── horizontal-movement.gd
│           │   │
│           │   └── vertical-movement/
│           │       ├── vertical-movement.tscn
│           │       └── vertical-movement.gd
│           │
│           └── health/
│               ├── health_component.tscn
│               └── health_component.gd
│
├── project.godot
└── [arquivos/pastas auxiliares do Godot]
```
