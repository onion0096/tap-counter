const fs = require('fs');
const path = require('path');
const { Resvg } = require('../weather_app_widget/node_modules/@resvg/resvg-js');

const jobs = [
  { svg: 'icon.svg', out: 'icon-192.png', size: 192 },
  { svg: 'icon.svg', out: 'icon-512.png', size: 512 },
  { svg: 'icon-maskable.svg', out: 'icon-192-maskable.png', size: 192 },
  { svg: 'icon-maskable.svg', out: 'icon-512-maskable.png', size: 512 },
];

for (const job of jobs) {
  const svg = fs.readFileSync(path.join(__dirname, 'icons', job.svg), 'utf8');
  const resvg = new Resvg(svg, { fitTo: { mode: 'width', value: job.size } });
  const png = resvg.render().asPng();
  fs.writeFileSync(path.join(__dirname, 'icons', job.out), png);
  console.log('wrote', job.out);
}
