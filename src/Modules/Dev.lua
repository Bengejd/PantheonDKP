local _G = _G;
local PDKP = _G.PDKP

local Dev, Defaults, Util, Guild, Comms = PDKP:GetInst('Dev', 'Defaults', 'Util', 'Guild', 'Comms')

Dev.bids = {
    ['Cheesedogs'] = {
        ['dkp'] = 30,
        ['bid'] = 10,
        ['index'] = 1,
    },
    ['Veltrix'] = {
        ['dkp'] = 25,
        ['bid'] = 5,
        ['index'] = 3,
    },
    ['Nightshelf'] = {
        ['dkp'] = 20,
        ['bid'] = 20,
        ['index'] = 2,
    },
    ['Neekio'] = {
        ['dkp'] = 35,
        ['bid'] = 25,
        ['index'] = 4,
    },
}

Dev.commands = {
    ['dev']=function() end,
    ['purge_db']=function()
        Dev:Purge_DB()
    end,
}

function Dev:Print(...)
    local string = strjoin(" ", tostringall(...))
    if Defaults.development or Defaults.debug then
        PDKP:Print(Util:FormatTextColor(string, Util.info))
    end
end

function Dev:IsDev()
    return Defaults.development or Defaults.debug
end

function Dev:ClockSpeed(isEnd, funcName)
    if not isEnd then
        Dev.clockStartTime = time()
    end
    if isEnd then
        local total_time = time() - Dev.clockStartTime
        Util.start = nil
        Dev:Print(funcName, 'took', total_time, 'seconds to run')
    end
end

function Dev:HandleCommands(msg)
    if not Defaults.development then return end
    local cmd = PDKP:GetArgs(msg)

    if Dev.commands[cmd] then return Dev.commands[cmd]() end
end

function Dev:Purge_DB()
    wipe(PDKP.db)

    Dev:Print("Database has been purged, reload to see changes.")
end
