local ThreadsHandler = {}
ThreadsHandler.__index = ThreadsHandler

wax.shared.Threads = {}

function ThreadsHandler:GiveThread(Thread:thread) : (thread)
    table.insert(wax.shared.Threads, Thread)
    return Thread
end

return ThreadsHandler