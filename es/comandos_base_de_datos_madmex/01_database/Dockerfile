#FROM geodata/gdal:1.11.2
FROM ubuntu:14.04
#FROM postgres:9.4
#RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list
RUN apt-get -y update
#RUN apt-get -y install wget
RUN apt-get -y install openssh-server postgresql-client-9.3 postgresql-client-common postgresql-common 

#RUN echo "host    all             all             0.0.0.0/0               md5" >> /etc/postgresql/9.3/main/pg_hba.conf

#RUN echo "listen_addresses = '*'" >> /etc/postgresql/9.3/main/postgresql.conf

#RUN service postgresql start && sudo -u postgres createuser -d -r -s docker

#RUN service postgresql start && sudo -u postgres createdb -O docker docker



#postgresql-contrib 
#postgresql-9.3-postgis-2.1 postgis gdal-bin python-gdal
#RUN echo "host    all             all             0.0.0.0/0               md5" >> /etc/postgresql/9.3/main/pg_hba.conf
#RUN service postgresql start
# && /bin/su postgres -c "createuser -d -s -r -l madmex_user" && /bin/su postgres -c "psql postgres -c \"ALTER USER madmex_user WITH ENCRYPTED PASSWORD 'madmex_user.'\"" && service postgresql stop
#RUN echo "listen_addresses = '*'" >> /etc/postgresql/9.3/main/postgresql.conf
#RUN echo "port = 5432" >> /etc/postgresql/9.3/main/postgresql.conf

RUN mkdir /var/run/sshd
#RUN groupadd postgres
#RUN useradd postgres -g postgres -m -s /bin/bash
#RUN echo "postgres ALL=(ALL:ALL) NOPASSWD:ALL"|(EDITOR="tee -a" visudo)
#RUN echo 'postgres:postgres'|chpasswd

RUN echo 'root:madmex' |chpasswd

RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
#RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

#ENV NOTVISIBLE "in users profile"
#RUN echo "export VISIBLE=now" >> /etc/profile
#RUN ssh-keygen -P "" -t dsa -f /etc/ssh/ssh_host_dsa_key -y


#CMD    /usr/sbin/sshd -D

#USER postgres
EXPOSE 5432
EXPOSE 22
