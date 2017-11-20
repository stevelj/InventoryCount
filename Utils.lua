Utils = {}
function Utils.SetOrHookScript(widget, handle, func)
  if widget:GetScript(handle) then
    widget:HookScript(handle,func)
  else
    widget:SetScript(handle, func)
  end
end