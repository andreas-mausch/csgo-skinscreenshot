const fs = require('fs');
const vdf = require('./node_modules/@node-steam/vdf/lib');

const itemsGame = vdf.parse(fs.readFileSync("./data/items_game.txt", "utf8"));
const english = vdf.parse(fs.readFileSync("./data/csgo_english.txt", "utf8"))["lang"]["Tokens"];

function getTranslation(key) {
  const translation = english[Object.keys(english)
    .find(k => k.toLowerCase() === key.toLowerCase())
  ];
  return translation ? translation : key;
}

const items = itemsGame["items_game"]["sticker_kits"];
Object.entries(items).forEach(([key, value]) => {
  const name = value["name"];
  const itemName = value["item_name"];
  const translation = itemName ? getTranslation(itemName.slice(1)) : "";

  console.log(`${key.padStart(5, ' ')}: ${translation} (${name})`);
});
