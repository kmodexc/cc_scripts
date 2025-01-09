function main()
    hostname = os.getComputerLabel()
    if hostname == nil then
        print("Error: Set computer label first")
        return
    end
    protocol = "remote_control"
    rednet.host(protocol, hostname)
    id, msg = rednet.receive(protocol)
    print("Run from remote",id,"program",msg)
    shell.run(msg)
end

main()