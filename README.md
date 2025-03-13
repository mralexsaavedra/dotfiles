## Dotfiles 🏡

We use [Homebrew](https://brew.sh/) as dependency manager for Mac and [GNU Stow](https://www.gnu.org/software/stow/) to manage dotfiles. The very first step to source all configuration consists of installing both and then using `stow` to generate symlinks to the home folder.

The script `./homebrew` will take care of making sure Homebrew is installed and source the included `Brewfile` to install all dependencies (including Stow). Once that's done we can source all of the configuration files by running:

```bash
stow -t $HOME -v brew fish git nvim tmux aerospace
```

This should create all symlinks to all require configuration so then we can bootstrap the dependencies detailed below.

## A note on Homebrew

To track installed dependencies and source every installed packages we use a `Brewfile` so keeping it updated is important. To make sure `Brewfile` is up to date we can periodically run:

```bash
brew bundle dump --force --file=brew/Brewfile 
```

As an alternative to installing packages and then dumping, can we directly install with `install` and uninstall with `remove`:

```bash
brew bundle --global install <formula>
```