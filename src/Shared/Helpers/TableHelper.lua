local TableHelper = {}

function TableHelper:CloneDeep(tab: {})
  local NewTab = {}

  for property, value in tab do
    if typeof(value) == "table" then
      NewTab[property] = TableHelper:CloneDeep(value)
    else
      NewTab[property] = value
    end
  end

  return NewTab
end

return TableHelper