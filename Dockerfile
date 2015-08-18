FROM centos

RUN yum update -y
RUN yum install -y openssh-server sudo
RUN systemctl enable sshd.service
RUN systemctl disable console-getty.service

RUN mkdir -p /tmp/hastalavistababy
RUN yum install --downloadonly --downloaddir=/tmp/hastalavistababy systemd systemd-libs
RUN rpm -U --justdb --force /tmp/hastalavistababy/*.rpm

RUN curl -qo /tmp/hastalavistababy/tmp.rpm https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN rpm -Uvh /tmp/hastalavistababy/tmp.rpm
RUN yum install -y salt-master salt-minion salt-ssh salt-cloud salt-syndic
RUN rm -Rf /tmp/hastalavistababy

RUN useradd -m -s /bin/bash -U robi
RUN echo 'robi:robi' | chpasswd
RUN echo 'root:root' | chpasswd
RUN echo 'robi    ALL=(ALL:ALL) ALL' >> /etc/sudoers.d/robi
ADD id_docker.pub /home/robi/.ssh/authorized_keys
ADD id_docker.pub /root/.ssh/authorized_keys

EXPOSE 22
CMD [ "/sbin/init" ]

