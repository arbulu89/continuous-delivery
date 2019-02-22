FROM opensuse/leap:15

MAINTAINER Xabier Arbulu Insausti

# install
RUN zypper in -y sudo osc tar gzip build

COPY upload.sh /upload.sh
COPY oscrc /root/.config/osc/oscrc
