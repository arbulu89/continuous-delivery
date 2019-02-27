FROM opensuse/leap:15

MAINTAINER Xabier Arbulu Insausti

# install
RUN zypper in -y sudo osc tar gzip build vim

COPY scripts /scripts
COPY oscrc /root/.config/osc/oscrc
