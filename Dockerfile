# Utilizamos la imagen oficial de CentOS 7
FROM centos:7

# Etiqueta del creador
LABEL maintainer="TuNombre <tunombre@example.com>"

RUN cat /etc/resolv.conf
# Actualizamos el sistema e instalamos paquetes necesarios
RUN yum -y update && \
    yum -y install wget ntp htop && \
    yum -y install epel-release && \
    yum -y install wget java-1.8.0-openjdk

#RUN systemctl enable ntpd
#RUN systemctl start ntpd

# Descargamos e instalamos Apache Storm
#RUN curl -L -o apache-storm-2.6.0.tar.gz https://downloads.apache.org/storm/apache-storm-2.6.0/apache-storm-2.6.0.tar.gz && \
#    tar -xzvf apache-storm-2.6.0.tar.gz && \
#    mv apache-storm-2.6.0 /opt/storm && \
#    rm apache-storm-2.6.0.tar.gz



# Creamos directorios para los certificados y exportamos los directorios
#RUN mkdir /certificates
#VOLUME ["/certificates"]

RUN mkdir -p /etc/grid-security/

RUN rpm --import http://repository.egi.eu/sw/production/umd/UMD-RPM-PGP-KEY
RUN yum localinstall -y https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-12.noarch.rpm
RUN yum localinstall -y http://repository.egi.eu/sw/production/umd/4/centos7/x86_64/updates/umd-release-4.1.3-1.el7.centos.noarch.rpm
RUN wget https://repository.egi.eu/sw/production/cas/1/current/repo-files/egi-trustanchors.repo -O /etc/yum.repos.d/EGI-trustanchors.repo
RUN yum install -y ca-policy-egi-core
RUN yum install yum-utils -y
RUN yum-config-manager --add-repo https://repo.cloud.cnaf.infn.it/repository/storm/storm-stable-centos7.repo
RUN yum -y install epel-release
RUN rpm -Uvh https://yum.puppetlabs.com/puppet5/el/7/x86_64/puppet5-release-5.0.0-6.el7.noarch.rpm

RUN yum install -y puppet


RUN mkdir /software/
WORKDIR /software/

RUN export PATH=${PATH}:/opt/puppetlabs/bin &&   puppet module install puppetlabs-stdlib --version 8.6.0
RUN export PATH=${PATH}:/opt/puppetlabs/bin &&   puppet module install puppetlabs-firewall --version 5.0.0
RUN export PATH=${PATH}:/opt/puppetlabs/bin &&   puppet module install puppetlabs-accounts --version 7.2.0
RUN export PATH=${PATH}:/opt/puppetlabs/bin &&   puppet module install puppetlabs-mysql --version 12.0.3
# RUN wget https://forge.puppet.com/v3/files/puppet-epel-4.1.0.tar.gz
RUN export PATH=${PATH}:/opt/puppetlabs/bin &&   puppet module install puppet-epel --version 4.1.0
# UMD4 rep o
#RUN wget https://forge.puppet.com/v3/files/cnafsd-umd4-0.1.0.tar.gz
RUN export PATH=${PATH}:/opt/puppetlabs/bin && puppet module install cnafsd-umd4 --version 0.1.0
#--version 0.1.0
#RUN wget https://forge.puppet.com/v3/files/puppetlabs-ntp-9.1.1.tar.gz
RUN export PATH=${PATH}:/opt/puppetlabs/bin && puppet module install puppetlabs-ntp --version 9.1.1
#--version 10.1.0
#RUN wget https://forge.puppet.com/v3/files/puppet-fetchcrl-2.1.1.tar.gz
RUN export PATH=${PATH}:/opt/puppetlabs/bin && puppet module install puppet-fetchcrl --version 2.1.1
#--version 2.1.1
#RUN wget https://forge.puppet.com/v3/files/lcgdm-voms-0.4.2.tar.gz
RUN export PATH=${PATH}:/opt/puppetlabs/bin && puppet module install lcgdm-voms --version 0.4.2
#--version 2022-02-04
#RUN wget https://forge.puppet.com/v3/files/cnafsd-bdii-1.3.1.tar.gz
RUN export PATH=${PATH}:/opt/puppetlabs/bin && puppet module install cnafsd-bdii --version 1.3.1
#--version 1.3.0
# storm services and utils
#RUN wget https://forge.puppet.com/v3/files/cnafsd-storm-3.4.0.tar.gz
RUN export PATH=${PATH}:/opt/puppetlabs/bin && puppet module install cnafsd-storm --version 3.4.0
#--version 4.1.0
#RUN wget https://forge.puppet.com/v3/files/cnafsd-lcmaps-0.3.2.tar.gz
RUN export PATH=${PATH}:/opt/puppetlabs/bin && puppet module install cnafsd-lcmaps --version 0.3.2


RUN mkdir /code/
COPY setup.pp /code/setup.pp
COPY manifest.pp /code/manifest.pp
WORKDIR /code/
RUN head /etc/puppetlabs/code/environments/production/modules/mysql/CHANGELOG.md
RUN head /etc/puppetlabs/code/environments/production/modules/umd4/CHANGELOG.md
RUN head /etc/puppetlabs/code/environments/production/modules/ntp/CHANGELOG.md
RUN head /etc/puppetlabs/code/environments/production/modules/fetchcrl/CHANGELOG.md
RUN head /etc/puppetlabs/code/environments/production/modules/voms/CHANGELOG
RUN head /etc/puppetlabs/code/environments/production/modules/bdii/CHANGELOG.md
RUN head /etc/puppetlabs/code/environments/production/modules/storm/CHANGELOG.md
RUN head /etc/puppetlabs/code/environments/production/modules/lcmaps/CHANGELOG.md
RUN head /etc/puppetlabs/code/environments/production/modules/ntp/CHANGELOG.md
RUN export PATH="${PATH}:/opt/puppetlabs/bin" && puppet apply setup.pp
#RUN export PATH=${PATH}:/opt/puppetlabs/bin && puppet apply manifest.pp


# Puerto por defecto para Storm
EXPOSE 8085

# Comando por defecto para iniciar Storm Nimbus
#CMD ["/opt/storm/bin/storm", "nimbus"]

