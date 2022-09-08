--[[== Usage:
	This module supports Documentation Reader by ProbableAI.

	This module is made to mimic the DatastoreService. It's made so it's easily swapable between
	Datastore and Firebase Realtime Database just by adding .GetDatastore().
	Understand how to use DatastoreService and this should look really similar.
	
	The benefits of using FirebaseService is that you can get specific data from within the database JSON hierarchy.
		E.g. Firebase:GetAsync("Profile/Stats/Money");

	FirebaseService FirebaseService
		Functions:
			void FirebaseService:SetUseFirebase(bool);
			Firebase FirebaseService:GetFirebase(string name, string scope);
	
	Firebase Firebase
		Functions:
			GlobalDatastore Firebase.GetDatastore();
			Variant Firebase:GetAsync(string directory);
			void Firebase:SetAsync(string directory, variant value, table header);
			void Firebase:RemoveAsync(string directory);
			number Firebase:IncrementAsync(string directory, number delta);
			void Firebase:UpdateAsync(string directory, function callback);
	
	Please set your database link and authentication token before using it in Configurations.
	
	Enjoy			
	~MXKhronos
--]]
--== Configuration;
local defaultDatabase = ""; -- Set your database link


--== Variables;
local HttpService = game:GetService("HttpService");
local DataStoreService = game:GetService("DataStoreService");

local FirebaseService = {};
local UseFirebase = true;


--== Script;

--[[**
	Sets whether Firebase's data can be updated from server. Data can still be read from realtime Database regardless.
	@param value bool Using Firebase
**--]]
function FirebaseService:SetUseFirebase(value)
	UseFirebase = value and true or false;
end

--[[**
	Sets whether Firebase's data can be updated from server. Data can still be read from realtime Database regardless.
	@param name string Given name of a JSON Object in the Realtime Database.
	@param scope string Optional scope.
	@returns FirebaseService FirebaseService
**--]]
function FirebaseService:GetFirebase(name, database, authenticationToken)
	database = database or defaultDatabase;
	local datastore = DataStoreService:GetDataStore(name);
	
	local databaseName = database..HttpService:UrlEncode(name);
	local authentication = ".json?auth="..authenticationToken;
	
	local Firebase = {};
	
	--[[**
		A method to get a datastore with the same name and scope.
		@returns GlobalDataStore GlobalDataStore
	**--]]
	function Firebase.GetDatastore()
		return datastore;
	end
	
	--[[**
		Returns the value of the entry in the database JSON Object with the given key.
		@param directory string Directory of the value that you are look for. E.g. "PlayerSaves" or "PlayerSaves/Stats".
		@returns FirebaseService FirebaseService
	**--]]
	function Firebase:GetAsync(directory)
		local data = nil;
		
		--== Firebase Get;
		local getTick = tick();
		local tries = 0; repeat until pcall(function() tries = tries +1;
			data = HttpService:GetAsync(databaseName..HttpService:UrlEncode(directory and "/"..directory or "")..authentication, true);
		end) or tries > 2;
		if type(data) == "string" then
			if data:sub(1,1) == '"' then
				return data:sub(2, data:len()-1);
			elseif data:len() <= 0 then
				return nil;
			end
		end
		return tonumber(data) or data ~= "null" and data or nil;
	end
	
	--[[**
		Sets the value of the key. This overwrites any existing data stored in the key.
		@param directory string Directory of the value that you are look for. E.g. "PlayerSaves" or "PlayerSaves/Stats".
		@param value variant Value can be any basic data types. It's recommened you HttpService:JSONEncode() your values before passing it through.
		@param header table Optional HTTPRequest Header overwrite. Default is {["X-HTTP-Method-Override"]="PUT"}.
	**--]]
	function Firebase:SetAsync(directory, value, header)
		if not UseFirebase then return end
		if value == "[]" then self:RemoveAsync(directory); return end;
		
		--== Firebase Set;
		header = header or {["X-HTTP-Method-Override"]="PUT"};
		local replyJson = "";
		if type(value) == "string" and value:len() >= 1 and value:sub(1,1) ~= "{" and value:sub(1,1) ~= "[" then
			value = '"'..value..'"';
		end
		local success, errorMessage = pcall(function()
		replyJson = HttpService:PostAsync(databaseName..HttpService:UrlEncode(directory and "/"..directory or "")..authentication, value,
			Enum.HttpContentType.ApplicationUrlEncoded, false, header);
		end);
		if not success then
			warn("FirebaseService>> [ERROR] "..errorMessage);
			pcall(function()
				replyJson = HttpService:JSONDecode(replyJson or "[]");
			end)
		end
	end
	
	--[[**
		Removes the given key from the data store and returns the value associated with that key.
		@param directory string Directory of the value that you are look for. E.g. "PlayerSaves" or "PlayerSaves/Stats".
	**--]]
	function Firebase:RemoveAsync(directory)
		if not UseFirebase then return end
		self:SetAsync(directory, "", {["X-HTTP-Method-Override"]="DELETE"});
	end
	
	--[[**
		Increments the value of a particular key and returns the incremented value.
		@param directory string Directory of the value that you are look for. E.g. "PlayerSaves" or "PlayerSaves/Stats".
		@param delta number The incrementation rate.
	**--]]
	function Firebase:IncrementAsync(directory, delta)
		delta = delta or 1;
		if type(delta) ~= "number" then warn("FirebaseService>> increment delta is not a number for key ("..directory.."), delta(",delta,")"); return end;
		local data = self:GetAsync(directory) or 0;
		if data and type(data) == "number" then
			data = data+delta;
			self:SetAsync(directory, data);
		else
			warn("FirebaseService>> Invalid data type to increment for key ("..directory..")");
		end
		return data;
	end
	
	--[[**
		Retrieves the value of a key from a data store and updates it with a new value.
		@param directory string Directory of the value that you are look for. E.g. "PlayerSaves" or "PlayerSaves/Stats".
		@param callback function Works similarly to Roblox's GlobalDatastore:UpdateAsync().
	**--]]
	function Firebase:UpdateAsync(directory, callback)
		local data = self:GetAsync(directory);
		local callbackData = callback(data);
		if callbackData then
			self:SetAsync(directory, callbackData);
		end
	end
	
	return Firebase;
end

return FirebaseService;