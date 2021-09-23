public Action:Teleport(client, args) {
  if (GetCmdArgs() != 6) {
    ReplyToCommand(client, "Need 6 arguments (x, y, z) (viewangle x, y, z)");
    return Plugin_Handled;
  }

  char arg1[32], arg2[32], arg3[32], arg4[32], arg5[32], arg6[32];
  GetCmdArg(1, arg1, sizeof(arg1));
  GetCmdArg(2, arg2, sizeof(arg2));
  GetCmdArg(3, arg3, sizeof(arg3));
  GetCmdArg(4, arg4, sizeof(arg4));
  GetCmdArg(5, arg5, sizeof(arg5));
  GetCmdArg(6, arg6, sizeof(arg6));

  float origin[3];
  origin[0] = StringToFloat(arg1);
  origin[1] = StringToFloat(arg2);
  origin[2] = StringToFloat(arg3);

  float viewangles[3];
  viewangles[0] = StringToFloat(arg4);
  viewangles[1] = StringToFloat(arg5);
  viewangles[2] = StringToFloat(arg6);

  PrintToServer("Teleport x=%f, y=%f, z=%f; vx=%f, vy=%f, vz=%f", origin[0], origin[1], origin[2], viewangles[0], viewangles[1], viewangles[2]);
  TeleportEntity(client, origin, viewangles, NULL_VECTOR);

  return Plugin_Handled;
}
