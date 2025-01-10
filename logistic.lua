require("movement")

print("Logistic V6")

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
    move_to_gps(x1,y1,z1)
    set_dir_gps(dx1,dz1)
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

function controller()
    num_chests = 3
    chest_cap = 27*64
    storage_pos = vector.new(164,63,-46)
    storage_ori = vector.new(0,0,1)
    input_pos = vector.new(163,63,-46)
    input_ori = vector.new(-1,0,0)
    input_str = vector_to_str(input_pos,input_ori)
    free_chests = {}
    for i=1,num_chests do
        free_chests[i] = {"pos": storage_pos.add(vector.new(i-1,0,0)),"ori": storage_ori,"items": 0}
    end
    filled_chests = {}
    peripheral.find("modem", rednet.open)
    while true do
        cid,msg,prot = rednet.receive("logistic_pre_sorter")
        spl = mysplit(msg," ")
        it_name = spl[1]
        it_count = spl[2]
        print("received",it_count,"items of",it_name)
        if filled_chests[it_name] == nil then
            for i=1,num_chests do
                ch = free_chests[i]
                if ch ~= nil then
                    filled_chests[it_name] = ch
                    break
                end
            end
        end
        chest = filled_chests[it_name]
        chest_str = vector_to_str(chest["pos"],chest["ori"])
        msg = "logistic move "..input_str.." "..chest_str.." "..it_count
        print("send to chest",chest_str)
        rednet.broadcast(msg,"remote_control")
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
    end
end

if pcall(debug.getlocal, 4, 1) then
    print("in package")
else
    print("in main script")
    main()
end