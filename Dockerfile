FROM debian:bookworm-slim AS builder
ARG TARGETARCH

FROM builder AS builder_amd64
ENV ARCH=x86_64
FROM builder AS builder_arm64
ENV ARCH=aarch64
FROM builder AS builder_riscv64
ENV ARCH=riscv64

FROM builder_${TARGETARCH} AS build
RUN apt-get update
RUN apt-get install -y curl gpg ca-certificates tar dirmngr build-essential git autoconf libtool pkg-config libdb++-dev libboost-dev libboost-system-dev bsdmainutils openssl libssl-dev automake make autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev libboost-thread-dev
WORKDIR /opt
COPY bellscoin ./bellscoin
COPY bin ./bin
WORKDIR /opt/bellscoin
RUN rm -rf .git
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

FROM debian:bookworm-slim
LABEL name="bellscoin" description="bellscoin"
LABEL maintainer="Sandshrew Inc <inquiries@sandshrew.io>"
ARG GROUP_ID=1000
ARG USER_ID=1000
RUN groupadd -g ${GROUP_ID} bellscoin \
    && useradd -u ${USER_ID} -g bellscoin -d /bellscoin bellscoin
ENV HOME /bellscoin
EXPOSE 19918
WORKDIR /bellscoin
COPY --from=build /opt/ /opt/
RUN apt update \
    && apt install -y --no-install-recommends gosu libatomic1 libboost-all-dev libssl-dev libdb++-dev curl gpg ca-certificates tar dirmngr build-essential git autoconf libtool pkg-config libdb++-dev libboost-dev libboost-system-dev bsdmainutils openssl libssl-dev automake make autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev libboost-thread-dev \
    && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && ln -sv /opt/bellscoin/src/bellsd /usr/local/bin/bellsd \
    && ln -sv /opt/bin/* /usr/local/bin
ENTRYPOINT ["bells_oneshot"]
