FROM debian:bookworm

ARG TARGET_TRIPLE=arm-linux-gnueabihf

RUN apt-get update
RUN apt-get install gcc-${TARGET_TRIPLE} ninja-build cmake ldc wget perl dub -y

WORKDIR /build

# LDC runtime
RUN export CC=${TARGET_TRIPLE}-gcc && \
    ldc-build-runtime --ninja --dFlags="-w;-mtriple=${TARGET_TRIPLE}" && \
    mv ldc-build-runtime.tmp/lib/* /usr/${TARGET_TRIPLE}/lib/ && \
    rm ldc-build-runtime.tmp -rf

# Copy files from repo
COPY ldc2-rpi /usr/local/bin/ldc2
RUN sed -i "s/DOCKER_TARGET_TRIPLE=/DOCKER_TARGET_TRIPLE=${TARGET_TRIPLE}/g" /usr/local/bin/ldc2

COPY dub-rpi /usr/local/bin/dub

COPY ldc2.conf /etc/ldc2.conf

RUN ln -s /usr/${TARGET_TRIPLE}/lib /cross-libs

WORKDIR /src
CMD ["/usr/local/bin/ldc2"]
