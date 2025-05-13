#!/bin/bash


echo "Installing ARK Ascended Game Server with SteamCMD..."
steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$SERVER_GAME_DIR" +login anonymous +app_update "$STEAM_APP_ID" +quit

echo "Starting ASA Server..."

ulimit -n 100000
xvfb-run -a wine "$SERVER_GAME_DIR/ShooterGame/Binaries/Win64/ArkAscendedServer.exe $SERVER_MAP?SessionName=$SERVER_NAME?RCONEnabled=true?RCONPort=$PORT_RCON?AltSaveDirectoryName=$SERVER_SAVE_NAME?ShowFloatingDamageText=true?noTributeDownloads=false?PreventDownloadDinos=false?PreventDownloadItems=false?PreventDownloadSurvivors=false?PreventUploadDinos=false?PreventUploadItems=false?PreventUploadSurvivors=false?PvEAllowStructuresAtSupplyDrops=True?ServerPassword=$SERVER_PASS?ServerAdminPassword=$ADMIN_PASS -mods=$SERVER_MODS -WinLiveMaxPlayers=$MAX_PLAYERS -port=$PORT_GAME -NoTransferFromFiltering -UnstasisDinoObstructionCheck -disabledinonetrangescaling -oldconsole -servergamelog -servergamelogincludetribelogs -ServerRCONOutputTribeLogs -NotifyAdminCommandsInChat -NoBattlEye"