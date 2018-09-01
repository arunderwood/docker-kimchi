FROM debian:jessie as build_base
WORKDIR /

# Install build deps for wok and kimchi
RUN (apt-get update &&\
  DEBIAN_FRONTEND=noninteractive apt-get install -y gcc \
    make autoconf automake gettext git pkgconf xsltproc \
    logrotate python2.7)

RUN (git clone https://github.com/kimchi-project/wok.git &&\
      cd wok &&\
      ./autogen.sh --system &&\
      make)

RUN (git clone https://github.com/kimchi-project/kimchi.git &&\
      cd kimchi &&\
      ./autogen.sh --system &&\
      make)

#FROM debian:jessie
#WORKDIR /

# Install runtime deps for wok and kimchi
RUN (apt-get update &&\
  DEBIAN_FRONTEND=noninteractive apt-get install -y python2.7 \
  python-cherrypy3 python-cheetah python-pam python-m2crypto \
  nginx python-jsonschema python-psutil python-ldap python-lxml \
  openssl websockify gettext python-configobj novnc qemu-kvm \
  python-libvirt libvirt-bin nfs-common python-parted sosreport \
  python-ethtool sosreport python-ipaddr open-iscsi python-guestfs \
  libguestfs-tools spice-html5 python-magic python-paramiko \
  python-imaging fonts-font-awesome geoip-database nginx-light \
  --no-install-recommends)

#RUN pip install cherrypy cheetah pam m2crypto jsonschema psutil ldap lxml configobj libvirt parted ethtool ipaddr guestfs magic paramiko imaging

# COPY --from=build_base /wok /wok
# COPY --from=build_base /kimchi /kimchi

RUN (cd /wok &&\
     make install &&\
     cd / &&\
     rm -rf /wok)

RUN (cd /kimchi &&\
     make install &&\
     cd / &&\
     rm -rf /var/lib/kimchi/isos /kimchi)

RUN (sed -i "s/#create_iso_pool = true/create_iso_pool = false/g" /etc/wok/plugins.d/kimchi.conf &&\
  sed -i "s/#display_proxy_port = 64667/display_proxy_port = 64668/g" /etc/wok/plugins.d/kimchi.conf)

CMD [""kimchid"", "--host=0.0.0.0"]
