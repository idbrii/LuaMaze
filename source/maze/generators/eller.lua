-- Eller's algorithm
function Maze:Eller(maze)
  maze:resetDoors(true)
  
  -- Prepairing sets representations
  local sets = {}
  local setMap = {}
  for i = 1, #maze[1] do
    setMap[i] = i
    sets[i] = { [i] = true, n = 1 }
  end
  
  for y = 1, #maze do
    for x = 1, #maze[1] - 1 do
      -- Randomly remove east wall and merging sets
      if setMap[x] ~= setMap[x + 1] and
      (math.random(2) == 1 or y == #maze) then
        maze[y][x].east:open()
        -- Merging sets together
        local lIndex = setMap[x]; local rIndex = setMap[x + 1]
        local lSet = sets[lIndex]; local rSet = sets[rIndex]
        for i = 1, #maze[1] do
          if setMap[i] ~= rIndex then goto continue end
          lSet[i] = true; lSet.n = lSet.n + 1
          rSet[i] = nil;  rSet.n = rSet.n - 1
          setMap[i] = lIndex
          ::continue::
        end
      end
    end
    
    if y == #maze then break end
    
    -- Randomly remove south walls and making sure that at least one cell in each set has no south wall
    for i, set in pairs(sets) do
      local opened
      local lastCell
      for x, j in pairs(set) do
        if x == "n" then goto continue end
        lastCell = x
        if math.random(2) == 1 then 
          maze[y][x].south:open() 
          opened = true
        end
        ::continue::
      end
      
      if not opened and lastCell then maze[y][lastCell].south:open() end
    end
    
    -- Removing cell with south walls from their sets
    for x = 1, #maze[1] do
      if maze[y][x].south:isClosed() then
        local set = sets[setMap[x]]
        set[x] = nil; set.n = set.n - 1
        setMap[x] = nil
      end
    end
    
    -- Gathering all empty sets in a list
    local emptySets = {}
    for i, set in pairs(sets) do
      if set.n == 0 then emptySets[#emptySets + 1] = i end
    end
    
    -- Assigning all cell without a set to an empty set from the list
    for x = 1, #maze[1] do
      if not setMap[x] then
        setMap[x] = emptySets[#emptySets]; emptySets[#emptySets] = nil
        local set = sets[setMap[x]]
        set[x] = true; set.n = set.n + 1
      end
    end
  end
end