line_x = {-3,-1,1,3}
line_y = 1
line_len = 8

water_pos_x = { -2, 2 }

require("movement")


function farm_line(x)
    for y=line_y,(line_y + line_len) do
        move_to(x,y)
        success, data = turtle.inspectDown()
        if not success then
            print("not found")
            turtle.digDown()
            turtle.placeDown()
        else
            print("found state "..data["state"]["age"])
            if data["state"]["age"] == 7 then
                turtle.digDown()
                turtle.suckDown()
                turtle.placeDown()
            end
        end
    end
end

function suck_items(x)
    move_to(x, line_y)
    turtle.down()
    turtle.suckDown()
    turtle.up()
end

function farm()

    turtle.select(1)

    for k,line_x in pairs(line_x) do
        print("farm line "..line_x)
        farm_line(line_x)
    end

    for k,water_x in pairs(water_pos_x) do
        print("suck items "..water_x)
        suck_items(water_x)
    end

    print("return home")

    move_to(0,0)

    print("remove all items")
    for i=2,16 do
        turtle.select(i)
        turtle.dropDown()
    end

end

if pcall(debug.getlocal, 4, 1) then
    print("in package")
else
    print("in main script")
    farm()
end
