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
    end
end

if pcall(debug.getlocal, 4, 1) then
    print("in package")
else
    print("in main script")
    main()
end