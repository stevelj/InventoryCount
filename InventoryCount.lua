InvC = {}
local InvC = InvC

local BAG_UPDATE,ADDON_LOADED="BAG_UPDATE","ADDON_LOADED"
local pairs,select,type = pairs,select,type
local REAGENTBANK_CONTAINER,NUM_BAG_SLOTS,NUM_BANKBAGSLOTS = REAGENTBANK_CONTAINER,NUM_BAG_SLOTS,NUM_BANKBAGSLOTS

-- create frame
local frame = CreateFrame("Frame", nil, UIParent)--,'ThinBorderTemplate')

-- slash commands
local function slashHandler(message)
  if message == "show" then
    frame.disabled = false
    frame:Show()
  elseif message == "hide" then
    frame.disabled = true
    frame:Hide()
  end
end
SLASH_INVENTORYCOUNT1 = '/invc'
SlashCmdList.INVENTORYCOUNT = slashHandler


-- build frame
frame.disabled=false
frame:Hide()
frame:SetSize(150,145)
frame:SetBackdropColor(0,0,0,1)
frame:SetPoint("LEFT", UIParent, "LEFT", 15, 0)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEAVING_WORLD")
frame:RegisterEvent(ADDON_LOADED)
frame:SetScript("OnEvent", function(self, event, ...) InvC[event](self,event,...) end)

InvC.editFrame = ICEditFrame:New(frame)
InvC.tt = CreateFrame("GameTooltip", "tt", nil, "GameTooltipTemplate")

local widgets = {}

local function GetCounts()
  local counts = {}
  for name,_ in pairs(limits) do
    counts[name] = 0
  end
  for bag = REAGENTBANK_CONTAINER, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS  do
    for slot = 1,GetContainerNumSlots(bag) do
      local item = GetContainerItemLink(bag, slot)
      if item then
        local name = item:match("|h%[(.+)%]")
        if name and counts[name] then
          local count = counts[name]
          count = count + select(2,GetContainerItemInfo(bag,slot))
          counts[name] = count
        end
      end
    end
  end
  return counts
end

local function createItem(name, limit, count)
  return {name=name, limit=limit, count=count}
end

function frame:Load()
  local previous
  local counts = GetCounts()
  for key,value in pairs(limits) do
    if not widgets[key] then
      local item = createItem(key,value,counts[key])
      local itemFrame = ICItemFrame:New(frame,item)
      itemFrame:SetSize(125,20)
      if previous then
        itemFrame:SetPoint("TOPLEFT",previous,"BOTTOMLEFT")
      else 
        itemFrame:SetPoint("TOPLEFT", 5,-15)
      end      
      widgets[key] = itemFrame
      previous = itemFrame
    end
  end
  self:RegisterEvent(BAG_UPDATE)
end
Utils.SetOrHookScript(frame,"OnShow", frame.Load)

function frame:Destroy()
  self:UnregisterEvent(BAG_UPDATE)
end
Utils.SetOrHookScript(frame, "OnHide", frame.Destroy)

function InvC.ADDON_LOADED(_,_, addon, ...)
  if addon == "InventoryCount" then 
    frame:UnregisterEvent(ADDON_LOADED)
    if type(limits) ~= "table" then limits = { ['Foxflower'] = 0, ['Starlight Rose'] = 0, ['Fjarnskaggl'] = 0, ['Dreamleaf'] = 0, ['Aethril'] = 0, ['Astral Glory'] = 0, ['Yseralline Seed'] = 0 } end

    --if type(limits) ~= "table" then limits = {} end

  end
end

function InvC.PLAYER_ENTERING_WORLD(...)
  if frame.disabled == false then frame:Show() end
end

function InvC.PLAYER_LEAVING_WORLD(...)
  frame:Hide()
end

function InvC.BAG_UPDATE(...)
  local counts = GetCounts()
  for key,value in pairs(counts) do
    widgets[key]:GetItem().count = value
    widgets[key]:Update()
  end
end

function InvC.LimitUpdate(self, item)
  limits[item.name] = item.limit
end
