local DebugStats = {}

local counters = {}

function DebugStats.inc(name, by)
    by = by or 1
    counters[name] = (counters[name] or 0) + by
end

function DebugStats.get(name)
    return counters[name] or 0
end

function DebugStats.reset()
    counters = {}
end

function DebugStats.log()
    print("--- DebugStats ---")
    for k, v in pairs(counters) do
        print(k .. ": " .. tostring(v))
    end
    print("------------------")
end

return DebugStats
