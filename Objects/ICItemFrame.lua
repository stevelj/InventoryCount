local unpack = unpack
ICItemFrame = {}
function ICItemFrame:New(parent, _item)
  local this = CreateFrame("Button",nil,parent)
  local tt = InvC.tt
  local editFrame = InvC.editFrame
  this:RegisterForClicks("RightButtonUp")
  local label = this:CreateFontString(nil,"ARTWORK","ChatFontNormal")
  local value = this:CreateFontString(nil,"ARTWORK","ChatFontNormal")
  local item = _item

  label:SetPoint("LEFT")
  value:SetPoint("RIGHT")

  local function CheckLimit()
    if item.limit <= item.count then
      -- TODO make this a preference
      return {0,1,0} -- red
    else
      return {1,0,0} -- green
    end
  end

  function this:Update()
    label:SetText(item.name)
    value:SetText(item.count)
    value:SetTextColor(unpack(CheckLimit()))
  end
  this:Update()

  local function OnEnter()
    tt:SetOwner(this, "ANCHOR_RIGHT")
    tt:SetText(item.limit,1,1,1)
    tt:Show()
  end
  this:SetScript("OnEnter",OnEnter)

  local function OnLeave()
    tt:Hide()
  end
  this:SetScript("OnLeave",OnLeave)

  local function OnClick(widget,button)
    editFrame:Show(this)
  end
  this:SetScript("OnClick",OnClick)

  function this:SetItem(_item)
    item= _item
  end

  function this:GetItem()
    return item
  end

  return this
end