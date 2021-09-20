public Action:Teleport(client, args)
{
  if (GetCmdArgs() != 6)
  {
    ReplyToCommand(client, "Need 6 arguments (x, y, z) (viewangle x, y, z)");
    return Plugin_Handled;
  }

  new String:arg1[32], String:arg2[32], String:arg3[32], String:arg4[32], String:arg5[32], String:arg6[32];
  GetCmdArg(1, arg1, sizeof(arg1));
  GetCmdArg(2, arg2, sizeof(arg2));
  GetCmdArg(3, arg3, sizeof(arg3));
  GetCmdArg(4, arg4, sizeof(arg4));
  GetCmdArg(5, arg5, sizeof(arg5));
  GetCmdArg(6, arg6, sizeof(arg6));

  new Float:origin[3];
  origin[0] = StringToFloat(arg1);
  origin[1] = StringToFloat(arg2);
  origin[2] = StringToFloat(arg3);

  new Float:viewangles[3];
  viewangles[0] = StringToFloat(arg4);
  viewangles[1] = StringToFloat(arg5);
  viewangles[2] = StringToFloat(arg6);

  TeleportEntity(client, origin, viewangles, NULL_VECTOR);
  PrintToServer("Teleport x=%f, y=%f, z=%f; vx=%f, vy=%f, vz=%f", origin[0], origin[1], origin[2], viewangles[0], viewangles[1], viewangles[2]);

  return Plugin_Handled;
}
