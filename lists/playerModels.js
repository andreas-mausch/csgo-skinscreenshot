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

const items = itemsGame["items_game"]["items"];
Object.entries(items).forEach(([key, value]) => {
  if (value["prefab"] === "customplayer" || value["prefab"] === "customplayertradable") {
    const name = value["name"];
    const modelFile = value["model_player"];
    const itemName = value["item_name"];
    const translation = itemName ? getTranslation(itemName.slice(1)) : "";

    console.log(`${key.padStart(5, ' ')}: ${translation} (${name})`);
    console.log(`       ${modelFile}`);
  }
});
