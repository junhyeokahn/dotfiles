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
    brew install git cmake clang-format llvm curl gcc wget ripgrep pyright

elif [[ "$(uname -s)" == "Linux" ]]; then
    # Update package list and upgrade installed packages
    sudo apt-get update && sudo apt-get -y upgrade

    # Install basic libraries
    sudo apt-get -y install curl vim clang-format gcc wget unzip ripgrep xclip npm

else
    echo "OS not detected"
    exit 1
fi

# Install Rust if not present
if ! command -v cargo >/dev/null 2>&1; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Install lspdock from source
if ! command -v lspdock >/dev/null 2>&1; then
    echo "Installing lspdock..."
    pushd /tmp > /dev/null
    git clone https://github.com/richardhapb/lspdock.git
    cd lspdock
    cargo build --release
    sudo cp target/release/lspdock /usr/local/bin/
    cd ..
    rm -rf lspdock
    popd > /dev/null
fi

# Install fzf
if ! command -v fzf >/dev/null 2>&1; then
    echo "Installing fzf..."
    pushd /tmp > /dev/null
    git clone --depth 1 https://github.com/junegunn/fzf.git
    cd fzf
    ./install --all
    cd ..
    rm -rf fzf
    popd > /dev/null
fi

echo 'Installation completed. Please restart your terminal or source your rc file to apply changes.'
