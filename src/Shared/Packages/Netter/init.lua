--[[
    _   __     __  __           
   / | / /__  / /_/ /____  _____
  /  |/ / _ \/ __/ __/ _ \/ ___/
 / /|  /  __/ /_/ /_/  __/ /    
/_/ |_/\___/\__/\__/\___/_/     
              
Copyright (c): T:Riza Corporation 2020-2023
]]

local RunService = game:GetService("RunService")

return (RunService:IsServer() and require(script.Server) or require(script.Client))