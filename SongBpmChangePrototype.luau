-- bpm test
local function beatToTime(beat:number, bpm:number)
    return beat / (bpm / 60)
end
local function stepToTime(step:number, bpm:number)
    return (step / 4) / (bpm / 60)
end

local SongLength = 270
local startbpm = 160
local bpmchange = {
    [1] = 205
}
local bpmchangetime = {
    [1] = beatToTime(94, 160)
}
local bpmchangepassed = {
    [1] = false
}

local i = 0
local bpm = startbpm
local steps = {}
while true do
    i = i + 1
    local t = stepToTime(i, bpm)
    if t > SongLength then
        break
    else
        table.insert(steps, t)
        for i,v in pairs(bpmchangetime) do
            if v >= t and not bpmchangepassed[i] then
                bpmchangepassed[i] = true
                bpm = bpmchange[i]
                break
            end
        end
    end
end

--print(#steps)

for i = 1,500 do
    print(steps[i])
end
