local gridList = {}
local selectedRow={}
local columnCount={}
local staticListID = 0
function guiCreateStaticGridList(x, y, w, h, rel, parent)

    staticListID = staticListID+1
    
    if not rel then rel = false end
    if not parent then parent = nil end   
    
    gridList[staticListID]={}
    gridList[staticListID]["Column"]={}
    gridList[staticListID]["Row"]={}
    gridList[staticListID]["RowInColumn"]={}
    selectedRow[staticListID]={}
    
    columnCount[staticListID] = 0
    
    gridList[staticListID]["Background"] = guiCreateStaticImage(x-1, y-1, w+2, h+2, "panel.png", rel, parent)
    guiSetProperty(gridList[staticListID]["Background"], "ImageColours", "tl:FF333333 tr:FF333333 bl:FF333333 br:FF333333")
    gridList[staticListID]["Main"] = guiCreateStaticImage(1, 1, w, h, "panel.png", rel, gridList[staticListID]["Background"])
    guiSetProperty(gridList[staticListID]["Main"], "ImageColours", "tl:FF000000 tr:FF000000 bl:FF000000 br:FF000000")
    gridList[staticListID]["Frame"] = guiCreateScrollPane(0, 0, w, h, rel, gridList[staticListID]["Main"])
    
    return staticListID, gridList[staticListID]["Background"]
end

function guiStaticGridListAddColumn(id, text, width)
    if not gridList[id]["Frame"] then return nil end
    if width < 0 or width > 1 then width = 1 end
    local columnCreated = true
    local colID = 1
    
    if columnCount[id] < 1 then columnCreated = false end
    for i = 1, table.maxn(gridList[id]["Column"]) do colID = colID + 1 end
    
    local createXPos = 0
    local createWidth = 0
    
    local getFrameWidth, getFrameHeight = guiGetSize(gridList[id]["Main"], false)
    
    if not columnCreated then 
    
        gridList[id]["TopLine"] = guiCreateStaticImage(5, 18, getFrameWidth-10, 1, "panel.png", false, gridList[id]["Frame"])
        
    else
    
        createXPos, _ = guiGetPosition(gridList[id]["Column"][colID-1], true)
        createWidth, _ = guiGetSize(gridList[id]["Column"][colID-1], true)
        
    end
    
    gridList[id]["Column"][colID] = guiCreateLabel(createXPos+createWidth, 1/getFrameHeight, width, 15/getFrameHeight, tostring(text), true, gridList[id]["Frame"])
    guiSetFont(gridList[id]["Column"][colID], "default-small")
    guiLabelSetHorizontalAlign(gridList[id]["Column"][colID], "center", false)
    guiLabelSetVerticalAlign(gridList[id]["Column"][colID], "center")
    columnCount[id]=columnCount[id]+1
    
    local newPos, _ = guiGetPosition(gridList[id]["Column"][colID], false)
    local newWidth, _ = guiGetSize(gridList[id]["Column"][colID], false)
    local checkWidth = newPos+newWidth
    
    if checkWidth > getFrameWidth then 
    
        guiSetSize(gridList[id]["TopLine"], checkWidth-10, 1, false) 
        for i = 1, table.maxn(gridList[id]["Row"]) do guiSetSize(gridList[id]["Row"][i], checkWidth-10, 16, false) end
        
    end
    
    return colID
end

function guiStaticGridListSetColumnTitle(id, colID, text)
    if not gridList[id]["Column"][colID] then return nil end
    guiSetText(gridList[id]["Column"][colID], tostring(text))
end

function guiStaticGridListGetColumnTitle(id, colID)
    if not gridList[id]["Column"][colID] then return nil end
    return guiGetText(gridList[id]["Column"][colID])
end

