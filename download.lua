files = {
    "baum",
    "composter",
    "farm",
    "line",
    "logistic",
    "makeroom",
    "movement",
    "moveto",
    "mytunnel",
    "puttop",
    "queue",
    "remote_control",
    "savetunnel"
}

local function get(sFile)

    local cacheBuster = ("%x"):format(math.random(0, 2 ^ 30))
    local response, err = http.get(
    --    "https://raw.githubusercontent.com/kmodexc/cc_scripts/refs/heads/main/" .. (sFile) .. "?cb=" .. cacheBuster
    "http://kmode.dev:40000/" .. (sFile) .. "?cb=" .. cacheBuster
    )

    if not response then
        io.stderr:write("Failed.\n")
        print(err)
        return
    end

    print("Success.")

    local res = response.readAll()
    response.close()

    local sPath = shell.resolve(sFile)

    if res then
        local file = fs.open(sPath, "w")
        file.write(res)
        file.close()

        print("Downloaded as " .. sFile)
    end
end



for k,v in pairs(files) do
    shell.run("rm "..v..".lua")
    cacheBuster = ("%x"):format(math.random(0, 2 ^ 30))
    --shell.run("wget "..v..".lua?cb="..cacheBuster)
    get(v..".lua")
end