local time = {cmd = {},worker = {}}

time.worker.timepass = function(session)
    session.data.time = session.data.time + 1
end

time.preload = function(session) -- preload runs before setting commands and workers
    session.data.time = 0
end

time.setup = function(session) -- setup runs after setting commands and workers
    session:workeradd("timepass","_timepass",1)
end

time.cmd["time.get"] = function(session)
    return session.data.time
end

time.cmd["time.print"] = function(session)
    print(session.data.time)
end

return time