function guiStaticGridListAddRow(id)
    if not gridList[id]["Frame"] then return nil end
    local rowCreated = false
    local rowID = 1
    for i = 1, table.maxn(gridList[id]["Row"]) do rowID = rowID + 1 rowCreated = true end
    local createRowYPos = 20
    --local createHeight = 0
    if rowCreated then
        _, createRowYPos = guiGetPosition(gridList[id]["Row"][rowID-1], false)
        createRowYPos = createRowYPos+16
        --_, createHeight = guiGetSize(gridList[id]["Row"][rowID-1], false)
    end
    local widthTopLine, _ = guiGetSize(gridList[id]["TopLine"], false)
    gridList[id]["Row"][rowID] = guiCreateStaticImage(5, createRowYPos, widthTopLine, 16, "panel.png", false, gridList[id]["Frame"])
    guiSetProperty(gridList[id]["Row"][rowID], "ImageColours", "tl:FF000000 tr:FF000000 bl:FF000000 br:FF000000")
    setElementData(gridList[id]["Row"][rowID], "SelectedColor", "FF607FFF")
    setElementData(gridList[id]["Row"][rowID], "JoinedColor", "FF222222")
    gridList[id]["RowInColumn"][rowID]={}
    
    addEventHandler("onClientGUIClick", gridList[id]["Row"][rowID], 
        function()
            guiStaticGridListSetSelectedItem(id, rowID, 1)
        end, false)
        
    addEventHandler("onClientMouseEnter", root, function() 
        if source == gridList[id]["Row"][rowID] then 
            if not selectedRow[id][rowID] then 
                guiSetProperty(gridList[id]["Row"][rowID], "ImageColours", "tl:"..getElementData(gridList[id]["Row"][rowID], "JoinedColor").." tr:"..getElementData(gridList[id]["Row"][rowID], "JoinedColor").." bl:"..getElementData(gridList[id]["Row"][rowID], "JoinedColor").." br:"..getElementData(gridList[id]["Row"][rowID], "JoinedColor")) 
            end 
        end 
    end)

    addEventHandler("onClientMouseLeave", root, function() 
        if source == gridList[id]["Row"][rowID] then 
            if not selectedRow[id][rowID] then 
                guiSetProperty(gridList[id]["Row"][rowID], "ImageColours", "tl:FF000000 tr:FF000000 bl:FF000000 br:FF000000") 
            end 
        end 
    end)
    
    return rowID
end

function guiStaticGridListSetItemText(id, rowID, colID, text)

    if not text then text = "" end

    if gridList[id]["RowInColumn"][rowID][colID] then guiSetText(gridList[id]["RowInColumn"][rowID][colID], tostring(text)) return 1; end   
    
    local getColumnPosition = {guiGetPosition(gridList[id]["Column"][colID], false)}
    local getColumnSize = {guiGetSize(gridList[id]["Column"][colID], false)}
    
    gridList[id]["RowInColumn"][rowID][colID] = guiCreateLabel(getColumnPosition[1], 0, getColumnSize[1], 16, tostring(text), false, gridList[id]["Row"][rowID])
    guiLabelSetHorizontalAlign(gridList[id]["RowInColumn"][rowID][colID], "center", false)
    guiLabelSetVerticalAlign(gridList[id]["RowInColumn"][rowID][colID], "center")
    
    addEventHandler("onClientGUIClick", gridList[id]["RowInColumn"][rowID][colID], 
        function()
            guiStaticGridListSetSelectedItem(id, rowID, colID)
        end, false)
        
    addEventHandler("onClientMouseEnter", root, function() 
        if source == gridList[id]["RowInColumn"][rowID][colID] then 
            if not selectedRow[id][rowID] then 
                guiSetProperty(gridList[id]["Row"][rowID], "ImageColours", "tl:"..getElementData(gridList[id]["Row"][rowID], "JoinedColor").." tr:"..getElementData(gridList[id]["Row"][rowID], "JoinedColor").." bl:"..getElementData(gridList[id]["Row"][rowID], "JoinedColor").." br:"..getElementData(gridList[id]["Row"][rowID], "JoinedColor")) 
            end 
        end 
    end)
    
    addEventHandler("onClientMouseLeave", root, function() 
        if source == gridList[id]["RowInColumn"][rowID][colID] then 
            if not selectedRow[id][rowID] then 
                guiSetProperty(gridList[id]["Row"][rowID], "ImageColours", "tl:FF000000 tr:FF000000 bl:FF000000 br:FF000000") 
            end 
        end 
    end)
    
    return gridList[id]["RowInColumn"][rowID][colID]
