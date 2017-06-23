FROM python:2.7-onbuild

# 1) COPY requirements.txt
# 2) Run pip install on ^
# 3) COPY . /usr/src/app

#ENV GUNICORN_VERSION 19.3.0
# pip install gunicorn==${GUNICORN_VERSION} && \

## Install our dependencies

RUN apt-get update && \
    apt-get -y install libxml2-dev libxslt1-dev zlib1g-dev openssh-client build-essential \
               libproj-dev libgdal-dev python-gdal libgeos-dev gfortran texlive-full && \
    apt-get -y autoremove && \
    apt-get clean

# Install proj from source
RUN cd /tmp &&\
    wget http://download.osgeo.org/proj/proj-4.9.2.tar.gz &&\
    tar -xvf proj-4.9.2.tar.gz  &&\
    cd proj-4.9.2 &&\
    ./configure &&\
    make install &&\
    cd &&\
    rm -fr /tmp/proj-4.9.2 /tmp/proj-4.9.2.tar.gz

RUN pip install --upgrade numpy scipy matplotlib

## Apply our own overrides
COPY local_settings.py /usr/src/app/readthedocs.org/readthedocs/settings/local_settings.py

# RUN cp ./local_settings.py.example readthedocs.org/readthedocs/settings/local_settings.py

## Import our private key for cloning private repos
RUN mkdir /root/.ssh
RUN chmod 700 /root/.ssh
RUN echo "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config
RUN echo "    IdentityFile /root/.ssh/id_rsa" >> /etc/ssh/ssh_config


## This is a volume for our database
VOLUME ["/persistent"]

ENTRYPOINT ["./entrypoint.sh"]
## Some defaults to pass to gunicorn/entrypoint
#CMD ["-b", "0.0.0.0:80", "-w", "2", "readthedocs.wsgi:application"]

## Not using gunicorn, just manage.py Let's setup some defaults, which can be
# changed at runtime by the user (just specify a new cmd)
CMD ["runserver", "0.0.0.0:80"]
