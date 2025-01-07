width = tonumber(arg[1])
length = tonumber(arg[2])
height = tonumber(arg[3])
 
require("movement")

-- mod three layers
for z=0,(math.floor(height/3)-1) do
    layer = 3*z+1
    move_z_to(layer)
    for x=0,(width-1) do
        if x % 2 == 0 then
            for y=0,(length-1) do
                move_to(x,y)
                turtle.digUp()
                turtle.digDown()
            end
        else
            for y=0,(length-1) do
                move_to(x,length-y-1)
                turtle.digUp()
                turtle.digDown()
            end
        end
    end
end

-- remainder term
for z=0,((height%3)-1) do
    layer = 3*math.floor(height/3)+z
    move_z_to(layer)
    for x=0,(width-1) do
        if x % 2 == 0 then
            for y=0,(length-1) do
                move_to(x,y)
            end
        else
            for y=0,(length-1) do
                move_to(x,length-y-1)
            end
        end
    end
end

-- go back
move_to(0,0)
move_z_to(0)
 