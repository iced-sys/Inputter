local TableUtil = require(script.Parent.Parent.TableUtil)
local HttpService = game:GetService("HttpService")

local Serializer = {}

local function serializeEnums(tbl: any): boolean
	if type(tbl) ~= "table" then
		return false
	end
	for key, value in pairs(tbl) do
		if type(value) == "table" then
			if not serializeEnums(value) then
				return false
			end
		elseif type(value) == "function" or type(value) == "userdata" then
			tbl[key] = tostring(value)
		end
	end
	return true
end

local function deserializeEnums(tbl: any): boolean
	if type(tbl) ~= "table" then
		return false
	end
	for key, value in pairs(tbl) do
		if type(value) == "table" then
			if not deserializeEnums(value) then
				return false
			end
		elseif type(value) == "string" and value:match("^Enum%.") then
			local rootEnums = Enum:GetEnums()
			for _, enum: Enum in pairs(rootEnums) do
				for _, enumItem in pairs(enum:GetEnumItems()) do
					if tostring(enumItem) == value then
						tbl[key] = enumItem
						break
					end
				end
			end
		end
	end
	return true
end

Serializer.encode = function(tbl: any): string
	tbl = TableUtil.Copy(tbl, true)
	serializeEnums(tbl)
	return HttpService:JSONEncode(tbl)
end

Serializer.decode = function(json: string): any
	local tbl = HttpService:JSONDecode(json)
	if not deserializeEnums(tbl) then
		error("Failed to deserialize enums in JSON: " .. json)
	end
	return tbl
end

return Serializer
