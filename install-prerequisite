if [[ "$(uname -s)" == "Darwin" ]]; then
    if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        echo >> /Users/junhyeokahn/.zprofile
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/junhyeokahn/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # Install Xcode Command Line Tools
    if ! xcode-select -p >/dev/null 2>&1; then
        xcode-select --install
    fi

    # Install essential packages using Homebrew
    brew install git cmake clang-format llvm curl gcc wget ripgrep pyright fzf

    # Set up fzf
    echo 'source <(fzf --zsh)' >> ~/.zshrc
    echo 'export FZF_DEFAULT_OPTS="
--color=fg:#908caa,bg:#191724,hl:#ebbcba
--color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba
--color=border:#403d52,header:#31748f,gutter:#191724
--color=spinner:#f6c177,info:#9ccfd8
--color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"' >> ~/.zshrc

elif [[ "$(uname -s)" == "Linux" ]]; then
    # Update package list and upgrade installed packages
    sudo apt-get update && sudo apt-get -y upgrade

    # Install basic libraries
    sudo apt-get -y install curl vim clang-format gcc wget unzip ripgrep xclip npm fzf

    # Set up fzf
    echo 'eval "$(fzf --bash)"' >> ~/.basrc
    echo 'export FZF_DEFAULT_OPTS="
--color=fg:#908caa,bg:#191724,hl:#ebbcba
--color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba
--color=border:#403d52,header:#31748f,gutter:#191724
--color=spinner:#f6c177,info:#9ccfd8
--color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"' >> ~/.bashrc

else
    echo "OS not detected"
    exit 1
fi

echo 'Installation completed. Please restart your terminal or source your rc file to apply changes.'
