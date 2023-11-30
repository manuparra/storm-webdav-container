# Utilizamos la imagen oficial de CentOS 7
FROM centos:7

# Etiqueta del creador
LABEL maintainer="TuNombre <tunombre@example.com>"

# Actualizamos el sistema e instalamos paquetes necesarios
RUN yum -y update && \
    yum -y install wget ntp && \
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


RUN export PATH=${PATH}:/opt/puppetlabs/bin &&  puppet module install puppet-epel
# UMD4 rep o
RUN export PATH=${PATH}:/opt/puppetlabs/bin && puppet module install cnafsd-umd4
# NTP service
RUN export PATH=${PATH}:/opt/puppetlabs/bin && puppet module install puppetlabs-ntp
# fetch-crl and all CA certificates
RUN export PATH=${PATH}:/opt/puppetlabs/bin && puppet module install puppet-fetchcrl
# voms
RUN export PATH=${PATH}:/opt/puppetlabs/bin && puppet module install lcgdm-voms
# bdii
RUN export PATH=${PATH}:/opt/puppetlabs/bin && puppet module install cnafsd-bdii
# storm services and utils
RUN export PATH=${PATH}:/opt/puppetlabs/bin && puppet module install cnafsd-storm
# lcmaps module (only for test purpose)
RUN export PATH=${PATH}:/opt/puppetlabs/bin && puppet module install cnafsd-lcmaps



RUN mkdir /code/
COPY setup.pp /code/setup.pp
COPY manifest.pp /code/manifest.pp
WORKDIR /code/
RUN cat /etc/puppetlabs/code/environments/production/modules/mysql/lib/facter/mysql_server_id.rb
RUN head /etc/puppetlabs/code/environments/production/modules/mysql/CHANGELOG.md
RUN export PATH="${PATH}:/opt/puppetlabs/bin" && puppet help && puppet apply setup.pp
RUN export PATH="${PATH}:/opt/puppetlabs/bin" && puppet apply setup.pp
#RUN export PATH=${PATH}:/opt/puppetlabs/bin && puppet apply manifest.pp


# Puerto por defecto para Storm
EXPOSE 8085

# Comando por defecto para iniciar Storm Nimbus
#CMD ["/opt/storm/bin/storm", "nimbus"]

