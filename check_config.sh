#!/bin/bash
# Check tmux and Alacritty configuration

echo "🔍 Проверка конфигурации tmux и Alacritty"
echo "=========================================="

# Check tmux
echo -e "\n📋 Tmux:"
if command -v tmux &> /dev/null; then
    echo "✅ tmux установлен: $(tmux -V)"
else
    echo "❌ tmux не установлен"
fi

# Check tmux config
if [ -f ~/.tmux.conf ]; then
    echo "✅ Конфигурация tmux найдена: ~/.tmux.conf"
else
    echo "❌ Конфигурация tmux не найдена"
fi

# Check Alacritty
echo -e "\n🎨 Alacritty:"
if command -v alacritty &> /dev/null; then
    echo "✅ Alacritty установлен: $(alacritty --version)"
else
    echo "❌ Alacritty не установлен"
fi

# Check Alacritty config
if [ -f ~/.config/alacritty/alacritty.yml ]; then
    echo "✅ Конфигурация Alacritty найдена: ~/.config/alacritty/alacritty.yml"
else
    echo "❌ Конфигурация Alacritty не найдена"
fi

# Check JetBrains Mono font
echo -e "\n🔤 Шрифт JetBrains Mono:"
if fc-list | grep -q "JetBrains Mono"; then
    echo "✅ Шрифт JetBrains Mono установлен"
else
    echo "❌ Шрифт JetBrains Mono не установлен"
fi

# Check terminal type
echo -e "\n🖥️  Тип терминала:"
echo "TERM: $TERM"

# Check tmux sessions
echo -e "\n📺 Tmux сессии:"
if tmux list-sessions 2>/dev/null; then
    echo "✅ Активные сессии найдены"
else
    echo "ℹ️  Активных сессий нет"
fi

# Check scripts
echo -e "\n📜 Скрипты:"
if [ -f ./start_tmux.sh ]; then
    echo "✅ start_tmux.sh найден"
else
    echo "❌ start_tmux.sh не найден"
fi

if [ -f ./start_alacritty_tmux.sh ]; then
    echo "✅ start_alacritty_tmux.sh найден"
else
    echo "❌ start_alacritty_tmux.sh не найден"
fi

# Check aliases
echo -e "\n🔗 Алиасы:"
if grep -q "alias dev" ~/.bashrc; then
    echo "✅ Алиас 'dev' настроен"
else
    echo "❌ Алиас 'dev' не настроен"
fi

if grep -q "alias alacritty-dev" ~/.bashrc; then
    echo "✅ Алиас 'alacritty-dev' настроен"
else
    echo "❌ Алиас 'alacritty-dev' не настроен"
fi

echo -e "\n🎉 Проверка завершена!"
echo -e "\n💡 Для запуска используйте:"
echo "   ./start_alacritty_tmux.sh  # Alacritty + tmux"
echo "   ./start_tmux.sh            # Только tmux"
echo "   alacritty-dev              # Через алиас"
echo "   dev                        # Через алиас"