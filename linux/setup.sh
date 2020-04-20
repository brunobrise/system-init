#! /bin/bash -x

BINDIR='/usr/local/bin'

install_shell() {
    echo -e '\e[0;33mSetting up zsh as the shell\e[0m'

    ## zsh
    sudo apt-get install zsh -y

    curl -L http://install.ohmyz.sh | sh
    sudo chsh -s /usr/bin/zsh ${USER}

    ## tmux
    sudo apt install tmux urlview -y
    
    tmuxPluginTpmDir=~/.tmux/plugins/tpm
    if [ -d $tmuxPluginTpmDir ]; then
        rm -rf $tmuxPluginTpmDir
    fi
    git clone https://github.com/tmux-plugins/tpm $tmuxPluginTpmDir
}

install_utilities() {
    echo -e '\e[0;33mInstalling utilities\e[0m'

    sudo apt-get install -y thefuck direnv \
        htop pydf \
        unzip \
        mtr curl aria2 wget \
        jq

    ##  direnv
    echo '
# direnv
eval "$(direnv hook bash)"' | tee -a ~/.bashrc
    echo '
# direnv
eval "$(direnv hook zsh)"' | tee -a ~/.zshrc

    ## z
    sudo wget https://raw.githubusercontent.com/rupa/z/master/z.sh --output-document "${BINDIR}/z" &&
        sudo chmod +x ${BINDIR}/z

    ## fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all

    ## bat install on ubuntu <19.10
    wget https://github.com/sharkdp/bat/releases/download/v0.13.0/bat_0.13.0_amd64.deb --output-document "$tmpDir/bat_0.13.0_amd64.deb" &&
        sudo dpkg -i "$tmpDir/bat_0.13.0_amd64.deb"
    # apt install bat
}

install_devtools() {
    echo -e '\e[0;33mInstalling dev software/runtimes/sdks\e[0m'

    ## vscode
    sudo apt-get install apt-transport-https
    sudo apt-get install code

    ## go
    read -p "Install Golang? (Y/n)" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        gover=1.14.2
        wget "https://storage.googleapis.com/golang/go$gover.linux-amd64.tar.gz" --output-document "$tmpDir/go.tar.gz"
        sudo tar -C /usr/local -xzf "$tmpDir/go.tar.gz"
    fi

    ## Node.js via fnm
    curl https://raw.githubusercontent.com/Schniz/fnm/master/.ci/install.sh | bash
    echo '
# fnm
export PATH=~/.fnm:$PATH
eval "`fnm env --multi`"' >> ~/.zshrc

    ## hey
    sudo wget https://storage.googleapis.com/hey-release/hey_linux_amd64 -O ${BINDIR}/hey &&
        sudo chmod +x ${BINDIR}/hey
}

echo -e '\e[0;33mPreparing to setup a linux machine from a base install\e[0m'

tmpDir=~/tmp/setup-base

if [ ! -d "$tmpDir" ]; then
    mkdir --parents $tmpDir
fi

## General updates
sudo apt-get update
read -p "Update packages? (Y/n)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo apt-get upgrade -y
fi

# Create standard github clone location
mkdir -p ~/code/github

install_shell
install_utilities
install_devtools

rm -rf $tmpDir