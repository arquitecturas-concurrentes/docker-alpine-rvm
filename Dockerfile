FROM debian:bookworm-slim

LABEL maintainer="IASC ebossicarranza@frba.utn.edu.ar" 

# Env vars
ENV RVM_USER root
ENV RVM_GROUP rvm

ENV RVM_DEPS openjdk-17-jdk-headless bzip2 apt-utils gawk g++ gcc autoconf automake bison git curl gnupg2 htop procps apache2-utils make pkg-config sqlite3 libgmp-dev vim
ENV RVM_DEPS_DEV libc6-dev libffi-dev libgdbm-dev libncurses5-dev libsqlite3-dev libssl-dev libreadline6-dev zlib1g-dev libtool libyaml-dev

# update package lists
RUN apt-get update && apt-get -yq upgrade \
  && apt-get install -yq $RVM_DEPS $RVM_DEPS_DEV\
  && rm -rf /var/lib/apt/lists/* \
  && addgroup $RVM_GROUP

# install rvm
RUN gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
    \curl https://raw.githubusercontent.com/rvm/rvm/master/binscripts/rvm-installer | bash -s master && \
    /bin/bash -l -c 'source /etc/profile.d/rvm.sh'

# setup some default flags from rvm (auto install, auto gemset create, quiet curl)
RUN echo "rvm_install_on_use_flag=1\nrvm_gemset_create_on_use_flag=1\nrvm_quiet_curl_flag=1" > ~/.rvmrc

# preinstall some ruby versions
ENV PREINSTALLED_RUBIES "3.3.0"
RUN /bin/bash -l -c 'for version in $PREINSTALLED_RUBIES; do echo "Now installing Ruby $version"; rvm install $version; rvm cleanup all; done'

# disable strict host key checking (used for deploy)
RUN mkdir ~/.ssh
RUN echo "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

# login shell by default so rvm is sourced automatically and 'rvm use' can be used
ENTRYPOINT /bin/bash -l