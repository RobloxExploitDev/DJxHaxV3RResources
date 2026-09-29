local HttpService = game:GetService("HttpService")
local LogService = game:GetService("LogService")

local socket

local function getWebSocketConnect()
    if typeof(WebSocket) == "table" and type(WebSocket.connect) == "function" then
        return WebSocket.connect
    elseif typeof(syn) == "table" and typeof(syn.websocket) == "table" and type(syn.websocket.connect) == "function" then
        return syn.websocket.connect
    elseif type(websocket) == "table" and type(websocket.connect) == "function" then
        return websocket.connect
    end
    return nil
end

local wsConnect = getWebSocketConnect()

local function Connect()
    if not wsConnect then
        return
    end

    while true do
        local success, ws = pcall(function()
            return wsConnect("ws://localhost:8765")
        end)

        if success and ws then
            socket = ws
            pcall(function()
               -- print("[V3R] Console Redirection Connected.")
               -- honestly this part is useless lol no point having the print think
            end)

            pcall(function()
                ws.OnClose:Connect(function()
                    socket = nil
                end)
            end)

            break
        end

        task.wait(2)
    end
end

Connect()

task.spawn(function()
    while true do
        if not socket then
            Connect()
        end

        task.wait(2)
    end
end)

LogService.MessageOut:Connect(function(message, mtype)
    if not socket then
        return
    end

    pcall(function()
        socket:Send(HttpService:JSONEncode({
            message = message,
            type = mtype.Name:gsub("Message", "")
        }))
    end)
end)
