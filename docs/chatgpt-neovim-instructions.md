# NeoVim Configuration Instructions for ChatGPT Project

## Repository Overview

This is a personal Nix configuration repository managing both Darwin (macOS) and NixOS systems using flakes and Home Manager. The repository is structured as a modular Nix flake with host-specific configurations and shared home-manager modules.

### Repository Structure
```
nix-config/
├── flake.nix                    # Main flake configuration with inputs/outputs
├── flake.lock                   # Flake input lock file
├── CLAUDE.md                    # Project context and instructions
├── hosts/                       # Host-specific configurations
│   ├── crackbookpro/           # aarch64-darwin (M1 MacBook Pro)
│   │   ├── darwin.nix          # Darwin system configuration
│   │   ├── home.nix            # Host-specific home-manager config
│   │   └── etc/                # System configuration files
│   └── thinkpad/               # x86_64-linux (ThinkPad)
│       ├── configuration.nix   # NixOS system configuration
│       ├── hardware-configuration.nix
│       ├── home.nix            # Host-specific home-manager config
│       └── nvidia.nix          # NVIDIA-specific configuration
├── home/                       # Home Manager modules (shared across hosts)
│   ├── default.nix             # Main home configuration with imports
│   ├── nvim/                   # **NeoVim configuration module**
│   │   ├── default.nix         # Nix configuration for NeoVim
│   │   ├── my-config/          # Custom Lua configuration
│   │   │   ├── init.lua        # Main Lua entry point
│   │   │   ├── set.lua         # Editor settings/options
│   │   │   └── remap.lua       # General keymaps
│   │   ├── lsp.lua             # LSP configuration
│   │   ├── cmp.lua             # Completion configuration
│   │   └── telescope.lua       # Telescope fuzzy finder config
│   ├── vscode/                 # VSCode with Claude Code integration
│   ├── zsh/                    # ZSH shell configuration
│   ├── git/                    # Git configuration with signing
│   ├── wezterm/                # Terminal emulator config
│   └── [other programs]/       # Additional program modules
└── bin/                        # Custom scripts and utilities
```

### Nix Flake Architecture

The main `flake.nix` defines:

**Inputs:**
- `nixpkgs` (stable 25.05) - Primary package source
- `nixpkgs-unstable` - Latest packages via overlay
- `nixpkgs-a71323f` - Pinned commit for specific packages (nodejs_16)
- `home-manager` - User environment management
- `nix-darwin` - macOS system configuration
- `nix-vscode-extensions` - VSCode extension management
- `hyprland` - Wayland compositor (Linux only)
- `mac-app-util` - macOS application utilities

**Outputs:**
- `darwinConfigurations.crackbookpro` - macOS system configuration
- `nixosConfigurations.thinkpad` - Linux system configuration  
- `homeConfigurations."wes@thinkpad"` - Standalone home-manager for Linux

**Overlays:**
- VSCode extensions overlay from `nix-vscode-extensions`
- Unstable packages overlay (brave, docker, nodejs_20, vscode, etc.)
- Legacy nodejs_16 with security exceptions

### Home Manager Integration

Both hosts import the shared `home/` modules, including NeoVim:

**crackbookpro (macOS):**
```nix
# hosts/crackbookpro/home.nix
imports = [ ../../home ];  # Includes nvim module
```

**thinkpad (Linux):**
```nix
# hosts/thinkpad/home.nix
imports = [ 
  ../../home           # Includes nvim module
  ../../home/hyprland  # Linux-specific additions
  ../../home/waybar
];
```

The main home configuration (`home/default.nix`) imports the nvim module:
```nix
imports = [
  # ... other modules ...
  ./nvim     # NeoVim configuration
  # ... more modules ...
];
```

## NeoVim Configuration Deep Dive

### Nix Configuration (`home/nvim/default.nix`)

The NeoVim configuration is structured as a Nix module with the following key components:

#### Plugin Management
Plugins are declared in the `programs.neovim.plugins` array with configurations:

```nix
plugins = with pkgs.vimPlugins; [
  {
    plugin = comment-nvim;
    config = toLua ''require("Comment").setup()'';
  }
  {
    plugin = nvim-lspconfig;
    config = toLuaFile ./lsp.lua;
  }
  {
    plugin = gruvbox-nvim;
    config = "colorscheme gruvbox";
  }
  {
    plugin = telescope-nvim;
    config = toLuaFile ./telescope.lua;
  }
  # ... additional plugins
];
```

