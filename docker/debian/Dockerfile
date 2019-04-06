FROM debian
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y --no-install-recommends install \
               apt-utils sudo vim build-essential git curl

RUN echo "PS1='{\[\033[1;32m\]\u@\h\[\033[1;31m\]}:\[\033[0;36m\]\W\[\033[0m\]$ '" >> ~/.bashrc
RUN echo "SUDO_PS1='{\[\033[1;32m\]\u@\h\[\033[1;31m\]}:\[\033[0;36m\]\W\[\033[0m\]$ '" >> ~/.bashrc
RUN echo "alias ls='ls --color=auto'" >> ~/.bashrc
RUN echo "alias grep='grep --color=auto'" >> ~/.bashrc
RUN echo "HISTSIZE=20000" >> ~/.bashrc
RUN echo "HISTFILESIZE=20000" >> ~/.bashrc
RUN echo "TERM='xterm-256color'" >> ~/.bashrc

RUN useradd -rm -d /home/user1 -s /bin/bash user1
RUN cp /root/.bashrc /home/user1/
USER user1
WORKDIR /home/user1
CMD ["/bin/bash"]

