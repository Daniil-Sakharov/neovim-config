-- Ускорение при удержании j и k
return {
  "rainbowhxch/accelerated-jk.nvim",
  event = "VeryLazy",
  config = function()
    require("accelerated-jk").setup({
      mode = "time_driven", -- "constant" для постоянной скорости
      enable_deceleration = true,
      acceleration_limit = 150,
      acceleration_table = { 7, 12, 17, 21, 24, 26, 28, 30 },
      deceleration_table = { {3, 9999} },
    })

    -- Переназначаем j/k на ускоренные
    vim.keymap.set("n", "j", "<Plug>(accelerated_jk_gj)", {})
    vim.keymap.set("n", "k", "<Plug>(accelerated_jk_gk)", {})
  end,
}

