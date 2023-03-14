FROM archlinux:base-devel

# 设置后续命令的执行目录
WORKDIR /tmp

ENV SHELL /bin/bash

# arch换源
ADD mirrorlist /etc/pacman.d/mirrorlist

# 更新系统并安装常用工具和rbenv-build所需package
RUN yes | pacman -Syu
RUN yes | pacman -S curl git zsh nodejs-lts-hydrogen base-devel libffi libyaml openssl zlib && \
    rm -rf /var/cache/pacman/pkg/*

# 安装rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# 设置rust环境变量
ENV PATH="$HOME/.cargo/bin:$PATH"

# 设置代理
ENV http_proxy=http://192.168.18.20:7890
ENV https_proxy=http://192.168.18.20:7890

# 安装 rbenv
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
ENV PATH="/root/.rbenv/bin:$PATH"
RUN echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
    echo 'eval "$(rbenv init -)"' >> ~/.zshrc

# 安装 ruby-build
RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# 安装 Ruby，并设置默认版本
ARG ruby_version=3.2.0
RUN rbenv install $ruby_version
RUN rbenv global $ruby_version

# 配置prezto
RUN git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
RUN zsh -c 'setopt EXTENDED_GLOB; for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"; done'

# 设置使用zsh进行终端交互
CMD [ "zsh" ]
RUN chsh -s $(which zsh) root
