# Checks for "temp" folder. If not existant creates it
function TempFolder {    
    if (!(Test-Path $TempPath)) {
        Write-Host "Creating temp folder"
        New-Item -Name $TempPath -ItemType "directory"
    }
}

# Checks for "Server" folder. If not existant creates it
function Arma3ServerFolder {
    if (!(Test-Path $A3ServerPath)) {
        Write-Host "Creating Arma 3 Server folder"
        New-Item -Name $A3ServerPath -ItemType "directory"
    } else {
        return $true
    }
}

function SteamCMDFolder {
    if (!(Test-Path $STEAMPATH)) {
        Write-Host "Creating SteamCMD folder"
        New-Item -Name $STEAMPATH -ItemType "directory"
    } else {
        return $true
    }   
}

function ExileSeverFolder {    
    return Test-Path $ExileServerPath    
}

function DownloadSteamCMD ($confirm = 1) {
    TempFolder    
    if ((SteamCMDFolder) -and ($confirm)) {
        $opt = Read-Host "SteamCMD folder already exists, continue? (y/n)"
        if ($opt -ne "y"){
            return
        }
    }
    Write-Host "Downloading SteamCMD"
    Invoke-WebRequest "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" -OutFile "$TempPath\steamcmd.zip"

    # Extracts SteamCmd into "temp"
    Write-Host "Extracting SteamCMD"
    Expand-Archive "$TempPath\steamcmd.zip" -DestinationPath $STEAMPATH    
}

function DownloadArma3Server ($confirm = 1) {
    if ((Arma3ServerFolder) -and ($confirm)) {
        $opt = Read-Host "Arma 3 Server folder already exists, continue? (y/n)"
        if ($opt -ne "y"){
            return
        }
    }
    Write-Host "Downloading Arma 3 Server"
    # "." befor path, because steamcmd downloads to its folder, leave "." or possibly put complete path in "PATH" variables
    & $STEAMPATH\steamcmd.exe +login $STEAMLOGIN +force_install_dir ".$A3ServerPath" +app_update $A3serverBRANCH validate +quit
}

function DownloadExileServer ($confirm = 1) {
    TempFolder    
    Arma3ServerFolder
    if ((ExileSeverFolder) -and ($confirm)) {
        $opt = Read-Host "Exile Server folder already exists, continue? (y/n)"
        if ($opt -ne "y"){
            return
        }
    }
    Write-Host "Downloading Exile Server"
    Invoke-WebRequest "http://www.exilemod.com/ExileServer-1.0.4a.zip" -OutFile ".\temp\exile-server.zip"
    
    # Extracts Exile Server into "temp"
    Write-Host "Extracting Exile server"
    Expand-Archive ".\temp\exile-server.zip" -DestinationPath ".\temp\exile-server" -Force
    
    # Copy Exile Server files into Arma 3 Server
    Write-Host "Copying Exile Server files"
    Copy-Item -Path ".\temp\exile-server\Arma 3 Server\*" -Destination $A3ServerPath -Recurse -Force
}

function DownloadMod ($modId) {
    TempFolder
    Arma3ServerFolder
    Write-Host "Iniciando o download de $modId"
    $teste=0
    while (!($teste -like "*Success*")) { 
        $teste = & $STEAMPATH\steamcmd.exe +login $STEAMLOGIN +force_install_dir ".$TempPath" +workshop_download_item $A3ID $modId validate +quit
    }
    $teste
    Move-Item -Path "$TempPath\steamapps\workshop\content\107410\$mod\" -Destination $A3ServerPath    
}

function DownloadMods ($confirm = 1) {
    TempFolder
    Arma3ServerFolder
    foreach ($mod in $mods){
        if (!(Test-Path $A3ServerPath\$mod)){
            Write-Host "Iniciando o download de $mod"
            $teste=0
            while (!($teste -like "*Success*")) { 
                $teste = & $STEAMPATH\steamcmd.exe +login $STEAMLOGIN +force_install_dir ".$TempPath" +workshop_download_item $A3ID $mod validate +quit
                $teste          
            }
            $teste
            Move-Item -Path "$TempPath\steamapps\workshop\content\107410\$mod\" -Destination $A3ServerPath    
        }        
    }    
}

