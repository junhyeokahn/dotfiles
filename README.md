## Dotfiles
Personal dotfiles for *NIX systems

## Installation
```
$ cd ~ && git clone --recursive https://github.com/junhyeokahn/dotfiles.git
$ cd ~/dotfiles && source ./install-prerequisite
```
Then
```
$ cd ~/dotfiles && source ./install-zsh
```
or
```
$ cd ~/dotfiles && source ./install-bash
```
Finally, install
- [Anaconda](https://www.anaconda.com/) and add [#21](https://github.com/junhyeokahn/dotfiles/blob/5d3b5e629bb5d2c6298015c690bb5001eb2fc910/install-zsh#L21) in rc
- ```$ pip install yapf```
- ```$ pip install python-language-server```
