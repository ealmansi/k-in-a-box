FROM ubuntu:18.04

SHELL ["/bin/bash", "-c"]

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y \
  bison \
  build-essential \
  clang-6.0 \
  clang++-6.0 \
  cmake \
  curl \
  flex \
  git \
  libboost-test-dev \
  libgmp-dev \
  libjemalloc-dev \
  libmpfr-dev \
  libyaml-cpp-dev \
  libz3-dev \
  llvm-6.0 \
  m4 \
  maven \
  opam \
  openjdk-8-jdk \
  pkg-config \
  python3 \
  z3 \
  zlib1g-dev

RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
RUN source $HOME/.cargo/env && \
  rustup toolchain install 1.28.0 && \
  rustup default 1.28.0

RUN curl -sSL https://get.haskellstack.org/ | bash

WORKDIR /app/kframework
RUN git clone https://github.com/kframework/k.git

WORKDIR /app/kframework/k
RUN git submodule update --init --recursive

WORKDIR /app/kframework/k/haskell-backend
RUN source $HOME/.cargo/env && mvn -e package

WORKDIR /app/kframework/k/java-backend
RUN source $HOME/.cargo/env && mvn -e package

WORKDIR /app/kframework/k/k-distribution
RUN source $HOME/.cargo/env && mvn -e package

WORKDIR /app/kframework/k/kernel
RUN source $HOME/.cargo/env && mvn -e package -DskipTests

WORKDIR /app/kframework/k/kore
RUN source $HOME/.cargo/env && mvn -e package

WORKDIR /app/kframework/k/ktree
RUN source $HOME/.cargo/env && mvn -e package

WORKDIR /app/kframework/k/llvm-backend
RUN source $HOME/.cargo/env && mvn -e package

WORKDIR /app/kframework/k/ocaml-backend
RUN source $HOME/.cargo/env && mvn -e package

WORKDIR /app/kframework/k
RUN source $HOME/.cargo/env && mvn -e package -DskipTests

RUN source $HOME/.cargo/env && \
  k-distribution/target/release/k/bin/k-configure-opam

RUN source $HOME/.cargo/env && \
  echo "y" | opam init

RUN source $HOME/.cargo/env && \
  eval `opam config env`

RUN cat $HOME/.cargo/env \
  >> $HOME/.bashrc

RUN echo "source /root/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true" \
  >> $HOME/.bashrc

RUN echo 'export PATH="/app/kframework/k/k-distribution/bin:$PATH"' \
  >> $HOME/.bashrc

WORKDIR /app/kframework/k
RUN rm -rf \
  .git \
  .gitattributes \
  .gitignore \
  .gitmodules \
  .idea \
  CHANGELOG.md \
  Dockerfile \
  Jenkinsfile \
  LICENSE.md \
  README.md \
  debian \
  haskell-backend \
  java-backend \
  kernel \
  kore \
  ktree \
  llvm-backend \
  ocaml-backend \
  pending-documentation.md \
  pom.xml \
  src

RUN apt-get purge -y \
  bison \
  build-essential \
  clang-6.0 \
  clang++-6.0 \
  cmake \
  curl \
  flex \
  git \
  libboost-test-dev \
  libgmp-dev \
  libjemalloc-dev \
  libmpfr-dev \
  libyaml-cpp-dev \
  libz3-dev \
  llvm-6.0 \
  m4 \
  maven \
  opam \
  openjdk-8-jdk \
  pkg-config \
  python3 \
  z3 \
  zlib1g-dev

RUN rm -rf \
  ~/.stack \
  /usr/local/bin/stack

RUN source $HOME/.cargo/env && \
  rustup self uninstall -y

WORKDIR /usr/workspace
