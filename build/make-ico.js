const fs = require('fs');
const path = require('path');
const { Resvg } = require('../../weather_app_widget/node_modules/@resvg/resvg-js');
const pngToIco = require('../node_modules/png-to-ico');

const svg = fs.readFileSync(path.join(__dirname, '..', 'icon.svg'), 'utf8');
const sizes = [16, 32, 48, 64, 128, 256];

Promise.all(
  sizes.map((size) => {
    const resvg = new Resvg(svg, { fitTo: { mode: 'width', value: size } });
    return resvg.render().asPng();
  })
)
  .then((buffers) => pngToIco(buffers))
  .then((buf) => {
    fs.writeFileSync(path.join(__dirname, 'icon.ico'), buf);
    console.log('wrote build/icon.ico');
  })
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
