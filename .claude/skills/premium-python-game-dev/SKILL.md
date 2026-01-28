---
name: premium-python-game-dev
description: Expert skill for developing Python-based games with premium Apple-like UI/UX aesthetics, optimized for Windows 11, covering setup, design, implementation, and deployment
when-to-use: When you want to create a Python game with exceptional visual design, smooth user experience, and professional polish that meets Apple's design standards
capabilities:
  - Set up Python game development environments with optimal configurations for Windows 11
  - Design and implement premium, Apple-inspired UI/UX with attention to typography, spacing, animations, and visual hierarchy
  - Choose and configure appropriate Python game frameworks (Pygame, Arcade, Godot with Python, etc.)
  - Create smooth animations and transitions with proper easing functions
  - Implement responsive layouts that adapt to different window sizes
  - Apply Apple's Human Interface Guidelines principles to game interfaces
  - Optimize performance for Windows 11 hardware acceleration
  - Design accessible interfaces with proper contrast and keyboard navigation
  - Create custom UI components with premium feel (buttons, sliders, menus, modals)
  - Implement proper state management and game loops
  - Add polish through micro-interactions, hover states, and feedback
  - Package and distribute games as Windows executables
  - Handle Windows 11-specific features like high DPI scaling and window management
---

# Premium Python Game Development

## Overview

This skill specializes in creating Python-based games that exemplify premium design principles inspired by Apple's Human Interface Guidelines, optimized specifically for Windows 11. We focus on creating polished, professional experiences that users would expect from top-tier applications.

## Core Principles

### Apple Design Philosophy
- **Simplicity**: Every element serves a purpose; nothing is gratuitous
- **Clarity**: Text is legible, icons are precise, and adornments are subtle
- **Depth**: Use of shadows, blur, and layering creates hierarchy without clutter
- **Elegance**: Smooth animations and natural motion guide user attention

### Windows 11 Optimization
- Leverage Direct2D/Direct3D hardware acceleration where possible
- Properly handle high DPI displays (150%, 200% scaling)
- Respect Windows 11 window management behaviors (snap, maximize, minimize)
- Use system fonts (Segoe UI Variable) for native feel when appropriate
- Implement proper dark/light mode support

## Preferred Tech Stack

### Game Frameworks
- **Pygame**: Most mature, extensive ecosystem
- **Arcade**: Modern, Pythonic, excellent for 2D games
- **Pyglet**: Low-level OpenGL access for custom rendering

### UI Enhancement Libraries
- **pygame_gui**: Professional UI components for Pygame
- **Dear PyGui**: Immediate mode GUI with premium aesthetics
- **Custom implementations**: For Apple-specific design patterns

## Design System

### Typography
```python
# Apple-inspired typography hierarchy
TYPOGRAPHY = {
    'display': {
        'font': 'SF Pro Display',
        'sizes': [34, 28, 22, 20, 17],
        'weights': ['bold', 'semibold', 'medium']
    },
    'body': {
        'font': 'SF Pro Text',
        'sizes': [17, 15, 13],
        'weights': ['regular', 'medium', 'semibold']
    }
}
```

### Color Palette
```python
# Apple-inspired color system with semantic naming
COLORS = {
    # Semantic colors (adapt for light/dark mode)
    'background': '#F5F5F7',        # Apple light gray
    'background_dark': '#1C1C1E',   # Dark mode background
    'surface': '#FFFFFF',           # Card/panel background
    'surface_dark': '#2C2C2E',      # Dark mode surface
    
    # Accents
    'primary': '#007AFF',           # Apple blue
    'success': '#34C759',           # Apple green
    'warning': '#FF9500',           # Apple orange
    'danger': '#FF3B30',            # Apple red
    
    # Text
    'text_primary': '#1D1D1F',
    'text_secondary': '#86868B',
    'text_tertiary': '#AEAEB2',
    
    # Effects
    'glass_overlay': (255, 255, 255, 0.7),
    'shadow_light': (0, 0, 0, 0.08),
    'shadow_medium': (0, 0, 0, 0.12),
}
```

### Spacing System
```python
# 8-point grid system
SPACING = {
    'xs': 4,
    'sm': 8,
    'md': 16,
    'lg': 24,
    'xl': 32,
    'xxl': 48
}
```

### Border Radius
```python
# Apple's rounded corner progression
CORNER_RADIUS = {
    'sm': 6,
    'md': 10,
    'lg': 14,
    'xl': 18,
    'pill': 999
}
```

## Component Templates

