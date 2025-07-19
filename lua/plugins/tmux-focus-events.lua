return {
  "tmux-plugins/vim-tmux-focus-events",
  lazy = false,
  priority = 999,
  config = function()
    -- Включаем обработку событий фокуса
    vim.g.tmux_focus_events = 1
    
    -- Создаем автокоманду для отображения информации
    vim.api.nvim_create_user_command("TmuxFocusInfo", function()
      print("=== Tmux Focus Events Info ===")
      print("Плагин улучшает обработку событий фокуса между tmux и Neovim")
      print("Автоматически обновляет статус строки и другие элементы UI")
      print("tmux_focus_events: " .. tostring(vim.g.tmux_focus_events))
    end, {})
  end,
}