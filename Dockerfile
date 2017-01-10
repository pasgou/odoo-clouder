FROM ubuntu:16.04
MAINTAINER Pascal GOUHIER <pascal.go@gouhier.fr>

# generate locales
RUN locale-gen en_US.UTF-8 && update-locale
RUN echo 'LANG="en_US.UTF-8"' > /etc/default/locale


# Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN apt-get update \
 && apt-get install -y wget \
 && echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
 && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Add PostgreSQL's repository. It contains the most recent stable release
#     of PostgreSQL, ``9.5``.
# install dependencies as distrib packages when system bindings are required
# some of them extend the basic odoo requirements for a better "apps" compatibility
# most dependencies are distributed as wheel packages at the next step

RUN set -x; \
         apt-get update \
      && apt-get install -y --no-install-recommends \
            ca-certificates \
            python-gevent \
            python-pip \
            python-pyinotify \
            python-watchdog \
            python-renderpm \
            adduser \
            ghostscript \
            postgresql-client-9.5 \
            python \
            python-pip \
            python-imaging \
            python-setuptools \
            python-pychart python-libxslt1 xfonts-base xfonts-75dpi \
            libxrender1 libxext6 fontconfig \
            python-zsi \
            python-lasso \
            libzmq5 \
          # libpq-dev is needed to install pg_config which is required by psycopg2
            libpq-dev \
          # These libraries are needed to install the pip modules
            python-dev \
            libffi-dev \
            libxml2-dev \
            libxslt1-dev \
            libldap2-dev \
            libsasl2-dev \
            libssl-dev \
            libevent-dev \
            postgresql-server-dev-9.5 \
            build-essential \
          # Librairies required for LESS
            node-less \
            nodejs \
            npm \
          # This library is necessary to upgrade PIL/pillow module
            libjpeg8-dev \
          # Git is required to clone Odoo project
            git \
          # Utilities
            curl \
            nano \
      && pip install --upgrade pip


# create the odoo user
RUN adduser --home=/opt/odoo --disabled-password --gecos "" --shell=/bin/bash odoo

# changing user is required by openerp which won't start with root
# makes the container more unlikely to be unwillingly changed in interactive mode
USER odoo

RUN /bin/bash -c "mkdir -p /opt/odoo/{bin,etc,sources/odoo,config,addons/CE_inherited,addons/clouder,addons/enterprise,addons/ENT_inherit,addons/external,addons/nonfree,addons/private,data}"
RUN /bin/bash -c "mkdir -p /opt/odoo/var/{run,log,egg-cache}"

# Add Odoo sources and remove .git folder in order to reduce image size
WORKDIR /opt/odoo/sources

RUN git clone https://github.com/odoo/odoo.git --depth=1 -b 9.0 odoo && \
  rm -rf odoo/.git

# Add Clouder modules and dependencies
WORKDIR /opt/odoo/addons
RUN git clone --depth=1 -b 0.9.0 https://github.com/clouder-community/clouder.git clouder && rm -rf clouder/.git \
 && git clone https://github.com/OCA/connector.git --depth=1 -b 9.0 external && rm -rf external/.git


USER root
# Install Odoo python dependencies
RUN pip install -r /opt/odoo/sources/odoo/requirements.txt
RUN pip install -r /opt/odoo/addons/clouder/requirements.txt

# SM: Install LESS
RUN npm install -g less less-plugin-clean-css && \
  ln -s /usr/bin/nodejs /usr/bin/node

# must unzip this package to make it visible as an odoo external dependency
RUN easy_install -UZ py3o.template

# install wkhtmltopdf based on QT5
# Warning: do not use latest version (0.12.2.1) because it causes the footer issue (see https://github.com/odoo/odoo/issues/4806)
ADD http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb /opt/sources/wkhtmltox.deb
RUN dpkg -i /opt/sources/wkhtmltox.deb

# Execution environment
COPY sources/odoo.conf /opt/odoo/config/odoorc
RUN chown odoo /opt/odoo/config/odoorc
COPY bin/init.sh /init.sh
RUN chmod +x /init.sh

# Add volumes. For addons :
# "/opt/odoo/addons/CE_inherited" : adapted modules from Odoo official Community version,
# "/opt/odoo/addons/clouder" : Clouder modules (do not use a filesytem pointer, Clouder is imported (see before),
# "/opt/odoo/addons/enterprise" : volume where install Enterprise modules,
# "/opt/odoo/addons/ENT_inherit" : if modules from Enterprise version are used in new or inherited modules,
# "/opt/odoo/addons/external" : Community modules (OCA or others),
# "/opt/odoo/addons/nonfree" : non free modules (paid themes for example), and your own modules wich depend from nonfree module(s)
# "/opt/odoo/addons/private" : your own modules from scratch, even if they depend from other (community) modules
VOLUME ["/opt/odoo/var", "/opt/odoo/etc", "/opt/odoo/addons/CE_inherited","/opt/odoo/addons/clouder","/opt/odoo/addons/enterprise","/opt/odoo/addons/ENT_inherit","/opt/odoo/addons/external","/opt/odoo/addons/nonfree","/opt/odoo/addons/private", "/opt/odoo/data"]

# Set the default config file
ENV ODOO_RC /opt/odoo/config/odoorc
ENV ODOO_BIN /opt/odoo/sources/odoo/openerp-server

# Expose the odoo ports (for linked containers)
EXPOSE 8069 8072

# Set the default entrypoint (non overridable) to run when starting the container
USER odoo

ENTRYPOINT ["/init.sh"]

CMD ["/opt/odoo/sources/odoo/openerp-server"]

