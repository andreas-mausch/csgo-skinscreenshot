
public Action Find(int client, int args) {
  findItems(client, "items", "hands");
  findItems(client, "items", "hands_paintable");
  findItems(client, "items", "customplayer");
  findItems(client, "items", "customplayertradable");
  findItems(client, "paint_kits", "");
  findItems(client, "sticker_kits", "");

  return Plugin_Handled;
}

public void findItems(int client, char[] key, char[] prefabFilter) {
  Handle kv = CreateKeyValues("mytest");
  if (!FileToKeyValues(kv, "scripts/items/items_game.txt")) {
    ReplyToCommand(client, "Couldn't load items_game.txt");
    kv.Close();
    return;
  }

  if (!KvGotoFirstSubKey(kv, false)) {
    ReplyToCommand(client, "Couldn't locate first key");
    kv.Close();
    return;
  }

  do {
    char currentKey[64];
    KvGetSectionName(kv, currentKey, sizeof(currentKey));

    if (!StrEqual(key, currentKey)) {
      continue;
    }

    if (!KvGotoFirstSubKey(kv, true)) {
      ReplyToCommand(client, "Couldn't locate subkey");
      kv.Close();
      return;
    }

    do {
      char section[64], value[256], prefab[256];
      KvGetSectionName(kv, section, sizeof(section));
      KvGetString(kv, "name", value, sizeof(value), "default");
      KvGetString(kv, "prefab", prefab, sizeof(prefab));

      if (StrEqual(prefabFilter, prefab)) {
        ReplyToCommand(client, "Key: %s, Prefab: %s; Index: %s; Name: %s", key, prefab, section, value);
      }
    } while (KvGotoNextKey(kv, true));

    KvGoBack(kv);
  } while (KvGotoNextKey(kv, false));

  kv.Close();
  ReplyToCommand(client, "Done");
}