function DownloadModsTeste ($confirm = 1) {
    TempFolder
    Arma3ServerFolder
    foreach ($mod in $hash1.Keys){
        Write-Host "AQUI $mod"
        Write-Host "TESTE $hash1.$mod"
        $id = $hash1.$mod
        Write-Host "AAAAA: $a"
        if (!(Test-Path $A3ServerPath\$mod)){
            Write-Host "Iniciando o download de $mod"
            $teste=0            
            while (!($teste -like "*Success*")) { 
                $teste = & $STEAMPATH\steamcmd.exe +login $STEAMLOGIN +force_install_dir ".$TempPath" +workshop_download_item $A3ID $id validate +quit
                #$teste          
            }
            $teste
            Move-Item -Path "$TempPath\steamapps\workshop\content\107410\$id" -Destination $A3ServerPath\$mod   
        } else {
            Write-Host "$hash1.$mod folder already exists"
        }        
    }    
}

function Purge {
    $opt = Read-Host "Are you sure you want to purge? (y/n)"
    if ($opt -ne "y"){
        return
    } else {
        Remove-Item $TempPath -Force 2> $null
        Remove-Item $STEAMPATH -Force 2> $null
        Remove-Item $A3ServerPath -Force 2> $null
    }
}

function DeleteTemp{
    $opt = Read-Host "Are you sure you want to delete temp? (y/n)"
    if ($opt -ne "y"){
        return
    } else {
        Remove-Item $TempPath -Force 2> $null
    }
}

function FreshInstall {
    Purge
    DownloadSteamCMD 0
    DownloadArma3Server 0
    DownloadExileServer 0
    DownloadMods 0
    DeleteTemp
}

function Install {
    DownloadSteamCMD
    DownloadArma3Server
    DownloadExileServer
    DownloadMods
    DeleteTemp
}


#initialize variables
Write-Host "Initializing variables"
. .\variables.ps1

$hash1
$exit = 0
while ($exit -ne 3){

    Write-Host "Options: "
    Write-Host "1 - Complete Install"
    Write-Host "2 - Partial Install"
    Write-Host "3 - Exit"
    $exit = Read-Host "Option"

    switch ($exit) {
        1 {
            $install = 0
            while($install -ne 3){
                Write-Host "Options: "
                Write-Host "1 - Install"
                Write-Host "2 - Fresh Install"
                Write-Host "3 - Return"
                $install = Read-Host "Option"
                switch ($install) {
                    1 { Install; $install = 3; break; }
                    2 { FreshInstall; $install = 3; break; }
                    3 { break;}
                    Default { Write-Host -ForegroundColor "Red" "Invalid option"; break; }
                }
            }            
          }
        2 {
            $partial = 0
            while ($partial -ne 9) {                
                Write-Host "Options: "
                Write-Host "1 - Download SteamCMD"
                Write-Host "2 - Download Arma 3 Server"
                Write-Host "3 - Download Exile Server"
                Write-Host "4 - Download Mods"
                Write-Host "5 - Download especific Mod"
                Write-Host "6 - Copy configs"
                Write-Host "7 - Delete temp folder"
                Write-Host "8 - Purge"
                Write-Host "9 - Return"
                $partial = Read-Host "Option"
                switch ($partial) {
                    1 { DownloadSteamCMD; break; }
                    2 { DownloadArma3Server; break; }
                    3 { DownloadExileServer; break; }
                    4 { DownloadModsTeste; break; }
                    5 { $modId = Read-Host "Mod ID"; DownloadMod $modId; break; }
                    6 { Write-Host "TODO"; break;}
                    7 { DeleteTemp; break;}
                    8 { Purge; break; }
                    9 { break; }
                    Default { Write-Host -ForegroundColor "Red" "Invalid option"; break; }
                }
            }
        }
        3 { break;}
        Default { Write-Host -ForegroundColor "Red" "Invalid option"; break; }
    }

}


