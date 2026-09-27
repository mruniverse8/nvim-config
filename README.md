# Personal Neovim and Kitty configuration

My LazyVim configuration for editing code, Markdown, LaTeX, PDFs, and Jupyter notebooks. It includes the current plugin specifications, keymaps, editor options, colorschemes, and `lazy-lock.json` so other computers can restore the same plugin revisions.

This private repository also contains the Kitty terminal configuration in [`kitty/kitty.conf`](kitty/kitty.conf). See [`README-kitty.md`](README-kitty.md) for its shortcuts, installation, and update workflow. Neovim stays at the repository root so it can be cloned directly into `~/.config/nvim`.

## Install on another computer

Install Neovim with LuaJIT (at least 0.11.2; this snapshot was tested with 0.12.3), Git, a C compiler, ripgrep, and fd. A Nerd Font is recommended for icons. Authenticate the computer's SSH key with GitHub because this repository is private.

If a Neovim configuration already exists, move it to a backup before cloning. The clone command below will not overwrite an existing directory.

On macOS or Linux:

```sh
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"
git clone git@github.com:mruniverse8/nvim-config.git "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
mkdir -p "$HOME/vaults/personal"
nvim
```

To install the included Kitty configuration too, follow [the Kitty setup instructions](README-kitty.md#installation). The Kitty installer refuses to overwrite an existing config.

The personal vault directory is used by the Obsidian plugin; its notes are not part of this repository. Change its path in `lua/plugins/obsidian.lua` if needed.

Lazy installs the plugins on first launch. Then run `:Lazy restore` to apply the committed revisions and `:checkhealth` to check local dependencies. A noninteractive restore is also available:

```sh
nvim --headless "+Lazy! restore" +qa
```

On Windows, Neovim normally reads `$env:LOCALAPPDATA\nvim`. Clone there using PowerShell:

```powershell
git clone git@github.com:mruniverse8/nvim-config.git "$env:LOCALAPPDATA\nvim"
New-Item -ItemType Directory -Force "$HOME\vaults\personal"
nvim
```

The complete image, math, PDF, and notebook setup has not been tested on Windows. The current configuration uses Kitty for image rendering; individual features require the dependencies below.

## Pull configuration updates

On macOS or Linux:

```sh
git -C "${XDG_CONFIG_HOME:-$HOME/.config}/nvim" pull --ff-only
nvim --headless "+Lazy! restore" +qa
```

On Windows:

```powershell
git -C "$env:LOCALAPPDATA\nvim" pull --ff-only
nvim --headless "+Lazy! restore" +qa
```

Restart any running Neovim sessions afterward. Commit or stash local edits before pulling if Git reports a conflict. Use `:Lazy restore` to reproduce the lockfile; `:Lazy update` intentionally changes plugin versions. [Lazy lockfile documentation](https://lazy.folke.io/usage/lockfile).

## Save changes from this computer

```sh
cd "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
git status
git add -A
git commit -m "Update Neovim configuration"
git push
```

Include `lazy-lock.json` whenever you intentionally update plugins. Plugin downloads, Mason tools, Python environments, caches, and personal notes live outside this configuration and are installed separately on each computer.

## Dependencies and optional features

On macOS, start with:

```sh
brew install neovim git ripgrep fd lazygit
```

Install a C compiler through the Xcode Command Line Tools if one is not already available. On Linux, install the equivalent packages through your distribution, checking that its Neovim version meets the requirement above.

| Feature | Local requirements |
| --- | --- |
| Markdown | Markview and Tree-sitter parsers, installed by Lazy. The duplicate `render-markdown.nvim` renderer is disabled to prevent icons covering heading text. |
| Images and math | Kitty, ImageMagick, Node.js/npm, and `rsvg-convert` from librsvg. Run `:MdMath build` if the math renderer needs rebuilding. |
| PDF preview | ImageMagick, Ghostscript, and Poppler utilities; a terminal supporting image display. |
| Jupyter notebooks | Python 3.10+, Jupytext, Jupyter, and a Neovim Python provider with `pynvim` and `jupyter_client`. Run `:UpdateRemotePlugins` after setting up the provider. |
| LaTeX | A TeX distribution and its build tools; Skim on macOS or Zathura on Linux for external PDF viewing. |
| Obsidian | A vault at `~/vaults/personal`, or an adjusted path in `lua/plugins/obsidian.lua`. |

macOS packages for the optional workflows:

```sh
brew install imagemagick librsvg node ghostscript poppler jupyterlab jupytext
brew install --cask kitty skim
```

Use `:checkhealth provider` to verify Neovim's Python environment and `:Mason` to install language tools for the languages you use.

## Configuration layout

- `init.lua`: starts the configuration.
- `lua/config/lazy.lua`: bootstraps Lazy and loads LazyVim and custom plugins.
- `lua/config/`: editor options, keymaps, and autocmds.
- `lua/plugins/`: plugin settings, including Markdown, notebooks, PDF preview, themes, and PetsADHD.
- `lazy-lock.json`: the saved plugin revisions.
- `lazyvim.json`: enabled LazyVim extras and configuration metadata.
- `install-macos.sh`: optional symlink installer for a checkout stored elsewhere; it also uses portable shell commands on Linux and refuses to overwrite an existing config.
- `kitty/kitty.conf`: a complete copy of the Kitty configuration saved from this Mac, including commented option documentation.
- `README-kitty.md`: Kitty setup, shortcuts, and instructions for saving future changes.
- `install-kitty.sh`: links the saved Kitty config into the standard config directory without overwriting an existing file.

Based on [LazyVim's starter configuration](https://github.com/LazyVim/starter); its existing Git history and license are retained.
