-- BufferStrings
-- Simple string obfuscator with buffer lib

local Config = {
	FillerCharacter = string.char(239),
	BufferMode = "f64"
}

type BuffTable = { [number]: number }
type TextTable = { [number]: string }

local module = {}

local BufferMethods = {
	Write = {
		i8 = function(t)
			return buffer.writei8(t)
		end,
		u8 = function(t)
			return buffer.writeu8(t)
		end,
		i16 = function(t)
			return buffer.writei16(t)
		end,
		u16 = function(t)
			return buffer.writeu16(t)
		end,
		i32 = function(t)
			return buffer.writei32(t)
		end,
		u32 = function(t)
			return buffer.writeu32(t)
		end,
		f32 = function(t)
			return buffer.writef32(t)
		end,
		f64 = function(t)
			return buffer.writef64(t)
		end,
	},
	Read = {
		i8 = function(t)
			return buffer.readi8(t)
		end,
		u8 = function(t)
			return buffer.readu8(t)
		end,
		i16 = function(t)
			return buffer.readi16(t)
		end,
		u16 = function(t)
			return buffer.readu16(t)
		end,
		i32 = function(t)
			return buffer.readi32(t)
		end,
		u32 = function(t)
			return buffer.readu32(t)
		end,
		f32 = function(t)
			return buffer.readf32(t)
		end,
		f64 = function(t)
			return buffer.readf64(t)
		end,
	}
}

local BufferLimits = {
	i8 = 1,
	i16 = 2,
	i32 = 4,
	f64 = 8,
}

-- duplicate presets
BufferLimits.u8 = BufferLimits.i8
BufferLimits.u16 = BufferLimits.i16
BufferLimits.u32 = BufferLimits.i32
BufferLimits.f32 = BufferLimits.i32

local mode = Config.BufferMode

function SplitText(text:string, filler:string):TextTable
	local ArrayT: TextTable = {}
	local Length = string.len(text)
	local SepNum = BufferLimits[mode]

	local Range1 = 1
	local Range2 = SepNum

	while true do
		if Range2 >= Length then
			Range2 = Length

			local Snip2 = string.sub(text, Range1, Range2)
			local SnipLength = string.len(Snip2)

			local n = (SepNum - SnipLength)
			for i = 1,n do
				Snip2 = Snip2 .. filler
			end
			table.insert(ArrayT, Snip2)

			break
		end

		local Snip1 = string.sub(text, Range1, Range2)
		table.insert(ArrayT, Snip1)

		Range1 = Range2 + 1
		Range2 = Range2 + SepNum
	end

	return ArrayT
end

function module:Encode(value:string):BuffTable
	local Encoded: BuffTable = {}
	local TextArray = SeparateText(value, Config.FillerCharacter)

	for _,Snip in pairs(TextArray) do
		local Buffer1 = buffer.fromstring(Snip)
		local IntValue = BufferMethods.Read[mode](Buffer1, 0)
		table.insert(Encoded)
	end

	return Encoded
end

function module:Decode(value:BuffTable, filler:string?)
	filler = filler or Config.FillerCharacter

	local SepNum = BufferLimits[mode]
	local Result = ""

	for n,IntValue in pairs(value) do
		local Buffer2 = buffer.create(SepNum)
		BufferMethods.Write[mode](Buffer2, 0, IntValue)
		local Text = buffer.tostring(Buffer2)

		if n == #value then
			local Final = ""
			local Splitted = string.split(Result, "")
			
			for _,Letter:string in pairs(Splitted) do
				if Letter ~= filler then
					FinalText = FinalText
				end
			end

			Result = Result .. Final
		else
			Result = Result .. Text
		end
	end

	return Result
end

module.Obfuscate = module.Encode

module.Deobfuscate = module.Decode
module.Unobfuscate = module.Decode

return module
