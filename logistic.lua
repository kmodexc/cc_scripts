require("movement")

print("Logistic V12")

function move_items_to(x1,y1,z1,dx1,dz1,x2,y2,z2,dx2,dz2,num_items)
    print("Get",num_items)
    move_to_gps(x1,y1,z1)
    set_dir_gps(dx1,dz1)
    collected_count = 0
    while collected_count < num_items do
        iter_col = math.min(64,num_items-collected_count)
        if turtle.suck(iter_col) then
            collected_count = collected_count + iter_col
        end
    end
    move_to_gps(x2,y2,z2)
    set_dir_gps(dx2,dz2)
    for i=1,16 do
        turtle.select(i)
        turtle.drop()
    end
end

function chest_is_filled()
    return peripheral.call("front", "list")[1] ~= nil
end

function pre_sorter()
    protocol = "logistic_pre_sorter"
    peripheral.find("modem", rednet.open)
    while true do
        if turtle.suck() then
            detail = turtle.getItemDetail()
            item_name = detail["name"]
            item_count = detail["count"]
            turtle.turnLeft()
            turtle.turnLeft()
            turtle.drop()
            rednet.broadcast(item_name.." "..item_count,protocol)
            while chest_is_filled() do sleep(1) end
            turtle.turnLeft()
            turtle.turnLeft()
        end
    end
end

function mysplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function vector_to_str(vec,ori)
    x = vec:dot(vector.new(1,0,0))
    y = vec:dot(vector.new(0,1,0))
    z = vec:dot(vector.new(0,0,1))
    dx = ori:dot(vector.new(1,0,0))
    dz = ori:dot(vector.new(0,0,1))
    return ""..x.." "..y.." "..z.." "..dx.." "..dz
end

function save_data(data,path)
    file = fs.open(path,"w")
    for k,v in pairs(data["free"]) do
        str_cont = "free,"..v["pos"]:tostring()..","..v["ori"]:tostring()
        file.writeLine(str_cont)
    end
    for k,v in pairs(data["filled"]) do
        str_cont = "filled,"..v["pos"]:tostring()..","..v["ori"]:tostring()..","..k..","..v["items"]
        file.writeLine(str_cont)
    end
    file.close()
end

function load_data(path)
    data = {}
    data["free"] = {}
    data["filled"] = {}
    free_cnt = 0
    file = fs.open(path,"r")
    while true do
        line = file.readLine()
        if line == nil then
            break
        end
        ls = mysplit(line,",")
        if ls[1] == "free" then
            obj = {}
            obj["pos"] = vector.new(tonumber(ls[2]),tonumber(ls[3]),tonumber(ls[4]))
            obj["ori"] = vector.new(tonumber(ls[5]),tonumber(ls[6]),tonumber(ls[7]))
            obj["items"] = 0
            data["free"][free_cnt] = obj
            free_cnt = free_cnt + 1
        elseif ls[1] == "filled" then
            obj = {}
            obj["pos"] = vector.new(tonumber(ls[2]),tonumber(ls[3]),tonumber(ls[4]))
            obj["ori"] = vector.new(tonumber(ls[5]),tonumber(ls[6]),tonumber(ls[7]))
            key = ls[8]
            obj["items"] = tonumber(ls[9])
            data["filled"][key] = obj
        end
    end
    file.close()
end

