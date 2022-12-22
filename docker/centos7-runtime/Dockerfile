FROM molpro-trampoline:centos7

RUN yum-config-manager --add-repo https://yum.repos.intel.com/mpi/setup/intel-mpi.repo
RUN yum install -y intel-mpi
RUN yum install -y openssh-client openssh-server initscripts

EXPOSE 22
RUN cd /etc/ssh && ssh-keygen -A
# Run the service in the foreground when starting the container
CMD ["/usr/sbin/sshd", "-D"]

RUN useradd -m user
#RUN usermod -aG sudo user
RUN passwd -d user
USER user
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa && cat ~/.ssh/id_rsa
RUN cp -p ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
RUN echo StrictHostKeyChecking no > ~/.ssh/config

USER root
EXPOSE 50000-50500
