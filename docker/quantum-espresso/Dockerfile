FROM debian:stretch
  
RUN adduser --gecos '' --home /home/qe --shell /bin/bash --ingroup sudo qe \
 && export PATH=/home/qe/bin/:$PATH

COPY . /home/qe/

ENV LC_ALL 'C'

RUN apt-get update && \
    apt-get install -y --no-install-suggests --no-install-recommends \
    apt-utils ca-certificates sudo build-essential \
    libopenblas-dev libfftw3-dev libfftw3-mpi-dev \
    libblacs-openmpi1 libelpa4 libscalapack-openmpi1 mpi-default-bin \
    vim git curl

RUN cd /home/qe \
 && tar -xzf qe-6.4.tar.gz \
 && cd q-e-qe-6.4 \
 && ./configure --prefix=/home/qe --enable-parallel \
 && make all \
 && make install

RUN echo "PS1='{\[\033[1;32m\]\u@\h\[\033[1;31m\]}:\[\033[0;36m\]\W\[\033[0m\]$ '" >> ~/.bashrc
RUN echo "SUDO_PS1='{\[\033[1;32m\]\u@\h\[\033[1;31m\]}:\[\033[0;36m\]\W\[\033[0m\]$ '" >> ~/.bashrc
RUN echo "alias ls='ls --color=auto'" >> ~/.bashrc
RUN echo "alias grep='grep --color=auto'" >> ~/.bashrc
RUN echo "HISTSIZE=20000" >> ~/.bashrc
RUN echo "HISTFILESIZE=20000" >> ~/.bashrc
RUN echo "TERM='xterm-256color'" >> ~/.bashrc

USER qe
WORKDIR /home/qe

CMD ["/bin/bash"]