function controller()
    chests_up = 6
    chests_for= 17
    num_chests = chests_up*chests_for
    chest_cap = 27*64
    
    storage_pos = vector.new(169,63,-45)
    storage_ori = vector.new(0,0,1)
    input_pos = vector.new(170,64,-46)
    input_ori = vector.new(-1,0,0)
    input_str = vector_to_str(input_pos,input_ori)
    output_pos = vector.new(168,63,-45)
    output_ori = vector.new(-1,0,0)
    output_str = vector_to_str(output_pos,output_ori)

    datapath = "logistic_data.csv"
    if fs.find(datapath)[1] == nil then
        free_chests = {}
        for x=1,chests_for do
            for y=1,chests_up do
                i = y + ((x-1)*chests_up)
                free_chests[i] = {}
                free_chests[i]["pos"] = storage_pos:add(vector.new(x-1,y-1,0))
                free_chests[i]["ori"] = storage_ori
                free_chests[i]["items"] = 0
            end
        end
        filled_chests = {}
        logistic_data = {}
        logistic_data["free"] = free_chests
        logistic_data["filled"] = filled_chests
        save_data(logistic_data,datapath)
    else
        load_data(datapath)
        filled_chests = data["filled"]
        logistic_data = data["free"]
    end
    
    peripheral.find("modem", rednet.open)
    while true do
        cid,msg,prot = rednet.receive()
        if cid and prot == "logistic_pre_sorter" then
            spl = mysplit(msg," ")
            it_name = spl[1]
            it_count = spl[2]
            print("received",it_count,"items of",it_name)
            if not filled_chests[it_name] then
                for i=1,num_chests do
                    ch = free_chests[i]
                    if ch ~= nil then
                        filled_chests[it_name] = ch
                        table.remove(free_chests, i)
                        print("found free chest",i)
                        break
                    end
                end
            end
            chest = filled_chests[it_name]
            if not chest then
                print("Could not process item. No free chest found!")
            elseif (chest["items"] + it_count) > chest_cap
                print("Cant put items as chest limit exceeded!")
            else
                chest_str = vector_to_str(chest["pos"],chest["ori"])
                logistic_turtle_id = nil
                while not logistic_turtle_id do
                    print("search for logistic turtles")
                    logistic_turtle_id = rednet.lookup("remote_control")
                    if not logistic_turtle_id then
                        sleep()
                    end
                end
                msg = "logistic move "..input_str.." "..chest_str.." "..it_count
                print("send to chest",chest_str)
                rednet.broadcast(msg,"remote_control")
                chest["items"] = chest["items"] + it_count
                logistic_data["free"] = free_chests
                logistic_data["filled"] = filled_chests
                save_data(logistic_data,datapath)
            end
        elseif cid and prot == "logistic_request" then
            msg_split = mysplit(msg," ")
            print("process request for",msg)
            item_name = "minecraft:"..msg_split[1]
            it_count = tonumber(msg_split[2])
            chest = filled_chests[it_name]
            if not chest then
                print("Could not find",msg)
            elseif (chest["items"] - it_count) < 0
                print("Dont have enough items for",msg)
            else
                chest_str = vector_to_str(chest["pos"],chest["ori"])
                msg = "logistic move "..chest_str.." "..output_str.." "..it_count
                print("get item")
                rednet.broadcast(msg,"remote_control")
                chest["items"] = chest["items"] - it_count
                logistic_data["free"] = free_chests
                logistic_data["filled"] = filled_chests
                save_data(logistic_data,datapath)                
            end
        end
    end
end

function terminal()
    peripheral.find("modem", rednet.open)
    while true do
        io.write("Which element do you need? ")
        element = io.read()
        io.write("How many elements do you want? ")
        count = io.read()
        msg = element.." "..count
        rednet.broadcast(msg,"logistic_request")
        print("Logistic request ("..msg..") send!")
    end
end

function main()
    if arg[1] == "move" then
        arg_num = {}
        for i=1,11 do
            arg_num[i] = tonumber(arg[i+1])
        end
        x1,y1,z1,dx1,dz1 = arg_num[1],arg_num[2],arg_num[3],arg_num[4],arg_num[5]
        x2,y2,z2,dx2,dz2 = arg_num[6],arg_num[7],arg_num[8],arg_num[9],arg_num[10]
        num_items = arg_num[11]
        move_items_to(x1,y1,z1,dx1,dz1,x2,y2,z2,dx2,dz2,num_items)
    elseif arg[1] == "presorter" then
        pre_sorter()
    elseif arg[1] == "controller" then
        controller()
    elseif arg[1] == "terminal" then
        terminal()
    end
end

if pcall(debug.getlocal, 4, 1) then
    print("in package")
else
    print("in main script")
    main()
end