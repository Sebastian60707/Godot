# RPG Sandbox - Proyecto Godot

## Descripción
Este es un juego 2D RPG de estilo pixel art, ambientado en un mundo abierto tipo sandbox donde el jugador tiene total libertad para decidir qué hacer. Combina elementos de supervivencia, combate, exploración y construcción.

## Características Implementadas

### 🎮 Sistema de Movimiento
- Movimiento suave con WASD
- Animaciones direccionales del personaje
- Cámara que sigue al jugador

### 🌍 Generación de Mundo
- Mundo procedural infinito
- Múltiples biomas (pasto, tierra, piedra, agua, arena)
- Sistema de chunks optimizado
- Distribución automática de recursos

### 📦 Sistema de Recursos
- Recolección de materiales (madera, piedra, bayas, minerales)
- Diferentes tipos de nodos de recursos
- Regeneración automática de recursos
- Sistema de inventario

### 📊 Sistema de Supervivencia
- Estadísticas vitales (salud, hambre, sed)
- Sistema día/noche
- HUD con información en tiempo real

## Controles
- **W, A, S, D**: Movimiento del personaje
- **ESPACIO/ENTER**: Interactuar con recursos
- **ESC**: Menú (por implementar)

## Cómo usar este proyecto

1. Abre Godot Engine 4.3 o superior
2. Importa este proyecto usando "Import Project"
3. Selecciona el archivo `project.godot`
4. Ejecuta el juego con F5

## Estructura del Proyecto

```
/
├── Scenes/           # Escenas principales
├── Scripts/          # Scripts de lógica del juego
├── SPRITES/          # Sprites del personaje
├── TILES/            # Texturas para tilemaps
└── project.godot     # Archivo de configuración principal
```

## Próximas Características a Implementar
- Sistema de crafting
- Combate con enemigos
- Construcción de estructuras
- Más tipos de recursos y biomas
- Sistema de guardado

## Notas Técnicas
- Versión de Godot: 4.3+
- Resolución base: 1152x648
- Estilo: Pixel Art 2D