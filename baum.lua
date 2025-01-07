require("movement")
 
function fell()
    move_to(0,1)
    level = 0
    while turtle.detectUp() do
        move_z_to(level)
        move_to(0,1)
        move_to(0,2)
        move_to(1,2)
        move_to(1,1)
        level = level + 1
    end
    move_to(0,0)
    move_z_to(0)
end
 
function place()
    turtle.select(2)
    move_to(0,2)
    set_dir(1,0)
    turtle.place()
    move_to(0,1)
    set_dir(1,0)
    turtle.place()
    set_dir(0,1)
    turtle.place()
    move_to(0,0)
    set_dir(0,1)
    turtle.place()
    turtle.select(1)
end
 
function collect()
    set_dir(0,1)
    turtle.suck()
    move_z_to(-1)
    turtle.suckDown()
    move_z_to(-2)
    turtle.suck()
    move_to(0,1)
    turtle.suck()
    set_dir(1,0)
    turtle.suck()
    set_dir(0,1)
    move_to(0,2)
    set_dir(1,0)
    turtle.suck()
    move_to(0,0)
    move_z_to(0)
    set_dir(0,1)
    turtle.suckUp()
end
 
function refuel()
    if(turtle.getFuelLevel() < 50) then
        turtle.select(1)
        turtle.refuel(32)
    end
end
 
function unload()
    if(turtle.getItemCount(16) > 0) then
        move_to(0,-4)
        set_dir(0,-1)
        for i=4,16 do
            turtle.select(i)
            turtle.drop(64)
        end
    end
end

function load_bone_meal()
    move_to(0,-4)
    set_dir(0,-1)
    move_z_to(1)
    while turtle.suck() do end
    move_z_to(0)
end
 
while(true) do
    turtle.select(1)
    move_to(0,0)
    set_dir(0,1)
    if(turtle.compare()) then
        print("Fell tree")
        fell()
        print("Place sapplings")
        place()
        print("Wait collect")
        sleep(60)
        print("Collect")
        collect()
        refuel()
        print("Unload")
        unload()
        print("Reload Bone meal")
        load_bone_meal()
    else
        turtle.select(3)
        if turtle.getItemCount(3) > 1 then
            turtle.place()
        end
    end
end