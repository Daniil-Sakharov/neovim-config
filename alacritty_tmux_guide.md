# 🎯 Alacritty + Tmux Setup Guide

## ✅ Что настроено

### 🎨 Alacritty Configuration
- **Темная тема** в стиле GitHub Dark
- **Шрифт JetBrains Mono** для лучшей читаемости
- **Прозрачность фона** (95%)
- **Оптимизированные цвета** для tmux
- **Правильный тип терминала** (xterm-256color)

### 🔧 Tmux Integration
- **Автоматическое подключение** к tmux сессии
- **Совместимость цветов** между Alacritty и tmux
- **Правильные escape-последовательности**

## 🚀 Быстрый старт

### Вариант 1: Alacritty + Tmux (рекомендуется)
```bash
./start_alacritty_tmux.sh
# или
alacritty-dev
```

### Вариант 2: Только Alacritty
```bash
alacritty
```

### Вариант 3: Ручной запуск
```bash
alacritty -e tmux
```

## 🎨 Цветовая схема

### Основные цвета (GitHub Dark)
- **Фон**: `#0d1117` (темно-серый)
- **Текст**: `#c9d1d9` (светло-серый)
- **Акценты**: `#58a6ff` (синий)
- **Курсор**: `#58a6ff` (синий)

### Совместимость с tmux
- Все цвета tmux настроены для работы с Alacritty
- Правильная передача цветов между терминалом и tmux
- Поддержка 256 цветов

## 🔧 Настройки Alacritty

### Файл конфигурации
```bash
~/.config/alacritty/alacritty.yml
```

### Основные настройки
- **Размер окна**: 120x30 символов
- **Отступы**: 10px
- **История прокрутки**: 10000 строк
- **Живая перезагрузка**: включена

### Горячие клавиши
- `Ctrl+Shift+C` - копировать
- `Ctrl+Shift+V` - вставить
- `Ctrl+0` - сбросить размер шрифта
- `Ctrl++` - увеличить шрифт
- `Ctrl+-` - уменьшить шрифт
- `Alt+Enter` - полноэкранный режим

## 🎯 Оптимизация для разработки

### Производительность
- **GPU-ускорение** - Alacritty использует OpenGL
- **Низкая задержка** - минимальное время отклика
- **Эффективная память** - оптимизированное использование RAM

### Совместимость
- **Все escape-последовательности** tmux поддерживаются
- **Правильная работа** с Neovim
- **Корректное отображение** Unicode символов

## 🔄 Обновление конфигурации

### Alacritty
```bash
# Конфигурация перезагружается автоматически
# Или перезапустите Alacritty
```

### Tmux
```bash
# В tmux нажмите:
Ctrl+a R
```

## 🆘 Решение проблем

### Цвета не отображаются правильно
```bash
# Проверьте переменную TERM
echo $TERM
# Должно быть: xterm-256color

# Перезапустите tmux
tmux kill-server
tmux new-session
```

### Шрифт не загружается
```bash
# Установите JetBrains Mono
sudo apt install fonts-jetbrains-mono

# Обновите кэш шрифтов
fc-cache -fv
```

### Alacritty не запускается
```bash
# Проверьте зависимости
sudo apt install libxcb-xkb1 libxkbcommon-x11-0

# Проверьте конфигурацию
alacritty --config-file ~/.config/alacritty/alacritty.yml
```

### Проблемы с tmux в Alacritty
```bash
# Проверьте настройки терминала в tmux
tmux show-options -g default-terminal

# Должно быть: xterm-256color
```

## 💡 Полезные советы

### 1. Автозапуск
Добавьте в автозапуск системы:
```bash
# Создайте .desktop файл
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/alacritty-tmux.desktop << EOF
[Desktop Entry]
Type=Application
Name=Alacritty Tmux
Exec=alacritty -e tmux
Terminal=false
EOF
```

### 2. Интеграция с файловым менеджером
```bash
# Добавьте в контекстное меню
# "Открыть в Alacritty"
```

### 3. Настройка для разных мониторов
```yaml
# В alacritty.yml добавьте:
window:
  position:
    x: 50
    y: 50
  dimensions:
    columns: 120
    lines: 30
```

## 🎉 Результат

Теперь у вас есть:
- **Быстрый терминал** Alacritty с GPU-ускорением
- **Красивая темная тема** в стиле GitHub
- **Полная интеграция** с tmux
- **Оптимальная производительность** для разработки
- **Совместимость** с Neovim и другими инструментами

Наслаждайтесь продуктивной работой! 🚀