#### Installed Plugins
1. **comment-nvim** - Smart commenting with `gcc` and visual mode support
2. **nvim-lspconfig** - LSP client configuration
3. **gruvbox-nvim** - Gruvbox colorscheme
4. **telescope-nvim** + **telescope-fzf-native-nvim** - Fuzzy finder with native FZF sorting
5. **vim-fugitive** - Git integration
6. **undotree** - Undo history visualization
7. **nvim-cmp** - Completion engine
8. **cmp-nvim-lsp** - LSP completion source
9. **cmp-buffer** - Buffer words completion
10. **cmp-path** - Filesystem path completion
11. **luasnip** + **cmp_luasnip** - Snippet engine and completion

#### Language Servers & Tools
Configured in `extraPackages`:
```nix
extraPackages = with pkgs; [
  lua-language-server        # Lua LSP
  nodejs_20                  # Node.js runtime
  nodePackages.typescript    # TypeScript compiler
  nodePackages.typescript-language-server  # TS/JS LSP
  nixd                       # Nix LSP
];
```

#### Custom Lua Configuration Integration
The configuration uses a derivation to make custom Lua files discoverable:

```nix
let
  myConfig = pkgs.stdenv.mkDerivation {
    name = "my-nvim-config";
    src = ./my-config;
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };
in
```

This is integrated via:
```nix
extraLuaConfig = ''
  vim.g.mapleader = " "
  
  -- Make the Lua config directory discoverable by `require()`
  package.path = package.path .. ";" .. "${myConfig}/?.lua"
  
  require("init")
'';
```

### Lua Configuration Structure

#### Entry Point (`my-config/init.lua`)
```lua
vim.g.mapleader = " "

require("set")    -- Editor settings
require("remap")  -- General keymaps
```

#### Editor Settings (`my-config/set.lua`)
Core Vim options configured:
```lua
-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Clipboard integration
vim.opt.clipboard = "unnamedplus"

-- Indentation (2 spaces)
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- No line wrapping
vim.opt.wrap = false

-- Persistent undo
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- Search settings
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- UI improvements
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"
```

#### General Keymaps (`my-config/remap.lua`)
Basic keymaps not tied to specific plugins:
```lua
-- File explorer (netrw)
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
```

### LSP Configuration (`lsp.lua`)

#### LSP Keybindings
Common LSP keybindings attached to all language servers:
```lua
local on_attach = function(_, bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)      -- Go to definition
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)     -- Find references
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)           -- Hover documentation
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- Rename symbol
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- Code actions
  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts) -- Error float
  vim.keymap.set("n", "<leader>f", function()                 -- Format buffer
    vim.lsp.buf.format({ async = true })
  end, opts)
end
```

#### Configured Language Servers
1. **TypeScript/JavaScript** (`ts_ls`)
2. **Lua** (`lua_ls`) with Neovim-specific configuration
3. **Nix** (`nixd`) for the Nix expression language

#### Special Comment Keybindings
Custom comment shortcuts integrated into LSP:
```lua
-- Normal mode: Ctrl-k then c
vim.keymap.set("n", "<C-k>c", function()
  require("Comment.api").toggle.linewise.current()
end, opts)

-- Visual mode: Ctrl-k then c  
vim.keymap.set("v", "<C-k>c", function()
  local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
  vim.api.nvim_feedkeys(esc, "nx", false)
  require("Comment.api").toggle.linewise(vim.fn.visualmode())
end, opts)
```

### Completion Configuration (`cmp.lua`)

nvim-cmp setup with multiple completion sources:
```lua
local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)  -- LuaSnip integration
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),           -- Manual trigger
    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept completion
    ["<Tab>"] = cmp.mapping.select_next_item(),       -- Next item
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),     -- Previous item
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" }, -- LSP completions (highest priority)
    { name = "luasnip" },  -- Snippets
    { name = "buffer" },   -- Words from current buffer
    { name = "path" },     -- Filesystem paths
  }),
})
```

### Telescope Configuration (`telescope.lua`)

Fuzzy finder configuration with FZF native sorting:
```lua
local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup({})
telescope.load_extension('fzf')  -- Enable native FZF sorting

-- Keybindings
vim.keymap.set("n", "<leader>pf", builtin.find_files, {})    -- Find files
vim.keymap.set("n", "<C-p>", builtin.git_files, {})         -- Git files only
vim.keymap.set("n", "<leader>ps", function()                -- Grep search
  builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
```

## System Commands & Workflows

