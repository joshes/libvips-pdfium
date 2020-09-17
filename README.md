# libvips-pdfium

Docker image with libvips + pdfium support for nodejs.

```shell script
# Build
docker build -t libvips-pdfium .

# Validate (Should result in a dummy-out.png)
docker run --rm -v $(pwd):/data libvips-pdfium 
```

