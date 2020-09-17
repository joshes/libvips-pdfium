## Use same image as final target to ensure arch compatibility, in this case node:12
FROM node:12 as libs

## Install requirements
RUN apt-get update && \
    apt-get install -y wget git lib2.0-dev libexpat1-dev libexpat1 build-essential libjpeg-dev zlib1g-dev libpng-dev git libicu-dev libc++-dev libc++abi-dev

## Install pdfium binaries (pre-built)
RUN wget -q https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-linux.tgz && \
    mkdir -p /opt/pdfium && \
    tar -xf pdfium-linux.tgz -C /opt/pdfium

## Install vips
## This version *must* align with the node_modules/sharp/package.json -> config.libvps version in sharp
ENV VIPS_VERSION=8.10.0
RUN wget -q https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz && \
    tar -xf vips-${VIPS_VERSION}.tar.gz && \
    rm *.gz && \
    cd vips-${VIPS_VERSION} && \
    ./configure \
        --prefix=/usr \
        --with-pdfium-includes=/opt/pdfium/include \
        --with-pdfium-libraries=/opt/pdfium/lib && \
    make && \
    make install 

## -----------------------------
## TEST
## -----------------------------

FROM node:12

# Install native libs
COPY --from=libs /usr/ /usr/
COPY --from=libs /opt/ /opt/

ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/pdfium/lib

WORKDIR /app

COPY . .

RUN npm install

CMD ["node", "index.js"]