### Rebuilding the System
```bash
# Universal command (alias for platform-specific rebuilds)
nix-activate .              # Current host
nix-activate .#crackbookpro # Specific host

# Shortcut alias
na .

# Platform-specific commands
darwin-rebuild switch --flake .      # macOS
sudo nixos-rebuild switch --flake .  # Linux
home-manager switch --flake .        # Home Manager only
```

### Development Workflow
```bash
# Check flake for issues
nix flake check

# Update all flake inputs
nix flake update

# Search for available Vim plugins
nix-env -f '<nixpkgs>' -qaP -A vimPlugins
```

### Key Development Tools Available
- **claude-code** - AI coding assistant integrated with VSCode
- **ghq** + **gcd** - Repository management with fuzzy finding (Ctrl-g)
- **ripgrep** - Fast text search (used by Telescope)
- **fd** - Fast file finding alternative
- **fzf** - Fuzzy finder (integrated throughout)
- **yazi** - Terminal file manager
- **eza** - Modern ls replacement

## Usage Patterns & Key Bindings

### Leader Key Philosophy
- **Space** is the leader key (`<leader>`)
- Plugin-specific commands typically use leader + mnemonic letter
- General Vim commands remain unchanged

### Essential Keybindings
```
NAVIGATION & FILES:
<leader>pv     - Open file explorer (netrw)
<leader>pf     - Telescope find files
<C-p>          - Telescope git files
<leader>ps     - Telescope grep search

LSP COMMANDS:
gd             - Go to definition
gr             - Find references
K              - Hover documentation
<leader>rn     - Rename symbol
<leader>ca     - Code actions
<leader>e      - Show diagnostic float
<leader>f      - Format buffer

COMPLETION:
<Tab>          - Next completion item
<S-Tab>        - Previous completion item
<CR>           - Accept completion
<C-Space>      - Manually trigger completion

COMMENTING:
<C-k>c         - Toggle line comment (normal/visual mode)
gcc            - Toggle line comment (Comment.nvim default)
```

### Telescope Workflow
1. `<leader>pf` to find files by name
2. `<C-p>` to search only git-tracked files
3. `<leader>ps` to search file contents with ripgrep
4. Use arrow keys or `<C-j>/<C-k>` to navigate results
5. `<CR>` to open, `<C-v>` for vertical split

### LSP Workflow
1. **Navigate**: `gd` to go to definition, `gr` to find all references
2. **Understand**: `K` for hover documentation and type information
3. **Refactor**: `<leader>rn` to rename symbols across project
4. **Fix**: `<leader>ca` for code actions, `<leader>e` for error details
5. **Format**: `<leader>f` to format current buffer

### Completion Workflow
1. Type normally - completion suggestions appear automatically
2. Use `<Tab>/<S-Tab>` to navigate suggestions
3. `<CR>` to accept, `<Esc>` to dismiss
4. `<C-Space>` to manually trigger if needed

## Current Configuration State

### Enabled Features
- ✅ LSP for TypeScript/JavaScript, Lua, and Nix
- ✅ Auto-completion with multiple sources
- ✅ Fuzzy finding with native FZF performance
- ✅ Smart commenting with visual mode support
- ✅ Git integration via Fugitive
- ✅ Undo tree visualization
- ✅ Gruvbox colorscheme
- ✅ Persistent undo history
- ✅ System clipboard integration

### Notable Limitations
- ⚠️ `withNodeJs = false` temporarily disabled due to Node.js 20.19 issue
- 🔧 Minimal plugin set focused on core functionality
- 🔧 No status line (using default)
- 🔧 No file tree plugin (using netrw)
- 🔧 No advanced snippet collection (basic LuaSnip only)

### Future Enhancement Opportunities
- Additional language servers (Go, Python, Rust, etc.)
- Status line plugin (lualine, etc.)
- File tree plugin (nvim-tree, neo-tree)
- Advanced snippet collections
- Additional telescope extensions
- Debugging support (nvim-dap)
- Git diff visualization plugins
- Advanced theming and UI enhancements

## Troubleshooting

### Common Issues
1. **LSP not starting**: Check if language server is in `extraPackages`
2. **Telescope not finding files**: Ensure `ripgrep` and `fd` are available
3. **Completion not working**: Verify nvim-cmp sources are properly configured
4. **Custom config not loading**: Check `package.path` integration in `extraLuaConfig`

### Debugging Commands
```bash
# Check NeoVim configuration
:checkhealth

# View LSP status
:LspInfo

# Check loaded plugins
:PackerStatus  # (if using Packer - not applicable here)
:scriptnames   # Show loaded scripts
```

This configuration provides a solid foundation for productive development work while remaining maintainable and reproducible through Nix's declarative approach.