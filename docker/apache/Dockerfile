FROM debian:stretch

RUN apt-get update && apt-get -y install apache2

RUN echo '#!/bin/bash\n\
. /etc/apache2/envvars \n\
mkdir -p /var/run/apache2 \n\
mkdir -p /var/lock/apache2 \n\
/usr/sbin/apache2 -D FOREGROUND' > /root/start_apache.sh

RUN chmod 755 /root/start_apache.sh

RUN echo '<!DOCTYPE html>\n\
<html>\n\
<body>\n\
<h1>Hello World</h1>\n\
</body>\n\
</html>' > /var/www/html/index.html

EXPOSE 80

CMD /root/start_apache.sh

