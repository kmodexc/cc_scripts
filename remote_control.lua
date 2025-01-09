function main()
    hostname = os.getComputerLabel()
    if hostname == nil then
        print("Error: Set computer label first")
        return
    end
    protocol = "remote_control"
    peripheral.find("modem", rednet.open)
    rednet.host(protocol, hostname)
    while true do
        id, msg = rednet.receive(protocol)
        print("Run from remote",id,"program",msg)
        shell.run(msg)
        if msg == "exit" then
            return
        end
    end
end

main()