### Premium Button Component
```python
import pygame
from pygame import gfxdraw
import math

class PremiumButton:
    """
    Apple-inspired button with smooth animations and states.
    """
    def __init__(self, x, y, width, height, text, style='primary'):
        self.rect = pygame.Rect(x, y, width, height)
        self.text = text
        self.style = style
        self.hovered = False
        self.pressed = False
        self.animation_progress = 0.0
        self.target_progress = 0.0
        
        # Style configurations
        self.styles = {
            'primary': {
                'bg': COLORS['primary'],
                'bg_hover': '#0051D5',
                'text': '#FFFFFF',
                'shadow': COLORS['shadow_medium']
            },
            'secondary': {
                'bg': COLORS['background'],
                'bg_hover': '#E5E5EA',
                'text': COLORS['primary'],
                'shadow': COLORS['shadow_light']
            },
            'ghost': {
                'bg': 'transparent',
                'bg_hover': 'rgba(0, 122, 255, 0.1)',
                'text': COLORS['primary'],
                'shadow': None
            }
        }
    
    def update(self, mouse_pos, mouse_pressed):
        self.hovered = self.rect.collidepoint(mouse_pos)
        self.pressed = self.hovered and mouse_pressed
        
        # Smooth animation target
        self.target_progress = 1.0 if self.hovered else 0.0
        
        # Smooth interpolation (ease-out)
        diff = self.target_progress - self.animation_progress
        self.animation_progress += diff * 0.15
    
    def draw(self, surface, font):
        style = self.styles[self.style]
        
        # Calculate interpolated values
        current_bg = self._interpolate_color(
            style['bg'],
            style['bg_hover'],
            self.animation_progress
        )
        
        # Draw shadow with elevation on hover
        if style['shadow'] and self.hovered:
            shadow_surface = pygame.Surface(
                (self.rect.width, self.rect.height + 8),
                pygame.SRCALPHA
            )
            pygame.draw.rounded_rect(
                shadow_surface,
                (*style['shadow'], 100),
                pygame.Rect(0, 4, self.rect.width, self.rect.height),
                CORNER_RADIUS['md']
            )
            surface.blit(shadow_surface, (self.rect.x, self.rect.y))
        
        # Draw button background
        pygame.draw.rounded_rect(
            surface,
            current_bg,
            self.rect,
            CORNER_RADIUS['md']
        )
        
        # Draw text with proper alignment
        text_surface = font.render(self.text, True, style['text'])
        text_rect = text_surface.get_rect(center=self.rect.center)
        surface.blit(text_surface, text_rect)
    
    def _interpolate_color(self, color1, color2, progress):
        """Smoothly interpolate between two colors."""
        def hex_to_rgb(hex_color):
            if isinstance(hex_color, str):
                hex_color = hex_color.lstrip('#')
                return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
            return color1
        
        rgb1 = hex_to_rgb(color1)
        rgb2 = hex_to_rgb(color2)
        
        return tuple(
            int(rgb1[i] + (rgb2[i] - rgb1[i]) * progress)
            for i in range(3)
        )
    
    def is_clicked(self, event):
        if event.type == pygame.MOUSEBUTTONDOWN and event.button == 1:
            return self.hovered
        return False
```

