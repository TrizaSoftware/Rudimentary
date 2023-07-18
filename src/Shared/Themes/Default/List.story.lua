local List = require(script.Parent.List)

return function (target: Instance)
  local TestList = List {
    Title = "Test",
    Parent = target
  }

  return function ()
    TestList:Destroy()
  end
end