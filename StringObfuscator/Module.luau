-- F64Obfuscator Module V1.0.1
-- A simple string obfuscation utility, made by AsteriskCodes (@Untyper)

-- This tool uses the buffer library and 64-bit floating-point value conversions
-- Explanations (that i yapped about) are shown in the code...


--[=[ Types in module ]=]

if game then
	export type F64EncodedTable = { [number]: number }
	export type SeparatedTextTable = { [number]: string }
else
	type F64EncodedTable = { [number]: number }
	type SeparatedTextTable = { [number]: string }
end

--[=[ Constants in module ]=]

local Constants = {
	--[[
		(DO NOT CHANGE THE VALUE BELOW; IT WILL BREAK THE MODULE!)
		The "SeparationLength" should always be set to 8, because the functions, "buffer.readf64" and "buffer.write64",
		encodes up to eight characters within a string. If the value is set below 8, the code will error.
		If the value is set above 8, the library will only convert the first eight letters of the string.
		(This is the reason why it is required to separate the text, to encode all of the characters).
	]]
	SeparationLength = 8, -- Value used to divide the text by the number of letters
	--[[
		The "FillerCharacter" is used to fill the last section of the text. If the length of the last section of the text
		is less than eight, then the value will be used to fill it. (It is required to do so because of the 8-character limit
		explained above.)
		
		You can set this to any *string* character that is hopefully not in your original text value.
		(If so, the decoded string will not match the original.)
	]]
	FillerCharacter = string.char(239), -- Value used for filling the last section of the text (�)
}

-- Module
local F64Obfuscator = {}

--[=[ Custom functions used in the module ]=]

-- Divides text by 8 characters.
function SeparateText(text:string):SeparatedTextTable
	local TextTable: SeparatedTextTable = {}
	local TextLength = string.len(text)
	local count = Constants.SeparationLength
	
	local LastRangeX = 1
	local LastRangeY = count
	
	while true do
		if LastRangeY >= TextLength then
			LastRangeY = TextLength
			
			local LastSnippet = string.sub(text, LastRangeX, LastRangeY)
			local SnipLength = string.len(LastSnippet)
			
			for i = 1,(count - SnipLength) do
				LastSnippet = LastSnippet .. Constants.FillerCharacter
			end
			table.insert(TextTable, LastSnippet)
			
			break
		end
		
		local Snippet = string.sub(text, LastRangeX, LastRangeY)
		table.insert(TextTable, Snippet)
		
		LastRangeX = LastRangeY + 1 -- adds 1 with RangeY value (prevents getting the last character from last snippet)
		LastRangeY = LastRangeY + count -- adds the amount (8) to the RangeY value
	end
	
	return TextTable
end

--[=[ Module functions ]=]

-- Encodes text into a table of 64-bit floating-point values, each of them having the divided eight letters of the text.
function F64Obfuscator:F64Encode(value:string):F64EncodedTable
	local EncodedTable: F64EncodedTable = {}
	
	local TextTable = SeparateText(value)
	
	for _,Snippet in pairs(TextTable) do
		local Buffer1 = buffer.fromstring(Snippet)
		local FloatValue = buffer.readf64(Buffer1, 0)
		table.insert(EncodedTable, FloatValue)
	end
	
	return EncodedTable
end


-- Decodes a table of 64-bit floating-point values into a string.
function F64Obfuscator:F64Decode(encodedValue:F64EncodedTable):string
	local count = Constants.SeparationLength
	local DecodedString = "" -- used if method is "string"
	
	for n,FloatValue in pairs(encodedValue) do
		local Buffer2 = buffer.create(count)
		buffer.writef64(Buffer2, 0, FloatValue)
		local Result = buffer.tostring(Buffer2)
		
		if n == #encodedValue then -- if the last text (with the filler text) is selected...
			local FinalText = ""
			local SplittedText = string.split(Result, "")
			
			for _,Letter:string in pairs(SplittedText) do
				-- Below will exclude the filler characters within the last decoded text
				if Letter ~= Constants.FillerCharacter then
					FinalText = FinalText .. Letter
				end
			end
			
			DecodedString = DecodedString .. FinalText
		else
			DecodedString = DecodedString .. Result
		end
	end
	
	return DecodedString
end

return F64Obfuscator
