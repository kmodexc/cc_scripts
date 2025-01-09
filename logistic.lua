require("movement")

print("Logistic V4")

function main()
    arg_num = {}
    for i=1,11 do
        arg_num[i] = tonumber(arg[i])
    end
    x1,y1,z1,dx1,dz1 = arg_num[1],arg_num[2],arg_num[3],arg_num[4],arg_num[5]
    x2,y2,z2,dx2,dz2 = arg_num[6],arg_num[7],arg_num[8],arg_num[9],arg_num[10]
    num_items = arg_num[11]
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

if pcall(debug.getlocal, 4, 1) then
    print("in package")
else
    print("in main script")
    main()
end