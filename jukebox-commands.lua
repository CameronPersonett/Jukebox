local M = {}

-- Local functions
local sendPacket = function(cmd)
    rednet.broadcast({ command = cmd }, 'JBP')
end

-- Public functions
function M.queue(path)
    -- The song script will send the sample data to
    -- the player computer automagically
    shell.run(path)
end

function M.play(path)
    -- Queue the song
    if path ~= nil then
        shell.run(path)
    end
    -- Play it
    sendPacket('play')
end

function M.ff(ticks)
    local packet = {}
    packet.command = 'ff'
    packet.ticks = ticks
    rednet.broadcast(packet, 'JBP')
end

function M.rw(ticks)
    -- Default to 5 seconds
    if ticks == nil then
        ticks = 100
    end

    local packet = {}
    packet.command = 'rw'
    packet.ticks = ticks
    rednet.broadcast(packet, 'JBP')
end

-- Pause, skip and stop need no extra logic; just
-- chuck the packet at the player computer
function M.skip()
    sendPacket('skip')
end

function M.pause()
    sendPacket('pause')
end

function M.stop()
    sendPacket('stop')
end

return M