local G_dir, lastPos, lastDir
local A1, A2 = 727595, 798405  -- 5^17=D20*A1+A2
local D20, D40 = 1048576, 1099511627776  -- 2^20, 2^40
local X1, X2 = 0, 1

local Directions = {
	left = "left",
	top = "top",
	right = "right",
	bottom = "bottom",
}
local Map = {}

function move()
    Map:Go(8,-6)
end


function Map:Go(coordX, coordY)
	local currentX, currentY = getMapXY()
	if not self[currentX..','..currentY] then
		self[currentX..','..currentY] = {
		}
		self[currentX..','..currentY].dir = {
			["top"] = true,
			["bottom"] = true,
			["left"] = true,
			["right"] = true
		}
	end

	--print("currentX = "..currentX..", currentY = "..currentY)

	if currentX == coordX and currentY == coordY then
		print("[INFO] Vous etes arriver a destination !")
	else
		local possibleDirections = {}
		local dirX
		local dirY
		if currentX > coordX then -- Gauche
			dirX = Directions.left
			--print("left insert")
		elseif currentX < coordX then -- Droite
			dirX = Directions.right
			--print("right insert")
		end

		if currentY > coordY then -- Monter
			dirY = Directions.top
			--print("top insert")
		elseif currentY < coordY then -- Descendre
			dirY = Directions.bottom
			--print("bottom insert")	
		end

		dirX, dirY = Map:canGoToCoord(dirX, dirY, coordX, coordY)
		table.insert(possibleDirections, dirX)
		table.insert(possibleDirections, dirY)

		TryChangeMap(possibleDirections)
	end

end

function Map:canGoToCoord(tryDirX, tryDirY, coordToGoX, coordToGoY)
	local x, y = getMapXY()
	local tX = math.abs(x) - math.abs(coordToGoX)
	local tY = math.abs(y) - math.abs(coordToGoY)
	local polarityX
	local polarityY
	local nbIterX
	local nbIterY
	local coord
	local dirX, dirY


	if tryDirX == 'right' then
		polarityX = 1
		nbIterX = x + math.abs(tX)
	else
		polarityX = -1
		nbIterX = x - math.abs(tX)
	end

	if tryDirY == 'bottom' then
		polarityY = 1
		nbIterY = y + math.abs(tY)
	else
		polarityY = -1
		nbIterY = y - math.abs(tY)
	end

	for i = x, nbIterX, polarityX do -- Boucle X
		coord = i..','..y
		if tryDirX == nil then
			print('x nil')
			break
		end
		if self[coord] ~= nil then
			print(tostring(self[coord].dir[tryDirX]))
			if not self[coord].dir[tryDirX] then
				print('['..coord..'] X '..tryDirX..' = true')
				dirX = GetOppositeDirection(tryDirX)
			end
		else
			print('Plus de carte a parcourir X')
			dirX = tryDirX
			break
		end
	end

	for i = y, nbIterY, polarityY do -- Boucle Y
		coord = x..','..i
		if tryDirY == nil then
			print('y nil')
			break
		end
		if self[coord] ~= nil then
			print(tostring(self[coord].dir[tryDirY]))
			if not self[coord].dir[tryDirY] then
				print('['..coord..'] Y '..tryDirY..' = true')
				dirY = GetOppositeDirection(tryDirY)
			end
		else
			print('Plus de carte a parcourir Y')
			dirY = tryDirY
			break
		end
	end

	return dirX, dirY
end

function TryChangeMap(possibleDirections, otherDirection)
	local x, y = getMapXY()
	local allDirection = {
		'left',
		'right',
		'bottom',
		'top'
	}
	if possibleDirections == nil then
		possibleDirections = allDirection
	end
	--print('TryChangeMap()')
	local currentPos = map:currentPos()
	local tryDir
	if G_dir ~= nil then
		--DisableDirection(possibleDirections, GetOppositeDirection(G_dir))
		DisableDirection(allDirection, GetOppositeDirection(G_dir))
	end

	if currentPos ~= lastPos then
		lastPos = currentPos
		lastDir = G_dir
	end

	tryDir = GetRandomDirection(possibleDirections)
	G_dir = tryDir

	print(tostring(Map[x..','..y].dir[tryDir]))

	while not(changeMap(tryDir)) do
		Map[x..','..y].dir[tryDir] = false
		DisableDirection(possibleDirections, tryDir)
		DisableDirection(allDirection, tryDir)
		tryDir = GetRandomDirection(possibleDirections)
		if tryDir == nil then
			tryDir = GetRandomDirection(allDirection)
		end
		print("TryChangeMap "..tryDir)
		G_dir = tryDir
	end
