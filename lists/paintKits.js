const fs = require('fs');
const vdf = require('./node_modules/@node-steam/vdf/lib');
const { translate } = require('./translate');

const itemsGame = vdf.parse(fs.readFileSync("./data/items_game.txt", "utf8"));
const english = vdf.parse(fs.readFileSync("./data/csgo_english.txt", "utf8"))["lang"]["Tokens"];

const paintKits = itemsGame["items_game"]["paint_kits"];
Object.entries(paintKits).forEach(([key, value]) => {
  const tag = value["description_tag"];
  const translation = tag ? translate(english, tag.slice(1)) : "";

  console.log(`${key.padStart(5, ' ')}: ${translation} (${value["name"]})`);
});
