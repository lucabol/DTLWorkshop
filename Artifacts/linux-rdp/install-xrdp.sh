#!/bin/sh

case $(uname -m) in
"x86_64" | "amd64")
  ;;
*)
  echo "This only works on amd64" 1>&2
  exit -1
  ;;
esac

if [ -f /etc/os-release ]; then
  . /etc/os-release
  case "$ID:$VERSION_ID" in
  "ubuntu:14.04" | "ubuntu:16.04" | "ubuntu:16.10")
    if [ $VERSION_ID = "14.04" ]; then
      apt-add-repository -y ppa:ubuntu-mate-dev/ppa
      apt-add-repository -y ppa:ubuntu-mate-dev/trusty-mate
    fi
    apt-get update
    apt-get install ubuntu-mate-desktop -y -qq
    apt-get install xrdp -y -qq
(
cat <<'EOF'
#!/bin/sh

if [ -r /etc/default/locale ]; then
  . /etc/default/locale
  export LANG LANGUAGE
fi

mate-session
EOF
) > /etc/xrdp/startwm.sh
    echo 'reboot' | at now + 1 minute
    ;;
  "rhel:7"* | "centos:7")
    yum -y update
    yum -y groupinstall "Server with GUI"
    wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    yum -y install epel-release-latest-7.noarch.rpm
    yum -y install xrdp
    systemctl enable xrdp.service
    firewall-cmd --permanent --zone=public --add-port=3389/tcp
    firewall-cmd --reload
    chcon --type=bin_t /usr/sbin/xrdp
    chcon --type=bin_t /usr/sbin/xrdp-sesman
    shutdown -r +1
    ;;
  *)
    echo "Unknown or not supported distro" 1>&2
    exit -1
    ;;
  esac
else
  echo "Could not discover distro" 1>&2
  exit -1
fi
