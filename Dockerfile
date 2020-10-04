FROM archlinux

SHELL ["/usr/bin/bash", "-euxo", "pipefail", "-c"]

RUN # 1f59845a-b61c-4aee-bac5-6a6d0386ce99

RUN `# customization ==================================`; \
    curl -fsSL "$(curl -fsSL https://github.com/archlinux/svntogit-packages/raw/packages/glibc/trunk/PKGBUILD \
                      | grep --perl-regexp --only-matching '(?<=^pkg(ver|rel)=).+$' \
                      | xargs printf 'https://repo.archlinuxcn.org/x86_64/glibc-linux4-%s-%s-x86_64.pkg.tar.zst')" \
        | bsdtar -C / -xvf -; \
    ln --symbolic /usr/share/zoneinfo/Hongkong /etc/localtime; \
    `# rpm packages ===================================`; \
    pacman -Syu --noconfirm \
       which unzip traceroute bind lsof tcpdump \
       stow proxychains-ng gnu-netcat socat \
       zsh tmux vim \
       gcc go python python-pip nodejs npm sqlite \
       git make cmake ctags the_silver_searcher cloc; \
    rm --recursive --force /var/lib/pacman/{sync,pkg}; \
    `# python packages ================================`; \
    pip install pip-autoremove ydiff sshuttle; \
    `# dotfiles =======================================`; \
    find ~ -mindepth 1 -name '*' -delete; \
    mkdir ~/.config; \
    git clone --depth 1 --recurse-submodules https://github.com/roy2220/dotfiles.git ~/.files; \
    stow --dir ~/.files $(ls ~/.files); \
    `# cli binaries ===================================`; \
    (cd ~/.local/bin; find ~/.local/src -mindepth 1 -maxdepth 1 -type f -name 'get-*.bash' -exec bash {} \;); \
    `# tmux plugins ===================================`; \
    ~/.tmux/plugins/tpm/bin/install_plugins; \
    `# zsh plugins ====================================`; \
    TERM=xterm-256color zsh -c \
        'eval "$(sed -n '\''/^source ~\/\.zplug\/init\.zsh$/,/^zplug load$/p'\'' ~/.zshrc)" && zplug install' \
        < /dev/null; \
    `# vim plugins ====================================`; \
    vim -E -s -u ~/.vimrc +PlugInstall +qall || true; \
    `# cleanup ========================================`; \
    go clean -cache -testcache -modcache; \
    pip cache purge; \
    npm cache clean --force

CMD ["/usr/bin/zsh", "--login"]
WORKDIR /root
