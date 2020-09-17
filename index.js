const sharp = require('sharp');

(async () => {
  await sharp('dummy.pdf')
    .png()
    .toFile('/data/dummy-out.png')
})();