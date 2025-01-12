require("movement")

print("Logistic V28")

chest_cap = 54*64
datapath = "logistic_data.csv"
input_chest = {}
input_chest["pos"] = vector.new(170,64,-46)
input_chest["ori"] = vector.new(-1,0,0)
output_chest = {}
output_chest["pos"] = vector.new(168,63,-45)
output_chest["ori"] = vector.new(-1,0,0)

List = {}
function List.new ()
    return {first = 0, last = -1}
end
function List.pushleft (list, value)
    local first = list.first - 1
    list.first = first
    list[first] = value
end
function List.popright (list)
    local last = list.last
    if list.first > last then 
        return nil
    end
    local value = list[last]
    list[last] = nil         -- to allow garbage collection
    list.last = last - 1
    return value
end

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
    for _k,_v in pairs(data["filled"]) do
        for k,v in pairs(_v) do
            str_cont = "filled,"..v["pos"]:tostring()..","..v["ori"]:tostring()..",".._k..","..v["items"]
            file.writeLine(str_cont)
        end
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
            if data["filled"][key] == nil then
                data["filled"][key] = {}
            end
            data["filled"][key][#data["filled"][key]+1] = obj
        end
    end
    file.close()
    return data
end

function controller_move_items_to(chest1,chest2)
    chest1_str = vector_to_str(chest1["pos"],chest1["ori"])
    chest2_str = vector_to_str(chest2["pos"],chest2["ori"])
    logistic_turtle_id = nil
    while not logistic_turtle_id do
        print("search for logistic turtles")
        logistic_turtle_id = rednet.lookup("remote_control")
        if not logistic_turtle_id then
            --coroutine.yield()
        end
    end
    msg = "logistic move "..chest1_str.." "..chest2_str.." "..it_count
    print("send items from chest",chest1_str,"to chest",chest2_str)
    rednet.send(logistic_turtle_id, msg,"remote_control")
end

function controller_logistic_request(logistic_data,item_name,item_count)
    chest = logistic_data["filled"][item_name][#logistic_data["filled"][item_name]]
    if not chest then
        print("Could not find",item_name)
        write_monitor("Could not find "..item_name)
    elseif (chest["items"] - item_count) < 0 then
        --print("Dont have enough items for",msg)
        first_batch_item_count = chest["items"]
        controller_logistic_request(logistic_data,item_name,first_batch_item_count)
        controller_logistic_request(logistic_data,item_name,item_count - first_batch_item_count)
        return
    else
        controller_move_items_to(chest,output_chest)
        chest["items"] = chest["items"] - item_count
        if chest["items"] == 0 then
            logistic_data["filled"][item_name] = nil
            table.insert(logistic_data["free"],chest)
        end
        save_data(logistic_data,datapath)
    end
end

function controller_presorter_insert(logistic_data,item_name,item_count)
    if logistic_data["filled"][item_name] then
        chest = logistic_data["filled"][item_name][#logistic_data["filled"][item_name]]
        if (chest["items"] + item_count) > chest_cap then
            chest = nil
        end
    end
    if not chest then
        for i=1,num_chests do
            ch = logistic_data["free"][i]
            if ch ~= nil then
                logistic_data["filled"][item_name] = ch
                table.remove(logistic_data["free"], i)
                print("found free chest",i)
                chest = ch
                break
            end
        end
    end
    if not chest then
        print("Could not process item. No free chest found!")
    elseif (chest["items"] + item_count) > chest_cap then
        print("Cant put items as chest limit exceeded! (or no free chests)")
    else
        controller_move_items_to(input_chest,chest)
        chest["items"] = chest["items"] + item_count
        save_data(logistic_data,datapath)
    end
end

function coroutine_continue_next(queue)
    local co = List.popright(queue)
    if co ~= nil then
        if coroutine.resume(co) then
            List.pushleft(queue,co)
        end
    end
    return co
end

function write_monitor(msg)
    monitor = peripheral.find("monitor")
    monitor.setCursorPos(1,1)
    monitor.write(msg)
end

function controller()
    num_chests = 0
    queue_request = List.new()
    queue_sorter = List.new()

    if fs.find(datapath)[1] == nil then
        error("could not find logistic_file.csv")
    else
        logistic_data = load_data(datapath)
        for k1,v1 in pairs(logistic_data["free"]) do
            num_chests = num_chests + 1
        end
        for k1,v1 in pairs(logistic_data["filled"]) do
            for k2,v2 in pairs(v1) do 
                num_chests = num_chests + 1
            end
        end
    end
    
    peripheral.find("modem", rednet.open)
    while true do
        cid,msg,prot = rednet.receive(nil,1)
        if cid and prot == "logistic_pre_sorter" then
            spl = mysplit(msg," ")
            it_name = spl[1]
            it_count = spl[2]
            print("received",it_count,"items of",it_name)
            controller_presorter_insert(logistic_data,it_name,it_count)
        elseif cid and prot == "logistic_request" then
            msg_split = mysplit(msg," ")
            print("process request for",msg)
            write_monitor(msg)
            item_name = "minecraft:"..msg_split[1]
            it_count = tonumber(msg_split[2])
            controller_logistic_request(logistic_data,item_name,it_count)
        end
    end
end

function vector_to_single(vec)
    x = vec:dot(vector.new(1,0,0))
    y = vec:dot(vector.new(0,1,0))
    z = vec:dot(vector.new(0,0,1))
    return x,y,z
end

function scan_chest(chest)
    move_to_gps(vector_to_single(chest["pos"]))
    x,y,z = vector_to_single(chest["ori"])
    set_dir_gps(x,z)
    items = peripheral.call("front", "list")
    item_name = nil
    item_count = 0
    for k,v in pairs(items) do
        if item_name == nil then
            item_name = v["name"]
        else
            if item_name ~= v["name"] then
                print("chest has mutliple items",chest["pos"]:tostring())
                return nil,0
            end
        end
        item_count = item_count + v["count"]
    end
    return item_name, item_count
end

function scan(logistic_data)
    new_logistic_data = {}
    new_logistic_data["filled"] = {}
    new_logistic_data["free"] = {}
    for k1,v1 in pairs(logistic_data["free"]) do
        item_name,item_count = scan_chest(v1)
        if item_name ~= nil then
            if new_logistic_data["filled"][item_name] == nil then
                new_logistic_data["filled"][item_name] = {}
            end
            table.insert(new_logistic_data["filled"][item_name],v1)
        else
            table.insert(new_logistic_data["free"],v1)
        end
    end
    for k1,v1 in pairs(logistic_data["filled"]) do
        for k2,v2 in pairs(v1) do 
            item_name,item_count = scan_chest(v2)
            if item_name == nil then
                table.insert(new_logistic_data["free"],v2)
            else
                if new_logistic_data["filled"][item_name] == nil then
                    new_logistic_data["filled"][item_name] = {}
                end
                table.insert(new_logistic_data["filled"][item_name],v2)
                v2["items"] = item_count
            end
        end
    end
    return new_logistic_data
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
    elseif arg[1] == "scan" then
        logistic_data = load_data(datapath)
        logistic_data = scan(logistic_data)
        save_data(logistic_data,datapath)
    end
end

if pcall(debug.getlocal, 4, 1) then
    print("in package")
else
    print("in main script")
    main()
end