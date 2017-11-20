ICEditFrame = {}
function ICEditFrame:New(parent)

  local this = CreateFrame("Frame",nil,parent,"ThinBorderTemplate")
  local frame = nil
  this:SetSize(275, 25)
  this:Hide()
  
  local label = this:CreateFontString(nil,"ARTWORK","ChatFontNormal")
  label:SetPoint("TOPLEFT",5,-5)

  local edit = CreateFrame("EditBox",nil, this, "InputBoxTemplate")
  edit:SetPoint("LEFT", label, "RIGHT", 15, 0)
  edit:SetSize(50,20)
  edit:SetMaxLetters(5)
  edit:SetFontObject("ChatFontNormal");
  edit:SetNumeric(true)

  local cancel = CreateFrame("Button", nil, this, "UIPanelButtonGrayTemplate")
  cancel:SetText("Cancel")
  cancel:SetSize(50,20)
  cancel:SetPoint("RIGHT", -15,0)


  local ok = CreateFrame("Button", nil, this, "UIPanelButtonGrayTemplate")
  ok:SetText("OK")
  ok:SetSize(25,20)
  ok:SetPoint("RIGHT", cancel, "LEFT", -15,0)

  local function Reset()
    frame = nil
    this:Hide()
  end
  
  cancel:SetScript("OnClick", Reset)
  
  local function Apply()
    local item = frame:GetItem();
    item.limit = edit:GetNumber()
    frame:Update()
    InvC:LimitUpdate(item)
    Reset()
  end

  ok:SetScript("OnClick", Apply)
  
  local super = this.Show

  function this:Show(_frame)
    frame = _frame
    label:SetText(frame:GetItem().name)
    edit:SetNumber(frame:GetItem().limit)
    this:SetPoint("BOTTOMLEFT",this:GetParent(),"TOPLEFT")
    super(this)
  end
    
  return this
end