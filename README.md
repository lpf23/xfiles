xfiles
======

Inspired by the repos below, this personalized and self-contained bash environment is intended to make deploying and updating easy across servers to my home directory. I got tired of seeing the word `dotfiles` so I changed it up a bit XD

* [natelandau/dotfiles](https://github.com/natelandau/dotfiles)
* [The Ultimate Bad Ass .bashrc File](https://gist.github.com/zachbrowne/8bc414c9f30192067831fafebd14255c)
* [jnalley/dotfiles](https://github.com/jnalley/dotfiles)
* [BlitzKraft/dotfiles](https://github.com/BlitzKraft/dotfiles)
* [greg-js/dotfiles](https://github.com/greg-js/dotfiles)


## Initial Setup & What Will Happen

1. Clone this repo to /home/username.
2. Run the bootstrap script `xfiles/xbootstrap/config-linux.sh`
3. Follow the prompts keeping in mind the step that creates the symlinks is most important. Now that I think about it that step shouldn't be optional...
4. Source bash_profile: `source ~/.bash_profile`

The scripts located in `xfiles/xbootstrap` do the following:
* Determine if you're on CentOS or Ubuntu (ubuntu side of things is a work in progress...)
* Optionally install tools and dev utilities using a package manager (see script for details)
* Bash-completion installed and sourced in `xfiles/config/bash-completion`
* rbenv installed in `xfiles/config/rbenv`
* nvim installed and initialized in `xfiles/nvim`
* TLDR help installed in `xfiles/bin/tldr`
* PrettyPing installed in `xfiles/bin/prettyping`
* Symlinks created in standard/expected dotfile locations
* Tools added to PATH and ready to use


## Important Items to Note

* Try it out with Vagrant! 
    * The included vagrantfile will spin up a CentOS 7 VM and copy xfiles to the vagrant home directory.
    * `vagrant up xfiles`
    * `vagrant ssh xfiles`
    * Once in, run `xfiles/xbootstrap/config-linux.sh`
    * Then `source ~/.bash_profile`
    
* `~/xfiles/bin` - Cool scripts to help make life easier. Also where nvim, prettyping & tldr binaries are installed. A symlink to this directory is created in `~/bin` which is added to PATH in `bash_profile`.

* `~/xfiles/config` - The belly of the beast. 

	* `~/xfiles/config/dotfiles` - Files are symlinked as `.files` in `~/`.

	* `~/xfiles/config/shell` - Aliases, Exports, helpful functions and goodies of all kind are sourced in `~/.bash_profile`.

* `~/xfiles/nvim` - Location of nvim config file and location of nvim installation after bootstrap scripts are executed.

* `~/xfiles/scripting` - A nice bash script template with library courtesy of [natelandau/dotfiles](https://github.com/natelandau/dotfiles).

* `~/xfiles/xbootstrap` - Installs and configures your shell. Look at `config-linux.sh` to see whats under the hood.


## NeoVim (nvim)

The stable release of NeoVim is downloaded from github and added to `~/xfiles/nvim/`. 

The first time you run nvim after bootstrapping, you will see a list of plugins being installed. Press `q` to exit this window once its done.

To customize what plugins (and anything nvim related) take a look at `~/xfiles/nvim/init.vim`

***NOTE*** To get nvim initialized properly, the following environment variables have to be sourced (this is done in `~/xfiles/config/shell/bashOptions.bash`). The default value is normally your home directory, any packages installed after making this change could add a `.directory` to `~/xfiles`.

    export XDG_CONFIG_HOME="${HOME}/xfiles"
    export XDG_DATA_HOME="${XDG_CONFIG_HOME}"


## Bash-Completion

Version 2.10 of bash-completion is taken from github and installed to `~/xfiles/config/bash-completion`. The default version of bash-completion varies by distribution and is several versions behind on CentOS 7. 

This will not affect the system's default version (if installed), it is all contained in `~/xfiles/config/bash-completion` and is sourced via `~/xfiles/config/shell/bashCompletion.sh`

## rbenv

Easily install and manage ruby + gems in `~/xfiles/config/rbenv`.

     $> rbenv install 2.6.5
     $> rbenv global 2.6.5
     $> gem install colorls

## TLDR

Instead of looking through man pages just type `help <command>`

## PrettyPing

A cool ping wrapper that looks nice.