end


function changeMap(dir)
	local cellId = character.cellId()
	local dirArray = {
		['left'] = {
			xMin = 0,
			xMax = 15,
			yMin = 10,
			yMax = 450
		},
		['right'] = {
			xMin = 635,
			xMax = 648,
			yMin = 30,
			yMax = 450
		},
		['top'] = {
			xMin = 20,
			xMax = 615,
			yMin = 9,
			yMax = 16
		},
		['bottom'] = {
			xMin = 40,
			xMax = 589,
			yMin = 460,
			yMax = 464
		}
	}

	for kDir, vDir in pairs(dirArray) do
		if kDir == dir then
			local tenta = 0
			local tmpX = math.random(vDir.xMin, vDir.xMax)
			local tmpY = math.random(vDir.yMin, vDir.yMax)

			while tmpX < vDir.xMin and tmpX > vDir.xMax do
				tmpX = math.random(vDir.xMin, vDir.xMax)
			end
			while tmpY < vDir.yMin and tmpY > vDir.yMax do
				tmpY = math.random(vDir.yMin, vDir.yMax)
			end

			--print('kDir = '..kDir)
			--print("xMin : "..vDir.xMin..' xMax : '..vDir.xMax)
			--print("yMin : "..vDir.yMin..' yMax : '..vDir.yMax)

			while tenta < 5 do
				--print("x : "..tmpX..", y : "..tmpY)
				global:clickPosition(tmpX, tmpY)
				tmpX = math.random(vDir.xMin, vDir.xMax)
				tmpY = math.random(vDir.yMin, vDir.yMax)
				while tmpX < vDir.xMin and tmpX > vDir.xMax do
					tmpX = math.random(vDir.xMin, vDir.xMax)
				end
				while tmpY < vDir.yMin and tmpY > vDir.yMax do
					tmpY = math.random(vDir.yMin, vDir.yMax)
				end
				tenta = tenta + 1
				global:delay(250)
				if cellId ~= character.cellId() then
					--print('en mouvement')
					global:delay(10000)
				else
					--print('not mouvement')
					global:delay(50)
				end
			end
		end
	end

	return false
end

function getMapXY()
    local currentPos = tostring(map:currentPos())
    local currentX = tonumber(string.sub(currentPos, 0, string.find(currentPos, ",") - 1))
    local currentY = tonumber(string.sub(currentPos, -3))
	local i = 0

	if currentX == nil then
		--print('currentX = nil')
		currentX = 0
	end

	while currentY == nil do
		--print('currentY = nil')
		if i == 0 then
			currentY = tonumber(string.sub(currentPos, -2))
		elseif i == 1 then
			currentY = tonumber(string.sub(currentPos, -1))
		else
			currentY = 0
		end
		i = i + 1
	end

	return currentX, currentY
end

function print(str)
	global:printMessage(str)
end

function Rand()
	-- print('Rand()')
    local U = X2*A2
    local V = (X1*A2 + X2*A1) % D20
    V = (V*D20 + U) % D40
    X1 = math.floor(V/D20)
    X2 = V - X1*D20
    return V/D40
end

function GetOppositeDirection(dir)
	-- print('GetOppositeDirection()')
	if dir == Directions.left then
		return Directions.right
	elseif dir == Directions.right then
		return Directions.left
	elseif dir == Directions.top then
		return Directions.bottom
	elseif dir == Directions.bottom then
		return Directions.top
	end
	return nil
end

function DisableDirection(dirArray, dir)
	for i, v in ipairs(dirArray) do
		--print("disable v = "..v)
		if v == dir then
			--print(dirArray[i].." removed")
			table.remove(dirArray, i)
		end
	end
end

function GetRandomDirection(dirArray)
	local randomDir = math.floor(Rand()*#dirArray) + 1
	--if #dirArray > 1 then
		--dirArray = shuffleList(dirArray)
	--end
	for i, v in ipairs(dirArray) do
		if i == randomDir then
			print('RandomDirection '..v)
			return v
		end
	end
end

function shuffleList(list)
	newList = {}

	for i = 1, #list do
		e = table.remove(list, math.random(1, #list))
		table.insert(newList, e)
	end

	return newList
end