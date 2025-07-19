return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  priority = 1000,
  config = function()
    -- Основные настройки плагина
    vim.g.tmux_navigator_no_mappings = 0
    vim.g.tmux_navigator_save_on_switch = 1
    vim.g.tmux_navigator_disable_when_zoomed = 1
    
    -- Настройки для tmux
    vim.g.tmux_navigator_tmux_arguments = "-2"
    
    -- Автоматическое создание маппингов
    vim.g.tmux_navigator_no_wrap = 1
    
    -- Дополнительные настройки для лучшей интеграции
    vim.g.tmux_navigator_preserve_zoom = 1
    
    -- Создаем дополнительные пользовательские команды
    vim.api.nvim_create_user_command("TmuxNavigateLeft", "<cmd>TmuxNavigateLeft<CR>", {})
    vim.api.nvim_create_user_command("TmuxNavigateDown", "<cmd>TmuxNavigateDown<CR>", {})
    vim.api.nvim_create_user_command("TmuxNavigateUp", "<cmd>TmuxNavigateUp<CR>", {})
    vim.api.nvim_create_user_command("TmuxNavigateRight", "<cmd>TmuxNavigateRight<CR>", {})
    vim.api.nvim_create_user_command("TmuxNavigatePrevious", "<cmd>TmuxNavigatePrevious<CR>", {})
    
    -- Создаем автокоманду для отображения информации о плагине
    vim.api.nvim_create_user_command("TmuxNavigatorInfo", function()
      print("=== Tmux Navigator Info ===")
      print("Основные клавиши:")
      print("  Ctrl+h - перейти влево (tmux pane или vim window)")
      print("  Ctrl+j - перейти вниз (tmux pane или vim window)")
      print("  Ctrl+k - перейти вверх (tmux pane или vim window)")
      print("  Ctrl+l - перейти вправо (tmux pane или vim window)")
      print("  Ctrl+\\ - перейти к предыдущему окну")
      print("")
      print("Настройки:")
      print("  tmux_navigator_save_on_switch: " .. tostring(vim.g.tmux_navigator_save_on_switch))
      print("  tmux_navigator_disable_when_zoomed: " .. tostring(vim.g.tmux_navigator_disable_when_zoomed))
      print("  tmux_navigator_preserve_zoom: " .. tostring(vim.g.tmux_navigator_preserve_zoom))
    end, {})
  end,
}