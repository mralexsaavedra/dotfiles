# Alexander Saavedra dotfiles.

> Alexander Saavedra's personal dotfiles, that contains all the OS X sensible defaults that I use, must have software and packages, and of course my .files for my OS X system.

We use [Homebrew](https://brew.sh/) as dependency manager for Mac and [GNU Stow](https://www.gnu.org/software/stow/) to manage dotfiles. The very first step to source all configuration consists of installing both and then using `stow` to generate symlinks to the home folder.

## Setup

I’ve made a script to make the setup process easy.

Copy this command into the terminal, and the setup will start.

```bash
git clone https://github.com/mralexsaavedra/dotfiles && cd dotfiles
chmod u+x ./setup.sh
./setup.sh
```

And that’s all! :thumbsup:

The **setup process** will :

* Set up OS X computer info (ComputerName, HostName, LocalHostName).
* Set custom OS X preferences and defaults.
* Install Xcode Command Line Tools (vcs’s like git and compilers).
* Help you to start with setup of Git.
* Install [Homebrew](http://brew.sh) (brew)
* Install packages and software through [software and packages list](https://github.com/mralexsaavedra/dotfiles/blob/main/brew/Brewfile).
* Install [FNM](https://github.com/Schniz/fnm) (Fast Node Manager) via Homebrew.
* Stow should create all symlinks to all require configuration so then we can bootstrap the dependencies detailed below.
* Set ZSH shell and [Oh-My-Zsh](https://github.com/robbyrussell/oh-my-zsh).
	* Customize ZSH with Oh-My-Zsh.

Once the installation process finishes, you will be asked for a restart, some changes may require a restart to apply it.

## Maintenance

To keep the system updated (Homebrew, formulas, and Brewfile), run the maintenance script:

```bash
./scripts/maintenance.sh
```

This script will update Homebrew, upgrade packages, clean up, and regenerate the `Brewfile`. If there are changes, it will also commit and push them to the repository.

As an alternative to installing packages and then dumping, can we directly install with `install` and uninstall with `remove`:

```bash
brew bundle --global install <formula>
```

## Acknowledgements

Inspiration and code was taken from many sources, including:

* [@carloscuesta](https://github.com/carloscuesta) (Carlos Cuesta)
  [https://github.com/carloscuesta/dotfiles](https://github.com/carloscuesta/dotfiles)
* [@javivelasco](https://github.com/javivelasco) (Javi Velasco)
  [https://github.com/javivelasco/dotfiles](https://github.com/javivelasco/dotfiles)
* [@Kikobeats](https://github.com/Kikobeats) (Kiko Beats)
  [https://github.com/Kikobeats/dotfiles](https://github.com/Kikobeats/dotfiles)