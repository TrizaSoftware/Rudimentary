local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Player = Players.LocalPlayer

local function getTimeOfDayString()
  local dateTime = DateTime.now():ToLocalTime()
  local hour = dateTime.Hour

  if hour < 12 then
    return "Morning"
  elseif hour < 16 then
    return "Afternoon"
  else
    return "Evening"
  end
end

return function (Client)
  local CategoryTemplate = Client.UI:GetFolderForElement("CategoryTemplate").CategoryTemplate
  local CategoryItemTemplate = Client.UI:GetFolderForElement("CategoryItemTemplate").CategoryItemTemplate

  Client.Panel.General.ScrollingFrame.MainFrame.Username.Text = string.format("Good <b>%s</b>, %s"
  ,getTimeOfDayString()
  ,if Player.Name ~= Player.DisplayName then string.format("%s (@%s)", Player.DisplayName, Player.Name) else Player.Name
  )

  Client.Panel.General.ScrollingFrame.MainFrame.AdminLevel.Text = string.format("You're %s <b>%s</b>", Client.Utils.anOrA(Client.Data.AdminLevelName), Client.Data.AdminLevelName)

  local GameInfoCategory = CategoryTemplate:Clone()
  GameInfoCategory.CategoryName.Text = "Game Info"
  GameInfoCategory.Parent = Client.Panel.General.ScrollingFrame
  GameInfoCategory.Visible = true

  local PlaceNamePanel = CategoryItemTemplate:Clone()
  PlaceNamePanel.Icon.Image = string.format("rbxassetid://%s", Client.Icons.Home)
  PlaceNamePanel.CategoryItemName.Text = "Name"
  PlaceNamePanel.Value.Text = MarketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Asset).Name
  PlaceNamePanel.Parent = GameInfoCategory.ScrollingFrame
  PlaceNamePanel.Visible = true

  local ServerUptimePanel = CategoryItemTemplate:Clone()
  ServerUptimePanel.Icon.Image = string.format("rbxassetid://%s", Client.Icons.Schedule)
  ServerUptimePanel.CategoryItemName.Text = "Server Age"
  ServerUptimePanel.Parent = GameInfoCategory.ScrollingFrame
  ServerUptimePanel.Visible = true

  local ServerRegionPanel = CategoryItemTemplate:Clone()
  ServerRegionPanel.Icon.Image = string.format("rbxassetid://%s", Client.Icons.Map)
  ServerRegionPanel.CategoryItemName.Text = "Server Region"
  ServerRegionPanel.Value.Text = Client.Data.ServerRegion
  ServerRegionPanel.Parent = GameInfoCategory.ScrollingFrame
  ServerRegionPanel.Visible = true

  local ServerPlayersPanel = CategoryItemTemplate:Clone()
  ServerPlayersPanel.Icon.Image = string.format("rbxassetid://%s", Client.Icons.People)
  ServerPlayersPanel.CategoryItemName.Text = "Players In Server"
  ServerPlayersPanel.Value.Text = #Players:GetPlayers()
  ServerPlayersPanel.Parent = GameInfoCategory.ScrollingFrame
  ServerPlayersPanel.Visible = true

  local ServerAdminsPanel = CategoryItemTemplate:Clone()
  ServerAdminsPanel.Icon.Image = string.format("rbxassetid://%s", Client.Icons.Admin_panel_settings)
  ServerAdminsPanel.CategoryItemName.Text = "Admins In Server"
  ServerAdminsPanel.Value.Text = Client.Data.InGameAdmins
  ServerAdminsPanel.Parent = GameInfoCategory.ScrollingFrame
  ServerAdminsPanel.Visible = true


  task.spawn(function()
    while task.wait() do
      ServerUptimePanel.Value.Text = Client.Utils.formatTimeFromSeconds(workspace.DistributedGameTime)
    end
  end)

  Players.PlayerAdded:Connect(function()
    ServerPlayersPanel.Value.Text = #Players:GetPlayers()
  end)

  Players.ChildRemoved:Connect(function()
    ServerPlayersPanel.Value.Text = #Players:GetPlayers()
  end)

  local SystemInfoCategory = CategoryTemplate:Clone()
  SystemInfoCategory.CategoryName.Text = "System Info"
  SystemInfoCategory.Parent = Client.Panel.General.ScrollingFrame
  SystemInfoCategory.Visible = true

  local SystemVersionPanel = CategoryItemTemplate:Clone()
  SystemVersionPanel.Icon.Image = string.format("rbxassetid://%s", Client.Icons.Verified)
  SystemVersionPanel.CategoryItemName.Text = "Version"
  SystemVersionPanel.Value.Text = Client.Data.Version
  SystemVersionPanel.Parent = SystemInfoCategory.ScrollingFrame
  SystemVersionPanel.Visible = true

  local LatestVersionPanel = CategoryItemTemplate:Clone()
  LatestVersionPanel.Icon.Image = string.format("rbxassetid://%s", Client.Icons.Calendar)
  LatestVersionPanel.CategoryItemName.Text = "Latest Version"
  LatestVersionPanel.Value.Text = Client.Data.LatestVersion
  LatestVersionPanel.Parent = SystemInfoCategory.ScrollingFrame
  LatestVersionPanel.Visible = true

  Client.API.ListenForEvent("changeData", function(settingName, newValue)
    if settingName == "InGameAdmins" then
      ServerAdminsPanel.Value.Text = newValue
    elseif settingName == "LatestVersion" then
      LatestVersionPanel.Value.Text = newValue
    end
  end)

  local thumbnail = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
  Client.Panel.General.ScrollingFrame.MainFrame.Icon.Image = thumbnail
  
  local self = {}

  return self
end