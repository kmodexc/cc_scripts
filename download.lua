files = {"baum","composter","farm","line","makeroom","movement","mytunnel","puttop","savetunnel"}
for k,v in pairs(files) do
    shell.run("rm "..v..".lua")
    shell.run("wget https://raw.githubusercontent.com/kmodexc/cc_scripts/refs/heads/main/"..v..".lua")
end