### Modal/Alert Component
```python
class PremiumModal:
    """
    Apple-style modal with backdrop blur and smooth animations.
    """
    def __init__(self, title, message, buttons=None):
        self.title = title
        self.message = message
        self.buttons = buttons or [{'text': 'OK', 'style': 'primary'}]
        
        self.visible = False
        self.animation_progress = 0.0
        self.target_progress = 0.0
        
        self.width = 400
        self.height = 200
        self.center_x = 0
        self.center_y = 0
    
    def show(self):
        self.visible = True
        self.target_progress = 1.0
    
    def hide(self):
        self.target_progress = 0.0
    
    def update(self, screen_size):
        if self.target_progress == 0.0 and self.animation_progress < 0.01:
            self.visible = False
        
        # Smooth ease-out animation
        diff = self.target_progress - self.animation_progress
        self.animation_progress += diff * 0.12
        
        # Center calculation
        self.center_x = screen_size[0] // 2
        self.center_y = screen_size[1] // 2
        
        # Scale effect (pop in)
        scale = 0.95 + (0.05 * self._ease_out_back(self.animation_progress))
        self.current_width = int(self.width * scale)
        self.current_height = int(self.height * scale)
    
    def draw(self, surface, font_title, font_body):
        if not self.visible and self.animation_progress < 0.01:
            return
        
        # Backdrop blur effect (simplified)
        backdrop = pygame.Surface(surface.get_size(), pygame.SRCALPHA)
        backdrop.fill((0, 0, 0, int(40 * self.animation_progress)))
        surface.blit(backdrop, (0, 0))
        
        # Modal container
        modal_rect = pygame.Rect(0, 0, self.current_width, self.current_height)
        modal_rect.center = (self.center_x, self.center_y)
        
        # Modal background with shadow
        shadow_offset = 20
        shadow_surface = pygame.Surface(
            (self.current_width + shadow_offset * 2,
             self.current_height + shadow_offset * 2),
            pygame.SRCALPHA
        )
        pygame.draw.rounded_rect(
            shadow_surface,
            (*COLORS['shadow_medium'], int(80 * self.animation_progress)),
            shadow_surface.get_rect(),
            CORNER_RADIUS['lg']
        )
        surface.blit(
            shadow_surface,
            (modal_rect.x - shadow_offset, modal_rect.y - shadow_offset)
        )
        
        # Main modal
        pygame.draw.rounded_rect(
            surface,
            COLORS['surface'],
            modal_rect,
            CORNER_RADIUS['lg']
        )
        
        # Title
        title_surface = font_title.render(self.title, True, COLORS['text_primary'])
        title_rect = title_surface.get_rect(
            midtop=(modal_rect.centerx, modal_rect.top + SPACING['lg'])
        )
        surface.blit(title_surface, title_rect)
        
        # Message
        message_lines = self._wrap_text(self.message, font_body, modal_rect.width - SPACING['lg'] * 2)
        y_offset = title_rect.bottom + SPACING['md']
        for line in message_lines:
            line_surface = font_body.render(line, True, COLORS['text_secondary'])
            line_rect = line_surface.get_rect(
                midtop=(modal_rect.centerx, y_offset)
            )
            surface.blit(line_surface, line_rect)
            y_offset += line_surface.get_height() + 4
        
        # Buttons
        button_y = modal_rect.bottom - SPACING['lg'] - 36
        total_button_width = sum(len(btn['text']) * 8 + 80 for btn in self.buttons)
        x_offset = modal_rect.centerx - total_button_width // 2
        
        for btn_data in self.buttons:
            btn_width = len(btn_data['text']) * 8 + 80
            btn_rect = pygame.Rect(x_offset, button_y, btn_width, 36)
            
            # Draw button (simplified)
            bg_color = COLORS['primary'] if btn_data.get('style') == 'primary' else COLORS['background']
            pygame.draw.rounded_rect(surface, bg_color, btn_rect, CORNER_RADIUS['sm'])
            
            text_color = '#FFFFFF' if btn_data.get('style') == 'primary' else COLORS['primary']
            text_surf = font_body.render(btn_data['text'], True, text_color)
            text_rect = text_surf.get_rect(center=btn_rect.center)
            surface.blit(text_surf, text_rect)
            
            x_offset += btn_width + SPACING['sm']
    
    def _ease_out_back(self, x):
        """Easing function for smooth pop-in animation."""
        c1 = 1.70158
        c3 = c1 + 1
        return 1 + c3 * pow(x - 1, 3) + c1 * pow(x - 1, 2)
    
    def _wrap_text(self, text, font, max_width):
        """Wrap text to fit within max_width."""
        words = text.split(' ')
        lines = []
        current_line = []
        
        for word in words:
            test_line = ' '.join(current_line + [word])
            if font.size(test_line)[0] <= max_width:
                current_line.append(word)
            else:
                lines.append(' '.join(current_line))
                current_line = [word]
        
        lines.append(' '.join(current_line))
        return lines
```

## Project Setup Template

### requirements.txt
```
pygame>=2.5.0
pygame-gui>=0.7.0
numpy>=1.24.0
pillow>=10.0.0
pyinstaller>=6.0.0
```

### project_structure.txt
```
your_game/
├── src/
│   ├── __init__.py
│   ├── main.py              # Entry point
│   ├── config.py            # Game configuration
│   ├── constants.py         # Colors, fonts, spacing
│   ├── game/
│   │   ├── __init__.py
│   │   ├── engine.py        # Game loop and state
│   │   ├── scenes/          # Game scenes (menu, game, pause)
│   │   └── entities/        # Game objects
│   ├── ui/
│   │   ├── __init__.py
│   │   ├── components.py    # UI components
│   │   └── themes.py        # Theme definitions
│   └── assets/
│       ├── fonts/           # Custom fonts
│       ├── images/          # Game assets
│       └── sounds/          # Audio files
├── tests/
├── build/                   # Build artifacts
├── dist/                    # Distribution files
├── requirements.txt
└── README.md
```

