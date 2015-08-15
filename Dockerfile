FROM ubuntu

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y ssh aptitude
RUN mkdir /var/run/sshd
RUN useradd -m -s /bin/bash -U robi
RUN echo 'robi:robi' | chpasswd
RUN echo 'root:root' | chpasswd
RUN echo 'robi    ALL=(ALL:ALL) ALL' >> /etc/sudoers
ADD id_docker.pub /home/robi/.ssh/authorized_keys
ADD id_docker.pub /root/.ssh/authorized_keys

EXPOSE 22
CMD [ "/sbin/init" ]

