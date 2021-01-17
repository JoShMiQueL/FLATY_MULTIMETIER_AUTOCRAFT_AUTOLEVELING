function move()
	while true do
		print(character.cellId())
		global:delay(150)
	end
end

function print(str)
	global:printMessage(str)
end