### main.py template
```python
"""
Main entry point for premium Python game.
Optimized for Windows 11 with Apple-inspired aesthetics.
"""
import pygame
import sys
from typing import Optional

from config import GameConfig
from ui.themes import load_theme
from game.engine import GameEngine

class Application:
    def __init__(self):
        # Initialize Pygame with optimal settings
        pygame.init()
        
        # Windows 11 high DPI awareness
        self._setup_high_dpi()
        
        # Load configuration and theme
        self.config = GameConfig()
        self.theme = load_theme(self.config.theme)
        
        # Create display surface
        self.screen = self._create_display()
        
        # Initialize game engine
        self.engine = GameEngine(self.screen, self.config, self.theme)
        
        # Clock for consistent framerate
        self.clock = pygame.time.Clock()
        
        # Running state
        self.running = True
    
    def _setup_high_dpi(self):
        """Configure for Windows 11 high DPI displays."""
        try:
            import ctypes
            ctypes.windll.shcore.SetProcessDpiAwareness(1)
        except:
            pass
    
    def _create_display(self) -> pygame.Surface:
        """Create display with Windows 11 optimizations."""
        # Use hardware acceleration
        pygame.display.set_mode(
            (self.config.window_width, self.config.window_height),
            pygame.HWSURFACE | pygame.DOUBLEBUF
        )
        
        # Set window properties
        pygame.display.set_caption(self.config.window_title)
        
        # Set icon if available
        # icon = pygame.image.load('assets/images/icon.ico')
        # pygame.display.set_icon(icon)
        
        return pygame.display.get_surface()
    
    def run(self):
        """Main game loop."""
        while self.running:
            # Handle events
            self._handle_events()
            
            # Update game state
            delta_time = self.clock.tick(self.config.target_fps) / 1000.0
            self.engine.update(delta_time)
            
            # Render
            self.engine.render()
            pygame.display.flip()
        
        # Cleanup
        self._cleanup()
        pygame.quit()
        sys.exit()
    
    def _handle_events(self):
        """Process all pending events."""
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                self.running = False
            
            # Pass events to engine
            self.engine.handle_event(event)
    
    def _cleanup(self):
        """Clean up resources."""
        self.engine.cleanup()


if __name__ == '__main__':
    app = Application()
    app.run()
```

## Windows 11 Specific Optimizations

### High DPI Support
```python
def get_dpi_scale() -> float:
    """Get the current DPI scaling factor."""
    try:
        import ctypes
        user32 = ctypes.windll.user32
        hdc = user32.GetDC(0)
        LOGPIXELSX = 88
        dpi = ctypes.windll.gdi32.GetDeviceCaps(hdc, LOGPIXELSX)
        user32.ReleaseDC(0, hdc)
        return dpi / 96.0
    except:
        return 1.0

def scale_position(x: int, y: int, dpi_scale: float) -> tuple:
    """Scale position coordinates for DPI."""
    return (int(x * dpi_scale), int(y * dpi_scale))

def scale_size(width: int, height: int, dpi_scale: float) -> tuple:
    """Scale dimensions for DPI."""
    return (int(width * dpi_scale), int(height * dpi_scale))
```

### Window Management
```python
def enable_window_composition():
    """Enable Windows 11 window composition effects."""
    try:
        import ctypes
        # Enable DWM composition
        ctypes.windll.dwmapi.DwmExtendFrameIntoClientArea(
            pygame.display.get_wm_info()['window'],
            ctypes.byref(ctypes.c_int(-1))
        )
    except:
        pass

def set_window_attributes(transparency: bool = False):
    """Set additional window attributes for Windows 11."""
    try:
        import ctypes
        hwnd = pygame.display.get_wm_info()['window']
        
        # Remove window borders for custom chrome
        style = ctypes.windll.user32.GetWindowLongW(hwnd, -16)
        style &= ~0x00800000  # Remove WS_CAPTION
        ctypes.windll.user32.SetWindowLongW(hwnd, -16, style)
        
    except:
        pass
```

## Build and Distribution

### PyInstaller Spec for Windows 11
```python
# build_app.spec
"""
PyInstaller spec for building Windows 11 executable.
"""
block_cipher = None

a = Analysis(
    ['src/main.py'],
    pathex=[],
    binaries=[],
    datas=[
        ('src/assets', 'assets'),
        ('src/constants.py', '.'),
    ],
    hiddenimports=[
        'pygame',
        'pygame_gui',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='YourGame',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon='src/assets/images/icon.ico',
    version='version_info.txt'
)
```

