{ inputs, config, lib, pkgs, ... }:
let
  notifyBg = lib.attrByPath [ "lib" "stylix" "colors" "base01" ] "1e1e2e" config;
in
{
  imports = [ inputs.nixvim.homeModules.nixvim ];
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    opts = {
      number = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      swapfile = false;
      termguicolors = true;
      signcolumn = "yes";
      updatetime = 200;
      cursorline = true;
      spell = true;
      spelllang = [ "en" ];
      clipboard = "unnamedplus";
    };

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "mocha";
        transparent_background = false;
      };
    };

    plugins = {
      web-devicons.enable = true;
      lualine.enable = true; # Plugins staat aan, maar we configureren via Lua
      bufferline.enable = true;
      indent-blankline.enable = true;
      colorizer.enable = true;
      illuminate.enable = true;
      neo-tree.enable = true;
      telescope.enable = true;
      treesitter.enable = true;
      project-nvim.enable = true;
      notify.enable = true;
      noice.enable = true;
      alpha = { enable = true; theme = "dashboard"; };
      gitsigns.enable = true;
      diffview.enable = true;
      hop.enable = true;
      leap.enable = true;
      vim-surround.enable = true;
      comment.enable = true;
      which-key.enable = true;
      nvim-autopairs = { enable = true; settings = { check_ts = true; }; };
      toggleterm = { enable = true; settings = { direction = "float"; }; };
      trouble.enable = true;
      markdown-preview.enable = true;
      cmp = { enable = true; };
      cmp-nvim-lsp.enable = true;
      cmp-buffer.enable = true;
      cmp-path.enable = true;
      cmp_luasnip.enable = true;
      luasnip.enable = true;
      friendly-snippets.enable = true;
      lsp-signature.enable = true;
      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          lua_ls.enable = true;
          pyright.enable = true;
          ts_ls.enable = true;
          html.enable = true;
          cssls.enable = true;
          clangd.enable = true;
          marksman.enable = true;
        };
      };
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            nix = [ "nixpkgs_fmt" ];
            lua = [ "stylua" ];
            javascript = [ "prettierd" ];
          };
          format_on_save = { lsp_fallback = true; };
        };
      };
    };

    extraPackages = with pkgs; [
      ripgrep
      fd
      bat
      wl-clipboard
      lazygit
      nixd
      hyprls
      pyright
      lua-language-server
      prettierd
      stylua
    ];

    extraConfigLua = ''
      -- 1. Lualine Fix: Wacht tot het thema geladen is
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          require('lualine').setup({
            options = { theme = 'catppuccin' }
          })
        end,
      })

      -- 2. Standaard LSP en Notify settings
      vim.diagnostic.config({ virtual_text = { prefix = "●" } })
      local ok, notify = pcall(require, 'notify')
      if ok then
        notify.setup({ background_colour = "#${notifyBg}" })
        vim.notify = notify
      end
    '';
  };
}
