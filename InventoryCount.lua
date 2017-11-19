local BAG_UPDATE,PLAYER_ENTERING_WORLD,ADDON_LOADED="BAG_UPDATE", "PLAYER_ENTERING_WORLD","ADDON_LOADED"

local frame = CreateFrame("Frame", nil, UIParent) -- ThinBorderTemplate

local editFrame = CreateFrame("Frame",nil,frame, "ThinBorderTemplate")
editFrame:SetSize(275, 25)
editFrame:SetPoint("BOTTOMLEFT",editFrame:GetParent(),"TOPLEFT")
editFrame:Hide()

editFrame.label = editFrame:CreateFontString(nil,"ARTWORK","ChatFontNormal")
editFrame.label:SetPoint("TOPLEFT",5,-5)
editFrame.edit = CreateFrame("EditBox",nil,editFrame, "InputBoxTemplate")
editFrame.edit:SetPoint("LEFT", editFrame.label, "RIGHT", 15, 0)
editFrame.edit:SetSize(50,20)
editFrame.edit:SetMaxLetters(5)
editFrame.edit:SetFontObject("ChatFontNormal");
editFrame.edit:SetNumeric(true)

local cancel = CreateFrame("Button", nil, editFrame, "UIPanelButtonGrayTemplate")
cancel:SetText("Cancel")
cancel:SetSize(50,20)
cancel:SetPoint("RIGHT", -15,0)
cancel:SetScript("OnClick", function(self,...) self:GetParent():Hide() end)

local ok = CreateFrame("Button", nil, editFrame, "UIPanelButtonGrayTemplate")
ok:SetText("OK")
ok:SetSize(25,20)
ok:SetPoint("RIGHT", cancel, "LEFT", -15,0)
ok:SetScript("OnClick", 
  function(self,...) 
    local parent = self:GetParent()
    local herb = parent.herb
    herb.limit = editFrame.edit:GetNumber();
    UpdateHerb(herb)
    parent:Hide()
  end)

local tt = CreateFrame("GameTooltip", "tt", nil, "GameTooltipTemplate")

local pairs,print,error,unpack,tonumber,select,type = pairs,print,error,unpack,tonumber,select,type
local REAGENTBANK_CONTAINER,NUM_BAG_SLOTS,NUM_BANKBAGSLOTS = REAGENTBANK_CONTAINER,NUM_BAG_SLOTS,NUM_BANKBAGSLOTS

local widgets = {}

function UpdateHerb(herb)
  local text = widgets[herb.name]
  limits[herb.name] = herb.limit
  text:SetTextColor(unpack(CheckLimit(tonumber(text:GetText()), herb.limit)))
end

function CheckLimit(count, limit)
  if limit <= count then
    return {0,1,0} -- red
  else
    return {1,0,0} -- green
  end
end

function GetCount(name)
  local count = 0
  for bag = REAGENTBANK_CONTAINER, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS  do
      for slot = 1,GetContainerNumSlots(bag) do
        local item = GetContainerItemLink(bag, slot)
        if item and item:match("|h%["..name.."%]") then
          count = count + select(2,GetContainerItemInfo(bag,slot))
        end
      end
    end
    return count
end

function OnEnter(self, button)
  tt:SetOwner(self, "ANCHOR_RIGHT")
  tt:SetText(self.herb.limit,1,1,1)
  tt:Show()
end

function OnLeave(self, button)
  tt:Hide()
end

function ShowEdit(self, button)
  if button ~= "RightButton" then return end
  editFrame.label:SetText(self.herb.name)
  editFrame.edit:SetNumber(self.herb.limit)
  editFrame.herb = self.herb
  editFrame:Show()
end

function frame:Load()
  local previous
  for key,value in pairs(limits) do
    if not widgets[key] then
      local itemFrame = CreateFrame("Frame", nil, frame)
      itemFrame.herb = {name=key, limit=value, count=GetCount(key)}
      itemFrame:EnableMouse(true)
      itemFrame:SetScript("OnEnter", OnEnter)
      itemFrame:SetScript("OnLeave", OnLeave)
      itemFrame:SetScript("OnMouseUp", ShowEdit)
      itemFrame:SetSize(125,20)
      if previous then
        itemFrame:SetPoint("TOPLEFT",previous,"BOTTOMLEFT")
      else 
        itemFrame:SetPoint("TOPLEFT", 5,-5)
      end
      local label = itemFrame:CreateFontString(nil,"ARTWORK","ChatFontNormal")
      label:SetText(key)
      label:SetPoint("LEFT")
      local valueText = itemFrame:CreateFontString(nil,"ARTWORK","ChatFontNormal")
      valueText:SetText(itemFrame.herb.count)
      valueText:SetPoint("RIGHT")
      widgets[key] = valueText
      UpdateHerb(itemFrame.herb)
      itemFrame:Show()
      previous = itemFrame
    end
  end
end

frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
function frame:OnEvent(...)
  for key,_ in pairs(limits) do
    local text = widgets[key]
    local herb = text:GetParent().herb
    herb.count = GetCount(key)
    text:SetText(herb.count)
    text:SetTextColor(unpack(CheckLimit(herb.count, herb.limit)))
  end
end
frame:RegisterEvent(PLAYER_ENTERING_WORLD)
frame:RegisterEvent(ADDON_LOADED)
frame:SetScript("OnEvent", 
  function(self, event, arg1)
    if event == ADDON_LOADED and arg1 == "InventoryCount" then
      self:UnregisterEvent("ADDON_LOADED")
      if type(limits) ~= "table" then limits = { ['Foxflower'] = 0, ['Starlight Rose'] = 0, ['Fjarnskaggl'] = 0, ['Dreamleaf'] = 0, ['Aethril'] = 0, ['Astral Glory'] = 0 } end
      self:Load()
    elseif event == PLAYER_ENTERING_WORLD then
      self:UnregisterEvent(PLAYER_ENTERING_WORLD)
      self:RegisterEvent(BAG_UPDATE)
      self:SetScript("OnEvent", self.OnEvent)
    end
  end)
frame:SetPoint("LEFT", UIParent, "LEFT", 15, 0)
frame:SetSize(150,125)
frame:SetBackdropColor(0,0,0,1)
frame:Show()
frame:HookScript("OnShow", function(self) 
      self:Load()
      self:RegisterEvent(BAG_UPDATE)
    end)
frame:HookScript("OnHide", function(self) 
      self:UnregisterEvent(BAG_UPDATE)
    end)

SLASH_INVENTORYCOUNT1 = '/ic'
function SlashCmdList.INVENTORYCOUNT(message)
  if message == "show" then
    if not frame:IsShown() then frame:Show() end
  elseif message == "hide" then
    if frame:IsShown() then frame:Hide() end
  end
end
