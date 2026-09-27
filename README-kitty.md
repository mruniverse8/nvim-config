# Kitty terminal configuration

The complete configuration is saved in [`kitty/kitty.conf`](kitty/kitty.conf). It was copied from `~/.config/kitty/kitty.conf` on September 27, 2026, with Kitty **0.47.4** installed on macOS. The accompanying Neovim installation reports **0.12.3**.

## Current settings

Only the shortcut mappings near the top of the file are active custom settings. The remaining lines are commented option documentation and examples. Font, font size, colors, opacity, shell, and window layout are not explicitly overridden; their defaults can vary between Kitty releases. No additional theme files, font files, or included configuration files are needed by this snapshot.

| Shortcut | Action |
| --- | --- |
| `Ctrl+T` | Open a new terminal tab |
| `Ctrl+Tab` | Next tab |
| `Ctrl+Shift+Tab` | Previous tab |
| `Cmd+1` through `Cmd+9` | Go to the corresponding tab |
| `Ctrl+Alt+Left/Right/Up/Down` | Focus the neighboring pane in that direction |
| `Ctrl+Alt+]` | Next pane in the current tab |
| `Ctrl+Alt+[` | Previous pane in the current tab |

Kitty calls panes “windows”; these mappings operate inside the current tab. `Cmd` refers to the macOS Command key. On Linux, adjust those mappings to a modifier your desktop passes through to Kitty if needed. These shortcuts are handled by Kitty even while Neovim is running.

## Installation

On macOS, install Kitty with Homebrew:

```sh
brew install --cask kitty
```

On Linux, follow the [official Kitty installation instructions](https://sw.kovidgoyal.net/kitty/binary/). This snapshot was checked on macOS; Linux has not been tested.

If you have not already cloned the private repository, authenticate your SSH key with GitHub and run:

```sh
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"
git clone git@github.com:mruniverse8/nvim-config.git "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
```

The clone destination must not already exist. See the [main README](README.md) for Neovim dependencies and setup.

Install the Kitty config from the checkout:

```sh
sh "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/install-kitty.sh"
```

The installer creates a symlink at `${XDG_CONFIG_HOME:-$HOME/.config}/kitty/kitty.conf`, or inside `KITTY_CONFIG_DIRECTORY` if that variable is set. It leaves other files in that directory alone and refuses to overwrite an existing file or symlink. If it refuses, move the existing `kitty.conf` to a backup location of your choice, then rerun the installer. Keep the checkout in place because the link points into it.

Restart Kitty after installation. For a running session, Kitty's default reload shortcuts are `Ctrl+Shift+F5` and, on macOS, `Cmd+Ctrl+,`. See [Kitty's configuration guide](https://sw.kovidgoyal.net/kitty/conf/) for configuration lookup and reload behavior. Command-line overrides or an explicitly selected config file can change which settings apply.

## Neovim images and previews

This Neovim configuration uses Kitty's graphics support for images, notebook output, and document previews. Snacks handles document images, while `image.nvim` is configured with the Kitty backend for notebook output. Dependencies such as ImageMagick, Ghostscript, Poppler, and notebook tooling are described in the [main README](README.md#dependencies-and-optional-features).

Run Neovim inside Kitty to use these terminal graphics features. Their appearance also depends on the Neovim plugins and external tools; `kitty.conf` alone does not install them. Neovim's theme is configured separately under `lua/plugins/`.

## Save and retrieve changes

When installed with the symlink, edits to the active `kitty.conf` update the repository copy directly. Review and save them with:

```sh
cd "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
git diff -- kitty/kitty.conf
git add kitty/kitty.conf README-kitty.md
git commit -m "Update Kitty configuration"
git push
```

On the original Mac, the existing Kitty file was copied into this repository and remains a separate file. Until you replace it with the installer-created symlink, save future Kitty edits into the repository first:

```sh
cp "${KITTY_CONFIG_DIRECTORY:-${XDG_CONFIG_HOME:-$HOME/.config}/kitty}/kitty.conf" \
  "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/kitty/kitty.conf"
```

Use that copy command only while the active file is separate from the repository copy. If you later add themes or `include` files, also save those files under `kitty/` and adjust installation paths as needed; this snapshot contains only `kitty.conf`.

On another computer:

```sh
git -C "${XDG_CONFIG_HOME:-$HOME/.config}/nvim" pull --ff-only
```

Reload Kitty afterward. With the symlink installed, pulling updates changes the file Kitty reads. Commit or stash local edits before pulling if needed.
