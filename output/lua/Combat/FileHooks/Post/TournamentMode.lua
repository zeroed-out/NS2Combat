-- Todo: fix vanilla to not pass commands through to the chat
function ProcessSayCommand(player, command)
    for _, entry in ipairs(combatCommands) do
        if StringStartsWith(command, entry) then
            Server.ClientCommand(player, command)
            return true
        end
    end
end