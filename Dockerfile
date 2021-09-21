FROM opensuse/leap:15.3

MAINTAINER Xabier Arbulu Insausti

# install
RUN zypper -n ar https://download.opensuse.org/repositories/openSUSE:/Tools/openSUSE_15.1/openSUSE:Tools.repo
RUN zypper -n ar https://download.opensuse.org/repositories/devel:/languages:/go/openSUSE_Leap_15.1/devel:languages:go.repo
RUN zypper -n --gpg-auto-import-keys refresh --force --services
RUN zypper in -y sudo osc obs-service-format_spec_file obs-service-tar_scm obs-service-download_files obs-service-obs_scm obs-service-obs_scm-common obs-service-recompress obs-service-set_version obs-service-source_validator obs-service-verify_file obs-service-go_modules tar gzip build vim python3-packaging golang-packaging

COPY scripts /scripts
COPY oscrc /root/.config/osc/oscrc
