require("movement")

function main()
    x1,y1,z1,dx1,dz1 = arg[1],arg[2],arg[3],arg[4],arg[5]
    x2,y2,z2,dx2,dz2 = arg[5],arg[6],arg[7],arg[8],arg[9]
    num_items = arg[10]
    move_to_gps(x1,y1,z1)
    set_dir_gps(dx1,dz1)
    collected_count = 0
    while collected_count < num_items do
        iter_col = math.min(64,num_items-collected_count)
        if turtle.suck() then
            collected_count = collected_count + iter_col
        end
    end
end

main()