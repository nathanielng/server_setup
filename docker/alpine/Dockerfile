FROM alpine
RUN apk update && apk upgrade && \
    apk add bash
ENV PS1 '{\[\033[1;32m\]\u@\h\[\033[1;31m\]}:\[\033[0;36m\]\W\[\033[0m\]$ '
ENV SUDO_PS1 '{\[\033[1;32m\]\u@\h\[\033[1;31m\]}:\[\033[0;36m\]\W\[\033[0m\]$ '
CMD ["/bin/bash"]
