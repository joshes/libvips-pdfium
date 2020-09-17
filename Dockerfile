## Use same image as final target to ensure arch compatibility, in this case node:12
FROM node:12 as libs

## Install requirements
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
            wget=1.18-5+deb9u3 \
            git=1:2.11.0-3+deb9u7 \
            lib2.0-dev=2.50.3-2+deb9u2 \
            libexpat1-dev=2.2.0-2+deb9u3 \
            libexpat1=2.2.0-2+deb9u3 \
            build-essential=12.3 \
            libjpeg-dev=1:1.5.1-2+deb9u1 \
            zlib1g-dev=1:1.2.8.dfsg-5 \
            libpng-dev=1.6.28-1+deb9u1 \
            libicu-dev=57.1-6+deb9u4 \
            libc++-dev=3.5-2 \
            libc++abi-dev=3.5-2

## Install pdfium binaries (pre-built)
RUN wget -q https://github.com/bblanchon/pdfium-binaries/releases/latest/download/pdfium-linux.tgz && \
    mkdir -p /opt/pdfium && \
    tar -xf pdfium-linux.tgz -C /opt/pdfium

## Download libvips
## This version *must* align with the node_modules/sharp/package.json -> config.libvps version in sharp
ENV VIPS_VERSION=8.10.0

RUN wget -q https://github.com/libvips/libvips/releases/download/v${VIPS_VERSION}/vips-${VIPS_VERSION}.tar.gz && \
    tar -xf vips-${VIPS_VERSION}.tar.gz

WORKDIR /vips-${VIPS_VERSION}

## Install libvips
RUN ./configure \
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
COPY --from=libs /opt/pdfium/ /usr/

WORKDIR /app

COPY . .

RUN npm install

CMD ["node", "index.js"]
