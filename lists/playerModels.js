const fs = require('fs');
const vdf = require('./node_modules/@node-steam/vdf/lib');
const { translate } = require('./translate');

const itemsGame = vdf.parse(fs.readFileSync("./data/items_game.txt", "utf8"));
const english = vdf.parse(fs.readFileSync("./data/csgo_english.txt", "utf8"))["lang"]["Tokens"];

const items = itemsGame["items_game"]["items"];
Object.entries(items).forEach(([key, value]) => {
  if (value["prefab"] === "customplayer" || value["prefab"] === "customplayertradable") {
    const name = value["name"];
    const modelFile = value["model_player"];
    const itemName = value["item_name"];
    const translation = itemName ? translate(english, itemName.slice(1)) : "";

    console.log(`${key.padStart(5, ' ')}: ${translation} (${name})`);
    console.log(`       ${modelFile}`);
  }
});