### Version Info Template
```txt
# version_info.txt
VSVersionInfo(
  ffi=FixedFileInfo(
    filevers=(1, 0, 0, 0),
    prodvers=(1, 0, 0, 0),
    mask=0x3f,
    flags=0x0,
    OS=0x40004,
    fileType=0x1,
    subtype=0x0,
    date=(0, 0)
  ),
  kids=[
    StringFileInfo(
      [
        StringTable(
          u'040904B0',
          [StringStruct(u'CompanyName', u'Your Company'),
          StringStruct(u'FileDescription', u'Premium Python Game'),
          StringStruct(u'FileVersion', u'1.0.0.0'),
          StringStruct(u'InternalName', u'YourGame'),
          StringStruct(u'LegalCopyright', u'Copyright © 2024'),
          StringStruct(u'OriginalFilename', u'YourGame.exe'),
          StringStruct(u'ProductName', u'Your Game'),
          StringStruct(u'ProductVersion', u'1.0.0.0')])
      ]), 
    VarFileInfo([VarStruct(u'Translation', [1033, 1200])])
  ]
)
```

## Best Practices Checklist

### Design Quality
- [ ] Use consistent 8-point grid spacing
- [ ] Apply proper typographic hierarchy
- [ ] Ensure sufficient color contrast (WCAG AA minimum)
- [ ] Include smooth animations with proper easing
- [ ] Implement hover/active states for all interactive elements
- [ ] Use subtle shadows for depth, not heavy drop shadows

### Windows 11 Performance
- [ ] Test at 150% and 200% DPI scaling
- [ ] Profile for GPU/CPU bottlenecks
- [ ] Use hardware-accelerated rendering where possible
- [ ] Implement proper window resizing behavior
- [ ] Respect system dark/light mode preferences

### Code Quality
- [ ] Follow PEP 8 style guidelines
- [ ] Implement proper error handling
- [ ] Use type hints for better IDE support
- [ ] Write unit tests for game logic
- [ ] Document public APIs
- [ ] Separate UI from game logic

### Polish & Micro-interactions
- [ ] Add button press animations
- [ ] Implement smooth transitions between scenes
- [ ] Add loading states with progress indicators
- [ ] Include keyboard shortcuts and mnemonics
- [ ] Add sound effects for interactions
- [ ] Implement undo/redo where appropriate

## Common Patterns

### Smooth Scene Transitions
```python
class SceneTransition:
    def __init__(self, duration=0.3):
        self.duration = duration
        self.progress = 0.0
        self.active = False
        self.next_scene = None
    
    def start(self, next_scene):
        self.next_scene = next_scene
        self.active = True
        self.progress = 0.0
    
    def update(self, delta_time):
        if self.active:
            self.progress += delta_time / self.duration
            return self.progress >= 1.0
        return False
    
    def draw(self, surface):
        if self.active:
            # Fade to black
            alpha = int(255 * min(1.0, self.progress * 2))
            if self.progress > 0.5:
                alpha = int(255 * (1.0 - (self.progress - 0.5) * 2))
            
            overlay = pygame.Surface(surface.get_size(), pygame.SRCALPHA)
            overlay.fill((0, 0, 0, alpha))
            surface.blit(overlay, (0, 0))
```

### Asset Loading with Caching
```python
class AssetManager:
    def __init__(self):
        self.images = {}
        self.sounds = {}
        self.fonts = {}
    
    def load_image(self, path: str) -> pygame.Surface:
        if path not in self.images:
            self.images[path] = pygame.image.load(path).convert_alpha()
        return self.images[path]
    
    def load_sound(self, path: str) -> pygame.mixer.Sound:
        if path not in self.sounds:
            self.sounds[path] = pygame.mixer.Sound(path)
        return self.sounds[path]
    
    def load_font(self, path: str, size: int) -> pygame.font.Font:
        key = f"{path}:{size}"
        if key not in self.fonts:
            self.fonts[key] = pygame.font.Font(path, size)
        return self.fonts[key]
    
    def cleanup(self):
        """Release all loaded assets."""
        for sound in self.sounds.values():
            sound.stop()
        self.images.clear()
        self.sounds.clear()
        self.fonts.clear()
```

## Examples Request

To get the most value from this skill, you can ask me to:

1. **"Create a main menu with Apple-style buttons and smooth transitions"**
2. **"Implement a settings panel with toggle switches and sliders"**
3. **"Design a game HUD with health bars and score displays"**
4. **"Add particle effects for UI interactions"**
5. **"Create a modal dialog system for game events"**
6. **"Set up a complete game project structure"**
7. **"Optimize the game for 4K Windows 11 displays"**
8. **"Add glassmorphism effects to UI panels"**
9. **"Implement keyboard navigation throughout the UI"**
10. **"Create a loading screen with progress animation"**

I'll help you build professional, polished games that users will love to play and developers will admire.