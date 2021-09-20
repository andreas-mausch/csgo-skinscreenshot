public Action:ChangePlayerModel(client, args)
{
	if (!IsPlayerAlive(client))
	{
		ReplyToCommand(client, "You need to be alive to change your model.");
		return Plugin_Handled;
	}

	new String:model[256];
	GetCmdArg(1, model, sizeof(model));

	PrintToServer("ChangePlayerModel model=%s", model);

	if(!IsModelPrecached(model))
	{
		ReplyToCommand(client, "Model %s not found in cache.", model);
		return Plugin_Handled;
	}

	if (strlen(model) == 0)
	{
		CS_UpdateClientModel(client);
		ReplyToCommand(client, "Reset to default player model.");
		return Plugin_Handled;
	}

	char currentModel[256];
	GetClientModel(client, currentModel, sizeof(currentModel));

	if(StrContains(currentModel, "models/player/custom_player/legacy/") == -1)
	{
		ReplyToCommand(client, "You already have a custom player skin, remove your custom player skin for use a agent");
		return Plugin_Handled;
	}

	SetEntityModel(client, model);

	return Plugin_Handled;
}
