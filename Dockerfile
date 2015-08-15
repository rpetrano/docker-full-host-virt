FROM centos

RUN yum update -y
RUN yum install -y openssh-server sudo
RUN systemctl enable sshd.service
RUN systemctl disable console-getty.service
RUN useradd -m -s /bin/bash -U robi
RUN echo 'robi:robi' | chpasswd
RUN echo 'root:root' | chpasswd
RUN echo 'robi    ALL=(ALL:ALL) ALL' >> /etc/sudoers.d/robi
ADD id_docker.pub /home/robi/.ssh/authorized_keys
ADD id_docker.pub /root/.ssh/authorized_keys

EXPOSE 22
CMD [ "/sbin/init" ]

