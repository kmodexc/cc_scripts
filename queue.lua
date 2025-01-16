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
    list[last] = nil
    list.last = last - 1
    return value
end