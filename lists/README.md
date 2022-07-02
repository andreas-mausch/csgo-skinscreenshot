# Steam API Key

Put Steam API-Key (can be found [here](https://steamcommunity.com/dev/apikey)) in the package.json.
It is needed to download the latest schema file.

# Install

```bash
npm install
```

# Create lists for paint kits, player models, stickers and gloves

Clean up the *./data/* directory beforehand.

```bash
npm run download
npm run --silent paintKits > ../paint_kits.txt
npm run --silent playerModels > ../player_models.txt
npm run --silent stickers > ../stickers.txt
npm run --silent gloves > ../gloves.txt
```