end

function guiStaticGridListGetItemText(id, rowID, colID)
    if not gridList[id]["RowInColumn"][rowID][colID] then return nil end
    return guiGetText(gridList[id]["RowInColumn"][rowID][colID])
end

function guiStaticGridListSetItemColor(id, rowID, colID, r, g, b)
    if not gridList[id]["RowInColumn"][rowID][colID] then return nil end
    if not r or r < 0 or r > 255 then r = 255 end
    if not g or g < 0 or g > 255 then g = 255 end
    if not b or b < 0 or b > 255 then b = 255 end
    guiLabelSetColor(gridList[id]["RowInColumn"][rowID][colID], r, g, b)
end

function guiStaticGridListGetItemColor(id, rowID, colID)
    if not gridList[id]["RowInColumn"][rowID][colID] then return nil end
    local r, g, b = guiLabelGetColor(gridList[id]["RowInColumn"][rowID][colID])
    return r, g, b
end

function guiStaticGridListClear(id)
    if not gridList[id]["Row"][1] then return nil end
    for i = 1, table.maxn(gridList[id]["Row"]) do if gridList[id]["Row"][i] then table.remove(gridList[id]["Row"]) destroyElement(gridList[id]["Row"][i]) end end
end

function guiStaticGridListRemoveColumn(id, colID)
    if not gridList[id]["Column"][colID] then return nil end
    local newX, colX, newWid, colWid = 0, 0, 0, 0

    colX, _ = guiGetPosition(gridList[id]["Column"][colID], false)
    colWid, _ = guiGetSize(gridList[id]["Column"][colID], false)
    
    table.remove(gridList[id]["Column"], colID)
    destroyElement(gridList[id]["Column"][colID])
    for i = 1, table.maxn(gridList[id]["Row"]) do if gridList[id]["RowInColumn"][i][colID] then destroyElement(gridList[id]["RowInColumn"][i][colID]) end end
    columnCount[id] = columnCount[id]-1
    
    if columnCount[id] < 1 then destroyElement(gridList[id]["TopLine"]) guiStaticGridListClear(id) return 1 end
    
    
    for i = colID, table.maxn(gridList[id]["Column"]) do
    
        if i == colID then 
        
            guiSetPosition(gridList[id]["Column"][i+1], colX, 1, false) 
            for zi = 1, table.maxn(gridList[id]["Row"]) do if gridList[id]["RowInColumn"][zi][i+1] then guiSetPosition(gridList[id]["RowInColumn"][zi][i+1], colX, 0, false) end end
            
        else
        
            newX, _ = guiGetPosition(gridList[id]["Column"][i], false)
            newWid, _ = guiGetSize(gridList[id]["Column"][i], false)
            guiSetPosition(gridList[id]["Column"][i+1], newX+newWid, 1, false)
            for zi = 1, table.maxn(gridList[id]["Row"]) do if gridList[id]["RowInColumn"][zi][i+1] then guiSetPosition(gridList[id]["RowInColumn"][zi][i+1], newX+newWid, 0, false) end end
            
        end
        
    end
    
    local frameWidth, _ = guiGetSize(gridList[id]["Frame"], false)
    local lineWidth, _ = guiGetSize(gridList[id]["TopLine"], false)
    
    if lineWidth > frameWidth-10 then 
        lineWidth = lineWidth - colWid
        if lineWidth < frameWidth-10 then lineWidth = frameWidth-10 end
    end
    
    
    guiSetSize(gridList[id]["TopLine"], lineWidth, 1, false)
    
    for i = 1, table.maxn(gridList[id]["Row"]) do 
    
        guiSetSize(gridList[id]["Row"][i], lineWidth, 16, false) 
        
    end
    
