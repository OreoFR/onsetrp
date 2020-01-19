local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local RadioStatus = 0
local Track = nil
local Vehicle = nil
local Volume = 0.3

local Radios = {
    { label= "NRJ", url= "http://185.52.127.163/fr/30001/mp3_128.mp3?origine=fluxradios" },
    { label= "Fun Radio", url= "http://streaming.radio.funradio.fr:80/fun-1-44-128.mp3" },
    { label= "RMC", url= "http://chai5she.lb.vip.cdn.dvmr.fr/rmcinfo" },
    { label= "Radio Autoroute 107.7", url= "http://mediaming.streamakaci.com/sanef107_7_NORD.mp3" },
    { label= "Skyrock", url= "http://icecast.skyrock.net/s/natio_mp3_128k?tvr_name=tunein16&tvr_section1=128mp3" },
    { label= "Cherie FM", url= "http://cdn.nrjaudio.fm/audio1/fr/30201/mp3_128.mp3?origine=fluxradios" },
    { label= "RTL 2", url= "http://streaming.radio.rtl2.fr/rtl2-1-48-192" },
    { label= "Urban Hits US", url= "http://urbanhitus.ice.infomaniak.ch/urbanhitus-128.mp3" },
    { label= "Europe 1", url= "http://e1-live-mp3-128.scdn.arkena.com/europe1.mp3" },
}
local CurrentRadio = 1


AddEvent("OnKeyPress", function(key)
    -- Radio ON/OFF    
    if IsCtrlPressed() and key == 'R' and IsPlayerInVehicle() then
        if RadioStatus == 0 then
            AddPlayerChat(_("radio_radios_availables").." : (ctrl + numpad)")
            for k,v in pairs(Radios) do
                AddPlayerChat(k..' : '..v.label)            
            end
        end
        CallRemoteEvent("radio:getplayersinvehicle", RadioStatus)
    end

    -- Radio volume
    if RadioStatus == 1 and key == 'Num +' and IsPlayerInVehicle() then        
        CallRemoteEvent("radio:getplayersinvehicle", RadioStatus, 1)
    elseif RadioStatus == 1 and key == 'Num -' and IsPlayerInVehicle() then        
        CallRemoteEvent("radio:getplayersinvehicle", RadioStatus, 0)
    end

    -- Radio switch channel
    if RadioStatus == 1 and IsPlayerInVehicle() and IsCtrlPressed() then
        local channel = nil
        if key == "Num 1" then channel = 1 end
        if key == "Num 2" then channel = 2 end
        if key == "Num 3" then channel = 3 end
        if key == "Num 4" then channel = 4 end
        if key == "Num 5" then channel = 5 end
        if key == "Num 6" then channel = 6 end
        if key == "Num 7" then channel = 7 end
        if key == "Num 8" then channel = 8 end
        if key == "Num 9" then channel = 9 end

        if channel ~= nil then
            CallRemoteEvent("radio:getplayersinvehicle", RadioStatus, nil, channel)
        end
    end
end)

AddEvent("OnPlayerLeaveVehicle", function(player, vehicle, seat)
    StopRadio()
end)

AddEvent("OnPlayerEnterVehicle", function(player, vehicle, seat)
    if vehicle == Vehicle then
        StartRadio()
    end
end)

AddRemoteEvent("radio:turnonradio", function(vehicle)
    StartRadio(vehicle)
end)

AddRemoteEvent("radio:turnoffradio", function(vehicle)
    StopRadio(vehicle)
end)

AddRemoteEvent("radio:setvolume", function(vehicle, volume)
    if vehicle == Vehicle then
        SetVolume(volume)
    end
end)

AddRemoteEvent("radio:setchannel", function(vehicle, channel)
    if vehicle == Vehicle then
        SetChannel(channel)
    end
end)


function StartRadio(vehicle)
    if vehicle ~= nil then
        AddPlayerChat(_("radio_turning_on").." .. " .. _("radio_station").. " : "..Radios[CurrentRadio].label)
        Vehicle = vehicle
        RadioStatus = 1
    end
    
    Track = CreateSound(Radios[CurrentRadio].url)
    SetSoundVolume(Track, Volume)
end

function StopRadio(vehicle)
    if Track ~= nil then DestroySound(Track) end
    
    if vehicle ~= nil then
        AddPlayerChat(_("radio_turning_off").." ..")
        RadioStatus = 0
        Track = nil
        Vehicle = nil
        Volume = 0.5
        CurrentRadio = 1
    end
end

function SetVolume(volume)
    if volume == 1 and Volume < 1.0 then --Monte le son
        Volume = Volume + 0.1
        SetSoundVolume(Track, Volume)
    elseif volume == 0 and Volume > 0.0 then -- baisse le son
        Volume = Volume - 0.1
        SetSoundVolume(Track, Volume)
    end
end

function SetChannel(channel)    
    CurrentRadio = channel    
    AddPlayerChat(_("radio_switching_radio").." : "..Radios[CurrentRadio].label)
    DestroySound(Track)
    Track = CreateSound(Radios[CurrentRadio].url)
    SetSoundVolume(Track, Volume)
end
