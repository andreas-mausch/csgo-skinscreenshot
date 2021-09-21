const fs = require('fs');
const vdf = require('./node_modules/@node-steam/vdf/lib');

var itemsGame = vdf.parse(fs.readFileSync("./data/items_game.txt", "utf8"));
var english = vdf.parse(fs.readFileSync("./data/csgo_english.txt", "utf8"))["lang"]["Tokens"];

var paintKits = itemsGame["items_game"]["paint_kits"];
Object.entries(paintKits).forEach(([key, value]) => {
  var tag = value["description_tag"];

  if (!tag) {
    console.log(`${key}: ${value["name"]}`);
    return;
  }

  var translation = english[tag.slice(1)];
  console.log(`${key.padStart(5, ' ')}: ${translation} (${value["name"]})`);
});
