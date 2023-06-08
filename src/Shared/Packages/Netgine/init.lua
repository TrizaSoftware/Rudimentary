--[[
    _   __     __        _          
   / | / /__  / /_____ _(_)___  ___ 
  /  |/ / _ \/ __/ __ `/ / __ \/ _ \
 / /|  /  __/ /_/ /_/ / / / / /  __/
/_/ |_/\___/\__/\__, /_/_/ /_/\___/ 
               /____/                  
              
Copyright (c): T:Riza Corporation 2020-2023
]]

local RunService = game:GetService("RunService")

return (RunService:IsServer() and require(script.Server) or require(script.Client))