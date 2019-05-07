FROM opensuse/leap:15

MAINTAINER Xabier Arbulu Insausti

# install
RUN zypper in -y sudo osc obs-service-format_spec_file obs-service-tar_scm obs-service-download_files obs-service-obs_scm obs-service-obs_scm-common obs-service-recompress obs-service-set_version obs-service-source_validator obs-service-verify_file tar gzip build vim python3-packaging golang-packaging

COPY scripts /scripts
COPY oscrc /root/.config/osc/oscrc
