--[[

  _______   __     __ 
 /_  __/ | / /__  / /_
  / / /  |/ / _ \/ __/
 / / / /|  /  __/ /_  
/_/ /_/ |_/\___/\__/  
                      

Programmer(s): CodedJimmy

Copyright(c): T:Riza Corporation 2020-2022

]]

local RunService = game:GetService("RunService")

if RunService:IsServer() then
    return require(script.Server)
else
    return require(script.Client)
end