end

function guiStaticGridListRemoveRow(id, rowID)
    if not gridList[id]["Row"][rowID] then return nil end
    --local newLocalX, _ = guiGetPosition(gridList[id]["Row"][rowID])
    
    table.remove(gridList[id]["Row"], rowID)
    destroyElement(gridList[id]["Row"][rowID])
    gridList[id]["Row"][rowID] = nil
    
    for i = rowID, table.maxn(gridList[id]["Row"]) do
        --outputDebugString(i)
        if gridList[id]["Row"][i] ~= nil then
            --outputDebugString(i.." true "..type(gridList[id]["Row"][i]).." "..tostring(gridList[id]["Row"][i]))
            local xx, yy = guiGetPosition(gridList[id]["Row"][i], false)
            guiSetPosition(gridList[id]["Row"][i], xx, yy-16, false)
            
        end     
    
    end
end

function guiStaticGridListSetItemSelectedColor(id, rowID, r, g, b, a)
    if not gridList[id]["Row"][rowID] then return nil end
    if not a or a < 0 or a > 255 then a = 255 end
    if not r or r < 0 or r > 255 then r = 96  end
    if not g or g < 0 or g > 255 then g = 127 end
    if not b or b < 0 or b > 255 then b = 255 end
    setElementData(gridList[id]["Row"][rowID], "SelectedColor", string.format("%.2x%.2x%.2x%.2x", a, r, g, b))
end

function guiStaticGridListGetItemSelectedColor(id, rowID, bHex)
    if not gridList[id]["Row"][rowID] then return nil end
    if not bHex or (bHex ~= false and bHex ~= true) then bHex = false end
    local syr = string.sub(getElementData(gridList[id]["Row"][rowID], "SelectedColor"), 4, 12)
    
    if bHex then return syr 
    else 
        local a = tonumber(string.sub(syr, 1, 2), 16) 
        local r = tonumber(string.sub(syr, 3, 4), 16)
        local g = tonumber(string.sub(syr, 5, 6), 16) 
        local b = tonumber(string.sub(syr, 7, 8), 16) 
        return r, g, b, a 
    end
end

function guiStaticGridListSetItemJoinedColor(id, rowID, r, g, b, a)
    if not gridList[id]["Row"][rowID] then return nil end
    if not a or a < 0 or a > 255 then a = 255 end
    if not r or r < 0 or r > 255 then r = 34  end
    if not g or g < 0 or g > 255 then g = 34 end
    if not b or b < 0 or b > 255 then b = 34 end
    setElementData(gridList[id]["Row"][rowID], "JoinedColor", string.format("%.2x%.2x%.2x%.2x", a, r, g, b))
end

function guiStaticGridListGetItemJoinedColor(id, rowID, bHex)
    if not gridList[id]["Row"][rowID] then return nil end
    if not bHex or (bHex ~= false and bHex ~= true) then bHex = false end
    local syr = string.sub(getElementData(gridList[id]["Row"][rowID], "JoinedColor"), 4, 12)
    if bHex then return syr
    else
        local a = tonumber(string.sub(syr, 1, 2), 16) 
        local r = tonumber(string.sub(syr, 3, 4), 16)
        local g = tonumber(string.sub(syr, 5, 6), 16) 
        local b = tonumber(string.sub(syr, 7, 8), 16) 
        return r, g, b, a 
    end
end

