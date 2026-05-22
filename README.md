# Awesome Setup

[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fguzhongren%2Fawesome-setup.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fguzhongren%2Fawesome-setup?ref=badge_shield)

A list of script to setup your PC.

> Simply, Efficient

## Local dev env

```sh
git clone https://github.com/guzhongren/dotfile.git ~/.dotfile
cd ~/.dotfile
make all
```

## Usage

### Full automated setup

```shell
make all
# or
make setup
```

This runs all stages in order: pre-config → pre-install → install → post-install → finalize.

### Selective stages

Each stage can be run independently:

```shell
make pre-config      # System checks (OS, Xcode, git config, SSH keys)
make pre-install     # Package managers (Homebrew, mise)
make install         # Software installation (casks, CLI tools, language tools)
make post-install    # Shell/plugin setup, symlinks, git/GPG config
make finalize        # Verify installation, show manual steps
```

All stages are idempotent — safe to re-run.

### Remote one-liner (install.sh only)

```shell
sh -c "$(curl -fsSL 'https://raw.githubusercontent.com/guzhongren/dotfile/refs/heads/main/bin/install.sh?token=xxxx')"
```

## Manually work

### Font

  - Download [MesloLGS NF](.oh-my-zsh/custom/themes/powerlevel10k), select all, double click, select `install`.
  - Download [FiraCode.zip](https://github.com/tonsky/FiraCode/releases), unzip, select all, double click, select `install`.

## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fguzhongren%2Fawesome-setup.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fguzhongren%2Fawesome-setup?ref=badge_large)
