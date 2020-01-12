FROM ubuntu:18.04

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update && \
    apt-get install -y curl git perl pulseaudio build-essential && \
    apt-get clean

# git-lfs
RUN build_deps="curl" && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ${build_deps} ca-certificates && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git-lfs && \
    git lfs install && \
    DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove ${build_deps} && \
    rm -r /var/lib/apt/lists/*

# Download Dictation-kit for getting the binaries of Julius 4.5 and models
RUN git clone https://github.com/julius-speech/dictation-kit.git && \
    cd dictation-kit && \
    git checkout 1ceb4dec245ef482918ca33c55c71d383dce145e && \
    git lfs pull

# Download Segmentation-kit
RUN git clone https://github.com/Hiroshiba/segmentation-kit.git && \
    cd segmentation-kit && \
    git checkout 4b23e4b40acbf301731022a54aadad5a197ab2aa

ENTRYPOINT [ \
  "perl", \
  "segmentation-kit/segment_julius.pl", \
  "--juliusbin=./dictation-kit/bin/linux/julius", \
  "--hmmdefs=dictation-kit/model/phone_m/jnas-mono-16mix-gid.binhmm" \
]