function guiStaticGridListSetSelectedItem(id, rowID, colID)
    if not gridList[id]["Row"][rowID] then return nil end
    if not colID then colID = 1 end
    for i = 1, table.maxn(gridList[id]["Row"]) do guiSetProperty(gridList[id]["Row"][i], "ImageColours", "tl:FF000000 tr:FF000000 bl:FF000000 br:FF000000") selectedRow[id][i] = false end
    guiSetProperty(gridList[id]["Row"][rowID], "ImageColours", "tl:"..getElementData(gridList[id]["Row"][rowID], "SelectedColor").." tr:"..getElementData(gridList[id]["Row"][rowID], "SelectedColor").." bl:"..getElementData(gridList[id]["Row"][rowID], "SelectedColor").." br:"..getElementData(gridList[id]["Row"][rowID], "SelectedColor"))
    selectedRow[id][rowID] = true
    triggerEvent("onClientStaticGridListClickItem", localPlayer, id, rowID, colID)
end

function guiStaticGridListGetSelectedItem(id)
    if not gridList[id]["Frame"] then return nil end
    local selrow = false
    for i = 0, table.maxn(gridList[id]["Row"]) do
        if selectedRow[id][i] then
            selrow = i
            break
        end
    end
    return selrow
end

function guiStaticGridListGetRowCount(id)
    if not gridList[id]["Frame"] then return nil end
    local returnRowCount = 0
    for i = 0, table.maxn(gridList[id]["Row"]) do if gridList[id]["Row"][i] ~= nil then returnRowCount = returnRowCount + 1 end end
    return returnRowCount
end

function guiStaticGridListGetColumnCount(id)
    if not gridList[id]["Frame"] then return nil end
    return columnCount[id]
end

--[[addEventHandler("onClientResourceStart", root,
    function()
        local list = guiCreateStaticGridList(100, 100, 400, 400)
        guiStaticGridListAddColumn(list, "Авто", 0.1)
        guiStaticGridListAddColumn(list, "Лалка", 0.2)
        guiStaticGridListAddColumn(list, "Ааока", 0.1)
        guiStaticGridListAddColumn(list, "Тралл", 0.1)
        guiStaticGridListAddRow(list)
        guiStaticGridListAddRow(list)
        guiStaticGridListAddRow(list)
        guiStaticGridListAddRow(list)
        guiStaticGridListAddRow(list)
        guiStaticGridListAddRow(list)
        guiStaticGridListSetItemText(list, 1, 2, "C2R1")
        guiStaticGridListSetItemText(list, 2, 1, "C1R2")
        guiStaticGridListSetItemText(list, 1, 1, "C1R1")
        guiStaticGridListSetItemText(list, 2, 2, "C2R2")
        guiStaticGridListSetItemText(list, 3, 4, "C4R3")
        guiStaticGridListSetItemText(list, 4, 3, "C3R4")
        guiStaticGridListSetItemText(list, 3, 3, "C3R3")
        guiStaticGridListSetItemText(list, 4, 4, "C4R4")
        --guiStaticGridListRemoveColumn(list, 1)
        --guiStaticGridListRemoveColumn(list, 2)
        --guiStaticGridListRemoveColumn(list, 3)
        --guiStaticGridListRemoveColumn(list, 4)
        --guiStaticGridListRemoveRow(list, 2)
        --guiStaticGridListClear(list)
        guiStaticGridListSetItemSelectedColor(list, 2, 255, 0, 0)
        guiStaticGridListSetItemSelectedColor(list, 3, 0, 255, 0)
        guiStaticGridListSetItemSelectedColor(list, 4, 0, 0, 255)
        guiStaticGridListSetItemJoinedColor(list, 2, 100, 0, 0)
        guiStaticGridListSetItemJoinedColor(list, 3, 0, 100, 0)
        guiStaticGridListSetItemJoinedColor(list, 4, 0, 0, 100)
        guiStaticGridListSetColumnTitle(list, 1, "Тест")
        guiStaticGridListSetSelectedItem(list, 2)
        outputDebugString(tostring(guiStaticGridListGetSelectedItem(list)).." "..tostring(guiStaticGridListGetRowCount(list)).." "..tostring(guiStaticGridListGetColumnCount(list)).." "..tostring(guiStaticGridListGetItemText(list, 1, 2)))
        guiStaticGridListSetItemColor(list, 1, 2, 255, 0, 0)
        end)]]
    
    
    
    
