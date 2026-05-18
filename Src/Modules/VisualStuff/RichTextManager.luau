--!nocheck

-- // bocchirockssss 19/02/2025 (DD/MM/YY)

-- // This Code is extracted from:
-- // https://devforum.roblox.com/t/v3-huge-update-textmodule-handle-every-text-features-easily/2200604
-- // ^ Cool Module btw, make sure to check it out.

return function(Table: { string? })
	local Text = Table[1]
	local Settings = {
		Color = { "", [[color="]], [[" ]] },
		Size = { "", [[size="]], [[" ]] },
		Face = { "", [[face="]], [[" ]] },
		Weight = { "", [[weight="]], [[" ]] },
		Transparency = { "", [[transparency="]], [[" ]] },
		Stroke = { [[transparency="1" ]], [[color="]], [[joins="]], [[thickness="]], [[transparency="]], [[" ]] },
	}
	local Special = {
		Bold = { "", "", [[<b>]], [[</b>]] },
		Italic = { "", "", [[<i>]], [[</i>]] },
		Underlined = { "", "", [[<u>]], [[</u>]] },
		Strikethrough = { "", "", [[<s>]], [[</s>]] },
		Uppercase = { "", "", [[<uc>]], [[</uc>]] },
		Smallcaps = { "", "", [[<sc>]], [[</sc>]] },
		Break = { "", [[<br />]] },
	}

	for Key, Value in Settings do
		if Table[Key] and not (tostring(Key) == "Stroke") then
			Value[1] = Value[2] .. Table[Key] .. Value[3]
		elseif Table[Key] and (tostring(Key) == "Stroke") then
			local StrokeColor = Value[2] .. Table[Key][1] .. Value[6]
			local StrokeJoins = Value[3] .. Table[Key][2] .. Value[6]
			local StrokeThickness = Value[4] .. Table[Key][3] .. Value[6]
			local StrokeTransparency = Value[5] .. Table[Key][4] .. Value[6]

			Value[1] = StrokeColor .. StrokeJoins .. StrokeThickness .. StrokeTransparency
		end
	end

	for Key, Value in Special do
		if Table[Key] and Table[Key] == true and not (tostring(Key) == "Break") then
			Value[1] = Value[3]
			Value[2] = Value[4]
		elseif Table[Key] and Table[Key] == true and (tostring(Key) == "Break") then
			Value[1] = Value[2]
		end
	end

	local SpecialTextStart = Special.Bold[1]
		.. Special.Italic[1]
		.. Special.Underlined[1]
		.. Special.Strikethrough[1]
		.. Special.Uppercase[1]
		.. Special.Smallcaps[1]
	local SpecialTextEnd = Special.Smallcaps[2]
		.. Special.Uppercase[2]
		.. Special.Strikethrough[2]
		.. Special.Underlined[2]
		.. Special.Italic[2]
		.. Special.Bold[2]
	local SettingsText = Settings.Color[1]
		.. Settings.Size[1]
		.. Settings.Face[1]
		.. Settings.Weight[1]
		.. Settings.Transparency[1]
	return SpecialTextStart
		.. [[ <font ]]
		.. SettingsText
		.. [[>]]
		.. [[<stroke ]]
		.. Settings.Stroke[1]
		.. [[>]]
		.. Special.Break[1]
		.. Text
		.. [[</stroke> ]]
		.. [[</font>]]
		.. SpecialTextEnd
end
