files = {
    "baum",
    "composter",
    "farm",
    "line",
    "makeroom",
    "movement",
    "mytunnel",
    "puttop",
    "savetunnel",
    "remote_control",
    "logistic"
}
for k,v in pairs(files) do
    shell.run("rm "..v..".lua")
    cacheBuster = ("%x"):format(math.random(0, 2 ^ 30))
    shell.run("wget https://raw.githubusercontent.com/kmodexc/cc_scripts/refs/heads/main/"..v..".lua?cb="..cacheBuster)
end