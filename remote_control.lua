function main()
    hostname = os.getComputerLabel()
    if hostname == nil then
        print("Error: Set computer label first")
        return
    end
    protocol = "remote_control"
    while true do
        peripheral.find("modem", rednet.open)
        rednet.host(protocol, hostname)
        id, msg = rednet.receive(protocol)
        rednet.unhost(protocol, hostname)
        peripheral.find("modem", rednet.close)
        print("Run from remote",id,"program",msg)
        shell.run(msg)
        if msg == "exit" then
            return
        end
    end
end

main()