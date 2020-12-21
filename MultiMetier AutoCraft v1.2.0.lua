-- */ Base script for FlatyBot \*

-- USER VAR
    local AUTO_OPEN_BAG = true -- Active ou desactive l'ouverture auto des sac de ressources
    local AUTO_CRAFT = true -- Active ou desactive l'automatisation des craft
    local DEPOT_MAISON = false -- Pour activer le retourMaison mettre sur true et modifier les fonctions retourMaison et maison ligne 444 et 467
    local GATHER_ALL_RESOURCES_OF_JOB = true -- Si true recolte toutes les ressources du metier actuelle, sinon c'est en fonction des parametre de SELECT_OPTIONS_STOCK_ITEM 
    local PNJ_BANK = "left" -- right/left choisi le pnj dans la banque d'astrub left hiboux blanc, right hiboux noir

    local FRIGOST1 = false -- A activer si vous avez fait les donjon RM/MR (débloque la mine maksage + les 2 mines a sakai)
    local FRIGOST2 = false -- A activer si vous avez fait le donjon BEN (débloque une mine)
    local FRIGOST3 = false -- A activer si vous avez fait le donjon OBSI // Ne pas allez plus loin que fri3
    local SAHARACH = false -- Mettre true pour activer Saharach sinon mettre false
    local PANDALA = false -- Mettre true pour activer Pandala sinon mettre false
    local OTOMAI = false -- BUG

    local timeZoneMode = false -- Si true changement de zone par le temps passez, si false changement de zone par boucle
    local bMin = 2 -- Nombre de boucle mini a faire dans une zone avant changement de zone
    local bMax = 5 -- Nombre de boucle maxi a faire dans une zone avant changement de zone
    local tMin = 13 -- Temps mini a faire dans une zone avant changement de zone ( en minutes )
    local tMax = 17 -- Temps maxi a faire dans une zone avant changement de zone ( en minutes )

    local gatherAttemptByMap = 2 -- Tentative de récolte par map avant de changer de map (uniquement pour mineur pour l'instant)
    local delayToRetryGather = 500 -- Delais entre les tentative de récolte Mini 500 (en ms)
    -- fight option

    local focus = 1

-- GLOBAL VAR FLATYBOT

    MAX_PODS = 90
    ELEMENTS_TO_GATHER = {}

    FORBIDDEN_MONSTERS = {}
    MANDATORY_MONSTERS = {}

    MIN_MONSTERS = 1
    MAX_MONSTERS = 8

-- SCRIPT VAR

    local smallDelay, baseDelay, mediumDelay, longDelay, veryLongDelay = 100, 500, 1000, 2500, 5000
    local nbBoucle = 0
    local tmpIndex = 0
    local idZaapi, idTransporteur = nil , nil
    local heure, minute, lastMinute = nil, nil, 100
    local initTime, diffTime, lastGoodTime, tmpTime = 0, 0, 0, 0
    local initScript, oneHourPassed, timeInit = false, false, false
    local teleported, checkRessource, goCheckStock, goCraft, messageBank = false, false, false, false, false
    local currentJob, currentIdJob, currentMapId, currentMode, lastCurrentMode, toolCraft, pathIndex, lastNameZone, beforeLastNameZone, tbLimit = nil, nil, nil, nil, nil, nil, nil, nil, nil
    local iBoucleCraft, currentLevelCharacter, startLevelCharacter = 0, 0, 0
    local tmpAutoCraft, started, resetLoop = false, false, false
    local ZoneToFarm =  ""
    local totalXp, totalFight, lastXpGain = 0, 0, 0
    local lastItag, lastIcraft=  0, 0
    local totalGather, lastTotalGather = 0, 0



-- Lmoony VAR

    local Directions = {
	    left = "left",
	    top = "top",
	    right = "right",
	    bottom = "bottom",
    }

    local G_countFights = 0
    local G_dir
    local A1, A2 = 727595, 798405  -- 5^17=D20*A1+A2
    local D20, D40 = 1048576, 1099511627776  -- 2^20, 2^40
    local X1, X2 = 0, 1

-- TOM LA VACHETTE VAR

    MULTIPLE_MAP = {}
    MULTIPLE_MAP.CurrentSteps = {}

-- SCRIPT TABLE
    local PATH_FILTERED = {}

    local FIGHT_FILTERED = {}

    local CRAFT_FILTERED = {}

    local TESTED_CRAFT = {}

	local WORKTIME = {
		{
			job = "mineur",
			debut = "01:24",
			fin = "04:59"
		},
		{
			job = "alchimiste",
			debut = "04:59",
			fin = "07:32"
		},
		{
			job = "bucheron",
			debut = "07:32",
			fin = "10:23"
		},
		{
			job = "mineur",
			debut = "10:23",
			fin = "13:10"
		},
		{
			job = "alchimiste",
			debut = "13:10",
			fin = "15:14"
		},
		{
			job = "bucheron",
			debut = "15:14",
			fin = "17:42"
		},
		{
			job = "mineur",
			debut = "17:42",
			fin = "19:00"
		},
		{
			job = "alchimiste",
			debut = "19:00",
			fin = "22:26"
		},
		{
			job = "bucheron",
			debut = "22:26",
			fin = "01:24"
		},

	}

    local CRAFT = {
        ["paysan"] = {
            {
                name = "Pain d'incarnam",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 10,
                toolCraft = "four",
                minLevel = 1,
                idItem = 468,
                weight = 2,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Ble", nbIng = 4, idItem = 289, job = "paysan" },
                }
            },
            {
                name = "Michette",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 20,
                toolCraft = "four",
                minLevel = 10,
                idItem = 521,
                weight = 10,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Ble", nbIng = 5, idItem = 289, job = "paysan" },
                }            
            },
            {  
                name = "Carasau",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 30,
                toolCraft = "four",
                minLevel = 20,
                idItem = 528,
                weight = 9,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Orge", nbIng = 4, idItem = 400, job = "paysan" },
                    { name = "Ortie", nbIng = 1, idItem = 421 },
                }            
            },
            {  
                name = "Fougasse",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 40,
                toolCraft = "four",
                minLevel = 30,
                idItem = 524,
                weight = 11,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Orge", nbIng = 5, idItem = 400, job = "paysan" },
                    { name = "Ortie", nbIng = 1, idItem = 421 },
                }            
            },
            {  
                name = "Pain d'avoine",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 60,
                toolCraft = "four",
                minLevel = 40,
                idItem = 524,
                weight = 12,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Avoine", nbIng = 5, idItem = 533, job = "paysan" },
                    { name = "Aubergine", nbIng = 1, idItem = 2331, job = "divers" },
                    { name = "Sauge", nbIng = 1, idItem = 428 },
                }            
            },
            {  
                name = "Briochette",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 70,
                toolCraft = "four",
                minLevel = 60,
                idItem = 2024,
                weight = 12,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Houblon", nbIng = 5, idItem = 401, job = "paysan" },
                    { name = "Cendre eternelle", nbIng = 1, idItem = 1984, job = "divers" },
                    { name = "Trefle a 5 feuille", nbIng = 1, idItem = 395 },
                }            
            },
            {  
                name = "Pain consistant",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 80,
                toolCraft = "four",
                minLevel = 70,
                idItem = 692,
                weight = 12,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Houblon", nbIng = 5, idItem = 401, job = "paysan" },
                    { name = "Cerise", nbIng = 1, idItem = 1734, job = "divers" },
                    { name = "Trefle a 5 feuille", nbIng = 1, idItem = 395 },
                }            
            },
            {  
                name = "Biscotte",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 90,
                toolCraft = "four",
                minLevel = 80,
                idItem = 522,
                weight = 12,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Lin", nbIng = 5, idItem = 423, job = "paysan" },
                    { name = "Sang de scorbute", nbIng = 1, idItem = 2012, job = "divers" },
                    { name = "Menthe sauvage", nbIng = 1, idItem = 380 },
                }            
            },
            {  
                name = "Pain d'epices",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 100,
                toolCraft = "four",
                minLevel = 90,
                idItem = 16432,
                weight = 12,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Lin", nbIng = 5, idItem = 423, job = "paysan" },
                    { name = "Epices", nbIng = 1, idItem = 1977, job = "divers" },
                    { name = "Menthe sauvage", nbIng = 1, idItem = 380 },
                }            
            },
            {  
                name = "Pain de seigle",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 110,
                toolCraft = "four",
                minLevel = 100,
                idItem = 539,
                weight = 14,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Seigle", nbIng = 6, idItem = 532, job = "paysan" },
                    { name = "Eau potable", nbIng = 1, idItem = 532, job = "divers" },
                    { name = "Orchidee freyesque", nbIng = 1, idItem = 593 },
                }            
            },
            {  
                name = "Gaufre",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 110,
                toolCraft = "four",
                minLevel = 100,
                idItem = 16433,
                weight = 12,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Riz", nbIng = 6, idItem = 7018, job = "paysan" },
                    { name = "Eau potable", nbIng = 1, idItem = 532, job = "divers" },
                    { name = "Orchidee freyesque", nbIng = 1, idItem = 593 },
                }            
            },
        },
        ["alchimiste"] = {
            {
                name = "Potion de mini soin",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 10,
                minLevel = 1,
                idItem = 1182,
                weight = 4,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Ortie", nbIng = 4, idItem = 421, job = "alchimiste" },
                }
            },
            {
                name = "Potion de rappel",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 20,
                minLevel = 10,
                idItem = 548,
                weight = 5,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Sauge", nbIng = 4, idItem = 428, job = "alchimiste" },
                    { name = "Eau potable", nbIng = 1, idItem = 311, job = "divers" },
                }
            },
            {
                name = "Potion raide mhor",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 20,
                minLevel = 10,
                idItem = 16402,
                weight = 5,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Ortie", nbIng = 5, idItem = 421, job = "alchimiste" },
                }
            },
            {
                name = "Potion de mini soin superieur",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 30,
                minLevel = 20,
                idItem = 1183,
                weight = 7,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Sauge", nbIng = 4, idItem = 428, job = "alchimiste" },
                    { name = "Ble", nbIng = 1, idItem = 289 },
                }
            },
            {
                name = "Potion de souvenir",
                lot = nil,
                nbItemsBeforeNextCraft = 500,
                active = true,
                lvlToDesactive = 201,
                minLevel = 30,
                idItem = 7652,
                weight = 30,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Sauge", nbIng = 10, idItem = 428, job = "alchimiste" },
                    { name = "Ortie", nbIng = 20, idItem = 421, job = "alchimiste" },
                }
            },
            {
                name = "Potion de soin",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 50,
                minLevel = 40,
                idItem = 283,
                weight = 30,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Trefle a 5 feuille", nbIng = 5, idItem = 395, job = "alchimiste" },
                    { name = "Oignon", nbIng = 1, idItem = 1975, job = "divers" },
                    { name = "Orge", nbIng = 1, idItem = 400 },
                }
            },
            {
                name = "Potion ghetto raide",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 60,
                minLevel = 50,
                idItem = 580,
                weight = 8,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Trefle a 5 feuille", nbIng = 5, idItem = 395, job = "alchimiste" },
                    { name = "Graisse gelatineuse", nbIng = 1, idItem = 1983, job = "divers" },
                    { name = "Orge", nbIng = 1, idItem = 400 },
                }
            },
            {
                name = "Potion de soin superieure",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 70,
                minLevel = 60,
                idItem = 1183,
                weight = 8,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Menthe sauvage", nbIng = 5, idItem = 380, job = "alchimiste" },
                    { name = "Dose de jus goutus", nbIng = 1, idItem = 1731, job = "divers" },
                    { name = "Avoine", nbIng = 1, idItem = 533 },
                }
            },
            {
                name = "Potion pahoa raide",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 80,
                minLevel = 70,
                idItem = 1712,
                weight = 8,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Menthe sauvage", nbIng = 5, idItem = 380, job = "alchimiste" },
                    { name = "Aubergine", nbIng = 1, idItem = 2331, job = "divers" },
                    { name = "Avoine", nbIng = 1, idItem = 533 },
                }
            },
            {
                name = "Potion eau de fee",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 90,
                minLevel = 80,
                idItem = 1405,
                weight = 8,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Orchidee freyesque", nbIng = 5, idItem = 593, job = "alchimiste" },
                    { name = "Haricot", nbIng = 1, idItem = 6671, job = "divers" },
                    { name = "Houblon", nbIng = 1, idItem = 401 },
                }
            },
            {
                name = "Potion raide boule",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 100,
                minLevel = 90,
                idItem = 1713,
                weight = 8,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Orchidee freyesque", nbIng = 5, idItem = 593, job = "alchimiste" },
                    { name = "Cendre eternelle", nbIng = 1, idItem = 1984, job = "divers" },
                    { name = "Houblon", nbIng = 1, idItem = 401 },
                }
            },
            {
                name = "Sang de likrone",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 110,
                minLevel = 100,
                idItem = 1406,
                weight = 9,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Cerise", nbIng = 1, idItem = 1734, job = "divers" },
                    { name = "Edelweiss", nbIng = 6, idItem = 594, job = "alchimiste" },
                    { name = "Lin", nbIng = 1, idItem = 423 },
                }
            },
            {
                name = "Potion jeud raide",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 120,
                minLevel = 110,
                idItem = 16409,
                weight = 9,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Edelweiss", nbIng = 6, idItem = 594, job = "alchimiste" },
                    { name = "Sang de scorbute", nbIng = 1, idItem = 2012, job = "divers" },
                    { name = "Lin", nbIng = 1, idItem = 423 },
                }
            },
            {
                name = "Sang de trooll",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 130,
                minLevel = 120,
                idItem = 16410,
                weight = 9,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Graine de pandouille", nbIng = 6, idItem = 7059, job = "alchimiste" },
                    { name = "Epices", nbIng = 1, idItem = 1977, job = "divers" },
                    { name = "Seigle", nbIng = 1, idItem = 532 },
                }
            },
            {
                name = "Potion raide emption",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 140,
                minLevel = 130,
                idItem = 16412,
                weight = 9,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Graine de pandouille", nbIng = 6, idItem = 7059, job = "alchimiste" },
                    { name = "Eau potable", nbIng = 1, idItem = 311, job = "divers" },
                    { name = "Seigle", nbIng = 1, idItem = 532 },
                }
            },
            {
                name = "Potion des ancetre",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 200,
                minLevel = 135,
                idItem = 16419,
                weight = 60,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Malt", nbIng = 10, idItem = 405 },
                    { name = "Seigle", nbIng = 10, idItem = 532 },
                }
            },
            {
                name = "Potion bulbique",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 150,
                minLevel = 140,
                idItem = 16419,
                weight = 9,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Poudre de perlinpainpain", nbIng = 1, idItem = 519, job = "divers" },
                    { name = "Ginseng", nbIng = 6, idItem = 16385, job = "alchimiste" },
                    { name = "Malt", nbIng = 1, idItem = 405 },
                }
            },
            {
                name = "Potion raide izdaide",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 160,
                minLevel = 150,
                idItem = 16414,
                weight = 9,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Ginseng", nbIng = 6, idItem = 16385, job = "alchimiste" },
                    { name = "Poude temporelle", nbIng = 1, idItem = 1986, job = "divers" },
                    { name = "Malt", nbIng = 1, idItem = 405 },
                }
            },
            {
                name = "Larme d'eniripsa",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 170,
                minLevel = 160,
                idItem = 16415,
                weight = 12,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Belladone", nbIng = 7, idItem = 16387, job = "alchimiste" },
                    { name = "Resine", nbIng = 1, idItem = 1985, job = "divers" },
                    { name = "Chanvre", nbIng = 2, idItem = 425 },
                }
            },
            {
                name = "Potion axel raide",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 180,
                minLevel = 170,
                idItem = 16722,
                weight = 12,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Belladone", nbIng = 7, idItem = 16387, job = "alchimiste" },
                    { name = "Mesure de sel", nbIng = 1, idItem = 1730, job = "divers" },
                    { name = "Chanvre", nbIng = 2, idItem = 425 },
                }
            },
            {
                name = "Potion revitalisante",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = false,
                lvlToDesactive = 190,
                minLevel = 180,
                idItem = 16417,
                weight = 12,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Mandragore", nbIng = 7, idItem = 16389, job = "alchimiste" },
                    { name = "Mesure de poivre", nbIng = 1, idItem = 1978, job = "divers" },
                    { name = "Mais", nbIng = 2, idItem = 16454 },
                }
            },
            {
                name = "Potion raide reve",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = false,
                lvlToDesactive = 200,
                minLevel = 190,
                idItem = 11506,
                weight = 12,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Mandragore", nbIng = 7, idItem = 16389, job = "alchimiste" },
                    { name = "Citron", nbIng = 1, idItem = 1736, job = "divers" },
                    { name = "Mais", nbIng = 2, idItem = 16454 }
                }
            },
        },
        ["mineur"] = {
            {
                name = "Ferrite",
                lot = nil, 
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 20,
                minLevel = 1,
                idItem = 16440,
                weight = 80,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Fer", nbIng = 6, idItem = 312, job = "mineur" },
                    { name = "Frene", nbIng = 10, idItem = 303 }
                }
            },
            {
                name = "Aluminite",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 40,
                minLevel = 20,
                idItem = 747,
                weight = 100,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Fer", nbIng = 10, idItem = 312, job = "mineur" },
                    { name = "Cuivre", nbIng = 10, idItem = 441, job = "mineur" }
                }
            },
            {
                name = "Ebonite",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 201,
                minLevel = 40,
                idItem = 746,
                weight = 150,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Fer", nbIng = 10, idItem = 312, job = "mineur" },
                    { name = "Cuivre", nbIng = 10, idItem = 441, job = "mineur" },
                    { name = "Bronze", nbIng = 10, idItem = 442, job = "mineur" }
                }
            },
            {
                name = "Magnesite",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 201,
                minLevel = 60,
                idItem = 748,
                weight = 200,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Fer", nbIng = 10, idItem = 312, job = "mineur" },
                    { name = "Cuivre", nbIng = 10, idItem = 441, job = "mineur" },
                    { name = "Bronze", nbIng = 10, idItem = 442, job = "mineur" },
                    { name = "Kobalte", nbIng = 10, idItem = 443, job = "mineur" }
                }
            },
            {
                name = "Bakelelite",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 160,
                minLevel = 80,
                idItem = 749,
                weight = 200,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Cuivre", nbIng = 10, idItem = 441, job = "mineur" },
                    { name = "Bronze", nbIng = 10, idItem = 442, job = "mineur" },
                    { name = "Kobalte", nbIng = 10, idItem = 443, job = "mineur" },
                    { name = "Manganese", nbIng = 10, idItem = 445, job = "mineur" }
                }
            },
            {
                name = "Kouartz",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = false,
                lvlToDesactive = 120,
                minLevel = 100,
                idItem = 750,
                weight = 250,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Manganese", nbIng = 10, idItem = 445, job = "mineur" },
                    { name = "Etain", nbIng = 10, idItem = 444, job = "mineur" },
                    { name = "Silicate", nbIng = 10, idItem = 7032, job = "mineur" },
                    { name = "Bronze", nbIng = 10, idItem = 442, job = "mineur" },
                    { name = "Kobalte", nbIng = 10, idItem = 443, job = "mineur" }
                }
            },
            {
                name = "Kriptonite",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = false,
                lvlToDesactive = 140,
                minLevel = 120,
                idItem = 6457,
                weight = 300,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Silicate", nbIng = 10, idItem = 7032, job = "mineur" },
                    { name = "Bronze", nbIng = 10, idItem = 442, job = "mineur" },
                    { name = "Kobalte", nbIng = 10, idItem = 443, job = "mineur" },
                    { name = "Manganese", nbIng = 10, idItem = 445, job = "mineur" },
                    { name = "Etain", nbIng = 10, idItem = 444, job = "mineur" },
                    { name = "Argent", nbIng = 10, idItem = 350, job = "mineur" }
                }
            },
            {
                name = "Kobalite",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = false,
                lvlToDesactive = 160,
                minLevel = 140,
                idItem = 6458,
                weight = 300,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Silicate", nbIng = 10, idItem = 7032, job = "mineur" },
                    { name = "Kobalte", nbIng = 10, idItem = 443, job = "mineur" },
                    { name = "Manganese", nbIng = 10, idItem = 445, job = "mineur" },
                    { name = "Etain", nbIng = 10, idItem = 444, job = "mineur" },
                    { name = "Argent", nbIng = 10, idItem = 350, job = "mineur" },
                    { name = "Bauxite", nbIng = 10, idItem = 446, job = "mineur" }
                }
            },
            {
                name = "Rutile",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 201,
                minLevel = 160,
                idItem = 7036,
                weight = 350,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Manganese", nbIng = 10, idItem = 445, job = "mineur" },
                    { name = "Silicate", nbIng = 10, idItem = 7032, job = "mineur" },
                    { name = "Etain", nbIng = 10, idItem = 444, job = "mineur" },
                    { name = "Bauxite", nbIng = 10, idItem = 446, job = "mineur" },
                    { name = "Argent", nbIng = 10, idItem = 350, job = "mineur" },
                    { name = "Kobalte", nbIng = 10, idItem = 443, job = "mineur" },
                    { name = "Or", nbIng = 10, idItem = 313, job = "mineur" }
                }
            },
            {
                name = "Pyrute",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = false,
                lvlToDesactive = 201,
                minLevel = 180,
                idItem = 7035,
                weight = 400,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Or", nbIng = 10, idItem = 313, job = "mineur" },
                    { name = "Bauxite", nbIng = 10, idItem = 446, job = "mineur" },
                    { name = "Kobalte", nbIng = 10, idItem = 443, job = "mineur" },
                    { name = "Dolomite", nbIng = 10, idItem = 7033, job = "mineur" },
                    { name = "Manganese", nbIng = 10, idItem = 445, job = "mineur" },
                    { name = "Etain", nbIng = 10, idItem = 444, job = "mineur" },
                    { name = "Silicate", nbIng = 10, idItem = 7032, job = "mineur" },
                    { name = "Argent", nbIng = 10, idItem = 350, job = "mineur" }
                }
            },
            {
                name = "Ardonite",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = false,
                lvlToDesactive = 201,
                minLevel = 200,
                idItem = 12728,
                weight = 400,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Obsidienne", nbIng = 10, idItem = 11110, job = "mineur" },
                    { name = "Silicate", nbIng = 10, idItem = 7032, job = "mineur" },
                    { name = "Manganese", nbIng = 10, idItem = 445, job = "mineur" },
                    { name = "Bauxite", nbIng = 10, idItem = 446, job = "mineur" },
                    { name = "Dolomite", nbIng = 10, idItem = 7033, job = "mineur" },
                    { name = "Argent", nbIng = 10, idItem = 350, job = "mineur" },
                    { name = "Or", nbIng = 10, idItem = 313, job = "mineur" },
                    { name = "Etain", nbIng = 10, idItem = 444, job = "mineur" }
                }
            }
        },
        ["bucheron"] = {
            {
                name = "Planche agglomere",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 20,
                minLevel = 1,
                idItem = 16489,
                weight = 50,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Frene", nbIng = 6, idItem = 303, job = "bucheron" },
                    { name = "Fer", nbIng = 4, idItem = 312 }
                }
            },
            {
                name = "Planche contreplaque",
                lot = nil,
                nbItemsBeforeNextCraft = 200,
                active = true,
                lvlToDesactive = 201,
                minLevel = 20,
                idItem = 16490,
                weight = 100,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Frene", nbIng = 10, idItem = 303, job = "bucheron" },
                    { name = "Chataignier", nbIng = 10, idItem = 473, job = "bucheron" }
                }
            },
            {
                name = "Substrat de buisson",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 201,
                minLevel = 20,
                idItem = 2539,
                weight = 22,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Planche contreplaque", nbIng = 2, idItem = 16490, job = "substrat" },
                    { name = "Potion de souvenir", nbIng = 1, idItem = 7652 }
                }
            },
            {
                name = "Planche grille",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 201,
                minLevel = 40,
                idItem = 16491,
                weight = 150,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Frene", nbIng = 10, idItem = 303, job = "bucheron" },
                    { name = "Chataignier", nbIng = 10, idItem = 473, job = "bucheron" },
                    { name = "Noyer", nbIng = 10, idItem = 476, job = "bucheron" }
                }
            },
            {
                name = "Substrat de bocage",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 201,
                minLevel = 40,
                idItem = 12745,
                weight = 12,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Planche grille", nbIng = 1, idItem = 16491, job = "substrat" },
                    { name = "Potion de souvenir", nbIng = 1, idItem = 7652 }
                }
            },
            {
                name = "Planche de surf",
                lot = nil,
                nbItemsBeforeNextCraft = 200,
                active = true,
                lvlToDesactive = 201,
                minLevel = 60,
                idItem = 16492,
                weight = 200,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Frene", nbIng = 10, idItem = 303, job = "bucheron" },
                    { name = "Chataignier", nbIng = 10, idItem = 473, job = "bucheron" },
                    { name = "Noyer", nbIng = 10, idItem = 476, job = "bucheron" },
                    { name = "Chene", nbIng = 10, idItem = 460, job = "bucheron" }
                }
            },
            {
                name = "Substrat de futaie",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 201,
                minLevel = 60,
                idItem = 2540,
                weight = 12,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Planche de surf", nbIng = 1, idItem = 16492, job = "substrat" },
                    { name = "Potion de souvenir", nbIng = 1, idItem = 7652 }
                }
            },
            {
                name = "Planche a repasser",
                lot = nil,
                nbItemsBeforeNextCraft = 200,
                active = true,
                lvlToDesactive = 201,
                minLevel = 80,
                idItem = 16493,
                weight = 200,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Chene", nbIng = 10, idItem = 460, job = "bucheron" },
                    { name = "Bombu", nbIng = 10, idItem = 2358, job = "bucheron" },
                    { name = "Erable", nbIng = 10, idItem = 471, job = "bucheron" },
                    { name = "Noyer", nbIng = 10, idItem = 476, job = "bucheron" }
                }
            },
            {
                name = "Substrat de fascine",
                lot = nil,
                nbItemsBeforeNextCraft = 100,
                active = true,
                lvlToDesactive = 201,
                minLevel = 80,
                idItem = 2543,
                weight = 12,
                next = false,
                waitItemOfAnotherJob = false,
                ingredient = {
                    { name = "Planche a repasser", nbIng = 2, idItem = 16493, job = "substrat" },
                    { name = "Potion de souvenir", nbIng = 1, idItem = 7652 }
                }
            }
        }
    }

    local ITEM = {
        ["paysan"] = {
            ["Ble"] = { name = "Ble", id = 289, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 38, job = "paysan" },
            ["Orge"] = { name = "Orge", id = 400, current = 0, lvlToFarm = 20, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 43, job = "paysan" },
            ["Avoine"] = { name = "Avoine", id = 533, current = 0, lvlToFarm = 40, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 45, job = "paysan" },
            ["Houblon"] = { name = "Houblon", id = 401, current = 0, lvlToFarm = 60, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 39, job = "paysan" },
            ["Lin"] = { name = "Lin", id = 423, current = 0, lvlToFarm = 80, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 42, job = "paysan" },
            ["Riz"] = { name = "Riz", id = 7018, current = 0, lvlToFarm = 100, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 111, job = "paysan" },
            ["Seigle"] = { name = "Seigle", id = 532, current = 0, lvlToFarm = 100, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 44, job = "paysan" },
            ["Malt"] = { name = "Malt", id = 405, current = 0, lvlToFarm = 120, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 47, job = "paysan" },
            ["Chanvre"] = { name = "Chanvre", id = 425, current = 0, lvlToFarm = 140, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 46, job = "paysan" },
            ["Mais"] = { name = "Mais", id = 16454, current = 0, lvlToFarm = 160, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 260, job = "paysan" },
            ["Millet"] = { name = "Millet", id = 16456, current = 0, lvlToFarm = 180, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 261, job = "paysan" },
            ["Frostiz"] = { name = "Frostiz", id = 11109, current = 0, lvlToFarm = 200, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 134, job = "paysan" },
        },
        ["alchimiste"] = {
            ["Ortie"] = { name = "Ortie", id = 421, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 254, job = "alchimiste" },
            ["Sauge"] = { name = "Sauge", id = 428, current = 0, lvlToFarm = 20, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 255, job = "alchimiste" },
            ["Trefle"] = { name = "Trefle a 5 feuille", id = 395, current = 0, lvlToFarm = 40, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 67, job = "alchimiste" },
            ["MentheSauvage"] = { name = "Menthe sauvage", id = 380, current = 0, lvlToFarm = 60, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 66, job = "alchimiste" },
            ["Orchidee"] = { name = "Orchidee freyesque", id = 593, current = 0, lvlToFarm = 80, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 68, job = "alchimiste" },
            ["Edelweiss"] = { name = "Edelweiss", id = 594, current = 0, lvlToFarm = 100, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 61, job = "alchimiste" },
            ["GraineDePandouille"] = { name = "Graine de pandouille", id = 7059, current = 0, lvlToFarm = 120, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 112, job = "alchimiste" },
            ["Ginseng"] = { name = "Ginseng", id = 16385, current = 0, lvlToFarm = 140, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 256, job = "alchimiste" },
            ["Belladone"] = { name = "Belladone", id = 16387, current = 0, lvlToFarm = 160, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 257, job = "alchimiste" },
            ["Mandragore"] = { name = "Mandragore", id = 16389, current = 0, lvlToFarm = 180, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 258, job = "alchimiste" },
            ["PerceNeige"] = { name = "PerceNeige", id = 11102, current = 0, lvlToFarm = 200, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 131, job = "alchimiste" },
        },
        ["mineur"] = {
            ["Fer"] = { name = "Fer", id = 312, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 17, job = "mineur" },
            ["Cuivre"] = { name = "Cuivre", id = 441, current = 0, lvlToFarm = 20, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 53, job = "mineur" },
            ["Bronze"] = { name = "Bronze", id = 442, current = 0, lvlToFarm = 40, minStock = nil, maxStock = nil, forceFarm = false, gatherId = 55, job = "mineur" },
            ["Kobalte"] = { name = "Kobalte", id = 443, current = 0, lvlToFarm = 60, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 37, job = "mineur" },
            ["Manganese"] = { name = "Manganese", id = 445, current = 0, lvlToFarm = 80, minStock = nil, maxStock = nil, forceFarm = false, gatherId = 54, job = "mineur" },
            ["Etain"] = { name = "Etain", id = 444, current = 0, lvlToFarm = 100, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 52, job = "mineur" },
            ["Silicate"] = { name = "Silicate", id = 7032, current = 0, lvlToFarm = 100, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 114, job = "mineur" },
            ["Argent"] = { name = "Argent", id = 350, current = 0 , lvlToFarm = 120, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 24, job = "mineur" },
            ["Bauxite"] = { name = "Bauxite", id = 446, current = 0, lvlToFarm = 140, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 26, job = "mineur" },
            ["Or"] = { name = "Or", id = 313, current = 0, lvlToFarm = 160, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 25, job = "mineur" },
            ["Dolomite"] = { name = "Dolomite", id = 7033, current = 0, lvlToFarm = 180, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 113, job = "mineur" },
            ["Obsidienne"] = { name = "Obsidienne", id = 11110, current = 0, lvlToFarm = 200, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 135, job = "mineur" },
        },
        ["bucheron"] = {
            ["Frene"] = { name = "Frene", id = 303, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 1, job = "bucheron" },
            ["Chataignier"] = { name = "Chataignier", id = 473, current = 0, lvlToFarm = 20, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 33, job = "bucheron" },
            ["Noyer"] = { name = "Noyer", id = 476, current = 0, lvlToFarm = 40, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 34, job = "bucheron" },
            ["Chene"] = { name = "Chene", id = 460, current = 0, lvlToFarm = 60, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 8, job = "bucheron" },
            ["Bombu"] = { name = "Bombu", id = 2358, current = 0, lvlToFarm = 70, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 98, job = "bucheron" },
            ["Erable"] = { name = "Erable", id = 471, current = 0, lvlToFarm = 80, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 31, job = "bucheron" },
            ["Oliviolet"] = { name = "Oliviolet", id = 2357, current = 0, lvlToFarm = 90, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 101, job = "bucheron" },
            ["If"] = { name = "If", id = 461, current = 0, lvlToFarm = 100, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 28, job = "bucheron" },
            ["Bambou"] = { name = "Bambou", id = 7013, current = 0, lvlToFarm = 110, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 108, job = "bucheron" },
            ["Merisier"] = { name = "Merisier", id = 474, current = 0, lvlToFarm = 120, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 35, job = "bucheron" },
            ["Noisetier"] = { name = "Noisetier", id = 16488, current = 0, lvlToFarm = 130, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 259, job = "bucheron" },
            ["Ebene"] = { name = "Ebene", id = 449, current = 0, lvlToFarm = 140, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 29, job = "bucheron" },
            ["Kaliptus"] = { name = "Kaliptus", id = 7925, current = 0, lvlToFarm = 150, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 121, job = "bucheron" },
            ["Charme"] = { name = "Charme", id = 472, current = 0, lvlToFarm = 160, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 32, job = "bucheron" },
            ["BambouSombre"] = { name = "Bambou Sombre", id = 7016, current = 0, lvlToFarm = 170, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 109, job = "bucheron" },
            ["Orme"] = { name = "Orme", id = 470, current = 0, lvlToFarm = 180, minStock = nil, maxStock = 3000, forceFarm = false, gatherId = 30, job = "bucheron" }
        },
        ["divers"] = {
            ["Aubergine"] = { name = "Aubergine", id = 2331, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["SangDeScorbute"] = { name = "Sang de scorbute", id = 2012, current = 0, lvlToFarm = 1, minStock = 3000, maxStock = nil, forceFarm = false },
            ["CendreEternelle"] = { name = "Cendre eternelle", id = 1984, current = 0, lvlToFarm = 1, minStock = 3000, maxStock = nil, forceFarm = false },
            ["EauPotable"] = { name = "Eau potable", id = 311, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["Cerise"] = { name = "Cerise", id = 1734, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["Epices"] = { name = "Epices", id = 1977, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["Oignon"] = { name = "Oignon", id = 1975, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["GraisseGelatineuse"] = { name = "Graisse gelatineuse", id = 1983, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["DoseDeJusGoutus"] = { name = "Dose de jus goutus", id = 1731, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["Haricot"] = { name = "Haricot", id = 6671, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["PoudreDePerlinpainpain"] = { name = "Poudre de perlinpainpain", id = 519, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["PoudeTemporelle"] = { name = "Poude temporelle", id = 1986, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["Resine"] = { name = "Resine", id = 1985, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["MesureDeSel"] = { name = "Mesure de sel", id = 1730, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["MesureDePoivre"] = { name = "Mesure de poivre", id = 1978, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["Citron"] = { name = "Citron", id = 1736, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["plancheContrePlaque"] = { name = "Planche contreplaque", id = 16490, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["plancheGrille"] = { name = "Planche grille", id = 16491, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["plancheSurf"] = { name = "Planche de surf", id = 16492, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["plancheRepasser"] = { name = "Planche a repasser", id = 16493, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["plancheGravure"] = { name = "Planche de gravure", id = 16496, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["popoSouvenir"] = { name = "Potion de souvenir", id = 7652, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["popoVieillesse"] = { name = "Potion de viellesse", id = 17060, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
            ["popoAncetre"] = { name = "Potion des ancetre", id = 16419, current = 0, lvlToFarm = 1, minStock = nil, maxStock = 3000, forceFarm = false },
        }
    }

    local PATH_JOB = {
        ["paysan"] = {
            [1] = {
                name = "Zone ble amakna coin des Scarafeuille",
                tags = {
                    "Ble"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212481)") -- Zaap coin des Scarafeuille
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
                        { map = "88212481", changeMap = "right" }, 
                        { map = "88211969", changeMap = "right", custom = TryGather },
                        { map = "88080385", changeMap = "right", custom = TryGather }, -- Reboucle
                        { map = "88080897", changeMap = "right", custom = TryGather },
                        { map = "88081409", changeMap = "top", custom = TryGather },
                        { map = "88081408", changeMap = "left", custom = TryGather },
                        { map = "88080896", changeMap = "left", custom = TryGather },
                        { map = "88080384", changeMap = "bottom", custom = TryGatherWithBP } -- Reboucle sur 88080385
			        })
                end
            },
            [2] = {
                name = "Zone ble Astrub",
                tags = {
                    "Ble"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,191105026)") -- Zaap Astrub
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
                        { map = "191105026", changeMap = "left" },
                        { map = "191104002", changeMap = "top", custom = TryGather },
                        { map = "191104000", changeMap = "top", custom = TryGather },
                        { map = "188745218", changeMap = "top", custom = TryGather },
                        { map = "188745217", changeMap = "top", custom = TryGather },
                        { map = "189792777", changeMap = "left", custom = TryGather }, -- Reboucle
                        { map = "189792265", changeMap = "top", custom = TryGather },
                        { map = "189792264", changeMap = "top", custom = TryGather },
                        { map = "189792263", changeMap = "top", custom = TryGather },
                        { map = "189792262", changeMap = "top", custom = TryGather },
                        { map = "189792261", changeMap = "top", custom = TryGather },
                        { map = "189792260", changeMap = "right", custom = TryGather },
                        { map = "189792772", changeMap = "top", custom = TryGather },
                        { map = "189792771", changeMap = "top", custom = TryGather },
                        { map = "189792770", changeMap = "top", custom = TryGather },
                        { map = "189792769", changeMap = "right", custom = TryGather },
                        { map = "189793281", changeMap = "right", custom = TryGather },
                        { map = "189793793", changeMap = "bottom", custom = TryGather },
                        { map = "189793794", changeMap = "bottom", custom = TryGather },
                        { map = "189793795", changeMap = "bottom", custom = TryGather },
                        { map = "189793796", changeMap = "bottom", custom = TryGather },
                        { map = "189793797", changeMap = "left", custom = TryGather },
                        { map = "189793285", changeMap = "bottom", custom = TryGather },
                        { map = "189793286", changeMap = "right", custom = TryGather },
                        { map = "189793798", changeMap = "right", custom = TryGather },
                        { map = "189794310", changeMap = "bottom", custom = TryGather },
                        { map = "189794311", changeMap = "bottom", custom = TryGather },
                        { map = "189794312", changeMap = "bottom", custom = TryGather },
                        { map = "189794313", changeMap = "bottom", custom = TryGather },
                        { map = "188746753", changeMap = "left", custom = TryGather },
                        { map = "188746241", changeMap = "left", custom = TryGather },
                        { map = "188745729", changeMap = "top", custom = TryGather },
                        { map = "189793289", changeMap = "left", custom = TryGatherWithBP } -- Reboucle sur 189792777
			        })
                end
            },
            [3] = {
                name = "Zone ble coin des bouftout",
                tags = {
                    "Ble"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88082704)") -- Zaap coin des bouftout
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "88082704", changeMap = "bottom"},-- Zaap Bouftout ( 5,7 )
		                { map = "5,8", changeMap = "right", custom = TryGather },
		                { map = "6,8", changeMap = "bottom", custom = TryGather },
		                { map = "6,9", changeMap = "right", custom = TryGather },
		                { map = "7,9", changeMap = "right", custom = TryGather },
		                { map = "8,9", changeMap = "right", custom = TryGather },
		                { map = "9,9", changeMap = "top", custom = TryGather },
		                { map = "9,8", changeMap = "right", custom = TryGather },
		                { map = "10,8", changeMap = "top", custom = TryGather },
		                { map = "10,7", changeMap = "left", custom = TryGather },
		                { map = "9,7", changeMap = "top", custom = TryGather },
		                { map = "9,6", changeMap = "top", custom = TryGather },
		                { map = "9,5", changeMap = "left", custom = TryGather },
		                { map = "8,5", changeMap = "bottom", custom = TryGather },
		                { map = "8,6", changeMap = "left", custom = TryGather },
		                { map = "7,6", changeMap = "left", custom = TryGather },
		                { map = "6,6", changeMap = "left", custom = TryGather },
		                { map = "5,6", changeMap = "left", custom = TryGather },
		                { map = "4,6", changeMap = "bottom", custom = TryGather },
		                { map = "4,7", changeMap = "right", custom = TryGatherWithBP }
			        })
                end
            },
            [4] = {
                name = "Zone ble champs de bonta",
                tags = {
                    "Ble"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,142087694)") -- Zaap champ de bonta
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "142087694", changeMap = "top" }, -- Zaap sous bonta ( -27,-36 )
		                { map = "-27,-37", changeMap = "top", custom = TryGather },
		                { map = "-27,-38", changeMap = "top", custom = TryGather },
		                { map = "-27,-39", changeMap = "left", custom = TryGather },
		                { map = "-28,-39", changeMap = "left", custom = TryGather },
		                { map = "-29,-39", changeMap = "left", custom = TryGather },
		                { map = "-30,-39", changeMap = "top", custom = TryGather },
		                { map = "-30,-40", changeMap = "right", custom = TryGather },
		                { map = "-29,-40", changeMap = "right", custom = TryGather },
		                { map = "-28,-40", changeMap = "top", custom = TryGather },
		                { map = "-28,-41", changeMap = "top", custom = TryGather },
		                { map = "-28,-42", changeMap = "top", custom = TryGather },
		                { map = "-28,-43", changeMap = "top", custom = TryGather },
		                { map = "-28,-44", changeMap = "top", custom = TryGather },
		                { map = "-28,-45", changeMap = "right", custom = TryGather },
		                { map = "-27,-45", changeMap = "bottom", custom = TryGather },
		                { map = "-27,-44", changeMap = "bottom", custom = TryGather },
		                { map = "-27,-43", changeMap = "right", custom = TryGather },
		                { map = "-26,-43", changeMap = "right", custom = TryGather },
		                { map = "-25,-43", changeMap = "right", custom = TryGather },
		                { map = "-24,-43", changeMap = "bottom", custom = TryGather },
		                { map = "-24,-42", changeMap = "bottom", custom = TryGather },
		                { map = "-24,-41", changeMap = "bottom", custom = TryGather },
		                { map = "-24,-40", changeMap = "right", custom = TryGather },
		                { map = "-23,-40", changeMap = "bottom", custom = TryGather },
		                { map = "-23,-39", changeMap = "left", custom = TryGather },
		                { map = "-24,-39", changeMap = "left", custom = TryGather },
		                { map = "-25,-39", changeMap = "top", custom = TryGather },
		                { map = "-25,-40", changeMap = "left", custom = TryGather },
		                { map = "-26,-40", changeMap = "bottom", custom = TryGather },
		                { map = "-26,-39", changeMap = "bottom", custom = TryGather },
		                { map = "-26,-38", changeMap = "left", custom = TryGatherWithBP }
			        })
                end 
            },
            [5] = {
                name = "Zone orge coin des bouftout",
                tags = {
                    "Orge"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88082704)") -- Zaap Astrub
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "5,7", changeMap = "right" }, -- Zaap Bouftout ( 5,7 )
		                { map = "6,7", changeMap = "top", custom = TryGather }, -- Reboucle
		                { map = "6,6", changeMap = "right", custom = TryGather },
		                { map = "7,6", changeMap = "right", custom = TryGather },
		                { map = "8,6", changeMap = "right", custom = TryGather },
		                { map = "9,6", changeMap = "top", custom = TryGather },
		                { map = "9,5", changeMap = "right", custom = TryGather },
		                { map = "10,5", changeMap = "right", custom = TryGather },
		                { map = "11,5", changeMap = "bottom", custom = TryGather },
		                { map = "11,6", changeMap = "left", custom = TryGather },
		                { map = "10,6", changeMap = "bottom", custom = TryGather },
		                { map = "10,7", changeMap = "bottom", custom = TryGather },
		                { map = "10,8", changeMap = "bottom", custom = TryGather },
		                { map = "10,9", changeMap = "left", custom = TryGather },
		                { map = "9,9", changeMap = "top", custom = TryGather },
		                { map = "9,8", changeMap = "left", custom = TryGather },
		                { map = "8,8", changeMap = "left", custom = TryGather },
		                { map = "7,8", changeMap = "left", custom = TryGather },
		                { map = "6,8", changeMap = "top", custom = TryGatherWithBP } -- fin de boucle
			        })
                end
            },
            [6] = {
                name = "Zone orge coin des Scarafeuille",
                tags = {
                    "Orge"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212481)") -- Zaap Scara
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "-1,24", changeMap = "right" }, -- Zaap Scara ( -1,-24 )
		                { map = "0,24", changeMap = "right", custom = TryGather },
		                { map = "1,24", changeMap = "right", custom = TryGather },
		                { map = "2,24", changeMap = "bottom", custom = TryGather }, -- Reboucle
		                { map = "2,25", changeMap = "right", custom = TryGather },
		                { map = "3,25", changeMap = "top", custom = TryGather },
		                { map = "3,24", changeMap = "left", custom = TryGatherWithBP } -- fin de boucle
			        })
                end
            },
            [7] = {
                name = "Zone orge champs de bonta",
                tags = {
                    "Orge"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,142087694)") -- Zaap champs de bonta
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "-27,-36", changeMap = "top" }, -- Zaap Sous bonta ( -27,-36 )
		                { map = "-27,-37", changeMap = "left", custom = TryGather }, -- Reboucle
		                { map = "-28,-37", changeMap = "left", custom = TryGather }, 
		                { map = "-29,-37", changeMap = "top", custom = TryGather },
		                { map = "-29,-38", changeMap = "top", custom = TryGather },
		                { map = "-29,-39", changeMap = "right", custom = TryGather },
		                { map = "-28,-39", changeMap = "top", custom = TryGather },
		                { map = "-28,-40", changeMap = "right", custom = TryGather },
		                { map = "-27,-40", changeMap = "top", custom = TryGather },
		                { map = "-27,-41", changeMap = "top", custom = TryGather },
		                { map = "-27,-42", changeMap = "top", custom = TryGather },
		                { map = "-27,-43", changeMap = "top", custom = TryGather },
		                { map = "-27,-44", changeMap = "left", custom = TryGather },
		                { map = "-28,-44", changeMap = "top", custom = TryGather },
		                { map = "-28,-45", changeMap = "right", custom = TryGather },
		                { map = "-27,-45", changeMap = "right", custom = TryGather },
		                { map = "-26,-45", changeMap = "right", custom = TryGather },
		                { map = "-25,-45", changeMap = "bottom", custom = TryGather },
		                { map = "-25,-44", changeMap = "bottom", custom = TryGather },
		                { map = "-25,-43", changeMap = "right", custom = TryGather },
		                { map = "-24,-43", changeMap = "right", custom = TryGather },
		                { map = "-23,-43", changeMap = "right", custom = TryGather },
		                { map = "-22,-43", changeMap = "bottom", custom = TryGather },
		                { map = "-22,-42", changeMap = "left", custom = TryGather },
		                { map = "-23,-42", changeMap = "left", custom = TryGather },
		                { map = "-24,-42", changeMap = "bottom", custom = TryGather },
		                { map = "-24,-41", changeMap = "bottom", custom = TryGather },
		                { map = "-24,-40", changeMap = "bottom", custom = TryGather },
		                { map = "-24,-39", changeMap = "left", custom = TryGather },
		                { map = "-25,-39", changeMap = "left", custom = TryGather },
		                { map = "-26,-39", changeMap = "bottom", custom = TryGather },
		                { map = "-26,-38", changeMap = "bottom", custom = TryGather },
		                { map = "-26,-37", changeMap = "left", gather = true, custom = TryGatherWithBP } -- fin de boucle
			        })
                end
            },
            [8] = {
                name = "Zone Avoine coin des bouftout",
                tags = {
                    "Avoine"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88082704)") -- Zaap coin des bouftout
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "5,7", changeMap = "right" },  -- Zaap Bouftout
		                { map = "6,7", changeMap = "right", custom = TryGather },  -- Reboucle
		                { map = "7,7", changeMap = "right", custom = TryGather },
		                { map = "8,7", changeMap = "right", custom = TryGather },
		                { map = "9,7", changeMap = "top", custom = TryGather },
		                { map = "9,6", changeMap = "right", custom = TryGather },
		                { map = "10,6", changeMap = "bottom", custom = TryGather },
		                { map = "10,7", changeMap = "bottom", custom = TryGather },
		                { map = "10,8", changeMap = "bottom", custom = TryGather },
		                { map = "10,9", changeMap = "left", custom = TryGather },
		                { map = "9,9", changeMap = "left", custom = TryGather },
		                { map = "8,9", changeMap = "left", custom = TryGather },
		                { map = "7,9", changeMap = "left", custom = TryGather },
		                { map = "6,9", changeMap = "top", custom = TryGather },
		                { map = "6,8", changeMap = "top", custom = TryGatherWithBP }  -- fin de boucle
			        })
                end
            },
            [9] = {
                name = "Zone Avoine champs de bonta",
                tags = {
                    "Avoine"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,142087694)") -- Zaap champs de bonta
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "-27,-36", changeMap = "top"},  -- Zaap sous bonta
		                { map = "-27,-37", changeMap = "top"},  -- Reboucle
		                { map = "-27,-38", changeMap = "left", custom = TryGather },
		                { map = "-28,-38", changeMap = "bottom", custom = TryGather },
		                { map = "-28,-37", changeMap = "left", custom = TryGather },
		                { map = "-29,-37", changeMap = "top", custom = TryGather },
		                { map = "-29,-38", changeMap = "top", custom = TryGather },
		                { map = "-29,-39", changeMap = "right", custom = TryGather },
		                { map = "-28,-39", changeMap = "right", custom = TryGather },
		                { map = "-27,-39", changeMap = "top", custom = TryGather },
		                { map = "-27,-40", changeMap = "top", custom = TryGather },
		                { map = "-27,-41", changeMap = "top", custom = TryGather },
		                { map = "-27,-42", changeMap = "left", custom = TryGather },
		                { map = "-28,-42", changeMap = "left", custom = TryGather },
		                { map = "-29,-42", changeMap = "left", custom = TryGather },
		                { map = "-30,-42", changeMap = "top", custom = TryGather },
		                { map = "-30,-43", changeMap = "top", custom = TryGather },
		                { map = "-30,-44", changeMap = "right", custom = TryGather },
		                { map = "-29,-44", changeMap = "right", custom = TryGather },
		                { map = "-28,-44", changeMap = "right", custom = TryGather },
		                { map = "-27,-44", changeMap = "bottom", custom = TryGather },
		                { map = "-27,-43", changeMap = "right", custom = TryGather },
		                { map = "-26,-43", changeMap = "bottom", custom = TryGather },
		                { map = "-26,-42", changeMap = "right", custom = TryGather },
		                { map = "-25,-42", changeMap = "bottom", custom = TryGather },
		                { map = "-25,-41", changeMap = "left", custom = TryGather },
		                { map = "-26,-41", changeMap = "bottom", custom = TryGather },
		                { map = "-26,-40", changeMap = "bottom", custom = TryGather },
		                { map = "-26,-39", changeMap = "bottom", custom = TryGather },
		                { map = "-26,-37", changeMap = "left", custom = TryGatherWithBP }  -- fin de boucle
			        })
                end
            },
            [10] = {
                name = "Zone Avoine Lac de cania",
                tags = {
                    "Avoine"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,156240386)") -- Zaap Lac de cania
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "-3,-42", changeMap = "right"},  -- Zaap Lac de Cania
		                { map = "-2,-42", changeMap = "right", custom = TryGather },
		                { map = "-1,-42", changeMap = "right", custom = TryGather },
		                { map = "0,-42", changeMap = "top", custom = TryGather },
		                { map = "0,-43", changeMap = "top", custom = TryGather },
		                { map = "0,-44", changeMap = "top", custom = TryGather },
		                { map = "0,-45", changeMap = "top", custom = TryGather },  -- Reboucle
		                { map = "0,-46", changeMap = "top", custom = TryGather },
		                { map = "0,-47", changeMap = "top", custom = TryGather },
		                { map = "0,-48", changeMap = "left", custom = TryGather },
		                { map = "-1,-48", changeMap = "bottom", custom = TryGather },
		                { map = "-1,-47", changeMap = "bottom", custom = TryGather },
		                { map = "-1,-46", changeMap = "bottom", custom = TryGather },
		                { map = "-1,-45", changeMap = "right", custom = TryGatherWithBP } -- fin de boucle
			        })
                end
            },
            [11] = {
                name = "Zone Houblon coin des Scarafeuille",
                tags = {
                    "Houblon"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212481)") -- Zaap Coin des Scarafeuille
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "-1,24", changeMap = "right" },  -- Zaap Scara
		                { map = "0,24", changeMap = "bottom", custom = TryGather },  -- Reboucle
		                { map = "0,25", changeMap = "bottom", custom = TryGather },
		                { map = "0,26", changeMap = "bottom", custom = TryGather },
		                { map = "0,27", changeMap = "bottom", custom = TryGather },
		                { map = "0,28", changeMap = "right", custom = TryGather },
		                { map = "1,28", changeMap = "right", custom = TryGather },
		                { map = "2,28", changeMap = "right", custom = TryGather },
		                { map = "3,28", changeMap = "top", custom = TryGather },
		                { map = "3,27", changeMap = "top", custom = TryGather },
		                { map = "3,26", changeMap = "top", custom = TryGather },
		                { map = "3,25", changeMap = "top", custom = TryGather },
		                { map = "3,24", changeMap = "top", custom = TryGather },
		                { map = "3,23", changeMap = "top", custom = TryGather },
		                { map = "3,22", changeMap = "left", custom = TryGather },
		                { map = "2,22", changeMap = "bottom", custom = TryGather },
		                { map = "2,23", changeMap = "bottom", custom = TryGather },
		                { map = "2,24", changeMap = "bottom", custom = TryGather },
		                { map = "2,25", changeMap = "left", custom = TryGather },
		                { map = "1,25", changeMap = "top", custom = TryGather },
		                { map = "1,24", changeMap = "left", custom = TryGatherWithBP}
			        })
                end
            },
            [12] = {
                name = "Zone Houblon coin des bouftout",
                tags = {
                    "Houblon"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88082704)") -- Zaap Coin des bouftout
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "5,7", changeMap = "right" },  -- Zaap Bouftout
		                { map = "6,7", changeMap = "right", custom = TryGather },  -- Reboucle
		                { map = "7,7", changeMap = "right", custom = TryGather },
		                { map = "8,7", changeMap = "top", custom = TryGather },
		                { map = "8,6", changeMap = "right", custom = TryGather },
		                { map = "9,6", changeMap = "bottom", custom = TryGather },
		                { map = "9,7", changeMap = "bottom", custom = TryGather },
		                { map = "9,8", changeMap = "left", custom = TryGather },
		                { map = "8,8", changeMap = "left", custom = TryGather },
		                { map = "7,8", changeMap = "left", custom = TryGather },
		                { map = "6,8", changeMap = "top", custom = TryGatherWithBP }  -- fin de boucle
			        })
                end
            },
            [13] = {
                name = "Zone Houblon champs de cania",
                tags = {
                    "Houblon"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,142087694)") -- Zaap Champs de cania
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "-27,-36", changeMap = "top" },  -- Zaap sous Bonta
		                { map = "-27,-37", changeMap = "top", custom = TryGather },
		                { map = "-27,-38", changeMap = "top", custom = TryGather },
		                { map = "-27,-39", changeMap = "top", custom = TryGather },  -- Reboucle
		                { map = "-27,-40", changeMap = "top", custom = TryGather },
		                { map = "-27,-41", changeMap = "left", custom = TryGather },
		                { map = "-28,-41", changeMap = "top", custom = TryGather },
		                { map = "-28,-42", changeMap = "right", custom = TryGather },
		                { map = "-27,-42", changeMap = "right", custom = TryGather },
		                { map = "-26,-42", changeMap = "right", custom = TryGather },
		                { map = "-25,-42", changeMap = "right", custom = TryGather },
		                { map = "-24,-42", changeMap = "right", custom = TryGather },
		                { map = "-23,-42", changeMap = "bottom", custom = TryGather },
		                { map = "-23,-41", changeMap = "right", custom = TryGather },
		                { map = "-22,-41", changeMap = "bottom", custom = TryGather },
		                { map = "-22,-40", changeMap = "left", custom = TryGather },
		                { map = "-23,-40", changeMap = "left", custom = TryGather },
		                { map = "-24,-40", changeMap = "bottom", custom = TryGather },
		                { map = "-24,-39", changeMap = "left", custom = TryGather },
		                { map = "-25,-39", changeMap = "left", custom = TryGather },
		                { map = "-26,-39", changeMap = "left", custom = TryGatherWithBP }  -- fin de boucle
			        })
                end
            },
            [14] = {
                name = "Zone Lin coin des Scarafeuille",
                tags = {
                    "Lin"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212481)") -- Zaap Coin des Scarafeuille
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "-1,24", changeMap = "right" },  -- Zaap Scara
		                { map = "0,24", changeMap = "bottom", custom = TryGather },  -- Reboucle
		                { map = "0,25", changeMap = "right", custom = TryGather },
		                { map = "1,25", changeMap = "right", custom = TryGather },
		                { map = "2,25", changeMap = "bottom", custom = TryGather },
		                { map = "2,26", changeMap = "bottom", custom = TryGather },
		                { map = "2,27", changeMap = "right", custom = TryGather },
		                { map = "3,27", changeMap = "bottom", custom = TryGather },
		                { map = "3,28", changeMap = "right", custom = TryGather },
		                { map = "4,28", changeMap = "top", custom = TryGather },
		                { map = "4,27", changeMap = "top", custom = TryGather },
		                { map = "4,26", changeMap = "top", custom = TryGather },
		                { map = "4,25", changeMap = "top", custom = TryGather },
		                { map = "4,24", changeMap = "left", custom = TryGather },
		                { map = "3,24", changeMap = "top", custom = TryGather },
		                { map = "3,23", changeMap = "top", custom = TryGather },
		                { map = "3,22", changeMap = "left", custom = TryGather },
		                { map = "2,22", changeMap = "bottom", custom = TryGather },
		                { map = "2,23", changeMap = "bottom", custom = TryGather },
		                { map = "2,24", changeMap = "left", custom = TryGather },
		                { map = "1,24", changeMap = "left", custom = TryGatherWithBP } -- fin de boucle
			        })
                end
            },
            [15] = {
                name = "Zone Lin coin des bouftout",
                tags = {
                    "Lin"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88082704)") -- Zaap Coin des bouftout
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "5,7", changeMap = "right" },  -- Zaap Bouftout
		                { map = "6,7", changeMap = "right", custom = TryGather },
		                { map = "7,7", changeMap = "bottom", custom = TryGather },  -- Reboucle
		                { map = "7,8", changeMap = "bottom", custom = TryGather },
		                { map = "7,9", changeMap = "right", custom = TryGather },
		                { map = "8,9", changeMap = "right", custom = TryGather },
		                { map = "9,9", changeMap = "top", custom = TryGather },
		                { map = "9,8", changeMap = "top", custom = TryGather },
		                { map = "9,7", changeMap = "top", custom = TryGather },
		                { map = "9,6", changeMap = "top", custom = TryGather },
		                { map = "9,5", changeMap = "left", custom = TryGather },
		                { map = "8,5", changeMap = "top", custom = TryGather },
		                { map = "8,4", changeMap = "left", custom = TryGather },
		                { map = "7,4", changeMap = "bottom", custom = TryGather },
		                { map = "7,5", changeMap = "bottom", custom = TryGather },
		                { map = "7,6", changeMap = "bottom", custom = TryGatherWithBP }  -- fin de boucle
			        })
                end
            },
            [16] = {
                name = "Zone Lin champs de cania",
                tags = {
                    "Lin"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,142087694)") -- Zaap Champs de cania
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "-27,-36", changeMap = "top" },  -- Zaap sous bonta
		                { map = "-27,-37", changeMap = "top", custom = TryGather },
		                { map = "-27,-38", changeMap = "top", custom = TryGather },
		                { map = "-27,-39", changeMap = "top", custom = TryGather },  -- Reboucle
		                { map = "-27,-40", changeMap = "top", custom = TryGather },
		                { map = "-27,-41", changeMap = "right", custom = TryGather },
		                { map = "-26,-41", changeMap = "right", custom = TryGather },
		                { map = "-25,-41", changeMap = "right", custom = TryGather },
		                { map = "-24,-41", changeMap = "bottom", custom = TryGather },
		                { map = "-24,-40", changeMap = "right", custom = TryGather },
		                { map = "-23,-40", changeMap = "bottom", custom = TryGather },
		                { map = "-23,-39", changeMap = "left", custom = TryGather },
		                { map = "-24,-39", changeMap = "left", custom = TryGather },
		                { map = "-25,-39", changeMap = "left", custom = TryGather },
		                { map = "-26,-39", changeMap = "left", custom = TryGatherWithBP }  -- fin de boucle
			        })
                end
            },
            [17] = {
                name = "Zone Seigle coin des Scarafeuille",
                tags = {
                    "Seigle"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212481)") -- Zaap Coin des Scarafeuille
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "-1,24", changeMap = "right" },  -- Zaap scara
		                { map = "0,24", changeMap = "right", custom = TryGather },
		                { map = "1,24", changeMap = "right", custom = TryGather },
		                { map = "2,24", changeMap = "right", custom = TryGather },  -- Reboucle
		                { map = "3,24", changeMap = "right", custom = TryGather },
		                { map = "4,24", changeMap = "bottom", custom = TryGather },
		                { map = "4,25", changeMap = "bottom", custom = TryGather },
		                { map = "4,26", changeMap = "bottom", custom = TryGather },
		                { map = "4,27", changeMap = "left", custom = TryGather },
		                { map = "3,27", changeMap = "left", custom = TryGather },
		                { map = "2,27", changeMap = "top", custom = TryGather },
		                { map = "2,26", changeMap = "top", custom = TryGather },
		                { map = "2,25", changeMap = "top", custom = TryGatherWithBP }  -- fin de boucle
			        })
                end
            },
            [18] = {
                name = "Zone Seigle coin des bouftout",
                tags = {
                    "Seigle"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88082704)") -- Zaap Coin des bouftout
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                {map = "5,7", changeMap = "right" },  -- Zaap Bouftout
		                {map = "6,7", changeMap = "right", custom = TryGather },
		                {map = "7,7", changeMap = "right", custom = TryGather },
		                {map = "8,7", changeMap = "right", custom = TryGather }, -- Reboucle
		                {map = "9,7", changeMap = "bottom", custom = TryGather },
		                {map = "9,8", changeMap = "left", custom = TryGather },
		                {map = "8,8", changeMap = "top", custom = TryGatherWithBP } -- fin de boucle
			        })
                end
            },
            [19] = {
                name = "Zone Seigle champs de cania",
                tags = {
                    "Seigle"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,142087694)") -- Zaap Champs de cania
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "-27,-36", changeMap = "top" },  -- Zaap sous bonta
		                { map = "-27,-37", changeMap = "top", custom = TryGather },
		                { map = "-27,-38", changeMap = "top", custom = TryGather },  -- Reboucle
		                { map = "-27,-39", changeMap = "top", custom = TryGather },
		                { map = "-27,-40", changeMap = "left", custom = TryGather },
		                { map = "-28,-40", changeMap = "bottom", custom = TryGather },
		                { map = "-28,-39", changeMap = "left", custom = TryGather },
		                { map = "-29,-39", changeMap = "left", custom = TryGather },
		                { map = "-30,-39", changeMap = "top", custom = TryGather },
		                { map = "-30,-40", changeMap = "top", custom = TryGather },
		                { map = "-30,-41", changeMap = "top", custom = TryGather },
		                { map = "-30,-42", changeMap = "top", custom = TryGather },
		                { map = "-30,-43", changeMap = "top", custom = TryGather },
		                { map = "-30,-44", changeMap = "right", custom = TryGather },
		                { map = "-29,-44", changeMap = "right", custom = TryGather },
		                { map = "-28,-44", changeMap = "bottom", custom = TryGather },
		                { map = "-28,-43", changeMap = "bottom", custom = TryGather },
		                { map = "-28,-42", changeMap = "right", custom = TryGather },
		                { map = "-27,-42", changeMap = "right", custom = TryGather },
		                { map = "-26,-42", changeMap = "right", custom = TryGather },
		                { map = "-25,-42", changeMap = "top", custom = TryGather },
		                { map = "-25,-43", changeMap = "top", custom = TryGather },
		                { map = "-25,-44", changeMap = "right", custom = TryGather },
		                { map = "-24,-44", changeMap = "bottom", custom = TryGather },
		                { map = "-24,-43", changeMap = "bottom", custom = TryGather },
		                { map = "-24,-42", changeMap = "bottom", custom = TryGather },
		                { map = "-24,-41", changeMap = "left", custom = TryGather },
		                { map = "-25,-41", changeMap = "bottom", custom = TryGather },
		                { map = "-25,-40", changeMap = "right", custom = TryGather },
		                { map = "-24,-40", changeMap = "right", custom = TryGather },
		                { map = "-23,-40", changeMap = "bottom", custom = TryGather },
		                { map = "-23,-39", changeMap = "bottom", custom = TryGather },
		                { map = "-23,-38", changeMap = "left", custom = TryGather },
		                { map = "-24,-38", changeMap = "left", custom = TryGather },
		                { map = "-25,-38", changeMap = "left", custom = TryGather },
		                { map = "-26,-38", changeMap = "left", custom = TryGatherWithBP }  -- fin de boucle
			        })
                end
            },
            [20] = {
                name = "Zone Malt coin des Scarafeuille",
                tags = {
                    "Malt"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212481)") -- Zaap Coin des Scarafeuille
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "-1,24", changeMap = "right" },  -- Zaap scara
		                { map = "0,24", changeMap = "right", custom = TryGather },
		                { map = "1,24", changeMap = "right", custom = TryGather },
		                { map = "2,24", changeMap = "right", custom = TryGather },
		                { map = "3,24", changeMap = "bottom", custom = TryGather },
		                { map = "3,25", changeMap = "bottom", custom = TryGather },
		                { map = "3,26", changeMap = "bottom", custom = TryGather },  -- Reboucle
		                { map = "3,27", changeMap = "right", custom = TryGather },
		                { map = "4,27", changeMap = "right", custom = TryGather },
		                { map = "5,27", changeMap = "top", custom = TryGather },
		                { map = "5,26", changeMap = "left", custom = TryGather },
		                { map = "4,26", changeMap = "left", custom = TryGatherWithBP } -- fin de boucle
			        })
                end
            },
            [21] = {
                name = "Zone Malt coin des bouftout",
                tags = {
                    "Malt"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88082704)") -- Zaap Coin des bouftout
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "5,7", changeMap = "right" },  -- zaap Bouftou
		                { map = "6,7", changeMap = "right", custom = TryGather },
		                { map = "7,7", changeMap = "right", custom = TryGather },
		                { map = "8,7", changeMap = "top", custom = TryGather },  -- Reboucle
		                { map = "8,6", changeMap = "top", custom = TryGather },
		                { map = "8,5", changeMap = "right", custom = TryGather },
		                { map = "9,5", changeMap = "right", custom = TryGather },
		                { map = "10,5", changeMap = "bottom", custom = TryGather },
		                { map = "10,6", changeMap = "bottom", custom = TryGather },
		                { map = "10,7", changeMap = "bottom", custom = TryGather },
		                { map = "10,8", changeMap = "left", custom = TryGather },
		                { map = "9,8", changeMap = "left", custom = TryGather },
		                { map = "8,8", changeMap = "top", custom = TryGatherWithBP }  -- fin de boucle
			        })
                end
            },
            [22] = {
                name = "Zone Malt champs de cania",
                tags = {
                    "Malt"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,142087694)") -- Zaap Champs de cania
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "-27,-36", changeMap = "top" },  -- Zaap sous Bonta
		                { map = "-27,-37", changeMap = "top", custom = TryGather },
		                { map = "-27,-38", changeMap = "top", custom = TryGather },
		                { map = "-27,-39", changeMap = "top", custom = TryGather },
		                { map = "-27,-40", changeMap = "top", custom = TryGather },  -- Reboucle
		                { map = "-27,-41", changeMap = "top", custom = TryGather },
		                { map = "-27,-42", changeMap = "top", custom = TryGather },
		                { map = "-27,-43", changeMap = "right", custom = TryGather },
		                { map = "-26,-43", changeMap = "right", custom = TryGather },
		                { map = "-25,-43", changeMap = "bottom", custom = TryGather },
		                { map = "-25,-42", changeMap = "right", custom = TryGather },
		                { map = "-24,-42", changeMap = "right", custom = TryGather },
		                { map = "-23,-42", changeMap = "right", custom = TryGather },
		                { map = "-22,-42", changeMap = "bottom", custom = TryGather },
		                { map = "-22,-41", changeMap = "bottom", custom = TryGather },
		                { map = "-22,-40", changeMap = "bottom", custom = TryGather },
		                { map = "-22,-39", changeMap = "left", custom = TryGather },
		                { map = "-23,-39", changeMap = "left", custom = TryGather },
		                { map = "-24,-39", changeMap = "left", custom = TryGather },
		                { map = "-25,-39", changeMap = "top", custom = TryGather },
		                { map = "-25,-40", changeMap = "left", custom = TryGather },
		                { map = "-26,-40", changeMap = "left", custom = TryGatherWithBP }  -- fin de boucle
			        })
                end
            },
            [23] = {
                name = "Zone Malt Lac de cania",
                tags = {
                    "Malt"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,156240386)") -- Zaap Lac de cania
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "-3,-42", changeMap = "right" },  -- Zaap Lac de Cania
		                { map = "-2,-42", changeMap = "right", custom = TryGather },
		                { map = "-1,-42", changeMap = "right", custom = TryGather },
		                { map = "0,-42", changeMap = "top", custom = TryGather },
		                { map = "0,-43", changeMap = "top", custom = TryGather },
		                { map = "0,-44", changeMap = "top", custom = TryGather },
		                { map = "0,-45", changeMap = "top", custom = TryGather },  -- Reboucle
		                { map = "0,-46", changeMap = "left", custom = TryGather },
		                { map = "-1,-46", changeMap = "bottom", custom = TryGather },
		                { map = "-1,-45", changeMap = "right", custom = TryGatherWithBP }  -- fin de boucle
			        })
                end
            },
            [24] = {
                name = "Zone Chanvre champs de cania",
                tags = {
                    "Chanvre"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,142087694)") -- Zaap Champs de cania
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "-27,-36", changeMap = "top" },  -- Zaap sous bonta
		                { map = "-27,-37", changeMap = "top", custom = TryGather },
		                { map = "-27,-38", changeMap = "top", custom = TryGather },
		                { map = "-27,-39", changeMap = "top", custom = TryGather },  -- Reboucle
		                { map = "-27,-40", changeMap = "top", custom = TryGather },
		                { map = "-27,-41", changeMap = "left", custom = TryGather },
		                { map = "-28,-41", changeMap = "top", custom = TryGather },
		                { map = "-28,-42", changeMap = "right", custom = TryGather },
		                { map = "-27,-42", changeMap = "top", custom = TryGather },
		                { map = "-27,-43", changeMap = "right", custom = TryGather },
		                { map = "-26,-43", changeMap = "bottom", custom = TryGather },
		                { map = "-26,-42", changeMap = "right", custom = TryGather },
		                { map = "-25,-42", changeMap = "right", custom = TryGather },
		                { map = "-24,-42", changeMap = "right", custom = TryGather },
		                { map = "-23,-42", changeMap = "bottom", custom = TryGather },
		                { map = "-23,-41", changeMap = "right", custom = TryGather },
		                { map = "-22,-41", changeMap = "bottom", custom = TryGather },
		                { map = "-22,-40", changeMap = "bottom", custom = TryGather },
		                { map = "-22,-39", changeMap = "left", custom = TryGather },
		                { map = "-23,-39", changeMap = "left", custom = TryGather },
		                { map = "-24,-39", changeMap = "left", custom = TryGather },
		                { map = "-25,-39", changeMap = "left", custom = TryGather },
		                { map = "-26,-39", changeMap = "left", custom = TryGatherWithBP } -- fin de boucle
			        })
                end
            },
            [25] = {
                name = "Zone Mais Otomai",
                tags = {
                    "Mais"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,154642)") -- Zaap Otomai
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "-46,18", changeMap = "left" },  -- Zaap otoami 
		                { map = "-47,18", changeMap = "top", custom = TryGather },
		                { map = "-47,17", changeMap = "top", custom = TryGather },
		                { map = "-47,16", changeMap = "top", custom = TryGather },
		                { map = "-47,15", changeMap = "top", custom = TryGather },
		                { map = "-47,14", changeMap = "top", custom = TryGather },
		                { map = "-47,13", changeMap = "top", custom = TryGather },
		                { map = "-47,12", changeMap = "top", custom = TryGather },
		                { map = "-47,11", changeMap = "left", custom = TryGather },
		                { map = "-48,11", changeMap = "left", custom = TryGather },
		                { map = "-49,11", changeMap = "left", custom = TryGather },
		                { map = "-50,11", changeMap = "left", custom = TryGather },  -- Reboucle
		                { map = "-51,11", changeMap = "top", custom = TryGather },
		                { map = "-51,10", changeMap = "top", custom = TryGather },
		                { map = "-51,9", changeMap = "top", custom = TryGather },
		                { map = "-51,8", changeMap = "left", custom = TryGather },
		                { map = "-52,8", changeMap = "top", custom = TryGather },
		                { map = "-52,7", changeMap = "top", custom = TryGather },
		                { map = "-52,6", changeMap = "top", custom = TryGather },
		                { map = "-52,5", changeMap = "top", custom = TryGather },
		                { map = "-52,4", changeMap = "left", custom = TryGather },
		                { map = "-53,4", changeMap = "left", custom = TryGather },
		                { map = "-54,4", changeMap = "left", custom = TryGather },
		                { map = "-55,4", changeMap = "top", custom = TryGather },
		                { map = "-55,3", changeMap = "right", custom = TryGather },
		                { map = "-54,3", changeMap = "right", custom = TryGather },
		                { map = "-53,3", changeMap = "right", custom = TryGather },
		                { map = "-52,3", changeMap = "right", custom = TryGather },
		                { map = "-51,3", changeMap = "bottom", custom = TryGather },
		                { map = "-51,4", changeMap = "bottom", custom = TryGather },
		                { map = "-51,5", changeMap = "bottom", custom = TryGather },
		                { map = "-51,6", changeMap = "right", custom = TryGather },
		                { map = "-50,6", changeMap = "bottom", custom = TryGather },
		                { map = "-50,7", changeMap = "bottom", custom = TryGather },
		                { map = "-50,8", changeMap = "bottom", custom = TryGather },
		                { map = "-50,9", changeMap = "bottom", custom = TryGather },
		                { map = "-50,10", changeMap = "bottom", custom = TryGatherWithBP }  -- fin de boucle
			        })
                end
            },
            [26] = {
                name = "Zone Millet Lac de cania",
                tags = {
                    "Millet"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,156240386)") -- Zaap Lac de cania
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
		                { map = "-3,-42", changeMap = "top" },  -- Zaap Lac de Cania
		                { map = "-3,-43", changeMap = "top" },
		                { map = "-3,-49", changeMap = "left" },
		                { map = "-4,-49", changeMap = "left" },
		                { map = "-5,-49", changeMap = "left" },
		                { map = "-6,-49", changeMap = "top" },
		                { map = "-6,-50", changeMap = "top" },  -- reboucle
		                { map = "-6,-51", changeMap = "top", custom = TryGather },
		                { map = "-6,-52", changeMap = "top", custom = TryGather },
		                { map = "-6,-53", changeMap = "top", custom = TryGather },
		                { map = "-6,-54", changeMap = "top", custom = TryGather },
		                { map = "-6,-55", changeMap = "left", custom = TryGather },
		                { map = "-7,-55", changeMap = "top", custom = TryGather },
		                { map = "-7,-56", changeMap = "right", custom = TryGather },
		                { map = "-6,-56", changeMap = "top", custom = TryGather },
		                { map = "-6,-57", changeMap = "top", custom = TryGather },
		                { map = "-6,-58", changeMap = "top", custom = TryGather },
		                { map = "-6,-59", changeMap = "right", custom = TryGather },
		                { map = "-5,-59", changeMap = "bottom", custom = TryGather },
		                { map = "-5,-58", changeMap = "bottom", custom = TryGather },
		                { map = "-5,-57", changeMap = "bottom", custom = TryGather },
		                { map = "-5,-56", changeMap = "bottom", custom = TryGather },
		                { map = "-5,-55", changeMap = "right", custom = TryGather },
		                { map = "-4,-55", changeMap = "top", custom = TryGather },
		                { map = "-4,-56", changeMap = "top", custom = TryGather },
		                { map = "-4,-57", changeMap = "top", custom = TryGather },
		                { map = "-4,-58", changeMap = "top", custom = TryGather },
		                { map = "-4,-59", changeMap = "right", custom = TryGather },
		                { map = "-3,-59", changeMap = "bottom", custom = TryGather },
		                { map = "-3,-58", changeMap = "bottom", custom = TryGather },
		                { map = "-3,-57", changeMap = "bottom", custom = TryGather },
		                { map = "-3,-56", changeMap = "bottom", custom = TryGather },
		                { map = "-3,-55", changeMap = "bottom", custom = TryGather },
		                { map = "-3,-54", changeMap = "bottom", custom = TryGather },
		                { map = "-3,-52", changeMap = "bottom", custom = TryGather },
		                { map = "-3,-51", changeMap = "right", custom = TryGather },
		                { map = "-3,-53", changeMap = "bottom", custom = TryGather },
		                { map = "-2,-51", changeMap = "bottom", custom = TryGather },
		                { map = "-2,-50", changeMap = "left", custom = TryGather },
		                { map = "-3,-50", changeMap = "left", custom = TryGather },
		                { map = "-4,-50", changeMap = "left", custom = TryGather },
		                { map = "-5,-50", changeMap = "left", custom = TryGather },
		                { map = "-3,-44", changeMap = "top" },
		                { map = "-3,-45", changeMap = "top" },
		                { map = "-3,-46", changeMap = "top" },
		                { map = "-3,-47", changeMap = "top" },
		                { map = "-3,-48", changeMap = "top", custom = bouclePlus }  -- fin de boucle
			        })
                end
            },
        },
        ["alchimiste"] = {
            [1] = {
                name = "Zone Ortie coin des Scarafeuille",
                tags = {
                    "Ortie"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212481)") -- Zaap Scara
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "-1,24", changeMap = "right" },  -- Zaap Scara   +  Reboucle ( il reboucle sur le zaap )
		                { map = "0,24", changeMap = "right", custom = TryGather },
		                { map = "1,24", changeMap = "bottom", custom = TryGather },
		                { map = "1,25", changeMap = "bottom", custom = TryGather },
		                { map = "1,26", changeMap = "bottom", custom = TryGather },
		                { map = "1,27", changeMap = "left", custom = TryGather },
		                { map = "0,27", changeMap = "bottom", custom = TryGather },
		                { map = "0,28", changeMap = "right", custom = TryGather },
		                { map = "1,28", changeMap = "bottom", custom = TryGather },
		                { map = "1,29", changeMap = "left", custom = TryGather },
		                { map = "0,29", changeMap = "bottom", custom = TryGather },
		                { map = "0,30", changeMap = "right", custom = TryGather },
		                { map = "1,30", changeMap = "right", custom = TryGather },
		                { map = "2,30", changeMap = "bottom", custom = TryGather },
		                { map = "2,31", changeMap = "bottom", custom = TryGather },
		                { map = "2,32", changeMap = "right", custom = TryGather },
		                { map = "3,32", changeMap = "right", custom = TryGather },
		                { map = "4,32", changeMap = "right", custom = TryGather },
		                { map = "5,32", changeMap = "top", custom = TryGather },
		                { map = "5,31", changeMap = "top", custom = TryGather },
		                { map = "5,30", changeMap = "right", custom = TryGather },
		                { map = "6,30", changeMap = "right", custom = TryGather },
		                { map = "7,30", changeMap = "bottom", custom = TryGather },
		                { map = "7,31", changeMap = "right", custom = TryGather },
		                { map = "8,31", changeMap = "top", custom = TryGather },
		                { map = "8,30", changeMap = "right", custom = TryGather },
		                { map = "9,30", changeMap = "right", custom = TryGather },
		                { map = "10,30", changeMap = "top", custom = TryGather },
		                { map = "10,29", changeMap = "left", custom = TryGather },
		                { map = "9,29", changeMap = "left", custom = TryGather },
		                { map = "8,29", changeMap = "left", custom = TryGather },
		                { map = "7,29", changeMap = "left", custom = TryGather },
		                { map = "6,29", changeMap = "top", custom = TryGather },
		                { map = "6,28", changeMap = "left", custom = TryGather },
		                { map = "5,28", changeMap = "top", custom = TryGather },
		                { map = "5,27", changeMap = "left", custom = TryGather },
		                { map = "4,27", changeMap = "top", custom = TryGather },
		                { map = "4,26", changeMap = "top", custom = TryGather },
		                { map = "4,25", changeMap = "top", custom = TryGather },
		                { map = "4,24", changeMap = "top", custom = TryGather },
		                { map = "4,23", changeMap = "top", custom = TryGather },
		                { map = "4,22", changeMap = "right", custom = TryGather },
		                { map = "5,22", changeMap = "right", custom = TryGather },
		                { map = "6,22", changeMap = "right", custom = TryGather },
		                { map = "7,22", changeMap = "top", custom = TryGather },
		                { map = "7,21", changeMap = "right", custom = TryGather },
		                { map = "8,21", changeMap = "right", custom = TryGather },
		                { map = "9,21", changeMap = "right", custom = TryGather },
		                { map = "10,21", changeMap = "bottom", custom = TryGather },
		                { map = "10,22", changeMap = "right", custom = TryGather },
		                { map = "11,22", changeMap = "right", custom = TryGather },
		                { map = "12,22", changeMap = "top", custom = TryGather },
		                { map = "12,21", changeMap = "left", custom = TryGather },
		                { map = "11,21", changeMap = "top", custom = TryGather },
		                { map = "11,20", changeMap = "left", custom = TryGather },
		                { map = "10,20", changeMap = "left", custom = TryGather },
		                { map = "9,20", changeMap = "top", custom = TryGather },
		                { map = "9,19", changeMap = "left", custom = TryGather },
		                { map = "8,19", changeMap = "left", custom = TryGather },
		                { map = "7,19", changeMap = "top", custom = TryGather },
		                { map = "7,18", changeMap = "left", custom = TryGather },
		                { map = "6,18", changeMap = "bottom", custom = TryGather },
		                { map = "6,19", changeMap = "bottom", custom = TryGather },
		                { map = "6,20", changeMap = "bottom", custom = TryGather },
		                { map = "6,21", changeMap = "left", custom = TryGather },
		                { map = "5,21", changeMap = "left", custom = TryGather },
		                { map = "4,21", changeMap = "left", custom = TryGather },
		                { map = "3,21", changeMap = "top", custom = TryGather },
		                { map = "3,20", changeMap = "left", custom = TryGather },
		                { map = "2,20", changeMap = "bottom", custom = TryGather },
		                { map = "2,21", changeMap = "bottom", custom = TryGather },
		                { map = "2,22", changeMap = "bottom", custom = TryGather },
		                { map = "2,23", changeMap = "left", custom = TryGather },
		                { map = "1,23", changeMap = "left", custom = TryGather },
		                { map = "0,23", changeMap = "left", custom = TryGather },
		                { map = "-1,23", changeMap = "bottom", custom = bouclePlus } -- fin de boucle
                    }
                end
            },
            [2] = {
                name = "Zone Ortie coin des bouftout",
                tags = {
                    "Ortie"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88082704)") -- Zaap Scara
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "5,7", changeMap = "right" },  -- Zaap Bouftout
		                { map = "6,7", changeMap = "right", custom = TryGather },  -- Reboucle
		                { map = "7,7", changeMap = "top", custom = TryGather },
		                { map = "7,6", changeMap = "right", custom = TryGather },
		                { map = "8,6", changeMap = "right", custom = TryGather },
		                { map = "9,6", changeMap = "right", custom = TryGather },
		                { map = "10,6", changeMap = "right", custom = TryGather },
		                { map = "11,6", changeMap = "bottom", custom = TryGather },
		                { map = "11,7", changeMap = "bottom", custom = TryGather },
		                { map = "11,8", changeMap = "bottom", custom = TryGather },
		                { map = "11,9", changeMap = "left", custom = TryGather },
		                { map = "10,9", changeMap = "bottom", custom = TryGather },
		                { map = "10,10", changeMap = "right", custom = TryGather },
		                { map = "11,10", changeMap = "bottom", custom = TryGather },
		                { map = "11,11", changeMap = "bottom", custom = TryGather },
		                { map = "11,12", changeMap = "left", custom = TryGather },
		                { map = "10,12", changeMap = "left", custom = TryGather },
		                { map = "9,12", changeMap = "left", custom = TryGather },
		                { map = "8,12", changeMap = "left", custom = TryGather },
		                { map = "7,12", changeMap = "left", custom = TryGather },
		                { map = "6,12", changeMap = "left", custom = TryGather },
		                { map = "5,12", changeMap = "top|bottom", custom = TryGather },
		                { map = "5,13", changeMap = "bottom", custom = TryGather },
		                { map = "5,14", changeMap = "left", custom = TryGather },
		                { map = "4,14", changeMap = "left", custom = TryGather },
		                { map = "3,14", changeMap = "left", custom = TryGather },
		                { map = "2,14", changeMap = "top", custom = TryGather },
		                { map = "2,13", changeMap = "left", custom = TryGather },
		                { map = "1,13", changeMap = "bottom", custom = TryGather },
		                { map = "1,14", changeMap = "left", custom = TryGather },
		                { map = "0,14", changeMap = "left", custom = TryGather },
		                { map = "-1,14", changeMap = "top", custom = TryGather },
		                { map = "-1,13", changeMap = "right", custom = TryGather },
		                { map = "0,13", changeMap = "top", custom = TryGather },
		                { map = "0,12", changeMap = "left", custom = TryGather },
		                { map = "-1,12", changeMap = "top", custom = TryGather },
		                { map = "-1,11", changeMap = "top", custom = TryGather },
		                { map = "-1,10", changeMap = "right", custom = TryGather },
		                { map = "0,10", changeMap = "bottom", custom = TryGather },
		                { map = "0,11", changeMap = "right", custom = TryGather },
		                { map = "1,11", changeMap = "right", custom = TryGather },
		                { map = "2,11", changeMap = "bottom", custom = TryGather },
		                { map = "2,12", changeMap = "right", custom = TryGather },
		                { map = "3,12", changeMap = "top", custom = TryGather },
		                { map = "3,11", changeMap = "top", custom = TryGather },
		                { map = "3,10", changeMap = "right", custom = TryGather },
		                { map = "4,10", changeMap = "right", custom = TryGather },
		                { map = "5,10", changeMap = "right", custom = TryGather },
		                { map = "6,10", changeMap = "top", custom = TryGather },
		                { map = "6,9", changeMap = "right", custom = TryGather },
		                { map = "7,9", changeMap = "right", custom = TryGather },
		                { map = "8,9", changeMap = "top", custom = TryGather },
		                { map = "8,8", changeMap = "left", custom = TryGather },
		                { map = "7,8", changeMap = "left", custom = TryGather },
		                { map = "6,8", changeMap = "top", custom = TryGatherWithBP } -- fin de boucle
                    }
                end
            },
            [3] = {
                name = "Zone Ortie village amakna",
                tags = {
                    "Ortie"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88213271)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "-2,0", changeMap = "left" },  -- Zaap Amakna Village  +  Reboucle
		                { map = "-3,0", changeMap = "top", custom = TryGather },
		                { map = "-3,-1", changeMap = "top", custom = TryGather },
		                { map = "-3,-2", changeMap = "right", custom = TryGather },
		                { map = "-2,-2", changeMap = "top", custom = TryGather },
		                { map = "-2,-3", changeMap = "top", custom = TryGather },
		                { map = "-2,-4", changeMap = "right", custom = TryGather },
		                { map = "-1,-4", changeMap = "right", custom = TryGather },
		                { map = "0,-4", changeMap = "right", custom = TryGather },
		                { map = "1,-4", changeMap = "bottom", custom = TryGather },
		                { map = "1,-3", changeMap = "left", custom = TryGather },
		                { map = "0,-3", changeMap = "bottom", custom = TryGather },
		                { map = "0,-2", changeMap = "bottom", custom = TryGather },
		                { map = "0,-1", changeMap = "right", custom = TryGather },
		                { map = "1,-1", changeMap = "right", custom = TryGather },
		                { map = "2,-1", changeMap = "right", custom = TryGather },
		                { map = "3,-1", changeMap = "bottom", custom = TryGather },
		                { map = "3,0", changeMap = "right", custom = TryGather },
		                { map = "4,0", changeMap = "right", custom = TryGather },
		                { map = "5,0", changeMap = "right", custom = TryGather },
		                { map = "6,0", changeMap = "top", custom = TryGather },
		                { map = "6,-1", changeMap = "right", custom = TryGather },
		                { map = "7,-1", changeMap = "bottom", custom = TryGather },
		                { map = "7,0", changeMap = "right", custom = TryGather },
		                { map = "8,0", changeMap = "bottom", custom = TryGather },
		                { map = "8,1", changeMap = "bottom", custom = TryGather },
		                { map = "8,2", changeMap = "bottom", custom = TryGather },
		                { map = "8,3", changeMap = "bottom", custom = TryGather },
		                { map = "8,4", changeMap = "left", custom = TryGather },
		                { map = "7,4", changeMap = "bottom", custom = TryGather },
		                { map = "7,5", changeMap = "left", custom = TryGather },
		                { map = "6,5", changeMap = "left", custom = TryGather },
		                { map = "5,5", changeMap = "top", custom = TryGather },
		                { map = "5,4", changeMap = "right", custom = TryGather },
		                { map = "6,4", changeMap = "top", custom = TryGather },
		                { map = "6,3", changeMap = "top", custom = TryGather },
		                { map = "6,2", changeMap = "right", custom = TryGather },
		                { map = "7,2", changeMap = "top", custom = TryGather },
		                { map = "7,1", changeMap = "left", custom = TryGather },
		                { map = "6,1", changeMap = "left", custom = TryGather },
		                { map = "5,1", changeMap = "left", custom = TryGather },
		                { map = "4,1", changeMap = "left", custom = TryGather },
		                { map = "3,1", changeMap = "left", custom = TryGather },
		                { map = "2,1", changeMap = "top", custom = TryGather },
		                { map = "2,0", changeMap = "left", custom = TryGather },
		                { map = "1,0", changeMap = "bottom", custom = TryGather },
		                { map = "1,1", changeMap = "left", custom = TryGather },
		                { map = "0,1", changeMap = "left", custom = TryGather },
		                { map = "-1,1", changeMap = "top", custom = TryGather },
		                { map = "-1,0", changeMap = "left", custom = bouclePlus }  -- fin de boucle
                    }
                end
            },
            [4] = {
                name = "Zone Ortie plaine des porkass",
                tags = {
                    "BUG"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,84806401)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "-5,-23", changeMap = "right" },  -- Zaap Plaines des porkass
		                { map = "-4,-23", changeMap = "top", custom = TryGather },
		                { map = "-4,-24", changeMap = "top", custom = TryGather },
		                { map = "-4,-25", changeMap = "top", custom = TryGather },
		                { map = "-4,-26", changeMap = "top", custom = TryGather },
		                { map = "-4,-27", changeMap = "top", custom = TryGather },
		                { map = "-4,-28", changeMap = "top", custom = TryGather },
		                { map = "-4,-29", changeMap = "left", custom = TryGather },
		                { map = "-5,-29", changeMap = "top", custom = TryGather },
		                { map = "-5,-30", changeMap = "top", custom = TryGather },
		                { map = "-5,-31", changeMap = "top", custom = TryGather },
		                { map = "-5,-32", changeMap = "top", custom = TryGather },
		                { map = "-5,-33", changeMap = "right", custom = TryGather },
		                { map = "-4,-33", changeMap = "top", custom = TryGather },
		                { map = "-4,-34", changeMap = "left", custom = TryGather },
		                { map = "-5,-34", changeMap = "left", custom = TryGather },
		                { map = "-6,-34", changeMap = "left", custom = TryGather },
		                { map = "-7,-34", changeMap = "left", custom = TryGather },
		                { map = "-8,-34", changeMap = "top", custom = TryGather },
		                { map = "-8,-35", changeMap = "left", custom = TryGather },
		                { map = "-9,-35", changeMap = "bottom", custom = TryGather },
		                { map = "-9,-34", changeMap = "bottom", custom = TryGather },
		                { map = "-9,-33", changeMap = "left", custom = TryGather },
		                { map = "-10,-33", changeMap = "top", custom = TryGather },
		                { map = "-10,-34", changeMap = "top", custom = TryGather },
		                { map = "-10,-35", changeMap = "top", custom = TryGather },
		                { map = "-10,-36", changeMap = "left", custom = TryGather },
		                { map = "-11,-36", changeMap = "bottom", custom = TryGather },
		                { map = "-11,-35", changeMap = "left", custom = TryGather },
		                { map = "-12,-35", changeMap = "bottom", custom = TryGather },
		                { map = "-12,-34", changeMap = "right", custom = TryGather },
		                { map = "-11,-34", changeMap = "bottom", custom = TryGather },
		                { map = "-11,-33", changeMap = "bottom", custom = TryGather },
		                { map = "-11,-32", changeMap = "left", custom = TryGather },
		                { map = "-12,-32", changeMap = "left", custom = TryGather },
		                { map = "-13,-32", changeMap = "bottom", custom = TryGather },
		                { map = "-13,-31", changeMap = "left", custom = TryGather },
		                { map = "-14,-31", changeMap = "bottom", custom = TryGather },
		                { map = "-14,-30", changeMap = "right", custom = TryGather },
		                { map = "-13,-30", changeMap = "bottom", custom = TryGather },
		                { map = "-13,-29", changeMap = "left", custom = TryGather },
		                { map = "-14,-29", changeMap = "bottom", custom = TryGather },
		                { map = "-14,-28", changeMap = "right", custom = TryGather },
		                { map = "-13,-28", changeMap = "bottom", custom = TryGather },
		                { map = "-13,-27", changeMap = "left", custom = TryGather },
		                { map = "-14,-27", changeMap = "bottom", custom = TryGather },
		                { map = "-14,-26", changeMap = "bottom", custom = TryGather },
		                { map = "-14,-25", changeMap = "bottom", custom = TryGather },
		                { map = "-14,-24", changeMap = "right", custom = TryGather },
		                { map = "-13,-24", changeMap = "bottom", custom = TryGather },
		                { map = "-13,-23", changeMap = "bottom", custom = TryGather },
		                { map = "-13,-22", changeMap = "right", custom = TryGather },
		                { map = "-12,-22", changeMap = "bottom", custom = TryGather },
		                { map = "-12,-21", changeMap = "right", custom = TryGather },
		                { map = "-11,-21", changeMap = "bottom", custom = TryGather },
		                { map = "-11,-20", changeMap = "right", custom = TryGather },
		                { map = "-10,-20", changeMap = "bottom", custom = TryGather },
		                { map = "-10,-19", changeMap = "bottom", custom = TryGather },
		                { map = "-10,-18", changeMap = "right", custom = TryGather },
		                { map = "-9,-18", changeMap = "top", custom = TryGather },
		                { map = "-9,-19", changeMap = "right", custom = TryGather },
		                { map = "-8,-19", changeMap = "bottom", custom = TryGather },
		                { map = "-8,-18", changeMap = "right", custom = TryGather },
		                { map = "-7,-18", changeMap = "top", custom = TryGather },
		                { map = "-7,-19", changeMap = "right", custom = TryGather },
		                { map = "-6,-19", changeMap = "right", custom = TryGather },
		                { map = "-5,-19", changeMap = "top", custom = TryGather },
		                { map = "-5,-20", changeMap = "top", custom = TryGather },
		                { map = "-5,-21", changeMap = "top", custom = TryGather },
		                { map = "-5,-22", changeMap = "top", custom = TryGatherWithBP }  -- fin de boucle
                    }
                end
            },
            [5] = {
                name = "Zone Sauge champs de cania",
                tags = {
                    "Sauge"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,142087694)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "-27,-36", changeMap = "bottom" },  -- Zaap sous bonta
		                { map = "-27,-35", changeMap = "left", custom = TryGather },  -- Reboucle
		                { map = "-28,-35", changeMap = "left", custom = TryGather }, 
		                { map = "-29,-35", changeMap = "left", custom = TryGather },
		                { map = "-30,-35", changeMap = "top", custom = TryGather },
		                { map = "-30,-36", changeMap = "top", custom = TryGather },
		                { map = "-30,-37", changeMap = "top", custom = TryGather },
		                { map = "-30,-38", changeMap = "left", custom = TryGather },
		                { map = "-31,-38", changeMap = "top", custom = TryGather },
		                { map = "-31,-39", changeMap = "top", custom = TryGather },
		                { map = "-31,-40", changeMap = "right", custom = TryGather },
		                { map = "-30,-40", changeMap = "bottom", custom = TryGather },
		                { map = "-30,-39", changeMap = "right", custom = TryGather },
		                { map = "-29,-39", changeMap = "right", custom = TryGather },
		                { map = "-28,-39", changeMap = "right", custom = TryGather },
		                { map = "-27,-39", changeMap = "top", custom = TryGather },
		                { map = "-27,-40", changeMap = "left", custom = TryGather },
		                { map = "-28,-40", changeMap = "top", custom = TryGather },
		                { map = "-28,-41", changeMap = "right", custom = TryGather },
		                { map = "-27,-41", changeMap = "right", custom = TryGather },
		                { map = "-26,-41", changeMap = "top", custom = TryGather },
		                { map = "-26,-42", changeMap = "right", custom = TryGather },
		                { map = "-25,-42", changeMap = "right", custom = TryGather },
		                { map = "-24,-42", changeMap = "bottom", custom = TryGather },
		                { map = "-24,-41", changeMap = "right", custom = TryGather },
		                { map = "-23,-41", changeMap = "top", custom = TryGather },
		                { map = "-23,-42", changeMap = "right", custom = TryGather },
		                { map = "-22,-42", changeMap = "right", custom = TryGather },
		                { map = "-21,-42", changeMap = "bottom", custom = TryGather },
		                { map = "-21,-41", changeMap = "bottom", custom = TryGather },
		                { map = "-21,-40", changeMap = "left", custom = TryGather },
		                { map = "-22,-40", changeMap = "bottom", custom = TryGather },
		                { map = "-22,-39", changeMap = "bottom", custom = TryGather },
		                { map = "-22,-38", changeMap = "bottom", custom = TryGather },
		                { map = "-22,-37", changeMap = "left", custom = TryGather },
		                { map = "-23,-37", changeMap = "top", custom = TryGather },
		                { map = "-23,-38", changeMap = "top", custom = TryGather },
		                { map = "-23,-39", changeMap = "left", custom = TryGather },
		                { map = "-24,-39", changeMap = "left", custom = TryGather },
		                { map = "-25,-39", changeMap = "left", custom = TryGather },
		                { map = "-26,-39", changeMap = "bottom", custom = TryGather },
		                { map = "-26,-38", changeMap = "right", custom = TryGather },
		                { map = "-25,-38", changeMap = "bottom", custom = TryGather },
		                { map = "-25,-37", changeMap = "bottom", custom = TryGather },
		                { map = "-25,-36", changeMap = "right", custom = TryGather },
		                { map = "-24,-36", changeMap = "bottom", custom = TryGather },
		                { map = "-24,-35", changeMap = "left", custom = TryGather },
		                { map = "-25,-35", changeMap = "left", custom = TryGather },
		                { map = "-26,-35", changeMap = "left", custom = TryGatherWithBP }  -- fin de boucle
                    }
                end
            },
            [6] = {
                name = "Zone Sauge plaine des porkass",
                tags = {
                    "Sauge"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,84806401)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "-5,-23", changeMap = "top" },  -- Zaap porkass  + Reboucle
		                { map = "-5,-24", changeMap = "top", custom = TryGather },
		                { map = "-5,-25", changeMap = "left", custom = TryGather },
		                { map = "-6,-25", changeMap = "top", custom = TryGather },
		                { map = "-6,-26", changeMap = "top", custom = TryGather },
		                { map = "-6,-27", changeMap = "top", custom = TryGather },
		                { map = "-6,-28", changeMap = "right", custom = TryGather },
		                { map = "-5,-28", changeMap = "right", custom = TryGather },
		                { map = "-4,-28", changeMap = "right", custom = TryGather },
		                { map = "-3,-28", changeMap = "bottom", custom = TryGather },
		                { map = "-3,-27", changeMap = "right", custom = TryGather },
		                { map = "-2,-27", changeMap = "right", custom = TryGather },
		                { map = "-1,-27", changeMap = "right", custom = TryGather },
		                { map = "0,-27", changeMap = "right", custom = TryGather },
		                { map = "1,-27", changeMap = "bottom", custom = TryGather },
		                { map = "1,-26", changeMap = "left", custom = TryGather },
		                { map = "0,-26", changeMap = "left", custom = TryGather },
		                { map = "-1,-26", changeMap = "left", custom = TryGather },
		                { map = "-2,-26", changeMap = "bottom", custom = TryGather },
		                { map = "-2,-25", changeMap = "right", custom = TryGather },
		                { map = "-1,-25", changeMap = "right", custom = TryGather },
		                { map = "0,-25", changeMap = "right", custom = TryGather },
		                { map = "1,-25", changeMap = "bottom", custom = TryGather },
		                { map = "1,-24", changeMap = "left", custom = TryGather },
		                { map = "0,-24", changeMap = "left", custom = TryGather },
		                { map = "-1,-24", changeMap = "left", custom = TryGather },
		                { map = "-2,-24", changeMap = "bottom", custom = TryGather },
		                { map = "-2,-23", changeMap = "left", custom = TryGather },
		                { map = "-3,-23", changeMap = "top", custom = TryGather },
		                { map = "-3,-24", changeMap = "left", custom = TryGather },
		                { map = "-4,-24", changeMap = "bottom", custom = TryGather },
		                { map = "-4,-23", changeMap = "left", custom = TryGatherWithBP }  -- fin de boucle
                    }
                end
            },
            [7] = {
                name = "Zone Sauge routes rocailleuse",
                tags = {
                    "Sauge"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,164364304)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
		                {map = "-20,-20", changeMap = "right" },  -- Zaap Routes rocailleuse  ID zaap 164364304 
		                {map = "-19,-20", changeMap = "right", gather = true, custom = TryGather },  -- Rebouble
		                {map = "-18,-20", changeMap = "top", gather = true, custom = TryGather },
		                {map = "-18,-21", changeMap = "top", gather = true, custom = TryGather },
		                {map = "-18,-22", changeMap = "top", gather = true, custom = TryGather },
		                {map = "-18,-23", changeMap = "top", gather = true, custom = TryGather },
		                {map = "-18,-24", changeMap = "right", gather = true, custom = TryGather },
		                {map = "-17,-24", changeMap = "bottom", gather = true, custom = TryGather },
		                {map = "-17,-23", changeMap = "bottom", gather = true, custom = TryGather },
		                {map = "-17,-22", changeMap = "right", gather = true, custom = TryGather },
		                {map = "-16,-22", changeMap = "bottom", gather = true, custom = TryGather },
		                {map = "-16,-21", changeMap = "right", gather = true, custom = TryGather },
		                {map = "-15,-21", changeMap = "bottom", gather = true, custom = TryGather },
		                {map = "-15,-20", changeMap = "right", gather = true, custom = TryGather },
		                {map = "-14,-20", changeMap = "bottom", gather = true, custom = TryGather },
		                {map = "-14,-19", changeMap = "bottom", gather = true, custom = TryGather },
		                {map = "-14,-18", changeMap = "left", gather = true, custom = TryGather },
		                {map = "-15,-18", changeMap = "top", gather = true, custom = TryGather },
		                {map = "-15,-19", changeMap = "left", gather = true, custom = TryGather },
		                {map = "-16,-19", changeMap = "left", gather = true, custom = TryGather },
		                {map = "-17,-19", changeMap = "bottom", gather = true, custom = TryGather },
		                {map = "-17,-18", changeMap = "bottom", gather = true, custom = TryGather },
		                {map = "-17,-17", changeMap = "bottom", gather = true, custom = TryGather },
		                {map = "-17,-16", changeMap = "bottom", gather = true, custom = TryGather },
		                {map = "-17,-15", changeMap = "bottom", gather = true, custom = TryGather },
		                {map = "-17,-14", changeMap = "left", gather = true, custom = TryGather },
		                {map = "-18,-14", changeMap = "left", gather = true, custom = TryGather },
		                {map = "-19,-14", changeMap = "top", gather = true, custom = TryGather },
		                {map = "-19,-15", changeMap = "top", gather = true, custom = TryGather },
		                {map = "-19,-16", changeMap = "top", gather = true, custom = TryGather },
		                {map = "-19,-17", changeMap = "top", gather = true, custom = TryGather },
		                {map = "-19,-18", changeMap = "top", gather = true, custom = TryGather },
		                {map = "-19,-19", changeMap = "top", gather = true, custom = TryGatherWithBP }  -- fin de boucle
                    }
                end
            },
            [8] = {
                name = "Zone Sauge coin des bouftout",
                tags = {
                    "Sauge"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88082704)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "5,7", changeMap = "right" },  -- Zaap bouftout  +  Reboucle
		                { map = "6,7", changeMap = "bottom", custom = TryGather },
		                { map = "6,8", changeMap = "right", custom = TryGather },
		                { map = "7,8", changeMap = "top", custom = TryGather },
		                { map = "7,7", changeMap = "top", custom = TryGather },
		                { map = "7,6", changeMap = "top", custom = TryGather },
		                { map = "6,5", changeMap = "top", custom = TryGather },
		                { map = "6,4", changeMap = "right", custom = TryGather },
		                { map = "7,4", changeMap = "right", custom = TryGather },
		                { map = "8,4", changeMap = "top", custom = TryGather },
		                { map = "8,3", changeMap = "top", custom = TryGather },
		                { map = "8,2", changeMap = "top", custom = TryGather },
		                { map = "8,1", changeMap = "left", custom = TryGather },
		                { map = "7,1", changeMap = "left", custom = TryGather },
		                { map = "6,1", changeMap = "top", custom = TryGather },
		                { map = "6,0", changeMap = "left", custom = TryGather },
		                { map = "5,0", changeMap = "bottom", custom = TryGather },
		                { map = "5,1", changeMap = "bottom", custom = TryGather },
		                { map = "5,2", changeMap = "bottom", custom = TryGather },
		                { map = "5,3", changeMap = "left", custom = TryGather },
		                { map = "4,3", changeMap = "left", custom = TryGather },
		                { map = "3,3", changeMap = "left", custom = TryGather },
		                { map = "2,3", changeMap = "left", custom = TryGather },
		                { map = "1,3", changeMap = "left", custom = TryGather },
		                { map = "0,3", changeMap = "left", custom = TryGather },
		                { map = "-1,3", changeMap = "left", custom = TryGather },
		                { map = "-2,3", changeMap = "bottom", custom = TryGather },
		                { map = "-2,4", changeMap = "right", custom = TryGather },
		                { map = "-1,4", changeMap = "right", custom = TryGather },
		                { map = "0,4", changeMap = "right", custom = TryGather },
		                { map = "1,4", changeMap = "right", custom = TryGather },
		                { map = "2,4", changeMap = "bottom", custom = TryGather },
		                { map = "2,5", changeMap = "right", custom = TryGather },
		                { map = "3,5", changeMap = "bottom", custom = TryGather },
		                { map = "3,6", changeMap = "right", custom = TryGather },
		                { map = "7,5", changeMap = "left", custom = TryGather },
		                { map = "4,6", changeMap = "bottom", custom = TryGather },
		                { map = "4,7", changeMap = "right", custom = TryGatherWithBP }  -- fin de boucle
                    }
                end
            },
            [9] = {
                name = "Zone Trefle a 5 feuille coin des Scarafeuille",
                tags = {
                    "Trefle a 5 feuille"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212481)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "-1,24", changeMap = "left" },  -- Zaap scara
		                { map = "-2,24", changeMap = "left", custom = TryGather },  -- Reboucle
		                { map = "-3,24", changeMap = "left", custom = TryGather },
		                { map = "-4,24", changeMap = "bottom", custom = TryGather },
		                { map = "-4,25", changeMap = "bottom", custom = TryGather },
		                { map = "-4,26", changeMap = "bottom", custom = TryGather },
		                { map = "-4,27", changeMap = "left", custom = TryGather },
		                { map = "-5,27", changeMap = "left", custom = TryGather },
		                { map = "-6,27", changeMap = "bottom", custom = TryGather },
		                { map = "-6,28", changeMap = "bottom", custom = TryGather },
		                { map = "-6,29", changeMap = "right", custom = TryGather },
		                { map = "-5,29", changeMap = "bottom", custom = TryGather },
		                { map = "-5,30", changeMap = "bottom", custom = TryGather },
		                { map = "-5,31", changeMap = "bottom", custom = TryGather },
		                { map = "-5,32", changeMap = "right", custom = TryGather },
		                { map = "-4,32", changeMap = "top", custom = TryGather },
		                { map = "-4,31", changeMap = "top", custom = TryGather },
		                { map = "-4,30", changeMap = "right", custom = TryGather },
		                { map = "-3,30", changeMap = "right", custom = TryGather },
		                { map = "-2,30", changeMap = "top", custom = TryGather },
		                { map = "-2,29", changeMap = "left", custom = TryGather },
		                { map = "-3,29", changeMap = "top", custom = TryGather },
		                { map = "-3,28", changeMap = "top", custom = TryGather },
		                { map = "-3,27", changeMap = "top", custom = TryGather },
		                { map = "-3,26", changeMap = "right", custom = TryGather },
		                { map = "-2,26", changeMap = "top", custom = TryGather },
		                { map = "-2,25", changeMap = "top", custom = TryGatherWithBP }  -- fin de boucle
                    }
                end
            },
            [10] = {
                name = "Zone Trefle a 5 feuille coin des bouftout",
                tags = {
                    "Trefle a 5 feuille"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88082704)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "5,7", changeMap = "right" },  -- Zaap Bouftout  +  Reboucle
		                { map = "6,7", changeMap = "right", custom = TryGather },
		                { map = "7,7", changeMap = "bottom", custom = TryGather },
		                { map = "7,8", changeMap = "right", custom = TryGather },
		                { map = "8,8", changeMap = "right", custom = TryGather },
		                { map = "9,8", changeMap = "right", custom = TryGather },
		                { map = "10,8", changeMap = "top", custom = TryGather },
		                { map = "10,7", changeMap = "top", custom = TryGather },
		                { map = "10,6", changeMap = "right", custom = TryGather },
		                { map = "11,6", changeMap = "top", custom = TryGather },
		                { map = "11,5", changeMap = "left", custom = TryGather },
		                { map = "10,5", changeMap = "left", custom = TryGather },
		                { map = "9,5", changeMap = "left", custom = TryGather },
		                { map = "7,5", changeMap = "left", custom = TryGather },
		                { map = "8,5", changeMap = "left", custom = TryGather },
		                { map = "6,5", changeMap = "left", custom = TryGather },
		                { map = "5,5", changeMap = "left", custom = TryGather },
		                { map = "4,5", changeMap = "left", custom = TryGather },
		                { map = "3,5", changeMap = "left", custom = TryGather },
		                { map = "2,5", changeMap = "left", custom = TryGather },
		                { map = "1,5", changeMap = "left", custom = TryGather },
		                { map = "0,5", changeMap = "bottom", custom = TryGather },
		                { map = "0,6", changeMap = "right", custom = TryGather },
		                { map = "1,6", changeMap = "right", custom = TryGather },
		                { map = "2,6", changeMap = "bottom", custom = TryGather },
		                { map = "2,7", changeMap = "left", custom = TryGather },
		                { map = "1,7", changeMap = "bottom", custom = TryGather },
		                { map = "1,8", changeMap = "bottom", custom = TryGather },
		                { map = "1,9", changeMap = "right", custom = TryGather },
		                { map = "2,9", changeMap = "bottom", custom = TryGather },
		                { map = "2,10", changeMap = "bottom", custom = TryGather },
		                { map = "2,11", changeMap = "left", custom = TryGather },
		                { map = "1,11", changeMap = "bottom", custom = TryGather },
		                { map = "1,12", changeMap = "bottom", custom = TryGather },
		                { map = "1,13", changeMap = "bottom", custom = TryGather },
		                { map = "1,14", changeMap = "bottom", custom = TryGather },
		                { map = "1,15", changeMap = "bottom", custom = TryGather },
		                { map = "1,16", changeMap = "right", custom = TryGather },
		                { map = "2,16", changeMap = "top", custom = TryGather },
		                { map = "2,15", changeMap = "top", custom = TryGather },
		                { map = "2,14", changeMap = "top", custom = TryGather },
		                { map = "2,13", changeMap = "right", custom = TryGather },
		                { map = "3,13", changeMap = "bottom", custom = TryGather },
		                { map = "3,14", changeMap = "bottom", custom = TryGather },
		                { map = "3,15", changeMap = "right", custom = TryGather },
		                { map = "4,15", changeMap = "top", custom = TryGather },
		                { map = "4,14", changeMap = "top", custom = TryGather },
		                { map = "4,13", changeMap = "top", custom = TryGather },
		                { map = "4,12", changeMap = "right", custom = TryGather },
		                { map = "5,12", changeMap = "top", custom = TryGather },
		                { map = "5,11", changeMap = "top", custom = TryGather },
		                { map = "5,10", changeMap = "top", custom = TryGather },
		                { map = "5,9", changeMap = "top", custom = TryGather },
		                { map = "5,8", changeMap = "top", custom = bouclePlus }  -- fin de boucle
                    }
                end
            },
            [11] = {
                name = "Zone Trefle a 5 feuille village amakna",
                tags = {
                    "Trefle a 5 feuille"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88213271)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "-2,0", changeMap = "right" },  -- Zaap Amakna village
		                { map = "-1,0", changeMap = "top", custom = TryGather },  -- Reboucle
		                { map = "-1,-1", changeMap = "top", custom = TryGather },
		                { map = "-1,-2", changeMap = "top", custom = TryGather },
		                { map = "-1,-3", changeMap = "top", custom = TryGather },
		                { map = "-1,-4", changeMap = "right", custom = TryGather },
		                { map = "0,-4", changeMap = "bottom", custom = TryGather },
		                { map = "0,-3", changeMap = "bottom", custom = TryGather },
		                { map = "0,-2", changeMap = "right", custom = TryGather },
		                { map = "1,-2", changeMap = "top", custom = TryGather },
		                { map = "1,-3", changeMap = "right", custom = TryGather },
		                { map = "2,-3", changeMap = "bottom", custom = TryGather },
		                { map = "2,-2", changeMap = "right", custom = TryGather },
		                { map = "3,-2", changeMap = "bottom", custom = TryGather },
		                { map = "3,-1", changeMap = "right", custom = TryGather },
		                { map = "4,-1", changeMap = "right", custom = TryGather },
		                { map = "5,-1", changeMap = "top", custom = TryGather },
		                { map = "5,-2", changeMap = "top", custom = TryGather },
		                { map = "5,-3", changeMap = "right", custom = TryGather },
		                { map = "6,-3", changeMap = "right", custom = TryGather },
		                { map = "7,-3", changeMap = "bottom", custom = TryGather },
		                { map = "7,-2", changeMap = "bottom", custom = TryGather },
		                { map = "7,-1", changeMap = "right", custom = TryGather },
		                { map = "8,-1", changeMap = "top", custom = TryGather },
		                { map = "8,-2", changeMap = "right", custom = TryGather },
		                { map = "9,-2", changeMap = "bottom", custom = TryGather },
		                { map = "9,-1", changeMap = "bottom", custom = TryGather },
		                { map = "9,0", changeMap = "right", custom = TryGather },
		                { map = "10,0", changeMap = "right", custom = TryGather },
		                { map = "11,0", changeMap = "right", custom = TryGather },
		                { map = "12,0", changeMap = "right", custom = TryGather },
		                { map = "13,0", changeMap = "bottom", custom = TryGather },
		                { map = "13,1", changeMap = "left", custom = TryGather },
		                { map = "12,1", changeMap = "left", custom = TryGather },
		                { map = "11,1", changeMap = "left", custom = TryGather },
		                { map = "10,1", changeMap = "bottom", custom = TryGather },
		                { map = "10,2", changeMap = "left", custom = TryGather },
		                { map = "9,2", changeMap = "left", custom = TryGather },
		                { map = "8,2", changeMap = "left", custom = TryGather },
		                { map = "7,2", changeMap = "left", custom = TryGather },
		                { map = "6,2", changeMap = "top", custom = TryGather },
		                { map = "6,1", changeMap = "top", custom = TryGather },
		                { map = "6,0", changeMap = "left", custom = TryGather },
		                { map = "5,0", changeMap = "left", custom = TryGather },
		                { map = "4,0", changeMap = "bottom", custom = TryGather },
		                { map = "4,1", changeMap = "bottom", custom = TryGather },
		                { map = "4,2", changeMap = "left", custom = TryGather },
		                { map = "3,2", changeMap = "bottom", custom = TryGather },
		                { map = "3,3", changeMap = "left", custom = TryGather },
		                { map = "2,3", changeMap = "bottom", custom = TryGather },
		                { map = "2,4", changeMap = "left", custom = TryGather },
		                { map = "1,4", changeMap = "left", custom = TryGather },
		                { map = "0,4", changeMap = "left", custom = TryGather },
		                { map = "-1,4", changeMap = "top", custom = TryGather },
		                { map = "-1,3", changeMap = "top", custom = TryGather },
		                { map = "-1,2", changeMap = "top", custom = TryGather },
		                { map = "-1,1", changeMap = "top", custom = TryGatherWithBP }  -- fin de boucle
                    }
                end
            },
            [12] = {
                name = "Zone Menthe sauvage coin des bouftout",
                tags = {
                    "Menthe sauvage"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88082704)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "5,7", changeMap = "top" }, -- Zaap bouftout  +  Reboucle
		                { map = "5,6", changeMap = "top", custom = TryGather },
		                { map = "5,5", changeMap = "top", custom = TryGather },
		                { map = "5,4", changeMap = "top", custom = TryGather },
		                { map = "5,3", changeMap = "top", custom = TryGather },
		                { map = "5,2", changeMap = "left", custom = TryGather },
		                { map = "4,2", changeMap = "top", custom = TryGather },
		                { map = "4,1", changeMap = "right", custom = TryGather },
		                { map = "5,1", changeMap = "top", custom = TryGather },
		                { map = "5,0", changeMap = "top", custom = TryGather },
		                { map = "5,-1", changeMap = "left", custom = TryGather },
		                { map = "4,-1", changeMap = "left", custom = TryGather },
		                { map = "3,-1", changeMap = "left", custom = TryGather },
		                { map = "2,-1", changeMap = "left", custom = TryGather },
		                { map = "1,-1", changeMap = "left", custom = TryGather },
		                { map = "0,-1", changeMap = "left", custom = TryGather },
		                { map = "-1,-1", changeMap = "left", custom = TryGather },
		                { map = "-2,-1", changeMap = "left", custom = TryGather },
		                { map = "-3,-1", changeMap = "bottom", custom = TryGather },
		                { map = "-3,0", changeMap = "left", custom = TryGather },
		                { map = "-4,0", changeMap = "bottom", custom = TryGather },
		                { map = "-4,1", changeMap = "right", custom = TryGather },
		                { map = "-3,1", changeMap = "bottom", custom = TryGather },
		                { map = "-3,2", changeMap = "right", custom = TryGather },
		                { map = "-2,2", changeMap = "bottom", custom = TryGather },
		                { map = "-2,3", changeMap = "bottom", custom = TryGather },
		                { map = "-2,4", changeMap = "bottom", custom = TryGather },
		                { map = "-2,5", changeMap = "bottom", custom = TryGather },
		                { map = "-2,6", changeMap = "right", custom = TryGather },
		                { map = "-1,6", changeMap = "bottom", custom = TryGather },
		                { map = "-1,7", changeMap = "right", custom = TryGather },
		                { map = "0,7", changeMap = "bottom", custom = TryGather },
		                { map = "0,8", changeMap = "bottom", custom = TryGather },
		                { map = "0,9", changeMap = "left", custom = TryGather },
		                { map = "-1,9", changeMap = "left", custom = TryGather },
		                { map = "-2,9", changeMap = "left", custom = TryGather },
		                { map = "-3,9", changeMap = "bottom", custom = TryGather },
		                { map = "-3,10", changeMap = "right", custom = TryGather },
		                { map = "-2,10", changeMap = "right", custom = TryGather },
		                { map = "-1,10", changeMap = "right", custom = TryGather },
		                { map = "0,10", changeMap = "bottom", custom = TryGather },
		                { map = "0,11", changeMap = "right", custom = TryGather },
		                { map = "1,11", changeMap = "right", custom = TryGather },
		                { map = "2,11", changeMap = "right", custom = TryGather },
		                { map = "3,11", changeMap = "right", custom = TryGather },
		                { map = "4,11", changeMap = "right", custom = TryGather },
		                { map = "5,11", changeMap = "right", custom = TryGather },
		                { map = "6,11", changeMap = "right", custom = TryGather },
		                { map = "7,11", changeMap = "top", custom = TryGather },
		                { map = "7,10", changeMap = "top", custom = TryGather },
		                { map = "7,9", changeMap = "left", custom = TryGather },
		                { map = "6,9", changeMap = "top", custom = TryGather },
		                { map = "6,8", changeMap = "left", custom = TryGather },
		                { map = "5,8", changeMap = "top", custom = bouclePlus }
                    }
                end
            },
            [13] = {
                name = "Zone Menthe sauvage coin des Scarafeuille",
                tags = {
                    "Menthe sauvage"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212481)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "-1,24", changeMap = "right" },  -- Zaap Scara
		                { map = "0,24", changeMap = "bottom", custom = TryGather }, -- Reboucle
		                { map = "0,25", changeMap = "bottom", custom = TryGather },
		                { map = "0,26", changeMap = "bottom", custom = TryGather },
		                { map = "0,27", changeMap = "bottom", custom = TryGather },
		                { map = "0,28", changeMap = "bottom", custom = TryGather },
		                { map = "0,29", changeMap = "right", custom = TryGather },
		                { map = "1,29", changeMap = "right", custom = TryGather },
		                { map = "2,29", changeMap = "top", custom = TryGather },
		                { map = "2,28", changeMap = "right", custom = TryGather },
		                { map = "3,28", changeMap = "bottom", custom = TryGather },
		                { map = "3,29", changeMap = "bottom", custom = TryGather },
		                { map = "3,30", changeMap = "bottom", custom = TryGather },
		                { map = "3,31", changeMap = "bottom", custom = TryGather },
		                { map = "3,32", changeMap = "right", custom = TryGather },
		                { map = "4,32", changeMap = "right", custom = TryGather },
		                { map = "5,32", changeMap = "top", custom = TryGather },
		                { map = "5,31", changeMap = "top", custom = TryGather },
		                { map = "5,30", changeMap = "right", custom = TryGather },
		                { map = "6,30", changeMap = "right", custom = TryGather },
		                { map = "7,30", changeMap = "top", custom = TryGather },
		                { map = "7,29", changeMap = "left", custom = TryGather },
		                { map = "6,29", changeMap = "top", custom = TryGather },
		                { map = "6,28", changeMap = "left", custom = TryGather },
		                { map = "5,28", changeMap = "left", custom = TryGather },
		                { map = "4,28", changeMap = "top", custom = TryGather },
		                { map = "4,27", changeMap = "top", custom = TryGather },
		                { map = "4,26", changeMap = "top", custom = TryGather },
		                { map = "4,25", changeMap = "top", custom = TryGather },
		                { map = "4,24", changeMap = "top", custom = TryGather },
		                { map = "4,23", changeMap = "top", custom = TryGather },
		                { map = "4,22", changeMap = "right", custom = TryGather },
		                { map = "5,22", changeMap = "right", custom = TryGather },
		                { map = "6,22", changeMap = "right", custom = TryGather },
		                { map = "7,22", changeMap = "top", custom = TryGather },
		                { map = "7,21", changeMap = "right", custom = TryGather },
		                { map = "8,21", changeMap = "right", custom = TryGather },
		                { map = "9,21", changeMap = "right", custom = TryGather },
		                { map = "10,21", changeMap = "right", custom = TryGather },
		                { map = "11,21", changeMap = "right", custom = TryGather },
		                { map = "12,21", changeMap = "right", custom = TryGather },
		                { map = "13,21", changeMap = "right", custom = TryGather },
		                { map = "14,21", changeMap = "top", custom = TryGather },
		                { map = "14,20", changeMap = "top", custom = TryGather },
		                { map = "14,19", changeMap = "left", custom = TryGather },
		                { map = "13,19", changeMap = "bottom", custom = TryGather },
		                { map = "13,20", changeMap = "left", custom = TryGather },
		                { map = "12,20", changeMap = "left", custom = TryGather },
		                { map = "11,20", changeMap = "left", custom = TryGather },
		                { map = "10,20", changeMap = "left", custom = TryGather },
		                { map = "9,20", changeMap = "left", custom = TryGather },
		                { map = "8,20", changeMap = "left", custom = TryGather },
		                { map = "7,20", changeMap = "top", custom = TryGather },
		                { map = "7,19", changeMap = "top", custom = TryGather },
		                { map = "7,18", changeMap = "top", custom = TryGather },
		                { map = "7,17", changeMap = "top", custom = TryGather },
		                { map = "7,16", changeMap = "top", custom = TryGather },
		                { map = "7,15", changeMap = "top", custom = TryGather },
		                { map = "7,14", changeMap = "right", custom = TryGather },
		                { map = "8,14", changeMap = "top", custom = TryGather },
		                { map = "8,13", changeMap = "top", custom = TryGather },
		                { map = "8,12", changeMap = "left", custom = TryGather },
		                { map = "7,12", changeMap = "bottom", custom = TryGather },
		                { map = "7,13", changeMap = "left", custom = TryGather },
		                { map = "6,13", changeMap = "top", custom = TryGather },
		                { map = "6,12", changeMap = "left", custom = TryGather },
		                { map = "5,12", changeMap = "left", custom = TryGather },
		                { map = "4,12", changeMap = "left", custom = TryGather },
		                { map = "3,12", changeMap = "bottom", custom = TryGather },
		                { map = "3,13", changeMap = "left", custom = TryGather },
		                { map = "2,13", changeMap = "left", custom = TryGather },
		                { map = "1,13", changeMap = "left", custom = TryGather },
		                { map = "0,13", changeMap = "bottom", custom = TryGather },
		                { map = "0,14", changeMap = "right", custom = TryGather },
		                { map = "1,14", changeMap = "bottom", custom = TryGather },
		                { map = "1,15", changeMap = "right", custom = TryGather },
		                { map = "2,15", changeMap = "bottom", custom = TryGather },
		                { map = "2,16", changeMap = "left", custom = TryGather },
		                { map = "1,16", changeMap = "bottom", custom = TryGather },
		                { map = "1,17", changeMap = "right", custom = TryGather },
		                { map = "2,17", changeMap = "right", custom = TryGather },
		                { map = "3,17", changeMap = "bottom", custom = TryGather },
		                { map = "3,18", changeMap = "bottom", custom = TryGather },
		                { map = "3,19", changeMap = "bottom", custom = TryGather },
		                { map = "3,20", changeMap = "left", custom = TryGather },
		                { map = "2,20", changeMap = "left", custom = TryGather },
		                { map = "1,20", changeMap = "bottom", custom = TryGather },
		                { map = "1,21", changeMap = "bottom", custom = TryGather },
		                { map = "1,22", changeMap = "bottom", custom = TryGather },
		                { map = "1,23", changeMap = "bottom", custom = TryGather },
		                { map = "1,24", changeMap = "left", custom = bouclePlus }
                    }
                end
            },
            [14] = {
                name = "Zone Menthe sauvage Tainela",
                tags = {
                    "Menthe sauvage"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,120062979)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "1,-32", changeMap = "right" },  -- Zaap Tainela  +  Reboucle
		                { map = "2,-32", changeMap = "right", custom = TryGather },
		                { map = "3,-32", changeMap = "top", custom = TryGather },
		                { map = "3,-33", changeMap = "left", custom = TryGather },
		                { map = "2,-33", changeMap = "top", custom = TryGather },
		                { map = "2,-34", changeMap = "left", custom = TryGather },
		                { map = "1,-34", changeMap = "left", custom = TryGather },
		                { map = "0,-34", changeMap = "bottom", custom = TryGather },
		                { map = "0,-33", changeMap = "left", custom = TryGather },
		                { map = "-1,-33", changeMap = "bottom", custom = TryGather },
		                { map = "-1,-32", changeMap = "left", custom = TryGather },
		                { map = "-2,-32", changeMap = "bottom", custom = TryGather },
		                { map = "-2,-31", changeMap = "bottom", custom = TryGather },
		                { map = "-2,-30", changeMap = "right", custom = TryGather },
		                { map = "-1,-30", changeMap = "bottom", custom = TryGather },
		                { map = "-1,-29", changeMap = "right", custom = TryGather },
		                { map = "0,-29", changeMap = "right", custom = TryGather },
		                { map = "1,-29", changeMap = "top", custom = TryGather },
		                { map = "1,-30", changeMap = "top", custom = TryGather },
		                { map = "1,-31", changeMap = "top", custom = TryGatherWithBP } -- fin de boucle
                    }
                end
            },
            [15] = {
                name = "Zone Orchidee freyesque Village des eleveur",
                tags = {
                    "Orchidee freyesque"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,73400320)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "-16,1", changeMap = "right" },  -- Zaap eleveur
		                { map = "-15,1", changeMap = "bottom", custom = TryGather },
		                { map = "-15,2", changeMap = "right", custom = TryGather },
		                { map = "-14,2", changeMap = "bottom", custom = TryGather },
		                { map = "-14,3", changeMap = "left", custom = TryGather },
		                { map = "-15,3", changeMap = "left", custom = TryGather },
		                { map = "-16,3", changeMap = "top", custom = TryGather },
		                { map = "-16,2", changeMap = "left", custom = TryGather },
		                { map = "-17,2", changeMap = "left", custom = TryGather },
		                { map = "-18,2", changeMap = "bottom", custom = TryGather },
		                { map = "-18,3", changeMap = "bottom", custom = TryGather }, --- Reboucle
		                { map = "-18,4", changeMap = "left", custom = TryGather },
		                { map = "-19,4", changeMap = "left", custom = TryGather },
		                { map = "-20,4", changeMap = "left", custom = TryGather },
		                { map = "-21,4", changeMap = "left", custom = TryGather },
		                { map = "-22,4", changeMap = "top", custom = TryGather },
		                { map = "-22,3", changeMap = "top", custom = TryGather },
		                { map = "-22,2", changeMap = "left", custom = TryGather },
		                { map = "-23,2", changeMap = "top", custom = TryGather },
		                { map = "-23,1", changeMap = "right", custom = TryGather },
		                { map = "-22,1", changeMap = "top", custom = TryGather },
		                { map = "-22,0", changeMap = "right", custom = TryGather },
		                { map = "-21,0", changeMap = "bottom", custom = TryGather },
		                { map = "-21,1", changeMap = "bottom", custom = TryGather },
		                { map = "-21,2", changeMap = "bottom", custom = TryGather },
		                { map = "-21,3", changeMap = "right", custom = TryGather },
		                { map = "-20,3", changeMap = "top", custom = TryGather },
		                { map = "-20,2", changeMap = "top", custom = TryGather },
		                { map = "-20,1", changeMap = "top", custom = TryGather },
		                { map = "-20,0", changeMap = "top", custom = TryGather },
		                { map = "-20,-1", changeMap = "right", custom = TryGather },
		                { map = "-19,-1", changeMap = "bottom", custom = TryGather },
		                { map = "-19,0", changeMap = "bottom", custom = TryGather },
		                { map = "-19,1", changeMap = "bottom", custom = TryGather },
		                { map = "-19,2", changeMap = "bottom", custom = TryGather },
		                { map = "-19,3", changeMap = "right", custom = TryGatherWithBP } -- fin de boucle
                    }
                end
            },
            [16] = {
                name = "Zone Orchidee freyesque coin des Scarafeuille",
                tags = {
                    "Orchidee freyesque"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212481)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "-1,24", changeMap = "left" },  -- Zaap Scara
		                { map = "-2,24", changeMap = "left", custom = TryGather }, -- Reboucle
		                { map = "-3,24", changeMap = "left", custom = TryGather },
		                { map = "-4,24", changeMap = "left", custom = TryGather },
		                { map = "-5,24", changeMap = "left", custom = TryGather },
		                { map = "-6,24", changeMap = "bottom", custom = TryGather },
		                { map = "-6,25", changeMap = "bottom", custom = TryGather },
		                { map = "-6,26", changeMap = "right", custom = TryGather },
		                { map = "-5,26", changeMap = "bottom", custom = TryGather },
		                { map = "-5,27", changeMap = "left", custom = TryGather },
		                { map = "-6,27", changeMap = "bottom", custom = TryGather },
		                { map = "-6,28", changeMap = "right", custom = TryGather },
		                { map = "-5,28", changeMap = "right", custom = TryGather },
		                { map = "-4,28", changeMap = "right", custom = TryGather },
		                { map = "-3,28", changeMap = "right", custom = TryGather },
		                { map = "-2,28", changeMap = "top", custom = TryGather },
		                { map = "-2,27", changeMap = "top", custom = TryGather },
		                { map = "-2,26", changeMap = "right", custom = TryGather },
		                { map = "-1,26", changeMap = "top", custom = TryGather },
		                { map = "-1,25", changeMap = "left", custom = TryGather },
		                { map = "-2,25", changeMap = "top", custom = TryGatherWithBP } -- fin de boucle
                    }
                end
            },
            [17] = {
                name = "Zone Edelweiss Port de madrestam",
                tags = {
                    "Edelweiss"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,68419587)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
		                { map = "68419587", changeMap = "left" },
		                { map = "68551171", changeMap = "bottom" },
		                { map = "68551172", changeMap = "bottom", custom = TryGather },
		                { map = "68551173", changeMap = "right" },
		                { map = "68419589", changeMap = "bottom", custom = TryGather },
		                { map = "68419590", changeMap = "right", custom = TryGather },
		                { map = "68420102", changeMap = "bottom", custom = TryGather },
		                { map = "68420103", changeMap = "right", custom = TryGather },
		                { map = "68420615", changeMap = "right", custom = TryGather },
		                { map = "68421127", changeMap = "right" },
		                { map = "68421639", changeMap = "bottom" },
		                { map = "68421640", changeMap = "bottom", custom = TryGather },
		                { map = "68421641", changeMap = "top", custom = TryGather },
		                { map = "68421640", changeMap = "top", custom = TryGather },
		                { map = "68421639", changeMap = "top" },
		                { map = "68421127", changeMap = "left" },
		                { map = "68420615", changeMap = "left", custom = TryGather },
		                { map = "68420103", changeMap = "left", custom = TryGather },
		                { map = "68420102", changeMap = "top", custom = TryGather },
		                { map = "68419590", changeMap = "left", custom = TryGather },
		                { map = "68419589", changeMap = "top", custom = TryGather },
		                { map = "68551173", changeMap = "right" },
		                { map = "68551172", changeMap = "bottom", custom = TryGatherWithBP}
                    })
                end
            },
            [19] = {
                name = "Zone Ginseng Otomai",
                tags = {
                    "Ginseng"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,154642)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "-46,18", changeMap = "bottom" },  -- Zaap otomai
		                { map = "-46,19", changeMap = "left", custom = TryGather },
		                { map = "-47,19", changeMap = "left", custom = TryGather },
		                { map = "-48,19", changeMap = "left", custom = TryGather },
		                { map = "-49,19", changeMap = "bottom", custom = TryGather },
		                { map = "-49,20", changeMap = "bottom", custom = TryGather },
		                { map = "-49,21", changeMap = "left", custom = TryGather },
		                { map = "-50,21", changeMap = "left", custom = TryGather },
		                { map = "-51,21", changeMap = "top", custom = TryGather },
		                { map = "-51,20", changeMap = "top", custom = TryGather },  -- Reboucle
		                { map = "-51,19", changeMap = "top", custom = TryGather },
		                { map = "-51,18", changeMap = "right", custom = TryGather },
		                { map = "-50,18", changeMap = "top", custom = TryGather },
		                { map = "-50,17", changeMap = "left", custom = TryGather },
		                { map = "-51,17", changeMap = "top", custom = TryGather },
		                { map = "-51,16", changeMap = "right", custom = TryGather },
		                { map = "-50,16", changeMap = "top", custom = TryGather },
		                { map = "-50,15", changeMap = "top", custom = TryGather },
		                { map = "-50,14", changeMap = "left", custom = TryGather },
		                { map = "-51,14", changeMap = "top", custom = TryGather },
		                { map = "-51,13", changeMap = "top", custom = TryGather },
		                { map = "-51,12", changeMap = "left", custom = TryGather },
		                { map = "-52,12", changeMap = "bottom", custom = TryGather },
		                { map = "-52,13", changeMap = "left", custom = TryGather },
		                { map = "-53,13", changeMap = "top", custom = TryGather },
		                { map = "-53,12", changeMap = "top", custom = TryGather },
		                { map = "-53,11", changeMap = "right", custom = TryGather },
		                { map = "-52,11", changeMap = "top", custom = TryGather },
		                { map = "-52,10", changeMap = "left", custom = TryGather },
		                { map = "-53,10", changeMap = "left", custom = TryGather },
		                { map = "-54,10", changeMap = "left", custom = TryGather },
		                { map = "-55,10", changeMap = "bottom", custom = TryGather },
		                { map = "-55,11", changeMap = "right", custom = TryGather },
		                { map = "-54,11", changeMap = "bottom", custom = TryGather },
		                { map = "-54,12", changeMap = "left", custom = TryGather },
		                { map = "-55,12", changeMap = "bottom", custom = TryGather },
		                { map = "-55,13", changeMap = "left", custom = TryGather },
		                { map = "-56,13", changeMap = "bottom", custom = TryGather },
		                { map = "-56,14", changeMap = "bottom", custom = TryGather },
		                { map = "-56,15", changeMap = "right", custom = TryGather },
		                { map = "-55,15", changeMap = "right", custom = TryGather },
		                { map = "-54,15", changeMap = "right", custom = TryGather },
		                { map = "-53,15", changeMap = "right", custom = TryGather },
		                { map = "-52,15", changeMap = "bottom", custom = TryGather },
		                { map = "-52,16", changeMap = "bottom", custom = TryGather },
		                { map = "-52,17", changeMap = "bottom", custom = TryGather },
		                { map = "-52,18", changeMap = "bottom", custom = TryGather },
		                { map = "-52,19", changeMap = "bottom", custom = TryGather },
		                { map = "-52,20", changeMap = "right", custom = TryGatherWithBP }  -- fin de boucle
                    } 
                end
            },
            [20] = {
                name = "Zone Belladone Otomai",
                tags = {
                    "Belladone"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,154642)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "-46,18", changeMap = "bottom" },  --zaap otomai
		                { map = "-46,19", changeMap = "right", custom = TryGather },  -- Reboucle
		                { map = "-45,19", changeMap = "top", custom = TryGather },
		                { map = "-45,18", changeMap = "top", custom = TryGather },
		                { map = "-45,17", changeMap = "left", custom = TryGather },
		                { map = "-46,17", changeMap = "left", custom = TryGather },
		                { map = "-47,17", changeMap = "top", custom = TryGather },
		                { map = "-47,16", changeMap = "right", custom = TryGather },
		                { map = "-46,16", changeMap = "top", custom = TryGather },
		                { map = "-46,15", changeMap = "left", custom = TryGather },
		                { map = "-47,15", changeMap = "top", custom = TryGather },
		                { map = "-47,14", changeMap = "left", custom = TryGather },
		                { map = "-48,14", changeMap = "bottom", custom = TryGather },
		                { map = "-48,15", changeMap = "bottom", custom = TryGather },
		                { map = "-48,16", changeMap = "bottom", custom = TryGather },
		                { map = "-48,17", changeMap = "bottom", custom = TryGather },
		                { map = "-48,18", changeMap = "left", custom = TryGather },
		                { map = "-49,18", changeMap = "top", custom = TryGather },
		                { map = "-49,17", changeMap = "top", custom = TryGather },
		                { map = "-49,16", changeMap = "top", custom = TryGather },
		                { map = "-49,15", changeMap = "top", custom = TryGather },
		                { map = "-49,14", changeMap = "top", custom = TryGather },
		                { map = "-49,13", changeMap = "right", custom = TryGather },
		                { map = "-48,13", changeMap = "top", custom = TryGather },
		                { map = "-48,12", changeMap = "left", custom = TryGather },
		                { map = "-49,12", changeMap = "left", custom = TryGather },
		                { map = "-50,12", changeMap = "top", custom = TryGather },
		                { map = "-50,11", changeMap = "top", custom = TryGather },
		                { map = "-50,10", changeMap = "top", custom = TryGather },
		                { map = "-50,9", changeMap = "left", custom = TryGather },
		                { map = "-51,9", changeMap = "top", custom = TryGather },
		                { map = "-51,8", changeMap = "top", custom = TryGather },
		                { map = "-51,7", changeMap = "top", custom = TryGather },
		                { map = "-51,6", changeMap = "top", custom = TryGather },
		                { map = "-51,5", changeMap = "left", custom = TryGather },
		                { map = "-52,5", changeMap = "left", custom = TryGather },
		                { map = "-53,5", changeMap = "top", custom = TryGather },
		                { map = "-53,4", changeMap = "top", custom = TryGather },
		                { map = "-53,3", changeMap = "top", custom = TryGather },
		                { map = "-53,2", changeMap = "left", custom = TryGather },
		                { map = "-54,2", changeMap = "left", custom = TryGather },
		                { map = "-55,2", changeMap = "left", custom = TryGather },
		                { map = "-56,2", changeMap = "left", custom = TryGather },
		                { map = "-57,2", changeMap = "left", custom = TryGather },
		                { map = "-58,2", changeMap = "bottom", custom = TryGather },
		                { map = "-58,3", changeMap = "bottom", custom = TryGather },
		                { map = "-58,4", changeMap = "bottom", custom = TryGather },
		                { map = "-58,5", changeMap = "bottom", custom = TryGather },
		                { map = "-58,6", changeMap = "bottom", custom = TryGather },
		                { map = "-58,7", changeMap = "bottom", custom = TryGather },
		                { map = "-58,8", changeMap = "bottom", custom = TryGather },
		                { map = "-58,9", changeMap = "bottom", custom = TryGather },
		                { map = "-58,10", changeMap = "bottom", custom = TryGather },
		                { map = "-58,11", changeMap = "bottom", custom = TryGather },
		                { map = "-58,12", changeMap = "bottom", custom = TryGather },
		                { map = "-58,13", changeMap = "bottom", custom = TryGather },
		                { map = "-58,14", changeMap = "bottom", custom = TryGather },
		                { map = "-58,15", changeMap = "bottom", custom = TryGather },
		                { map = "-58,16", changeMap = "bottom", custom = TryGather },
		                { map = "-58,17", changeMap = "bottom", custom = TryGather },
		                { map = "-58,18", changeMap = "bottom", custom = TryGather },
		                { map = "-58,19", changeMap = "bottom", custom = TryGather },
		                { map = "-58,20", changeMap = "bottom", custom = TryGather },
		                { map = "-58,21", changeMap = "right", custom = TryGather },
		                { map = "-57,21", changeMap = "bottom", custom = TryGather },
		                { map = "-57,22", changeMap = "bottom", custom = TryGather },
		                { map = "-57,23", changeMap = "right", custom = TryGather },
		                { map = "-56,23", changeMap = "top", custom = TryGather },
		                { map = "-56,22", changeMap = "top", custom = TryGather },
		                { map = "-56,21", changeMap = "top", custom = TryGather },
		                { map = "-56,20", changeMap = "top", custom = TryGather },
		                { map = "-56,19", changeMap = "top", custom = TryGather },
		                { map = "-56,18", changeMap = "top", custom = TryGather },
		                { map = "-56,17", changeMap = "top", custom = TryGather },
		                { map = "-56,16", changeMap = "top", custom = TryGather },
		                { map = "-56,15", changeMap = "right", custom = TryGather },
		                { map = "-55,15", changeMap = "right", custom = TryGather },
		                { map = "-54,15", changeMap = "bottom", custom = TryGather },
		                { map = "-54,16", changeMap = "left", custom = TryGather },
		                { map = "-55,16", changeMap = "bottom", custom = TryGather },
		                { map = "-55,17", changeMap = "bottom", custom = TryGather },
		                { map = "-55,18", changeMap = "bottom", custom = TryGather },
		                { map = "-55,19", changeMap = "bottom", custom = TryGather },
		                { map = "-55,20", changeMap = "bottom", custom = TryGather },
		                { map = "-55,21", changeMap = "right", custom = TryGather },
		                { map = "-54,21", changeMap = "top", custom = TryGather },
		                { map = "-54,20", changeMap = "top", custom = TryGather },
		                { map = "-54,19", changeMap = "top", custom = TryGather },
		                { map = "-54,18", changeMap = "right", custom = TryGather },
		                { map = "-53,18", changeMap = "bottom", custom = TryGather },
		                { map = "-53,19", changeMap = "bottom", custom = TryGather },
		                { map = "-53,20", changeMap = "right", custom = TryGather },
		                { map = "-52,20", changeMap = "top", custom = TryGather },
		                { map = "-52,19", changeMap = "top", custom = TryGather },
		                { map = "-52,18", changeMap = "top", custom = TryGather },
		                { map = "-52,17", changeMap = "top", custom = TryGather },
		                { map = "-52,16", changeMap = "top", custom = TryGather },
		                { map = "-52,15", changeMap = "top", custom = TryGather },
		                { map = "-52,14", changeMap = "right", custom = TryGather },
		                { map = "-51,14", changeMap = "right", custom = TryGather },
		                { map = "-50,14", changeMap = "bottom", custom = TryGather },
		                { map = "-50,15", changeMap = "left", custom = TryGather },
		                { map = "-51,15", changeMap = "bottom", custom = TryGather },
		                { map = "-51,16", changeMap = "bottom", custom = TryGather },
		                { map = "-51,17", changeMap = "bottom", custom = TryGather },
		                { map = "-51,18", changeMap = "bottom", custom = TryGather },
		                { map = "-51,19", changeMap = "bottom", custom = TryGather },
		                { map = "-51,20", changeMap = "bottom", custom = TryGather },
		                { map = "-51,21", changeMap = "left", custom = TryGather },
		                { map = "-52,21", changeMap = "bottom", custom = TryGather },
		                { map = "-52,22", changeMap = "left", custom = TryGather },
		                { map = "-53,22", changeMap = "left", custom = TryGather },
		                { map = "-54,22", changeMap = "bottom", custom = TryGather },
		                { map = "-54,23", changeMap = "right", custom = TryGather },
		                { map = "-53,23", changeMap = "right", custom = TryGather },
		                { map = "-52,23", changeMap = "right", custom = TryGather },
		                { map = "-51,23", changeMap = "right", custom = TryGather },
		                { map = "-50,23", changeMap = "top", custom = TryGather },
		                { map = "-50,22", changeMap = "top", custom = TryGather },
		                { map = "-50,21", changeMap = "top", custom = TryGather },
		                { map = "-50,20", changeMap = "right", custom = TryGather },
		                { map = "-49,20", changeMap = "top", custom = TryGather },
		                { map = "-49,19", changeMap = "right", custom = TryGather },
		                { map = "-48,19", changeMap = "right", custom = TryGather },
		                { map = "-47,19", changeMap = "right", custom = TryGatherWithBP }  -- fin de boucle
                    }
                end
            },
            [21] = {
                name = "Zone Mandragore coin des bouftout",
                tags = {
                    "Mandragore"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88082704)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "5,7", changeMap = "right" }, -- Zaap Bouftou
		                { map = "6,7", changeMap = "right", custom = TryGather },
		                { map = "7,7", changeMap = "right", custom = TryGather },
		                { map = "8,7", changeMap = "right", custom = TryGather },
		                { map = "9,7", changeMap = "right", custom = TryGather },
		                { map = "10,7", changeMap = "right", custom = TryGather },
		                { map = "11,7", changeMap = "right", custom = TryGather },
		                { map = "12,7", changeMap = "bottom", custom = TryGather },
		                { map = "12,8", changeMap = "bottom", custom = TryGather },
		                { map = "12,9", changeMap = "bottom", custom = TryGather },
		                { map = "12,10", changeMap = "bottom", custom = TryGather },
		                { map = "12,11", changeMap = "bottom", custom = TryGather },
		                { map = "12,12", changeMap = "right", custom = TryGather },
		                { map = "13,12", changeMap = "bottom", custom = TryGather },
		                { map = "13,13", changeMap = "bottom", custom = TryGather },
		                { map = "13,14", changeMap = "bottom", custom = TryGather },
		                { map = "13,15", changeMap = "bottom", custom = TryGather },
		                { map = "13,16", changeMap = "left", custom = TryGather },
		                { map = "12,16", changeMap = "left", custom = TryGather },
		                { map = "11,16", changeMap = "top", custom = TryGather }, -- Reboucle
		                { map = "11,15", changeMap = "left", custom = TryGather },
		                { map = "10,15", changeMap = "top", custom = TryGather },
		                { map = "10,14", changeMap = "left", custom = TryGather },
		                { map = "9,14", changeMap = "bottom", custom = TryGather },
		                { map = "9,15", changeMap = "bottom", custom = TryGather },
		                { map = "9,16", changeMap = "left", custom = TryGather },
		                { map = "8,16", changeMap = "bottom", custom = TryGather },
		                { map = "8,17", changeMap = "right", custom = TryGather },
		                { map = "9,17", changeMap = "right", custom = TryGather },
		                { map = "10,17", changeMap = "top", custom = TryGather },
		                { map = "10,16", changeMap = "right", custom = TryGatherWithBP }
                    }
                end
            },
            [22] = { -- Bug
                name = "Zone Mandragore Brakmar",
                tags = {
                    "BUG"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,144419)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
		                { map = "-26,35", changeMap = "right" }, -- Zaap Brakmar
		                { map = "-25,35", changeMap = "right", custom = TryGather },
		                { map = "-24,35", changeMap = "right", custom = TryGather },
		                { map = "-23,35", changeMap = "right", custom = TryGather },
		                { map = "-22,35", changeMap = "right", custom = TryGather },
		                { map = "-21,35", changeMap = "right", custom = TryGather },
		                { map = "-20,35", changeMap = "top", custom = TryGather },
		                { map = "-20,34", changeMap = "right", custom = TryGather },
		                { map = "-19,34", changeMap = "right", custom = TryGather },
		                { map = "-18,34", changeMap = "bottom", custom = TryGather },
		                { map = "-18,35", changeMap = "bottom", custom = TryGather },
		                { map = "-18,36", changeMap = "bottom", custom = TryGather },
		                { map = "-18,37", changeMap = "bottom", custom = TryGather },
		                { map = "-18,38", changeMap = "bottom", custom = TryGather },
		                { map = "-18,39", changeMap = "right", custom = TryGather },
		                { map = "-17,39", changeMap = "right", custom = TryGather },
		                { map = "-16,39", changeMap = "right", custom = TryGather },
		                { map = "-15,39", changeMap = "right", custom = TryGather }, -- Reboucle
		                { map = "-14,39", changeMap = "right", custom = TryGather },
		                { map = "-13,39", changeMap = "top", custom = TryGather },
		                { map = "-13,38", changeMap = "top", custom = TryGather },
		                { map = "-13,37", changeMap = "left", custom = TryGather },
		                { map = "-14,37", changeMap = "left", custom = TryGather },
		                { map = "-15,37", changeMap = "bottom", custom = TryGather },
		                { map = "-15,38", changeMap = "bottom", custom = TryGatherWithBP } -- fin de boucle
                    }
                end
            },
        },
        ["mineur"] = {
	        [1] = { -- Mine Scara
                name = "Mine Scara",
                tags = {
                    "Fer"
                },
		        ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212481)") -- Zaap Scara
                    end
		        end,
		        ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
				        { map = "88212481", changeMap = "right" },
				        { map = "88211969", changeMap = "bottom" },
				        { map = "88211970", changeMap = "right" },
				        { map = "88080386", changeMap = "bottom" },
				        { map = "88080387", changeMap = "right" },
				        { map = "88080899", changeMap = "bottom" },
				        { map = "88080900", changeMap = "right" },
				        { map = "88081412", changeMap = "bottom" },
				        { map = "88081413", changeMap = "right" },
				        { map = "88081925", changeMap = "164" },
				        { map = "97255937", changeMap = "360", custom = TryGather },
				        { map = "97256961", changeMap = "276", custom = TryGather },
				        { map = "97257985", changeMap = "436", custom = TryGather },
				        { map = "97256961", changeMap = "351", custom = TryGather },
				        { map = "97255937", changeMap = "360", custom = TryGatherWithBP },
			        })
		        end			
	        },
            [2] = { -- Mine Herale
                name = "Mine Herale",
                tags = {
                    "Fer",
                    "Cuivre",
                    "Bronze",
                    "Manganese",
                    "Or"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88085249)") -- Zaap Rivage sufokien
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
				        { map = "88085249", changeMap = "left" },
				        { map = "88084737", changeMap = "left" },
				        { map = "88084225", changeMap = "top" },
				        { map = "88084226", changeMap = "top" },
				        { map = "88084227", changeMap = "left" },
				        { map = "88083715", changeMap = "left" },
				        { map = "88083203", changeMap = "top" },
				        { map = "88083204", changeMap = "left" },
				        { map = "88082692", changeMap = "332" },
				        { map = "97260033", changeMap = "405", custom = TryGather },
				        { map = "97261057", changeMap = "421", custom = TryGather },
				        { map = "97259011", changeMap = "276", custom = TryGather},
				        { map = "97261057", changeMap = "235", custom = TryGather },
				        { map = "97255939", changeMap = "446", custom = TryGather },
                        { map = "97256963", changeMap = "492", custom = TryGather },
                        { map = "97257987", changeMap = "212" },
				        { map = "97261057", changeMap = "227", custom = TryGather },
				        { map = "97260033", changeMap = "183", custom = TryGather },
				        { map = "97261059", changeMap = "417", custom = TryGatherWithBP },
                    })
                end
            },
            [3] = { -- Mine Astirite
                name = "Mine Astirite",
                tags = {
                    "Fer",
                    "Manganese"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88213271)") -- Zaap le village amakna
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "88213271", changeMap = "top" },
                        { map = "88213272", changeMap = "top" },
                        { map = "88213273", changeMap = "top" },
                        { map = "88213274", changeMap = "top" },
                        { map = "185862149", changeMap = "top" },
                        { map = "185862148", changeMap = "367" },
                        { map = "97255951", changeMap = "203" },
                        { map = "97256975", changeMap = "323", custom = TryGather },
                        { map = "97257999", changeMap = "268", custom = TryGather },
                        { map = "97260047", changeMap = "432", custom = TryGatherWithFDB },
                    })
                end
            },
            [4] = { -- Mine Istairameur
                name = "Mine Istairameur",
                tags = {
                    "Fer",
                    "Cuivre",
                    "Bronze",
                    "Manganese",
                    "Kobalte",
                    "Argent"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212746)") -- Zaap bord de la foret maléfique
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "88212746", changeMap = "top" },
                        { map = "88212747", changeMap = "top" },
                        { map = "88212748", changeMap = "top" },
                        { map = "88212749", changeMap = "top" },
                        { map = "88212750", changeMap = "left" },
                        { map = "88213262", changeMap = "left" },
                        { map = "88213774", changeMap = "354" },
                        { map = "97259013", changeMap = "258", custom = TryGather },
                        { map = "97260037", changeMap = "352", custom = TryGather },
                        { map = "97261061", changeMap = "284", custom = TryGather },
                        { map = "97255943", changeMap = "403", custom = TryGather },
                        { map = "97261061", changeMap = "458", custom = TryGather },
                        { map = "97260037", changeMap = "430", custom = TryGather },
                        { map = "97259013", changeMap = "276", custom = TryGather },
                        { map = "97256967", changeMap = "194" },
                        { map = "97260039", changeMap = "262" },
                        { map = "97257993", changeMap = "122" },
                        { map = "97261065", changeMap = "236" },
                        { map = "97259019", changeMap = "276" },
                        { map = "97260043", changeMap = "451", custom = TryGather },
                        { map = "97259019", changeMap = "438" },
                        { map = "97261065", changeMap = "213" },
                        { map = "97255947", changeMap = "199" },
                        { map = "97256971", changeMap = "239" },
                        { map = "97257995", changeMap = "374", custom = TryGather },
                        { map = "97256971", changeMap = "503" },
                        { map = "97255947", changeMap = "500"},
                        { map = "97261065", changeMap = "479" },
                        { map = "97257993", changeMap = "537" },
                        { map = "97260039", changeMap = "241" },
                        { map = "97261063", changeMap = "459", custom = TryGather },
                        { map = "97260039", changeMap = "451" },
                        { map = "97256967", changeMap = "518", custom = TryGatherWithBP },
                    })
                end
            },
            [5] = { -- Mine Astrub
                name = "Mine Astrub",
                tags = {
                    "Fer",
                    "Cuivre",
                    "Bronze",
                    "Etain",
                    "Silicate"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,191105026)") -- Zaap Astrub
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "191105026", changeMap = "left" },
                        { map = "191104002", changeMap = "left" },
                        { map = "191102978", changeMap = "left" },
                        { map = "188744196", changeMap = "left" },
                        { map = "188743684", changeMap = "bottom" },
                        { map = "188743685", changeMap = "415" },
                        { map = "188482052", changeMap = "167", custom = TryGather },
                        { map = "188483076", changeMap = "349", custom = TryGather },
                        { map = "188484100", changeMap = "169", custom = TryGather },
                        { map = "188483076", changeMap = "476", custom = TryGatherWithBP },
                    })
                end
            },
            [6] = { -- Mine de Cania
                name = "Mine de Cania",
                tags = {
                    "Fer",
                    "Cuivre",
                    "Bronze"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,156240386)") -- Zaap Lac de Cania
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "156240386", changeMap = "right" },
                        { map = "156240898", changeMap = "right" },
                        { map = "156241410", changeMap = "149" },
                        { map = "133431302", changeMap = "193", custom = TryGather },
                        { map = "133431300", changeMap = "180", custom = TryGather }, -- Reboucle
                        { map = "133431298", changeMap = "460", custom = TryGather },
                        { map = "133432322", changeMap = "129", custom = TryGather },
                        { map = "133432320", changeMap = "149", custom = TryGather },
                        { map = "133432578", changeMap = "450", custom = TryGather },
                        { map = "133432320", changeMap = "365", custom = TryGather },
                        { map = "133431296", changeMap = "307", custom = TryGather },
                        { map = "133432320", changeMap = "487", custom = TryGather },
                        { map = "133432322", changeMap = "362", custom = TryGather },
                        { map = "133433346", changeMap = "337", custom = TryGather },
                        { map = "133432322", changeMap = "337", custom = TryGather },
                        { map = "133431298", changeMap = "490", custom = TryGatherWithBP },
                    })
                end
            },
            [7] = { -- Mine Porco 1
                name = "Mine Porco 1",
                tags = {
                    "Fer",
                    "Cuivre",
                    "Kobalte",
                    "Etain"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212481)") -- Zaap Scara
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "88212481", changeMap = "right" },
                        { map = "88211969", changeMap = "right" },
                        { map = "88080385", changeMap = "bottom" },
                        { map = "88080386", changeMap = "bottom" },
                        { map = "88080387", changeMap = "bottom" },
                        { map = "88080388", changeMap = "bottom" },
                        { map = "88080389", changeMap = "bottom" },
                        { map = "88080390", changeMap = "bottom" },
                        { map = "88080391", changeMap = "bottom" },
                        { map = "72619521", changeMap = "bottom" },
                        { map = "72619522", changeMap = "147" },
                        { map = "30672658", changeMap = "362", custom = TryGather },
                        { map = "30672655", changeMap = "221", custom = TryGather },
                        { map = "30672649", changeMap = "408", custom = TryGather },
                        { map = "30672655", changeMap = "270", custom = TryGatherWithBP },
                    })
                end
            },
            [8] = { -- Mine Porco 2
                name = "Mine Porco 2",
                tags = {
                    "Fer",
                    "Etain",
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212481)") -- Zaap Scara
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "88212481", changeMap = "right" },
                        { map = "88211969", changeMap = "right" },
                        { map = "88080385", changeMap = "bottom" },
                        { map = "88080386", changeMap = "bottom" },
                        { map = "88080387", changeMap = "bottom" },
                        { map = "88080388", changeMap = "bottom" },
                        { map = "88080389", changeMap = "bottom" },
                        { map = "88080390", changeMap = "bottom" },
                        { map = "88080391", changeMap = "bottom" },
                        { map = "72619521", changeMap = "bottom" },
                        { map = "72619522", changeMap = "bottom" },
                        { map = "72619523", changeMap = "left" },
                        { map = "72619011", changeMap = "left" },
                        { map = "72618499", changeMap = "85" },
                        { map = "30671116", changeMap = "292", custom = TryGather },
                        { map = "30671110", changeMap = "479", custom = TryGather },
                        { map = "30671107", changeMap = "298", custom = TryGather },
                        { map = "30670848", changeMap = "344", custom = TryGather },
                        { map = "30671107", changeMap = "247", custom = TryGather },
                        { map = "30671110", changeMap = "188", custom = TryGatherWithBP },
                    })
                end
            },
            [9] = { -- Mine Auderie
                name = "Mine Auderie",
                tags = {
                    "Fer",
                    "Cuivre",
                    "Bronze",
                    "Kobalte"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88213271)") -- Zaap Amakna le village
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "88213271", changeMap = "bottom" },
                        { map = "88213270", changeMap = "bottom" },
                        { map = "88213269", changeMap = "bottom" },
                        { map = "88213268", changeMap = "bottom" },
                        { map = "88213267", changeMap = "250" },
                        { map = "97255949", changeMap = "376", custom = TryGather },
                        { map = "97256973", changeMap = "537", custom = TryGather },
                        { map = "97260045", changeMap = "254", custom = TryGather },
                        { map = "97261069", changeMap = "348", custom = TryGather },
                        { map = "97260045", changeMap = "291", custom = TryGather },
                        { map = "97256973", changeMap = "122", custom = TryGather },
                        { map = "97257997", changeMap = "235", custom = TryGather },
                        { map = "97259021", changeMap = "323", custom = TryGather },
                        { map = "97257997", changeMap = "451", custom = TryGather },
                        { map = "97256973", changeMap = "157", custom = TryGatherWithBP },
                    })
                end
            },
            [10] = { -- Mine de la grotte hative
                name = "Mine De la Grotte Hative",
                tags = {
                    "Bronze",
                    "Cuivre"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        idZaapi = "hative"
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,144419)") -- Zaap brakmar
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "144419", custom = zaapiToPath },
                        { map = "144425", changeMap = "bottom" },
                        { map = "172231693", changeMap = "bottom" },
                        { map = "172231694", changeMap = "bottom" },
                        { map = "172231695", changeMap = "bottom" },
                        { map = "172231696", changeMap = "right" },
                        { map = "172232208", changeMap = "194" },
                        { map = "178784266", changeMap = "127", custom = TryGather },
                        { map = "178785290", changeMap = "530", custom = TryGatherWithBP }
                    })
                end
            }, 
            [11] = { -- Mine Ebbernard
                name = "Mine Ebbernard",
                tags = {
                    "Manganese",
                    "Bronze",
                    "Kobalte",
                    "Cuivre"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        idZaapi = "ebbernard"
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,144419)") -- Zaap brakmar
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "144419", custom = zaapiToPath },
                        { map = "142880", changeMap = "top" },
                        { map = "142879", changeMap = "529" },
                        { map = "28312325", changeMap = "bottom" },
                        { map = "28312324", changeMap = "right" },
                        { map = "28312836", changeMap = "446" },
                        { map = "29622534", changeMap = "275" },
                        { map = "29622531", changeMap = "180", custom = TryGather },
                        { map = "29622272", changeMap = "180", custom = TryGather},
                        { map = "29622275", changeMap = "450", custom = TryGather },
                        { map = "29622275", changeMap = "450", custom = TryGather },
                        { map = "29622272", changeMap = "450", custom = TryGatherWithBP },
                    })
                end
            }, 
            [12] = { -- Mine secrete de bronze a brakmar
                name = "Mine secrete de bronze",
                tags = {
                    "Bronze"
                },
		        ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        idZaapi = "mineSecrete"
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,144419)") -- Zaap Brakmar
                    end
		        end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "144419", custom = zaapiToPath },
                        { map = "144928", changeMap = "right" },
                        { map = "144416", changeMap = "top" },
                        { map = "144415", changeMap = "110" },
                        { map = "172232193", changeMap = "top" },
                        { map = "172232192", changeMap = "left" },
                        { map = "172231680", changeMap = "left" },
                        { map = "172231168", changeMap = "left" },
                        { map = "172230656", changeMap = "top" },
                        { map = "173016076", changeMap = "51" },
                        { map = "178785280", changeMap = "447", custom = TryGather },
                        { map = "178785284", custom = TryGatherWithFDB },
                    })
                end
            }, 
            [13] = { -- Mine Hipouce
                name = "Mine Hipouce",
                tags = {
                    "Bronze",
                    "Kobalte"
                },
		        ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,171967506)") -- Zaap routte des roulotte
                    end
		        end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "171967506", changeMap = "bottom" },
                        { map = "171967507", changeMap = "bottom" },
                        { map = "171967508", changeMap = "bottom" },
                        { map = "173017857", changeMap = "bottom" },
                        { map = "173017600", changeMap = "bottom" },
                        { map = "173017601", changeMap = "434" },
                        { map = "173017602", changeMap = "484" },
                        { map = "173017603", changeMap = "bottom" },
                        { map = "173017604", changeMap = "right" },
                        { map = "173018116", changeMap = "bottom" },
                        { map = "173018117", changeMap = "left" },
                        { map = "173017605", changeMap = "493" },
                        { map = "173017606", changeMap = "268" },
                        { map = "178782208", custom = TryGatherWithCM },
                        { map = "178782210", custom = TryGatherWithCM },
                        { map = "178782208", changeMap = "138", custom = TryGather },
                        { map = "178783232", changeMap = "204", custom = TryGather },
                        { map = "178784256", changeMap = "476", custom = TryGather },
                        { map = "178783232", changeMap = "213", custom = TryGather },
                        { map = "178783236", changeMap = "138", custom = TryGather },
                        { map = "178784260", changeMap = "406", custom = TryGather },
                        { map = "178783236", changeMap = "323", custom = TryGather },
                        { map = "178782214", changeMap = "507", custom = TryGather },
                        { map = "178782216", changeMap = "450" },
                        { map = "178782218", changeMap = "518", custom = TryGather },
                        { map = "178782220", changeMap = "57", custom = TryGather },
                        { map = "178782218", custom = TryGatherWithCM },
                        { map = "178782216", changeMap = "162", custom = TryGather },
                        { map = "178782214", changeMap = "179", custom = TryGather },
                        { map = "178783236", changeMap = "527", custom = TryGather },
                        { map = "178783232", changeMap = "406", custom = TryGatherWithBP }
                    })
                end
            }, 
            [14] = { -- Mine plaine rocheuse au dessus du zaap
                name = "Mine Plaine rocheuse au dessus du zaap",
                tags = {
                    "Or",
                    "Bronze",
                    "Manganese",
                    "Kobalte"

                },
		        ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,147590153)") -- Zaap Plaine rocheuse
                    end
		        end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "147590153", changeMap = "top" },
                        { map = "147590152", changeMap = "top" },
                        { map = "147590151", custom = clickMap },
                        { map = "164758273", custom = TryGatherWithFDB },
                    })
                end
            }, 
            [15] = { -- Mine du chemin vers kartonpath
                name = "Mine Du chemin vers KartonPath",
                tags = {
                    "Kobalte",
                    "Manganese",
                    "Cuivre",
                    "Or"
                },
		        ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88085249)") -- Zaap Rivage Sufokien
                    end
		        end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "88085249", changeMap = "right" },
                        { map = "88085761", changeMap = "right" },
                        { map = "88086273", changeMap = "right" },
                        { map = "88086785", changeMap = "right" },
                        { map = "88087297", changeMap = "top" },
                        { map = "88087298", changeMap = "top" },
                        { map = "88087299", changeMap = "top" },
                        { map = "88087300", changeMap = "top" },
                        { map = "88087301", changeMap = "top" },
                        { map = "88087302", changeMap = "top" },
                        { map = "88087303", changeMap = "top" },
                        { map = "88087304", changeMap = "top" },
                        { map = "88087305", custom = clickMap },
                        { map = "117440512", changeMap = "222" },
                        { map = "117441536", changeMap = "167", custom = TryGather },
                        { map = "117442560", changeMap = "473", custom = TryGather },
                        { map = "117443584", changeMap = "236", custom = TryGather },
                        { map = "117440514", changeMap = "307", custom = TryGather },
                        { map = "117441538", changeMap = "250", custom = TryGather },
                        { map = "117442562", changeMap = "395", custom = TryGather },
                        { map = "117441538", changeMap = "421", custom = TryGather },
                        { map = "117440514", changeMap = "393", custom = TryGather },
                        { map = "117443584", changeMap = "253", custom = TryGather },
                        { map = "117442560", changeMap = "434", custom = TryGatherWithBP }
                    })
                end
            }, 
            [16] = { -- Mine Estrone
                name = "Mine Estrone",
                tags = {
                    "Manganese",
                    "Etain"
                },
		        ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,171967506)") -- Zaap Route des roulotte
                    end
		        end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "171967506", changeMap = "top" },
                        { map = "171967505", changeMap = "top" },
                        { map = "171967504", changeMap = "top" },
                        { map = "171967503", changeMap = "top" },
                        { map = "171967502", changeMap = "top" },
                        { map = "171967501", changeMap = "top" },
                        { map = "171967500", changeMap = "top" },
                        { map = "171967499", changeMap = "left" },
                        { map = "171966987", custom = clickMap },
                        { map = "178785286", changeMap = "113", custom = TryGather },
                        { map = "178785288", custom = TryGatherWithFDB }
                    })
                end
            }, 
            [17] = { -- Mine Manganese ile dragoeuf
                name = "Mine Manganese ile dragoeuf",
                tags = {
                    "Manganese",
                },
		        ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212481)") -- Zaap Route des roulotte
                    end
		        end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "88212481", changeMap = "left" },
                        { map = "84412416", changeMap = "left" },
                        { map = "84411904", changeMap = "left" },
                        { map = "84411392", custom = clickMap },
                        { map = "84410880", changeMap = "left" },
                        { map = "84410368", custom = clickMap },
                        { map = "86246410", changeMap = "431", custom = TryGather },
                        { map = "84410368", custom = finDeBoucle },
                    })
                end
            }, 
            [18] = { -- Mine Haut hurlement
                name = "Mine Haut hurlement",
                tags = {
                    "Etain",
                },
		        ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,164364304)") -- Zaap Route Rocailleuse
                    end
		        end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "164364304", changeMap = "bottom" },
                        { map = "164364305", changeMap = "bottom" },
                        { map = "164364306", changeMap = "bottom" },
                        { map = "164364307", changeMap = "bottom" },
                        { map = "164364308", changeMap = "bottom" },
                        { map = "164364309", changeMap = "bottom" },
                        { map = "164364310", changeMap = "bottom" },
                        { map = "164364311", changeMap = "bottom" },
                        { map = "164364312", changeMap = "bottom" },
                        { map = "171708416", changeMap = "bottom" },
                        { map = "171708417", changeMap = "left" },
                        { map = "171707905", changeMap = "bottom" },
                        { map = "171707906", changeMap = "bottom" },
                        { map = "171707907", changeMap = "bottom" },
                        { map = "171707908", custom = clickMap },
                        { map = "178784264", custom = TryGatherWithFDB },
                    })
                end
            },
            [19] = { -- Mine Bwork
                name = "Mine Bwork",
                tags = {
                    "Etain",
                    "Bronze",
                    "Or",
                    "Bauxite"
                },
		        ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212746)") -- Zaap Bord de la foret malefique
                    end
		        end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "88212746", changeMap = "top" },
                        { map = "88212747", changeMap = "top" },
                        { map = "88212748", changeMap = "top" },
                        { map = "88212749", changeMap = "top" },
                        { map = "88212750", changeMap = "top" },
                        { map = "88212751", custom = clickMap },
                        { map = "104073218", changeMap = "left" },
                        { map = "104072706", changeMap = "left" },
                        { map = "104072194", changeMap = "top" },
                        { map = "104072193", changeMap = "top" },
                        { map = "104072192", changeMap = "left" },
                        { map = "104071680", changeMap = "left" },
                        { map = "104071168", custom = clickMap },
                        { map = "104860165", changeMap = "444", custom = TryGather },
                        { map = "104071168", changeMap = "top" },
                        { map = "104071425", custom = clickMap },
                        { map = "104859139", changeMap = "444", custom = TryGather },
                        { map = "104071425", changeMap = "right" },
                        { map = "104071937", changeMap = "right" },
                        { map = "104072449", changeMap = "top" },
                        { map = "104072450", changeMap = "top" },
                        { map = "104072451", changeMap = "top" },
                        { map = "104072452", custom = clickMap },
                        { map = "104858121", changeMap = "348", custom = TryGather },
                        { map = "104860169", changeMap = "263", custom = TryGather },
                        { map = "104861193", changeMap = "248", custom = TryGather },
                        { map = "104862217", changeMap = "369", custom = TryGather },
                        { map = "104861193", changeMap = "254", custom = TryGather },
                        { map = "104859145", changeMap = "457", custom = TryGather },
                        { map = "104858121", changeMap = "507", custom = TryGather },
                        { map = "104072452", changeMap = "bottom" },
                        { map = "104072451", changeMap = "bottom" },
                        { map = "104072450", changeMap = "bottom" },
                        { map = "104072449", changeMap = "bottom" },
                        { map = "104072192", changeMap = "left" },
                        { map = "104071680", changeMap = "left", custom = TryGatherWithBP },
                    })
                end
            },
            [20] = { -- Mine du bois arak'hai
                name = "Mine du bois arak'hai",
                tags = {
                    "Argent",
                },
		        ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,84806401)") -- Zaap Plaine des porkass
                    end
		        end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "84806401", changeMap = "bottom" },
                        { map = "84806144", changeMap = "bottom" },
                        { map = "84806145", changeMap = "bottom" },
                        { map = "84806146", changeMap = "bottom" },
                        { map = "165156368", changeMap = "bottom" },
                        { map = "147854083", changeMap = "bottom" },
                        { map = "147854082", changeMap = "left" },
                        { map = "147853570", changeMap = "left" },
                        { map = "147853058", changeMap = "left" },
                        { map = "147852546", changeMap = "bottom" },
                        { map = "147852545", changeMap = "bottom" },
                        { map = "147852288", changeMap = "bottom" },
                        { map = "147852289", changeMap = "bottom" },
                        { map = "147852290", custom = clickMap },
                        { map = "149949440", custom = TryGatherWithFDB }
                    })
                end
            },
            [21] = { -- Mine Imale
                name = "Mine Imale",
                tags = {
                    "Argent",
                    "Bauxite"
                },
		        ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,171967506)") -- Zaap Route des roulotte
                    end
		        end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "171967506", changeMap = "bottom" },
                        { map = "171967507", changeMap = "bottom" },
                        { map = "171967508", changeMap = "bottom" },
                        { map = "173017857", changeMap = "bottom" },
                        { map = "173017600", changeMap = "bottom" },
                        { map = "173017601", changeMap = "right" },
                        { map = "173018113", changeMap = "right" },
                        { map = "173018625", changeMap = "right" },
                        { map = "173019137", changeMap = "right" },
                        { map = "173019649", changeMap = "bottom" },
                        { map = "173019650", changeMap = "bottom" },
                        { map = "173019651", changeMap = "bottom" },
                        { map = "173019652", changeMap = "bottom" },
                        { map = "173019653", changeMap = "right" },
                        { map = "173020165", changeMap = "right" },
                        { map = "172490758", changeMap = "right" },
                        { map = "172491270", changeMap = "right" },
                        { map = "172491782", custom = clickMap },
                        { map = "178783240", changeMap = "235", custom = TryGather },
                        { map = "178783242", custom = TryGatherWithFDB },
                    })
                end
            }
        },
        ["bucheron"] = {
            [1] = {
                name = "Zone frene #1",
                tags = {
                    "Frene"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,84806401)") -- Zaap Plaine des Porkass [-5,-23]
                    end
                end,
                ["PATH"] = function()
                    return {
                        { map = "84806401", changeMap = "bottom", custom = TryGather },
                        { map = "84806144", changeMap = "right", custom = TryGather },
                        { map = "84805632", changeMap = "right", custom = TryGather },
                        { map = "189661703", changeMap = "bottom", custom = TryGather }, -- Reboucle
                        { map = "189661704", changeMap = "bottom", custom = TryGather },
                        { map = "189661705", changeMap = "bottom", custom = TryGather },
                        { map = "189661706", changeMap = "bottom", custom = TryGather },
                        { map = "189661707", changeMap = "bottom", custom = TryGather },
                        { map = "189661708", changeMap = "bottom", custom = TryGather },
                        { map = "189661709", changeMap = "bottom", custom = TryGather },
                        { map = "189661710", changeMap = "right", custom = TryGather },
                        { map = "189530126", changeMap = "right", custom = TryGather },
                        { map = "189530638", changeMap = "top", custom = TryGather },
                        { map = "189530637", changeMap = "left", custom = TryGather },
                        { map = "189530125", changeMap = "top", custom = TryGather },
                        { map = "189530124", changeMap = "right", custom = TryGather },
                        { map = "189530636", changeMap = "top", custom = TryGather },
                        { map = "189530635", changeMap = "left", custom = TryGather },
                        { map = "189530123", changeMap = "top", custom = TryGather },
                        { map = "189530122", changeMap = "right", custom = TryGather },
                        { map = "189530634", changeMap = "top", custom = TryGather },
                        { map = "189530633", changeMap = "left", custom = TryGather },
                        { map = "189530121", changeMap = "top", custom = TryGather },
                        { map = "189530120", changeMap = "right", custom = TryGather },
                        { map = "189530632", changeMap = "top", custom = TryGather },
                        { map = "189530631", changeMap = "left", custom = TryGather },
                        { map = "189530119", changeMap = "left", custom = TryGatherWithBP }, -- Reboucle sur 189661703
                    }
                end
            },
            [2] = {
                name = "Zone frene #2",
                tags = {
                    "Frene"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,84806401)") -- Zaap Plaine des Porkass [-5,-23]
                    end
                end,
                ["PATH"] = function()
                    return {
                        { map = "84806401", changeMap = "right", custom = TryGather },
                        { map = "84805889", changeMap = "right", custom = TryGather },
                        { map = "84805377", changeMap = "right", custom = TryGather },
                        { map = "189530118", changeMap = "right", custom = TryGather }, -- Reboucle
                        { map = "189530630", changeMap = "right", custom = TryGather },
                        { map = "189531142", changeMap = "right", custom = TryGather },
                        { map = "189531654", changeMap = "right", custom = TryGather },
                        { map = "189532166", changeMap = "top", custom = TryGather },
                        { map = "189532165", changeMap = "left", custom = TryGather },
                        { map = "189531653", changeMap = "left", custom = TryGather },
                        { map = "189531141", changeMap = "left", custom = TryGather },
                        { map = "189530629", changeMap = "top", custom = TryGather },
                        { map = "189530628", changeMap = "right", custom = TryGather },
                        { map = "189531140", changeMap = "right", custom = TryGather },
                        { map = "189531652", changeMap = "right", custom = TryGather },
                        { map = "189532164", changeMap = "top", custom = TryGather },
                        { map = "189532163", changeMap = "left", custom = TryGather },
                        { map = "189531651", changeMap = "left", custom = TryGather },
                        { map = "189531139", changeMap = "left", custom = TryGather },
                        { map = "189530627", changeMap = "top", custom = TryGather },
                        { map = "189530626", changeMap = "right", custom = TryGather },
                        { map = "189531138", changeMap = "right", custom = TryGather },
                        { map = "189531650", changeMap = "right", custom = TryGather },
                        { map = "189532162", changeMap = "top", custom = TryGather },
                        { map = "189532161", changeMap = "left", custom = TryGather },
                        { map = "189531649", changeMap = "left", custom = TryGather },
                        { map = "189531137", changeMap = "left", custom = TryGather },
                        { map = "189530625", changeMap = "left", custom = TryGather },
                        { map = "189530113", changeMap = "bottom", custom = TryGather },
                        { map = "189530114", changeMap = "bottom", custom = TryGather },
                        { map = "189530115", changeMap = "bottom", custom = TryGather },
                        { map = "189530116", changeMap = "bottom", custom = TryGather },
                        { map = "189530117", changeMap = "bottom", custom = TryGatherWithBP }, -- Reboucle sur 189530118
                    }
                end
            },
            [3] = {
                name = "Zone Chataignier #1",
                tags = {
                    "Chataignier"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,84806401)") -- Zaap Plaine des Porkass [-5,-23]
                    end
                end,
                ["PATH"] = function()
                    return {
                        { map = "84806401", changeMap = "bottom", custom = TryGather },
                        { map = "84806144", changeMap = "right", custom = TryGather },
                        { map = "84805632", changeMap = "right", custom = TryGather },
                        { map = "189661703", changeMap = "bottom", custom = TryGather }, -- Reboucle
                        { map = "189661704", changeMap = "bottom", custom = TryGather },
                        { map = "189661705", changeMap = "bottom", custom = TryGather },
                        { map = "189661706", changeMap = "bottom", custom = TryGather },
                        { map = "189661707", changeMap = "bottom", custom = TryGather },
                        { map = "189661708", changeMap = "bottom", custom = TryGather },
                        { map = "189661709", changeMap = "bottom", custom = TryGather },
                        { map = "189661710", changeMap = "right", custom = TryGather },
                        { map = "189530126", changeMap = "right", custom = TryGather },
                        { map = "189530638", changeMap = "top", custom = TryGather },
                        { map = "189530637", changeMap = "left", custom = TryGather },
                        { map = "189530125", changeMap = "top", custom = TryGather },
                        { map = "189530124", changeMap = "right", custom = TryGather },
                        { map = "189530636", changeMap = "top", custom = TryGather },
                        { map = "189530635", changeMap = "left", custom = TryGather },
                        { map = "189530123", changeMap = "top", custom = TryGather },
                        { map = "189530122", changeMap = "right", custom = TryGather },
                        { map = "189530634", changeMap = "top", custom = TryGather },
                        { map = "189530633", changeMap = "left", custom = TryGather },
                        { map = "189530121", changeMap = "top", custom = TryGather },
                        { map = "189530120", changeMap = "right", custom = TryGather },
                        { map = "189530632", changeMap = "top", custom = TryGather },
                        { map = "189530631", changeMap = "left", custom = TryGather },
                        { map = "189530119", changeMap = "left", custom = TryGatherWithBP }, -- Reboucle sur 189661703
                    }
                end
            },
            [4] = {
                name = "Zone Chataignier #2",
                tags = {
                    "Chataignier"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,84806401)") -- Zaap Plaine des Porkass [-5,-23]
                    end
                end,
                ["PATH"] = function()
                    return {
                        { map = "84806401", changeMap = "right", custom = TryGather },
                        { map = "84805889", changeMap = "right", custom = TryGather },
                        { map = "84805377", changeMap = "right", custom = TryGather },
                        { map = "189530118", changeMap = "right", custom = TryGather }, -- Reboucle
                        { map = "189530630", changeMap = "right", custom = TryGather },
                        { map = "189531142", changeMap = "right", custom = TryGather },
                        { map = "189531654", changeMap = "right", custom = TryGather },
                        { map = "189532166", changeMap = "top", custom = TryGather },
                        { map = "189532165", changeMap = "left", custom = TryGather },
                        { map = "189531653", changeMap = "left", custom = TryGather },
                        { map = "189531141", changeMap = "left", custom = TryGather },
                        { map = "189530629", changeMap = "top", custom = TryGather },
                        { map = "189530628", changeMap = "right", custom = TryGather },
                        { map = "189531140", changeMap = "right", custom = TryGather },
                        { map = "189531652", changeMap = "right", custom = TryGather },
                        { map = "189532164", changeMap = "top", custom = TryGather },
                        { map = "189532163", changeMap = "left", custom = TryGather },
                        { map = "189531651", changeMap = "left", custom = TryGather },
                        { map = "189531139", changeMap = "left", custom = TryGather },
                        { map = "189530627", changeMap = "top", custom = TryGather },
                        { map = "189530626", changeMap = "right", custom = TryGather },
                        { map = "189531138", changeMap = "right", custom = TryGather },
                        { map = "189531650", changeMap = "right", custom = TryGather },
                        { map = "189532162", changeMap = "top", custom = TryGather },
                        { map = "189532161", changeMap = "left", custom = TryGather },
                        { map = "189531649", changeMap = "left", custom = TryGather },
                        { map = "189531137", changeMap = "left", custom = TryGather },
                        { map = "189530625", changeMap = "left", custom = TryGather },
                        { map = "189530113", changeMap = "bottom", custom = TryGather },
                        { map = "189530114", changeMap = "bottom", custom = TryGather },
                        { map = "189530115", changeMap = "bottom", custom = TryGather },
                        { map = "189530116", changeMap = "bottom", custom = TryGather },
                        { map = "189530117", changeMap = "bottom", custom = TryGatherWithBP }, -- Reboucle sur 189530118
                    }
                end
            },
            [5] = {
                name = "Zone Noyer #1",
                tags = {
                    "Noyer"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212481)") -- Zaap Plaine des scarafeuille [-1,-24]
                    end
                end,
                ["PATH"] = function()
                    return {
                        { map = "88212481", changeMap = "right", custom = TryGather },
                        { map = "88211969", changeMap = "right", custom = TryGather },
                        { map = "88080385", changeMap = "right", custom = TryGather },
                        { map = "88080897", changeMap = "right", custom = TryGather },
                        { map = "88081409", changeMap = "bottom", custom = TryGather },
                        { map = "88081410", changeMap = "bottom", custom = TryGather },
                        { map = "88081411", changeMap = "bottom", custom = TryGather },
                        { map = "88081412", changeMap = "bottom", custom = TryGather },
                        { map = "88081413", changeMap = "bottom", custom = TryGather },
                        { map = "88081414", changeMap = "bottom", custom = TryGather }, -- Reboucle
                        { map = "88081415", changeMap = "bottom", custom = TryGather },
                        { map = "88081416", changeMap = "bottom", custom = TryGather },
                        { map = "88081417", changeMap = "right", custom = TryGather },
                        { map = "88081929", changeMap = "top", custom = TryGather },
                        { map = "88081928", changeMap = "top", custom = TryGather },
                        { map = "88081927", changeMap = "right", custom = TryGather },
                        { map = "88082439", changeMap = "right", custom = TryGather },
                        { map = "88082951", changeMap = "right", custom = TryGather },
                        { map = "88083463", changeMap = "right", custom = TryGather },
                        { map = "88083975", changeMap = "right", custom = TryGather },
                        { map = "88084487", changeMap = "top", custom = TryGather },
                        { map = "88084486", changeMap = "left", custom = TryGather },
                        { map = "88083974", changeMap = "left", custom = TryGather },
                        { map = "88083462", changeMap = "left", custom = TryGather },
                        { map = "88082950", changeMap = "left", custom = TryGather },
                        { map = "88082438", changeMap = "left", custom = TryGather },
                        { map = "88081926", changeMap = "left", custom = TryGather },
                        { map = "88084486", changeMap = "left", custom = TryGatherWithBP }, -- Reboucle sur 88081414
                    }
                end
            },
            [6] = {
                name = "Zone Noyer #2",
                tags = {
                    "Noyer"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88082704)") -- Zaap Amakna coin des bouftout [5,7]
                    end
                end,
                ["PATH"] = function()
                    return {
                        { map = "88082704", changeMap = "bottom", custom = TryGather },
                        { map = "88082703", changeMap = "bottom", custom = TryGather },
                        { map = "88082702", changeMap = "bottom", custom = TryGather },
                        { map = "88082701", changeMap = "bottom", custom = TryGather },
                        { map = "88082700", changeMap = "bottom", custom = TryGather },
                        { map = "88082699", changeMap = "bottom", custom = TryGather },
                        { map = "88082698", changeMap = "bottom", custom = TryGather },
                        { map = "88082697", changeMap = "bottom", custom = TryGather }, -- Reboucle
                        { map = "88082696", changeMap = "bottom", custom = TryGather },
                        { map = "88082695", changeMap = "bottom", custom = TryGather },
                        { map = "88082694", changeMap = "bottom", custom = TryGather },
                        { map = "88082693", changeMap = "right", custom = TryGather },
                        { map = "88083205", changeMap = "top", custom = TryGather },
                        { map = "88083206", changeMap = "top", custom = TryGather },
                        { map = "88083207", changeMap = "top", custom = TryGather },
                        { map = "88083208", changeMap = "top", custom = TryGather },
                        { map = "88083209", changeMap = "left", custom = TryGatherWithBP } -- Reboucle sur 88082697
                    }
                end
            },
            [7] = {
                name = "Zone Noyer #3",
                tags = {
                    "Noyer"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88085249)") -- Zaap Rivage sufokien [10,22]
                    end
                end,
                ["PATH"] = function()
                    return {
                        { map = "88085249", changeMap = "right", custom = TryGather },
                        { map = "88085761", changeMap = "right", custom = TryGather },
                        { map = "88086273", changeMap = "right", custom = TryGather },
                        { map = "88086785", changeMap = "right", custom = TryGather },
                        { map = "88087297", changeMap = "top", custom = TryGather },
                        { map = "88087298", changeMap = "top", custom = TryGather }, -- Reboucle
                        { map = "88087299", changeMap = "top", custom = TryGather },
                        { map = "88087300", changeMap = "top", custom = TryGather },
                        { map = "88087301", changeMap = "top", custom = TryGather },
                        { map = "88087302", changeMap = "top", custom = TryGather },
                        { map = "88087303", changeMap = "top", custom = TryGather },
                        { map = "88087304", changeMap = "left", custom = TryGather },
                        { map = "88086792", changeMap = "bottom", custom = TryGather },
                        { map = "88086791", changeMap = "bottom", custom = TryGather },
                        { map = "88086790", changeMap = "bottom", custom = TryGather },
                        { map = "88086789", changeMap = "bottom", custom = TryGather },
                        { map = "88086788", changeMap = "bottom", custom = TryGather },
                        { map = "88086787", changeMap = "bottom", custom = TryGather },
                        { map = "88086786", changeMap = "right", custom = TryGatherWithBP } -- Reboucle sur 88087298

                    }
                end
            },
            [8] = {
                name = "Zone Chene #1",
                tags = {
                    "Chene"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212481)") -- Zaap Plaine des scarafeuille [-1,-24]
                    end
                end,
                ["PATH"] = function()
                    return {
                        { map = "88212481", changeMap = "right", custom = TryGather },
                        { map = "88211969", changeMap = "right", custom = TryGather },
                        { map = "88080385", changeMap = "right", custom = TryGather },
                        { map = "88080897", changeMap = "bottom", custom = TryGather },
                        { map = "88080898", changeMap = "bottom", custom = TryGather },
                        { map = "88080899", changeMap = "bottom", custom = TryGather },
                        { map = "88080900", changeMap = "bottom", custom = TryGather },
                        { map = "88080901", changeMap = "bottom", custom = TryGather },
                        { map = "88080902", changeMap = "bottom", custom = TryGather },
                        { map = "88080903", changeMap = "bottom", custom = TryGather }, -- Reboucle
                        { map = "88080904", changeMap = "right", custom = TryGather },
                        { map = "88081416", changeMap = "right", custom = TryGather },
                        { map = "88081928", changeMap = "right", custom = TryGather },
                        { map = "88082440", changeMap = "right", custom = TryGather },
                        { map = "88082952", changeMap = "right", custom = TryGather },
                        { map = "88083464", changeMap = "top", custom = TryGather },
                        { map = "88083463", changeMap = "left", custom = TryGather },
                        { map = "88082951", changeMap = "left", custom = TryGather },
                        { map = "88082439", changeMap = "left", custom = TryGather },
                        { map = "88081927", changeMap = "left", custom = TryGather },
                        { map = "88081415", changeMap = "left", custom = TryGatherWithBP } -- Reboucle sur 88080903
                    }
                end
            },
            [9] = {
                name = "Zone Chene #2",
                tags = {
                    "Chene"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,147590153)") -- Zaap Plaines rocheuses [-17,-47]
                    end
                end,
                ["PATH"] = function()
                    return {
                        { map = "147590153", changeMap = "bottom", custom = TryGather },
                        { map = "147590154", changeMap = "bottom", custom = TryGather },
                        { map = "147590155", changeMap = "right", custom = TryGather },
                        { map = "147590667", changeMap = "right", custom = TryGather },
                        { map = "155975694", changeMap = "top", custom = TryGather }, -- Reboucle
                        { map = "155975693", changeMap = "top", custom = TryGather },
                        { map = "155975692", changeMap = "top", custom = TryGather },
                        { map = "155975691", changeMap = "top", custom = TryGather },
                        { map = "155975690", changeMap = "top", custom = TryGather },
                        { map = "155975689", changeMap = "top", custom = TryGather },
                        { map = "155975688", changeMap = "top", custom = TryGather },
                        { map = "155975687", changeMap = "top", custom = TryGather },
                        { map = "155975686", changeMap = "top", custom = TryGather },
                        { map = "155975685", changeMap = "top", custom = TryGather },
                        { map = "155975684", changeMap = "top", custom = TryGather },
                        { map = "155975683", changeMap = "top", custom = TryGather },
                        { map = "155975682", changeMap = "top", custom = TryGather },
                        { map = "155975681", changeMap = "top", custom = TryGather },
                        { map = "155975680", changeMap = "right", custom = TryGather },
                        { map = "155976192", changeMap = "right", custom = TryGather },
                        { map = "155976704", changeMap = "bottom", custom = TryGather },
                        { map = "155976705", changeMap = "left", custom = TryGather },
                        { map = "155976193", changeMap = "bottom", custom = TryGather },
                        { map = "155976194", changeMap = "right", custom = TryGather },
                        { map = "155976706", changeMap = "bottom", custom = TryGather },
                        { map = "155976707", changeMap = "left", custom = TryGather },
                        { map = "155976195", changeMap = "bottom", custom = TryGather },
                        { map = "155976196", changeMap = "bottom", custom = TryGather },
                        { map = "155976197", changeMap = "right", custom = TryGather },
                        { map = "155976709", changeMap = "bottom", custom = TryGather },
                        { map = "155976710", changeMap = "left", custom = TryGather },
                        { map = "155976198", changeMap = "bottom", custom = TryGather },
                        { map = "155976199", changeMap = "right", custom = TryGather },
                        { map = "155976711", changeMap = "bottom", custom = TryGather },
                        { map = "155976712", changeMap = "left", custom = TryGather },
                        { map = "155976200", changeMap = "bottom", custom = TryGather },
                        { map = "155976201", changeMap = "right", custom = TryGather },
                        { map = "155976713", changeMap = "bottom", custom = TryGather },
                        { map = "155976714", changeMap = "left", custom = TryGather },
                        { map = "155976202", changeMap = "bottom", custom = TryGather },
                        { map = "155976203", changeMap = "bottom", custom = TryGather },
                        { map = "155976204", changeMap = "bottom", custom = TryGather },
                        { map = "155976205", changeMap = "bottom", custom = TryGather },
                        { map = "155976206", changeMap = "left", custom = TryGatherWithBP } -- Reboucle sur 155975694
                    }
                end
            },
            [10] = {
                name = "Zone Bombu #1",
                tags = {
                    "Bombu"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,84806401)") -- Zaap plaine des porkass [-5,-23]
                    end
                end,
                ["PATH"] = function()
                    return {
                        { map = "84806401", changeMap = "left", custom = TryGather },
                        { map = "84806913", changeMap = "left", custom = TryGather },
                        { map = "165155340", changeMap = "top", custom = TryGather }, -- Reboucle
                        { map = "165155339", changeMap = "top", custom = TryGather },
                        { map = "165155338", changeMap = "top", custom = TryGather },
                        { map = "165155337", changeMap = "top", custom = TryGather },
                        { map = "165155336", changeMap = "top", custom = TryGather },
                        { map = "165155335", changeMap = "top", custom = TryGather },
                        { map = "165155334", changeMap = "top", custom = TryGather },
                        { map = "165155333", changeMap = "top", custom = TryGather },
                        { map = "165155332", changeMap = "top", custom = TryGather },
                        { map = "165155331", changeMap = "top", custom = TryGather },
                        { map = "156238347", changeMap = "left", custom = TryGather },
                        { map = "156237835", changeMap = "bottom", custom = TryGather },
                        { map = "165154819", changeMap = "bottom", custom = TryGather },
                        { map = "165154820", changeMap = "bottom", custom = TryGather },
                        { map = "165154821", changeMap = "bottom", custom = TryGather },
                        { map = "165154822", changeMap = "bottom", custom = TryGather },
                        { map = "165154823", changeMap = "bottom", custom = TryGather },
                        { map = "165154824", changeMap = "bottom", custom = TryGather },
                        { map = "165154825", changeMap = "bottom", custom = TryGather },
                        { map = "165154826", changeMap = "bottom", custom = TryGather },
                        { map = "165154827", changeMap = "bottom", custom = TryGather },
                        { map = "165154828", changeMap = "bottom", custom = TryGather },
                        { map = "165154829", changeMap = "bottom", custom = TryGather },
                        { map = "165154830", changeMap = "bottom", custom = TryGather },
                        { map = "165154831", changeMap = "bottom", custom = TryGather },
                        { map = "165154832", changeMap = "right", custom = TryGather },
                        { map = "165155344", changeMap = "top", custom = TryGather },
                        { map = "165155343", changeMap = "top", custom = TryGather },
                        { map = "165155342", changeMap = "top", custom = TryGather },
                        { map = "165155341", changeMap = "top", custom = TryGatherWithBP } -- Reboucle sur 165155340
                    }
                end
            },
            [11] = {
                name = "Zone Bombu #2",
                tags = {
                    "Bombu"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,165152263)") -- Zaap Massif de cania [-13,-28]
                    end
                end,
                ["PATH"] = function()
                    return {
                        { map = "165152263", changeMap = "right", custom = TryGather },
                        { map = "165152775", changeMap = "top", custom = TryGather },
                        { map = "165152774", changeMap = "right", custom = TryGather },
                        { map = "165153286", changeMap = "top", custom = TryGather },
                        { map = "165153285", changeMap = "top", custom = TryGather },
                        { map = "165153284", changeMap = "top", custom = TryGather },
                        { map = "165153283", changeMap = "top", custom = TryGather },
                        { map = "165153282", changeMap = "right", custom = TryGather }, -- Reboucle
                        { map = "165153794", changeMap = "top", custom = TryGather },
                        { map = "165153793", changeMap = "right", custom = TryGather },
                        { map = "165154305", changeMap = "top", custom = TryGather },
                        { map = "165154304", changeMap = "top", custom = TryGather },
                        { map = "165154561", changeMap = "left", custom = TryGather },
                        { map = "165154049", changeMap = "left", custom = TryGather },
                        { map = "165153537", changeMap = "left", custom = TryGather },
                        { map = "165153025", changeMap = "left", custom = TryGather },
                        { map = "165152513", changeMap = "left", custom = TryGather },
                        { map = "139464201", changeMap = "left", custom = TryGather },
                        { map = "139463689", changeMap = "left", custom = TryGather },
                        { map = "139463177", changeMap = "bottom", custom = TryGather },
                        { map = "165150720", changeMap = "right", custom = TryGather },
                        { map = "165151232", changeMap = "right", custom = TryGather },
                        { map = "165151744", changeMap = "right", custom = TryGather },
                        { map = "165152256", changeMap = "right", custom = TryGather },
                        { map = "165152768", changeMap = "bottom", custom = TryGather },
                        { map = "165152769", changeMap = "bottom", custom = TryGather },
                        { map = "165152770", changeMap = "right", custom = TryGatherWithBP } -- Reboucle sur 165153282
                    }
                end
            },
            [12] = {
                name = "Zone Erable #1",
                tags = {
                    "Erable"
                },
                ["goPath"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,147590153)") -- Zaap Plaines rocheuses [-17,-47]
                    end
                end,
                ["toRet"] = function()
                    return {
                        { map = "147590153", changeMap = "bottom", custom = TryGather },
                        { map = "147590154", changeMap = "bottom", custom = TryGather },
                        { map = "147590155", changeMap = "right", custom = TryGather },
                        { map = "147590667", changeMap = "right", custom = TryGather },
                        { map = "155975694", changeMap = "top", custom = TryGather }, -- Reboucle
                        { map = "155975693", changeMap = "top", custom = TryGather },
                        { map = "155975692", changeMap = "top", custom = TryGather },
                        { map = "155975691", changeMap = "top", custom = TryGather },
                        { map = "155975690", changeMap = "top", custom = TryGather },
                        { map = "155975689", changeMap = "top", custom = TryGather },
                        { map = "155975688", changeMap = "top", custom = TryGather },
                        { map = "155975687", changeMap = "top", custom = TryGather },
                        { map = "155975686", changeMap = "top", custom = TryGather },
                        { map = "155975685", changeMap = "top", custom = TryGather },
                        { map = "155975684", changeMap = "top", custom = TryGather },
                        { map = "155975683", changeMap = "top", custom = TryGather },
                        { map = "155975682", changeMap = "top", custom = TryGather },
                        { map = "155975681", changeMap = "top", custom = TryGather },
                        { map = "155975680", changeMap = "right", custom = TryGather },
                        { map = "155976192", changeMap = "right", custom = TryGather },
                        { map = "155976704", changeMap = "bottom", custom = TryGather },
                        { map = "155976705", changeMap = "left", custom = TryGather },
                        { map = "155976193", changeMap = "bottom", custom = TryGather },
                        { map = "155976194", changeMap = "right", custom = TryGather },
                        { map = "155976706", changeMap = "bottom", custom = TryGather },
                        { map = "155976707", changeMap = "left", custom = TryGather },
                        { map = "155976195", changeMap = "bottom", custom = TryGather },
                        { map = "155976196", changeMap = "bottom", custom = TryGather },
                        { map = "155976197", changeMap = "right", custom = TryGather },
                        { map = "155976709", changeMap = "bottom", custom = TryGather },
                        { map = "155976710", changeMap = "left", custom = TryGather },
                        { map = "155976198", changeMap = "bottom", custom = TryGather },
                        { map = "155976199", changeMap = "right", custom = TryGather },
                        { map = "155976711", changeMap = "bottom", custom = TryGather },
                        { map = "155976712", changeMap = "left", custom = TryGather },
                        { map = "155976200", changeMap = "bottom", custom = TryGather },
                        { map = "155976201", changeMap = "right", custom = TryGather },
                        { map = "155976713", changeMap = "bottom", custom = TryGather },
                        { map = "155976714", changeMap = "left", custom = TryGather },
                        { map = "155976202", changeMap = "bottom", custom = TryGather },
                        { map = "155976203", changeMap = "bottom", custom = TryGather },
                        { map = "155976204", changeMap = "bottom", custom = TryGather },
                        { map = "155976205", changeMap = "bottom", custom = TryGather },
                        { map = "155976206", changeMap = "left", custom = TryGatherWithBP } -- Reboucle sur 155975694
                    }
                end
            },
            [13] = {
                name = "Zone Erable #2",
                tags = {
                    "Erable"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,191105026)") -- Zaap astrub [5,-18]
                    end
                end,
                ["PATH"] = function()
                    return {
                        { map = "191105026", changeMap = "right", custom = TryGather },
                        { map = "191106050", changeMap = "right", custom = TryGather },
                        { map = "188746756", changeMap = "bottom", custom = TryGather },
                        { map = "188746757", changeMap = "bottom", custom = TryGather },
                        { map = "188746758", changeMap = "bottom", custom = TryGather }, -- Reboucle
                        { map = "188746759", changeMap = "left", custom = TryGather },
                        { map = "188746247", changeMap = "left", custom = TryGather },
                        { map = "188745735", changeMap = "left", custom = TryGather },
                        { map = "188745223", changeMap = "left", custom = TryGather },
                        { map = "188744711", changeMap = "left", custom = TryGather },
                        { map = "188744199", changeMap = "left", custom = TryGather },
                        { map = "188743687", changeMap = "top", custom = TryGather },
                        { map = "188743686", changeMap = "top", custom = TryGather },
                        { map = "188743685", changeMap = "top", custom = TryGather },
                        { map = "188743684", changeMap = "top", custom = TryGather },
                        { map = "188743683", changeMap = "left", custom = TryGather },
                        { map = "189531146", changeMap = "left", custom = TryGather },
                        { map = "189530634", changeMap = "top", custom = TryGather },
                        { map = "189530633", changeMap = "top", custom = TryGather },
                        { map = "189530632", changeMap = "right", custom = TryGather },
                        { map = "189531144", changeMap = "right", custom = TryGather },
                        { map = "188743681", changeMap = "bottom", custom = TryGather },
                        { map = "188743682", changeMap = "right", custom = TryGather },
                        { map = "188744194", changeMap = "bottom", custom = TryGather },
                        { map = "188744195", changeMap = "bottom", custom = TryGather },
                        { map = "188744196", changeMap = "bottom", custom = TryGather },
                        { map = "188744197", changeMap = "bottom", custom = TryGather },
                        { map = "188744198", changeMap = "right", custom = TryGather },
                        { map = "188744710", changeMap = "right", custom = TryGather },
                        { map = "188745222", changeMap = "right", custom = TryGather },
                        { map = "188745734", changeMap = "right", custom = TryGather },
                        { map = "188746246", changeMap = "right", custom = TryGatherWithBP } -- Reboucle sur 188746758
                    }
                end
            },
            [14] = {
                name = "Zone Oliviolet #1",
                tags = {
                    "Oliviolet"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,171967506)") -- Zaap astrub [5,-18]
                    end
                end,
                ["PATH"] = function()
                    return {
                        { map = "171967506", changeMap = "top", custom = TryGather },
                        { map = "171967505", changeMap = "top", custom = TryGather },
                        { map = "171967504", changeMap = "right", custom = TryGather }, -- Reboucle
                        { map = "171968016", changeMap = "top", custom = TryGather },
                        { map = "171968015", changeMap = "top", custom = TryGather },
                        { map = "171968014", changeMap = "top", custom = TryGather },
                        { map = "171968013", changeMap = "top", custom = TryGather },
                        { map = "171968012", changeMap = "left", custom = TryGather },
                        { map = "171967500", changeMap = "top", custom = TryGather },
                        { map = "171967499", changeMap = "top", custom = TryGather },
                        { map = "171967498", changeMap = "top", custom = TryGather },
                        { map = "171967497", changeMap = "right", custom = TryGather },
                        { map = "171968009", changeMap = "top", custom = TryGather },
                        { map = "171968008", changeMap = "left", custom = TryGather },
                        { map = "171967496", changeMap = "top", custom = TryGather },
                        { map = "171967495", changeMap = "top", custom = TryGather },
                        { map = "171705867", changeMap = "top", custom = TryGather },
                        { map = "171705866", changeMap = "top", custom = TryGather },
                        { map = "171705865", changeMap = "right", custom = TryGather },
                        { map = "171706377", changeMap = "top", custom = TryGather },
                        { map = "171706376", changeMap = "left", custom = TryGather },
                        { map = "171705864", changeMap = "left", custom = TryGather },
                        { map = "171705352", changeMap = "left", custom = TryGather },
                        { map = "171704840", changeMap = "bottom", custom = TryGather },
                        { map = "171704841", changeMap = "bottom", custom = TryGather },
                        { map = "171704842", changeMap = "left", custom = TryGather },
                        { map = "171704330", changeMap = "bottom", custom = TryGather },
                        { map = "171704331", changeMap = "right", custom = TryGather },
                        { map = "171704843", changeMap = "right", custom = TryGather },
                        { map = "171705355", changeMap = "bottom", custom = TryGather },
                        { map = "171966983", changeMap = "bottom", custom = TryGather },
                        { map = "171966984", changeMap = "bottom", custom = TryGather },
                        { map = "171966985", changeMap = "bottom", custom = TryGather },
                        { map = "171966986", changeMap = "bottom", custom = TryGather },
                        { map = "171966987", changeMap = "bottom", custom = TryGather },
                        { map = "171966988", changeMap = "bottom", custom = TryGather },
                        { map = "171966989", changeMap = "bottom", custom = TryGather },
                        { map = "171966990", changeMap = "bottom", custom = TryGather },
                        { map = "171966991", changeMap = "bottom", custom = TryGather },
                        { map = "171966992", changeMap = "right", custom = TryGatherWithBP } -- Reboucle sur 171967504
                    }
                end
            },
            [15] = { -- Zaapi
                name = "Zone Oliviolet #2",
                tags = {
                    "Oliviolet"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        vHavre = true
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        idZaapi = "oliviolet"
                        map:changeMap("zaap(110,190,144419)") -- Zaap astrub [5,-18]
                    end
                end,
                ["PATH"] = function()
                    return {
                        { map = "144419", custom = zaapiToPath },
                        { map = "144425", changeMap = "bottom", custom = TryGather }, -- Reboucle
                        { map = "172231693", changeMap = "right", custom = TryGather },
                        { map = "172232205", changeMap = "right", custom = TryGather },
                        { map = "172232717", changeMap = "bottom", custom = TryGather },
                        { map = "172232718", changeMap = "bottom", custom = TryGather },
                        { map = "172232719", changeMap = "left", custom = TryGather },
                        { map = "172232207", changeMap = "bottom", custom = TryGather },
                        { map = "172232208", changeMap = "left", custom = TryGather },
                        { map = "172231696", changeMap = "left", custom = TryGather },
                        { map = "172231184", changeMap = "bottom", custom = TryGather },
                        { map = "172231185", changeMap = "left", custom = TryGather },
                        { map = "172230673", changeMap = "left", custom = TryGather },
                        { map = "172230161", changeMap = "left", custom = TryGather },
                        { map = "172229649", changeMap = "top", custom = TryGather },
                        { map = "172229648", changeMap = "top", custom = TryGather },
                        { map = "172229647", changeMap = "top", custom = TryGather },
                        { map = "172229646", changeMap = "top", custom = TryGather },
                        { map = "172229645", changeMap = "right", custom = TryGather },
                        { map = "172230157", changeMap = "right", custom = TryGather },
                        { map = "172230669", changeMap = "top", custom = TryGather },
                        { map = "172230668", changeMap = "right", custom = TryGather },
                        { map = "172231180", changeMap = "right", custom = TryGatherWithBP } -- Reboucle sur 144425
                    }
                end
            },
            [16] = {
                name = "Zone If #1",
                tags = {
                    "If"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,147590153)") -- Zaap astrub [5,-18]
                    end
                end,
                ["PATH"] = function()
                    return {
                        { map = "147590153", changeMap = "right", custom = TryGather },
                        { map = "147590665", changeMap = "right", custom = TryGather },
                        { map = "155975692", changeMap = "right", custom = TryGather },
                        { map = "155976204", changeMap = "right", custom = TryGather }, -- Reboucle
                        { map = "155976716", changeMap = "right", custom = TryGather },
                        { map = "155977228", changeMap = "top", custom = TryGather },
                        { map = "155977227", changeMap = "top", custom = TryGather },
                        { map = "155977226", changeMap = "top", custom = TryGather },
                        { map = "155977225", changeMap = "top", custom = TryGather },
                        { map = "155977224", changeMap = "top", custom = TryGather },
                        { map = "155977223", changeMap = "top", custom = TryGather },
                        { map = "155977222", changeMap = "top", custom = TryGather },
                        { map = "155977221", changeMap = "top", custom = TryGather },
                        { map = "155977220", changeMap = "top", custom = TryGather },
                        { map = "155977219", changeMap = "right", custom = TryGather },
                        { map = "155977731", changeMap = "top", custom = TryGather },
                        { map = "155977730", changeMap = "left", custom = TryGather },
                        { map = "155977218", changeMap = "top", custom = TryGather },
                        { map = "155977217", changeMap = "right", custom = TryGather },
                        { map = "155977729", changeMap = "top", custom = TryGather },
                        { map = "155977728", changeMap = "left", custom = TryGather },
                        { map = "155977216", changeMap = "left", custom = TryGather },
                        { map = "155976704", changeMap = "bottom", custom = TryGather },
                        { map = "155976705", changeMap = "bottom", custom = TryGather },
                        { map = "155976706", changeMap = "bottom", custom = TryGather },
                        { map = "155976707", changeMap = "left", custom = TryGather },
                        { map = "155976195", changeMap = "bottom", custom = TryGather },
                        { map = "155976196", changeMap = "bottom", custom = TryGather },
                        { map = "155976197", changeMap = "right", custom = TryGather },
                        { map = "155976709", changeMap = "bottom", custom = TryGather },
                        { map = "155976710", changeMap = "left", custom = TryGather },
                        { map = "155976198", changeMap = "bottom", custom = TryGather },
                        { map = "155976199", changeMap = "bottom", custom = TryGather },
                        { map = "155976200", changeMap = "bottom", custom = TryGather },
                        { map = "155976201", changeMap = "bottom", custom = TryGather },
                        { map = "155976202", changeMap = "bottom", custom = TryGather },
                        { map = "155976203", changeMap = "bottom", custom = TryGatherWithBP } -- Reboucle sur 155976204
                    }
                end
            },
            [17] = {
                name = "Zone If #2",
                tags = {
                    "If"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,156240386)") -- Zaap astrub [5,-18]
                    end
                end,
                ["PATH"] = function()
                    return {
                        { map = "156240386", changeMap = "right", custom = TryGather },
                        { map = "156240898", changeMap = "top", custom = TryGather },
                        { map = "156240897", changeMap = "top", custom = TryGather },
                        { map = "156240896", changeMap = "top", custom = TryGather },
                        { map = "127928335", changeMap = "top", custom = TryGather },
                        { map = "127928334", changeMap = "top", custom = TryGather },
                        { map = "127928333", changeMap = "top", custom = TryGather },
                        { map = "127928332", changeMap = "top", custom = TryGather },
                        { map = "126093076", changeMap = "top", custom = TryGather }, -- Reboucle
                        { map = "126093077", changeMap = "left", custom = TryGather },
                        { map = "126092565", changeMap = "left", custom = TryGather },
                        { map = "126092053", changeMap = "left", custom = TryGather },
                        { map = "126091541", changeMap = "top", custom = TryGather },
                        { map = "126091542", changeMap = "left", custom = TryGather },
                        { map = "126223126", changeMap = "left", custom = TryGather },
                        { map = "126223638", changeMap = "top", custom = TryGather },
                        { map = "126223639", changeMap = "top", custom = TryGather },
                        { map = "126223640", changeMap = "right", custom = TryGather },
                        { map = "126223128", changeMap = "top", custom = TryGather },
                        { map = "126223129", changeMap = "left", custom = TryGather },
                        { map = "126223641", changeMap = "left", custom = TryGather },
                        { map = "126224153", changeMap = "bottom", custom = TryGather },
                        { map = "126224152", changeMap = "bottom", custom = TryGather },
                        { map = "126224151", changeMap = "bottom", custom = TryGather },
                        { map = "126224150", changeMap = "bottom", custom = TryGather },
                        { map = "126224149", changeMap = "bottom", custom = TryGather },
                        { map = "126224148", changeMap = "right", custom = TryGather },
                        { map = "126223636", changeMap = "right", custom = TryGather },
                        { map = "126223124", changeMap = "right", custom = TryGather },
                        { map = "126091540", changeMap = "right", custom = TryGather },
                        { map = "126092052", changeMap = "right", custom = TryGather },
                        { map = "126092564", changeMap = "right", custom = TryGatherWithBP } -- Reboucle sur 126093076
                    }
                end
            },
            [18] = {
                name = "Zone Merisier #1",
                tags = {
                    "Merisier"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,147590153)") -- Zaap astrub [5,-18]
                    end
                end,
                ["PATH"] = function()
                    return{
                        { map = "147590153", changeMap = "bottom", custom = TryGather },
                        { map = "147590154", changeMap = "bottom", custom = TryGather },
                        { map = "147590155", changeMap = "bottom", custom = TryGather },
                        { map = "139462657", changeMap = "bottom", custom = TryGather },
                        { map = "139462658", changeMap = "bottom", custom = TryGather },
                        { map = "139462659", changeMap = "right", custom = TryGather },
                        { map = "139463171", changeMap = "right", custom = TryGather },
                        { map = "139463683", changeMap = "right", custom = TryGather },
                        { map = "139464195", changeMap = "right", custom = TryGather },
                        { map = "132121093", changeMap = "right", custom = TryGather }, -- Reboucle
                        { map = "132121605", changeMap = "right", custom = TryGather },
                        { map = "132122117", changeMap = "right", custom = TryGather },
                        { map = "132122629", changeMap = "top", custom = TryGather },
                        { map = "132122628", changeMap = "right", custom = TryGather },
                        { map = "132123140", changeMap = "top", custom = TryGather },
                        { map = "132123139", changeMap = "top", custom = TryGather },
                        { map = "132123138", changeMap = "top", custom = TryGather },
                        { map = "132123137", changeMap = "left", custom = TryGather },
                        { map = "132122625", changeMap = "bottom", custom = TryGather },
                        { map = "132122626", changeMap = "left", custom = TryGather },
                        { map = "132122114", changeMap = "top", custom = TryGather },
                        { map = "132122113", changeMap = "left", custom = TryGather },
                        { map = "132121601", changeMap = "top", custom = TryGather },
                        { map = "155977228", changeMap = "top", custom = TryGather },
                        { map = "155977227", changeMap = "top", custom = TryGather },
                        { map = "155977226", changeMap = "top", custom = TryGather },
                        { map = "155977225", changeMap = "top", custom = TryGather },
                        { map = "155977224", changeMap = "top", custom = TryGather },
                        { map = "155977223", changeMap = "top", custom = TryGather },
                        { map = "155977222", changeMap = "top", custom = TryGather },
                        { map = "155977221", changeMap = "top", custom = TryGather },
                        { map = "155977220", changeMap = "top", custom = TryGather },
                        { map = "155977219", changeMap = "right", custom = TryGather },
                        { map = "155977731", changeMap = "top", custom = TryGather },
                        { map = "155977730", changeMap = "left", custom = TryGather },
                        { map = "155977218", changeMap = "top", custom = TryGather },
                        { map = "155977217", changeMap = "left", custom = TryGather },
                        { map = "155976705", changeMap = "bottom", custom = TryGather },
                        { map = "155976706", changeMap = "bottom", custom = TryGather },
                        { map = "155976707", changeMap = "bottom", custom = TryGather },
                        { map = "155976708", changeMap = "bottom", custom = TryGather },
                        { map = "155976709", changeMap = "bottom", custom = TryGather },
                        { map = "155976710", changeMap = "bottom", custom = TryGather },
                        { map = "155976711", changeMap = "bottom", custom = TryGather },
                        { map = "155976712", changeMap = "bottom", custom = TryGather },
                        { map = "155976713", changeMap = "bottom", custom = TryGather },
                        { map = "155976714", changeMap = "bottom", custom = TryGather },
                        { map = "155976715", changeMap = "bottom", custom = TryGather },
                        { map = "155976716", changeMap = "bottom", custom = TryGather },
                        { map = "132121089", changeMap = "bottom", custom = TryGather },
                        { map = "132121090", changeMap = "bottom", custom = TryGather },
                        { map = "132121091", changeMap = "bottom", custom = TryGather },
                        { map = "132121092", changeMap = "bottom", custom = TryGatherWithBP } -- Reboucle sur 132121093
                    }
                end
            },
            [19] = {
                name = "Zone Ebene #1",
                tags = {
                    "Ebene"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212481)") -- Zaap astrub [5,-18]
                    end
                end,
                ["PATH"] = function()
                    return{
                        { map = "88212481", changeMap = "right", custom = TryGather },
                        { map = "88211969", changeMap = "right", custom = TryGather },
                        { map = "88080385", changeMap = "bottom", custom = TryGather },
                        { map = "88080386", changeMap = "bottom", custom = TryGather },
                        { map = "88080387", changeMap = "bottom", custom = TryGather },
                        { map = "88080388", changeMap = "bottom", custom = TryGather },
                        { map = "88080389", changeMap = "bottom", custom = TryGather },
                        { map = "88080390", changeMap = "bottom", custom = TryGather },
                        { map = "88080391", changeMap = "bottom", custom = TryGather },
                        { map = "72619521", changeMap = "bottom", custom = TryGather },
                        { map = "72619522", changeMap = "left", custom = TryGather },
                        { map = "72619010", changeMap = "bottom", custom = TryGather }, -- Reboucle
                        { map = "72619011", changeMap = "bottom", custom = TryGather },
                        { map = "72619012", changeMap = "left", custom = TryGather },
                        { map = "72618500", changeMap = "top", custom = TryGather },
                        { map = "72618499", changeMap = "top", custom = TryGather },
                        { map = "72618498", changeMap = "right", custom = TryGatherWithBP }

                    }
                end
            },
            [20] = {
                name = "Zone Noisetier #1",
                tags = {
                    "Noisetier"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,156240386)") -- Zaap astrub [5,-18]
                    end
                end,
                ["PATH"] = function()
                    return{
                        { map = "156240386", changeMap = "left", custom = TryGather },
                        { map = "156239874", changeMap = "left", custom = TryGather },
                        { map = "156239362", changeMap = "left", custom = TryGather },
                        { map = "156238850", changeMap = "left", custom = TryGather },
                        { map = "156238338", changeMap = "left", custom = TryGather },
                        { map = "156237826", changeMap = "left", custom = TryGather },
                        { map = "132123141", changeMap = "left", custom = TryGather }, -- Reboucle
                        { map = "132122629", changeMap = "left", custom = TryGather },
                        { map = "132122117", changeMap = "left", custom = TryGather },
                        { map = "132121605", changeMap = "left", custom = TryGather },
                        { map = "132121093", changeMap = "top", custom = TryGather },
                        { map = "132121092", changeMap = "top", custom = TryGather },
                        { map = "132121091", changeMap = "top", custom = TryGather },
                        { map = "132121090", changeMap = "top", custom = TryGather },
                        { map = "132121089", changeMap = "right", custom = TryGather },
                        { map = "132121601", changeMap = "bottom", custom = TryGather },
                        { map = "132121602", changeMap = "right", custom = TryGather },
                        { map = "132122114", changeMap = "top", custom = TryGather },
                        { map = "132122113", changeMap = "right", custom = TryGather },
                        { map = "132122625", changeMap = "right", custom = TryGather },
                        { map = "132123137", changeMap = "bottom", custom = TryGather },
                        { map = "132123138", changeMap = "bottom", custom = TryGather },
                        { map = "132123139", changeMap = "bottom", custom = TryGather },
                        { map = "132123140", changeMap = "bottom", custom = TryGatherWithBP } -- Reboucle sur 132123141
                    }
                end
            }
        }
    }

    local PATH_FIGHT = {
        ["leveling"] = {
            ["201"] = { -- Level 1 a 20
                {
                    name = "Astrub Piou",
                    tags = { -- SOON
                        'Plume de piou',
                        'Graine de sesame'
                    },
                    subArea = "Cite d'Astrub",
                    ["TP"] = function()
                        if map:currentMapId() ~= 162791424 then
                            havreSac()
               
                        elseif map:currentMapId() == 162791424 then
                            teleported = true
                            global:clickPosition(185,290) -- Debug zaap
                            global:delay(baseDelay)
                            map:changeMap("zaap(110,190,191105026)") -- Zaap Astrub
                        end
                    end,
                    MONSTER = {
                        ['MAX'] = {
                            ["100"] = 1,
                            ["150"] = 2,
                            ["250"] = 3,
                            ["300"] = 4,
                            ["400"] = 5,
                            ["500"] = 8
                        }
                    },
                    ["EQUIP_ITEM"] = function()
                        equipItem()
                        if currentLevelCharacter == 0 then
                        end
                    end,
                    ["SET_PARAMS"] = function()
                         global:printMessage("[INFO]["..string.upper(currentJob).."] Parametrage fight")
                         for kTable, vTable in pairs(FIGHT_FILTERED[pathIndex].MONSTER) do
                            if kTable == "MIN" then
                                setMonsters(vTable, 'min')
                            else
                                setMonsters(vTable, 'max')                                
                            end
                         end
                    end
                }
            }
        }
    }

    local PATH_REPLACE = {
        ["mineur"] = {
            -- lvl 20 a 40
            [1] = { -- Mine Istairameur
                name = "Mine Istairameur",
                tags = {
                    "Fer",
                    "Cuivre",
                    "Bronze",
                    "Manganese",
                    "Kobalte",
                    "Argent"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212746)") -- Zaap bord de la foret maléfique
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "88212746", changeMap = "top" },
                        { map = "88212747", changeMap = "top" },
                        { map = "88212748", changeMap = "top" },
                        { map = "88212749", changeMap = "top" },
                        { map = "88212750", changeMap = "left" },
                        { map = "88213262", changeMap = "left" },
                        { map = "88213774", changeMap = "354" },
                        { map = "97259013", changeMap = "258", custom = TryGather },
                        { map = "97260037", changeMap = "352", custom = TryGather },
                        { map = "97261061", changeMap = "284" },
                        { map = "97255943", changeMap = "403", custom = TryGather },
                        { map = "97261061", changeMap = "458", custom = TryGather },
                        { map = "97260037", changeMap = "430", custom = TryGather },
                        { map = "97259013", changeMap = "276", custom = TryGather },
                        { map = "97256967", changeMap = "194", custom = TryGather },
                        { map = "97260039", changeMap = "262", custom = TryGather },
                        { map = "97257993", changeMap = "122" },
                        { map = "97261065", changeMap = "236", custom = TryGather },
                        { map = "97259019", changeMap = "276", custom = TryGather },
                        { map = "97260043", changeMap = "451", custom = TryGather },
                        { map = "97259019", changeMap = "438", custom = TryGather },
                        { map = "97261065", changeMap = "213", custom = TryGather },
                        { map = "97255947", changeMap = "199", custom = TryGather },
                        { map = "97256971", changeMap = "239", custom = TryGather },
                        { map = "97257995", changeMap = "374", custom = TryGather },
                        { map = "97256971", changeMap = "503", custom = TryGather },
                        { map = "97255947", changeMap = "500", custom = TryGather },
                        { map = "97261065", changeMap = "479", custom = TryGather },
                        { map = "97257993", changeMap = "537" },
                        { map = "97260039", changeMap = "241", custom = TryGather },
                        { map = "97261063", changeMap = "296", custom = TryGather },
                        { map = "97255945", changeMap = "416", custom = TryGather },
                        { map = "97261063", changeMap = "459", custom = TryGather },
                        { map = "97260039", changeMap = "451", custom = TryGather },
                        { map = "97256967", changeMap = "518", custom = TryGatherWithBP }
                    })
                end
            },
            [2] = { -- Mine Astirite
                name = "Mine Astirite",
                tags = {
                    "Fer",
                    "Manganese",
                    "Kobalte",
                    "Cuivre"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88213271)") -- Zaap le village amakna
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "88213271", changeMap = "top" },
                        { map = "88213272", changeMap = "top" },
                        { map = "88213273", changeMap = "top" },
                        { map = "88213274", changeMap = "top" },
                        { map = "185862149", changeMap = "top" },
                        { map = "185862148", changeMap = "367" },
                        { map = "97255951", changeMap = "203" },
                        { map = "97256975", changeMap = "323", custom = TryGather },
                        { map = "97257999", changeMap = "268", custom = TryGather },
                        { map = "97260047", changeMap = "432", custom = TryGather },
                        { map = "97257999", changeMap = "403", custom = TryGatherWithBP }
                    })
                end
            },
            -- lvl 40 a 60
            [3] = { -- Mine Istairameur
                name = "Mine Istairameur",
                tags = {
                    "Fer",
                    "Cuivre",
                    "Bronze",
                    "Manganese",
                    "Kobalte",
                    "Argent"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212746)") -- Zaap bord de la foret maléfique
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "88212746", changeMap = "top" },
                        { map = "88212747", changeMap = "top" },
                        { map = "88212748", changeMap = "top" },
                        { map = "88212749", changeMap = "top" },
                        { map = "88212750", changeMap = "left" },
                        { map = "88213262", changeMap = "left" },
                        { map = "88213774", changeMap = "354" },
                        { map = "97259013", changeMap = "258", custom = TryGather },
                        { map = "97260037", changeMap = "352", custom = TryGather },
                        { map = "97261061", changeMap = "284", custom = TryGather },
                        { map = "97255943", changeMap = "403", custom = TryGather },
                        { map = "97261061", changeMap = "290", custom = TryGather },
                        { map = "97259015", changeMap = "451", custom = TryGather },
                        { map = "97261061", changeMap = "458", custom = TryGather },
                        { map = "97260037", changeMap = "303", custom = TryGather },
                        { map = "97257991", changeMap = "464", custom = TryGather },
                        { map = "97260037", changeMap = "430", custom = TryGather },
                        { map = "97259013", changeMap = "276", custom = TryGather },
                        { map = "97256967", changeMap = "194", custom = TryGather },
                        { map = "97260039", changeMap = "262", custom = TryGather },
                        { map = "97257993", changeMap = "122" },
                        { map = "97261065", changeMap = "236", custom = TryGather },
                        { map = "97259019", changeMap = "276", custom = TryGather },
                        { map = "97260043", changeMap = "451", custom = TryGather },
                        { map = "97259019", changeMap = "438", custom = TryGather },
                        { map = "97261065", changeMap = "213", custom = TryGather },
                        { map = "97255947", changeMap = "199", custom = TryGather },
                        { map = "97256971", changeMap = "239", custom = TryGather },
                        { map = "97257995", changeMap = "374", custom = TryGather },
                        { map = "97256971", changeMap = "503", custom = TryGather },
                        { map = "97255947", changeMap = "500", custom = TryGather },
                        { map = "97261065", changeMap = "479", custom = TryGather },
                        { map = "97257993", changeMap = "537" },
                        { map = "97260039", changeMap = "241", custom = TryGather },
                        { map = "97261063", changeMap = "296", custom = TryGather },
                        { map = "97255945", changeMap = "416", custom = TryGather },
                        { map = "97261063", changeMap = "459", custom = TryGather },
                        { map = "97260039", changeMap = "451", custom = TryGather },
                        { map = "97256967", changeMap = "518", custom = TryGatherWithBP }
                    })
                end
            },
            [4] = { -- Mine de Cania
                name = "Mine de Cania",
                tags = {
                    "Fer",
                    "Cuivre",
                    "Bronze",
                    "Manganese"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,156240386)") -- Zaap Lac de Cania
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "156240386", changeMap = "right" },
                        { map = "156240898", changeMap = "right" },
                        { map = "156241410", changeMap = "149" },
                        { map = "133431302", changeMap = "193", custom = TryGather },
                        { map = "133431300", changeMap = "180", custom = TryGather }, -- Reboucle
                        { map = "133431298", changeMap = "460", custom = TryGather },
                        { map = "133432322", changeMap = "129", custom = TryGather },
                        { map = "133432320", changeMap = "149", custom = TryGather },
                        { map = "133432578", changeMap = "450", custom = TryGather },
                        { map = "133432320", changeMap = "365", custom = TryGather },
                        { map = "133431296", changeMap = "307", custom = TryGather },
                        { map = "133432320", changeMap = "487", custom = TryGather },
                        { map = "133432322", changeMap = "362", custom = TryGather },
                        { map = "133433346", changeMap = "178", custom = TryGather },
                        { map = "133433344", changeMap = "529", custom = TryGather },
                        { map = "133433346", changeMap = "337", custom = TryGather },
                        { map = "133432322", changeMap = "337", custom = TryGather },
                        { map = "133431298", changeMap = "490", custom = TryGatherWithBP }
                    })
                end
            },
            -- lvl 60 a 80
            [5] = { -- Mine Astirite
                name = "Mine Astirite",
                tags = {
                    "Fer",
                    "Manganese",
                    "Kobalte"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88213271)") -- Zaap le village amakna
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "88213271", changeMap = "top" },
                        { map = "88213272", changeMap = "top" },
                        { map = "88213273", changeMap = "top" },
                        { map = "88213274", changeMap = "top" },
                        { map = "185862149", changeMap = "top" },
                        { map = "185862148", changeMap = "367" },
                        { map = "97255951", changeMap = "203" },
                        { map = "97256975", changeMap = "323", custom = TryGather },
                        { map = "97257999", changeMap = "268", custom = TryGather },
                        { map = "97260047", changeMap = "379", custom = TryGather },
                        { map = "97261071", changeMap = "248", custom = TryGather },
                        { map = "97260047", changeMap = "432", custom = TryGather },
                        { map = "97257999", changeMap = "403", custom = TryGatherWithBP }
                    })
                end
            },
            [6] = { -- Mine Istairameur
                name = "Mine Istairameur",
                tags = {
                    "Fer",
                    "Cuivre",
                    "Bronze",
                    "Manganese",
                    "Kobalte",
                    "Argent"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212746)") -- Zaap bord de la foret maléfique
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "88212746", changeMap = "top" },
                        { map = "88212747", changeMap = "top" },
                        { map = "88212748", changeMap = "top" },
                        { map = "88212749", changeMap = "top" },
                        { map = "88212750", changeMap = "left" },
                        { map = "88213262", changeMap = "left" },
                        { map = "88213774", changeMap = "354" },
                        { map = "97259013", changeMap = "258", custom = TryGather },
                        { map = "97260037", changeMap = "352", custom = TryGather },
                        { map = "97261061", changeMap = "284", custom = TryGather },
                        { map = "97255943", changeMap = "403", custom = TryGather },
                        { map = "97261061", changeMap = "290", custom = TryGather },
                        { map = "97259015", changeMap = "451", custom = TryGather },
                        { map = "97261061", changeMap = "458", custom = TryGather },
                        { map = "97260037", changeMap = "303", custom = TryGather },
                        { map = "97257991", changeMap = "464", custom = TryGather },
                        { map = "97260037", changeMap = "430", custom = TryGather },
                        { map = "97259013", changeMap = "276", custom = TryGather },
                        { map = "97256967", changeMap = "194", custom = TryGather },
                        { map = "97260039", changeMap = "262", custom = TryGather },
                        { map = "97257993", changeMap = "122" },
                        { map = "97261065", changeMap = "236", custom = TryGather },
                        { map = "97259019", changeMap = "276", custom = TryGather },
                        { map = "97260043", changeMap = "451", custom = TryGather },
                        { map = "97259019", changeMap = "438", custom = TryGather },
                        { map = "97261065", changeMap = "213", custom = TryGather },
                        { map = "97255947", changeMap = "199", custom = TryGather },
                        { map = "97256971", changeMap = "239", custom = TryGather },
                        { map = "97257995", changeMap = "374", custom = TryGather },
                        { map = "97256971", changeMap = "234", custom = TryGather },
                        { map = "97261067", changeMap = "521", custom = TryGather },
                        { map = "97256971", changeMap = "503", custom = TryGather },
                        { map = "97255947", changeMap = "500", custom = TryGather },
                        { map = "97261065", changeMap = "479", custom = TryGather },
                        { map = "97257993", changeMap = "537" },
                        { map = "97260039", changeMap = "241", custom = TryGather },
                        { map = "97261063", changeMap = "296", custom = TryGather },
                        { map = "97255945", changeMap = "416", custom = TryGather },
                        { map = "97261063", changeMap = "459", custom = TryGather },
                        { map = "97260039", changeMap = "451", custom = TryGather },
                        { map = "97256967", changeMap = "518", custom = TryGatherWithBP }
                    })
                end
            },
            [7] = { -- Mine Hipouce
                name = "Mine Hipouce",
                tags = {
                    "Bronze",
                    "Kobalte"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,171967506)") -- Zaap routte des roulotte
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "171967506", changeMap = "bottom" },
                        { map = "171967507", changeMap = "bottom" },
                        { map = "171967508", changeMap = "bottom" },
                        { map = "173017857", changeMap = "bottom" },
                        { map = "173017600", changeMap = "bottom" },
                        { map = "173017601", changeMap = "434" },
                        { map = "173017602", changeMap = "484" },
                        { map = "173017603", changeMap = "bottom" },
                        { map = "173017604", changeMap = "right" },
                        { map = "173018116", changeMap = "bottom" },
                        { map = "173018117", changeMap = "left" },
                        { map = "173017605", changeMap = "493" },
                        { map = "173017606", changeMap = "268" },
                        { map = "178782208", custom = TryGatherWithCM },
                        { map = "178782210", changeMap = "221", custom = TryGather },
                        { map = "178783234", custom = TryGatherWithCM },
                        { map = "178783232", changeMap = "204", custom = TryGather },
                        { map = "178784256", changeMap = "476", custom = TryGather },
                        { map = "178783232", changeMap = "213", custom = TryGather },
                        { map = "178783236", changeMap = "138", custom = TryGather },
                        { map = "178784260", changeMap = "406", custom = TryGather },
                        { map = "178783236", changeMap = "323", custom = TryGather },
                        { map = "178782214", changeMap = "507", custom = TryGather },
                        { map = "178782216", changeMap = "450" },
                        { map = "178782218", changeMap = "518", custom = TryGather },
                        { map = "178782220", changeMap = "57", custom = TryGather },
                        { map = "178782218", custom = TryGatherWithCM },
                        { map = "178782216", changeMap = "162", custom = TryGather },
                        { map = "178782214", changeMap = "179", custom = TryGather },
                        { map = "178783236", changeMap = "527", custom = TryGather },
                        { map = "178783232", changeMap = "406", custom = TryGatherWithBP }
                    })
                end
            },
            -- lvl 80 a 120
            [8] = { -- Mine Astirite
                name = "Mine Astirite",
                tags = {
                    "Fer",
                    "Manganese",
                    "Kobalte"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88213271)") -- Zaap le village amakna
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "88213271", changeMap = "top" },
                        { map = "88213272", changeMap = "top" },
                        { map = "88213273", changeMap = "top" },
                        { map = "88213274", changeMap = "top" },
                        { map = "185862149", changeMap = "top" },
                        { map = "185862148", changeMap = "367" },
                        { map = "97255951", changeMap = "203" },
                        { map = "97256975", changeMap = "323", custom = TryGather },
                        { map = "97257999", changeMap = "268", custom = TryGather },
                        { map = "97260047", changeMap = "379", custom = TryGather },
                        { map = "97261071", changeMap = "248", custom = TryGather },
                        { map = "97260047", changeMap = "432", custom = TryGather },
                        { map = "97257999", changeMap = "247", custom = TryGather },
                        { map = "97259023", changeMap = "451", custom = TryGather },
                        { map = "97257999", custom = TryGatherWithFDB }
                    })
                end
            },
            [9] = { -- Mine Istairameur
                name = "Mine Istairameur",
                tags = {
                    "Fer",
                    "Cuivre",
                    "Bronze",
                    "Manganese",
                    "Kobalte",
                    "Argent"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212746)") -- Zaap bord de la foret maléfique
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "88212746", changeMap = "top" },
                        { map = "88212747", changeMap = "top" },
                        { map = "88212748", changeMap = "top" },
                        { map = "88212749", changeMap = "top" },
                        { map = "88212750", changeMap = "left" },
                        { map = "88213262", changeMap = "left" },
                        { map = "88213774", changeMap = "354" },
                        { map = "97259013", changeMap = "258", custom = TryGather },
                        { map = "97260037", changeMap = "352", custom = TryGather },
                        { map = "97261061", changeMap = "284", custom = TryGather },
                        { map = "97255943", changeMap = "403", custom = TryGather },
                        { map = "97261061", changeMap = "290", custom = TryGather },
                        { map = "97259015", changeMap = "451", custom = TryGather },
                        { map = "97261061", changeMap = "458", custom = TryGather },
                        { map = "97260037", changeMap = "303", custom = TryGather },
                        { map = "97257991", changeMap = "464", custom = TryGather },
                        { map = "97260037", changeMap = "430", custom = TryGather },
                        { map = "97259013", changeMap = "276", custom = TryGather },
                        { map = "97256967", changeMap = "194", custom = TryGather },
                        { map = "97260039", changeMap = "262", custom = TryGather },
                        { map = "97257993", changeMap = "122" },
                        { map = "97261065", changeMap = "236", custom = TryGather },
                        { map = "97259019", changeMap = "276", custom = TryGather },
                        { map = "97260043", changeMap = "451", custom = TryGather },
                        { map = "97259019", changeMap = "438", custom = TryGather },
                        { map = "97261065", changeMap = "213", custom = TryGather },
                        { map = "97255947", changeMap = "199", custom = TryGather },
                        { map = "97256971", changeMap = "239", custom = TryGather },
                        { map = "97257995", changeMap = "374", custom = TryGather },
                        { map = "97256971", changeMap = "234", custom = TryGather },
                        { map = "97261067", changeMap = "521", custom = TryGather },
                        { map = "97256971", changeMap = "503", custom = TryGather },
                        { map = "97255947", changeMap = "500", custom = TryGather },
                        { map = "97261065", changeMap = "479", custom = TryGather },
                        { map = "97257993", changeMap = "537" },
                        { map = "97260039", changeMap = "241", custom = TryGather },
                        { map = "97261063", changeMap = "296", custom = TryGather },
                        { map = "97255945", changeMap = "332", custom = TryGather },
                        { map = "97260041", changeMap = "354", custom = TryGather},
                        { map = "97255945", changeMap = "416", custom = TryGather },
                        { map = "97261063", changeMap = "331", custom = TryGather },
                        { map = "97259017", changeMap = "436", custom = TryGather },
                        { map = "97261063", changeMap = "459", custom = TryGather },
                        { map = "97260039", changeMap = "451", custom = TryGather },
                        { map = "97256967", changeMap = "518", custom = TryGatherWithBP },
                    })
                end
            },
            [10] = { -- Mine Herale
                name = "Mine Herale",
                tags = {
                    "Fer",
                    "Cuivre",
                    "Bronze",
                    "Manganese",
                    "Or"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88085249)") -- Zaap Rivage sufokien
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "88085249", changeMap = "left" },
                        { map = "88084737", changeMap = "left" },
                        { map = "88084225", changeMap = "top" },
                        { map = "88084226", changeMap = "top" },
                        { map = "88084227", changeMap = "left" },
                        { map = "88083715", changeMap = "left" },
                        { map = "88083203", changeMap = "top" },
                        { map = "88083204", changeMap = "left" },
                        { map = "88082692", changeMap = "332" },
                        { map = "97260033", changeMap = "183", custom = TryGather },
                        { map = "97261059", changeMap = "417", custom = TryGather },
                        { map = "97260033", changeMap = "405", custom = TryGather },
                        { map = "97261057", changeMap = "235", custom = TryGather },
                        { map = "97255939", changeMap = "446", custom = TryGather },
                        { map = "97256963", changeMap = "492", custom = TryGather },
                        { map = "97257987", changeMap = "212" },
                        { map = "97261057", changeMap = "421", custom = TryGather },
                        { map = "97259011", changeMap = "276", custom = TryGather },
                        { map = "97261057", changeMap = "227", custom = TryGatherWithBP },
                    })
                end
            },
            -- lvl 120 a 160
            [11] = { -- Mine Istairameur
                name = "Mine Istairameur",
                tags = {
                    "Fer",
                    "Cuivre",
                    "Bronze",
                    "Manganese",
                    "Kobalte",
                    "Argent"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88212746)") -- Zaap bord de la foret maléfique
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "88212746", changeMap = "top" },
                        { map = "88212747", changeMap = "top" },
                        { map = "88212748", changeMap = "top" },
                        { map = "88212749", changeMap = "top" },
                        { map = "88212750", changeMap = "left" },
                        { map = "88213262", changeMap = "left" },
                        { map = "88213774", changeMap = "354" },
                        { map = "97259013", changeMap = "258", custom = TryGather },
                        { map = "97260037", changeMap = "352", custom = TryGather },
                        { map = "97261061", changeMap = "284", custom = TryGather },
                        { map = "97255943", changeMap = "403", custom = TryGather },
                        { map = "97261061", changeMap = "290", custom = TryGather },
                        { map = "97259015", changeMap = "451", custom = TryGather },
                        { map = "97261061", changeMap = "458", custom = TryGather },
                        { map = "97260037", changeMap = "303", custom = TryGather },
                        { map = "97257991", changeMap = "464", custom = TryGather },
                        { map = "97260037", changeMap = "430", custom = TryGather },
                        { map = "97259013", changeMap = "276", custom = TryGather },
                        { map = "97256967", changeMap = "194", custom = TryGather },
                        { map = "97260039", changeMap = "262", custom = TryGather },
                        { map = "97257993", changeMap = "122", custom = TryGather },
                        { map = "97261065", changeMap = "236", custom = TryGather },
                        { map = "97259019", changeMap = "276", custom = TryGather },
                        { map = "97260043", changeMap = "451", custom = TryGather},
                        { map = "97259019", changeMap = "438", custom = TryGather },
                        { map = "97261065", changeMap = "213", custom = TryGather },
                        { map = "97255947", changeMap = "199", custom = TryGather },
                        { map = "97256971", changeMap = "239", custom = TryGather },
                        { map = "97257995", changeMap = "374", custom = TryGather },
                        { map = "97256971", changeMap = "234", custom = TryGather },
                        { map = "97261067", changeMap = "521", custom = TryGather },
                        { map = "97256971", changeMap = "503", custom = TryGather },
                        { map = "97255947", changeMap = "500", custom = TryGather },
                        { map = "97261065", changeMap = "479", custom = TryGather },
                        { map = "97257993", changeMap = "537", custom = TryGather },
                        { map = "97260039", changeMap = "241", custom = TryGather },
                        { map = "97261063", changeMap = "296", custom = TryGather },
                        { map = "97255945", changeMap = "213", custom = TryGather },
                        { map = "97256969", changeMap = "401", custom = TryGather },
                        { map = "97255945", changeMap = "332", custom = TryGather },
                        { map = "97260041", changeMap = "354", custom = TryGather },
                        { map = "97255945", changeMap = "416", custom = TryGather },
                        { map = "97261063", changeMap = "331", custom = TryGather },
                        { map = "97259017", changeMap = "436", custom = TryGather },
                        { map = "97261063", changeMap = "459", custom = TryGather },
                        { map = "97260039", changeMap = "451", custom = TryGather },
                        { map = "97256967", changeMap = "518", custom = TryGatherWithBP },
                    })
                end
            },
            -- lvl 160 a 200
            [12] = { -- Mine Herale
                name = "Mine Herale",
                tags = {
                    "Fer",
                    "Cuivre",
                    "Bronze",
                    "Manganese",
                    "Or"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,88085249)") -- Zaap Rivage sufokien
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
				        { map = "88085249", changeMap = "left" },
				        { map = "88084737", changeMap = "left" },
				        { map = "88084225", changeMap = "top" },
				        { map = "88084226", changeMap = "top" },
				        { map = "88084227", changeMap = "left" },
				        { map = "88083715", changeMap = "left" },
				        { map = "88083203", changeMap = "top" },
				        { map = "88083204", changeMap = "left" },
				        { map = "88082692", changeMap = "332" },
				        { map = "97260033", changeMap = "405", custom = TryGather },
				        { map = "97261057", changeMap = "421", custom = TryGather },
				        { map = "97259011", changeMap = "276", custom = TryGather },
				        { map = "97261057", changeMap = "235", custom = TryGather },
				        { map = "97255939", changeMap = "446", custom = TryGather },
                        { map = "97256963", changeMap = "492", custom = TryGather },
                        { map = "97257987", changeMap = "492" },
				        { map = "97260035", changeMap = "288", custom = TryGather },
                        { map = "97257987", changeMap = "212" },
				        { map = "97261057", changeMap = "227", custom = TryGather },
				        { map = "97260033", changeMap = "183", custom = TryGather },
				        { map = "97261059", changeMap = "417", custom = TryGatherWithBP },
                    })
                end
            },

            -- Ajout Mines par condition
            [13] = { -- Pandala
                name = "Mine Pandala",
                tags = {
                    "Silicate",
                    "Dolomite"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,207619076)")
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "207619076", changeMap = "436" },
                        { map = "206307842", changeMap = "right" },
                        { map = "206308354", changeMap = "right" },
                        { map = "206308866", changeMap = "bottom" },
                        { map = "206308867", changeMap = "right" },
                        { map = "206309379", changeMap = "bottom" },
                        { map = "206309380", changeMap = "right" },
                        { map = "205260033", changeMap = "right", custom = TryGather },
                        { map = "205260545", changeMap = "right", custom = TryGather },
                        { map = "205261057", changeMap = "right", custom = TryGather },
                        { map = "205261569", changeMap = "top", custom = TryGather },
                        { map = "205261570", changeMap = "bottom", custom = TryGather },
                        { map = "205261569", changeMap = "bottom", custom = TryGather },
                        { map = "205261312", changeMap = "left", custom = TryGather },
                        { map = "205260800", changeMap = "left", custom = TryGather },
                        { map = "205260288", changeMap = "left", custom = TryGather },
                        { map = "205259776", changeMap = "left", custom = TryGather },
                        { map = "205259264", changeMap = "left", custom = TryGather },
                        { map = "205258752", changeMap = "bottom", custom = TryGather },
                        { map = "205258753", changeMap = "right", custom = TryGather },
                        { map = "205259265", changeMap = "right", custom = TryGather },
                        { map = "205259777", changeMap = "right", custom = TryGather },
                        { map = "205260289", changeMap = "right", custom = TryGather },
                        { map = "205260801", changeMap = "bottom", custom = TryGather },
                        { map = "205260802", changeMap = "left", custom = TryGather },
                        { map = "205260290", changeMap = "left", custom = TryGather },
                        { map = "205259778", changeMap = "left", custom = TryGather },
                        { map = "205259266", changeMap = "right", custom = TryGather },
                        { map = "205259778", changeMap = "bottom", custom = TryGather },
                        { map = "205259779", changeMap = "bottom", custom = TryGather },
                        { map = "205259780", changeMap = "right" , custom = TryGather },
                        { map = "205260292", changeMap = "319" , custom = TryGather },
                        { map = "207619084", changeMap = "235", custom = TryGather },
                        { map = "207620108", custom = TryGatherWithBP }
                    })
                end
            },
            [14] = { -- Mine Himum Saharach
                name = "Mine Himum",
                tags = {
                    "Argent",
                    "Bauxite",
                    "Or"
                },
                ["goPath"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,173278210)") -- Zaap Saharach
                    end
                end,
                ["toRet"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "173278210", changeMap = "top" },
                        { map = "173278209", changeMap = "top" },
                        { map = "173278208", changeMap = "right" },
                        { map = "173278720", changeMap = "147" },
                        { map = "173935364", changeMap = "297", custom = TryGather },
                        { map = "173936388", changeMap = "464", custom = TryGather },
                        { map = "173937412", changeMap = "382", custom = TryGather },
                        { map = "173938436", changeMap = "367", custom = TryGather },
                        { map = "173939460", changeMap = "432", custom = TryGather },
                        { map = "173938436", changeMap = "291", custom = TryGather },
                        { map = "173937412", changeMap = "264", custom = TryGather },
                        { map = "173936388", changeMap = "389", custom = TryGatherWithBP }
                    })
                end
            },
            [15] = { -- Mine Sakai
                name = "Mine Sakai",
                tags = {
                    "Etain",
                    "Obsidienne",
                    "Or",
                    "Bauxite"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        idTransporteur = "sakai"
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,54172969)") -- Frigost
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "54172969", changeMap = "right" },
                        { map = "54172457", changeMap = "right" },
                        { map = "54171945", changeMap = "right" },
                        { map = "54171433", changeMap = "right" },
                        { map = "54170921", changeMap = "right" },
                        { map = "54170409", changeMap = "bottom" },
                        { map = "54170408", changeMap = "bottom" },
                        { map = "54170407", changeMap = "bottom" },
                        { map = "54170406", changeMap = "bottom" },
                        { map = "54170405", changeMap = "bottom" },
                        { map = "54170404", changeMap = "bottom" },
                        { map = "54170403", changeMap = "bottom" },
                        { map = "54170402", changeMap = "right" },
                        { map = "54169890", changeMap = "right" },
                        { map = "54169378", changeMap = "right" },
                        { map = "54168866", changeMap = "right" },
                        { map = "54168354", changeMap = "right" },
                        { map = "54167842", custom = transporteurFrigostien },
                        { map = "54161193", changeMap = "right" },
                        { map = "54160681", changeMap = "right" },
                        { map = "54160169", changeMap = "top" },
                        { map = "54160170", changeMap = "top" },
                        { map = "54160171", changeMap = "top" },
                        { map = "54160172", changeMap = "right" },
                        { map = "54159660", changeMap = "right" },
                        { map = "54159148", changeMap = "173" },
                        { map = "57017863", changeMap = "429", custom = TryGather },        
                        { map = "54159148", changeMap = "top" },
                        { map = "54159149", changeMap = "right" },
                        { map = "54158637", changeMap = "377" }, 
                        { map = "57016839", changeMap = "298", custom = TryGather }, 
                        { map = "56886791", changeMap = "442", custom = TryGather }, 
                        { map = "57016839", changeMap = "262", custom = TryGather }, 
                        { map = "56885767", changeMap = "410", custom = TryGather }, 
                        { map = "57016839", custom = TryGatherWithFDB }
                    })
                end
            },
            [16] = { -- Mine Maksage
                name = "Mine Maksage",
                tags = {
                    "Obsidienne",
                    "Or",
                    "Bauxite"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        idTransporteur = "maksage"
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,54172969)") -- Frigost
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "54172969", changeMap = "right" },
                        { map = "54172457", changeMap = "right" },
                        { map = "54171945", changeMap = "right" },
                        { map = "54171433", changeMap = "right" },
                        { map = "54170921", changeMap = "right" },
                        { map = "54170409", changeMap = "bottom" },
                        { map = "54170408", changeMap = "bottom" },
                        { map = "54170407", changeMap = "bottom" },
                        { map = "54170406", changeMap = "bottom" },
                        { map = "54170405", changeMap = "bottom" },
                        { map = "54170404", changeMap = "bottom" },
                        { map = "54170403", changeMap = "bottom" },
                        { map = "54170402", changeMap = "right" },
                        { map = "54169890", changeMap = "right" },
                        { map = "54169378", changeMap = "right" },
                        { map = "54168866", changeMap = "right" },
                        { map = "54168354", changeMap = "right" },
                        { map = "54167842", custom = transporteurFrigostien },
                        { map = "54161738", changeMap = "bottom" },
                        { map = "54161737", changeMap = "left" },
                        { map = "54162249", changeMap = "left" },
                        { map = "54162761", changeMap = "left" },
                        { map = "54163273", changeMap = "198" },
                        { map = "56885760", changeMap = "212" },
                        { map = "57016832", changeMap = "256" },
                        { map = "54162757", changeMap = "bottom" },
                        { map = "54162756", changeMap = "bottom" },
                        { map = "54162755", changeMap = "bottom" },
                        { map = "54162754", changeMap = "bottom" },
                        { map = "54162753", changeMap = "bottom" },               
                        { map = "54162752", changeMap = "right" },
                        { map = "54162240", changeMap = "right" },
                        { map = "54161728", changeMap = "right" },
                        { map = "54161216", changeMap = "275" },
                        { map = "57017859", changeMap = "359", custom = TryGather },
                        { map = "57017861", changeMap = "270", custom = TryGather}, -- rt
                        { map = "57017859", changeMap = "206", custom = TryGather },
                        { map = "57016835", changeMap = "220", custom = TryGather },               
                        { map = "56885763", changeMap = "207", custom = TryGather },
                        { map = "56886787", changeMap = "396", custom = TryGather }, -- rt
                        { map = "56885763", changeMap = "436", custom = TryGather }, -- rt
                        { map = "57016835", changeMap = "257", custom = TryGather },               
                        { map = "57016837", changeMap = "401", custom = TryGather }, --rt              
                        { map = "57016835", changeMap = "409", custom = TryGather }, -- rt 
                        { map = "57017859", changeMap = "395", custom = TryGather }, -- rt
                        { map = "54161216", custom = finDeBoucle }          
                    })
                end
            },
            [17] = { -- Mine Hissoire
                name = "Mine Hissoire",
                tags = {
                    "Obsidienne",
                    "Bauxite"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        idTransporteur = "hissoire"
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,54172969)") -- Frigost
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "54172969", changeMap = "right" },
                        { map = "54172457", changeMap = "right" },
                        { map = "54171945", changeMap = "right" },
                        { map = "54171433", changeMap = "right" },
                        { map = "54170921", changeMap = "right" },
                        { map = "54170409", changeMap = "bottom" },
                        { map = "54170408", changeMap = "bottom" },
                        { map = "54170407", changeMap = "bottom" },
                        { map = "54170406", changeMap = "bottom" },
                        { map = "54170405", changeMap = "bottom" },
                        { map = "54170404", changeMap = "bottom" },
                        { map = "54170403", changeMap = "bottom" },
                        { map = "54170402", changeMap = "right" },
                        { map = "54169890", changeMap = "right" },
                        { map = "54169378", changeMap = "right" },
                        { map = "54168866", changeMap = "right" },
                        { map = "54168354", changeMap = "right" },
                        { map = "54167842", custom = transporteurFrigostien },
                        { map = "54161738", changeMap = "top" },
                        { map = "54161739", changeMap = "top" },
                        { map = "54161740", changeMap = "220" },
                        { map = "57017865", changeMap = "386", custom = TryGather },
                        { map = "56886793", changeMap = "270", custom = TryGather },
                        { map = "57017865", changeMap = "299", custom = TryGather },
                        { map = "57016841", changeMap = "260", custom = TryGather },
                        { map = "56885769", custom = TryGatherWithFDB }   
                    })
                end
            },
            [18] = { -- Mine Ouronigride
                name = "Mine Ouronigride",
                tags = {
                    "Obsidienne"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        idTransporteur = "ouronigride"
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,54172969)") -- Frigost
                    end
                end,
                ["PATH"] = function()
                    return MULTIPLE_MAP:Run({
                        { map = "54172969", changeMap = "right" },
                        { map = "54172457", changeMap = "right" },
                        { map = "54171945", changeMap = "right" },
                        { map = "54171433", changeMap = "right" },
                        { map = "54170921", changeMap = "right" },
                        { map = "54170409", changeMap = "bottom" },
                        { map = "54170408", changeMap = "bottom" },
                        { map = "54170407", changeMap = "bottom" },
                        { map = "54170406", changeMap = "bottom" },
                        { map = "54170405", changeMap = "bottom" },
                        { map = "54170404", changeMap = "bottom" },
                        { map = "54170403", changeMap = "bottom" },
                        { map = "54170402", changeMap = "right" },
                        { map = "54169890", changeMap = "right" },
                        { map = "54169378", changeMap = "right" },
                        { map = "54168866", changeMap = "right" },
                        { map = "54168354", changeMap = "right" },
                        { map = "54167842", custom = transporteurFrigostien },
                        { map = "54168407", changeMap = "bottom" },
                        { map = "54168406", changeMap = "bottom" },
                        { map = "54168405", changeMap = "left" },
                        { map = "54168917", changeMap = "left" },
                        { map = "54169429", changeMap = "left" },
                        { map = "54169941", changeMap = "left" },
                        { map = "54170453", changeMap = "left" },
                        { map = "54170965", changeMap = "left" },
                        { map = "54171477", changeMap = "left" },
                        { map = "54171989", changeMap = "96" },
                        { map = "57017867", custom = TryGatherWithFDB }
                    })
                end
            },
        },
        ["paysan"] = {
            [1] = {
                name = "Zone Riz Pandala",
                tags = {
                    "Riz"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,207619076)") -- Zaap Pandala
                    end
                end,
                ["PATH"] = function()
			        return MULTIPLE_MAP:Run({
                        { map = "207619076", changeMap = "436" },  
                        { map = "20,-29", changeMap = "bottom" }, 
                        { map = "20,-28", changeMap = "bottom" }, 
                        { map = "20,-27", changeMap = "bottom" }, 
                        { map = "20,-26", changeMap = "bottom", custom = TryGather },-- reboucle
                        { map = "20,-25", changeMap = "right", custom = TryGather }, 
                        { map = "21,-25", changeMap = "top", custom = TryGather }, 
                        { map = "21,-26", changeMap = "left", custom = TryGatherWithBP },-- boucle fini
			        })
                end
            },
        },
        ["alchimiste"] = {
            [1] = {
                name = "Zone Graine de pandouille Pandala",
                tags = {
                    "Graine de pandouille"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 and not vHavre then
                        havreSac()
               
                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,207619076)") -- Zaap Village Amakna
                    end
                end,
                ["PATH"] = function()
                    return {
                        { map = "207619076", changeMap = "436" },  -- Zaap Pandala
    	                { map = "20,-29", changeMap = "right" }, 
                        { map = "21,-29", changeMap = "right" }, 
                        { map = "22,-29", changeMap = "right" },
                        { map = "23,-29", changeMap = "right" },  
                        { map = "25,-28", changeMap = "right", custom = TryGather }, 
                        { map = "26,-28", changeMap = "top", custom = TryGather }, 
                        { map = "26,-29", changeMap = "right", custom = TryGather }, 
                        { map = "27,-29", changeMap = "top", custom = TryGather }, 
                        { map = "27,-30", changeMap = "top", custom = TryGather }, 
                        { map = "27,-31", changeMap = "left", custom = TryGather }, 
                        { map = "25,-31", changeMap = "bottom", custom = TryGather }, 
                        { map = "25,-30", changeMap = "bottom", custom = TryGather }, 
                        { map = "24,-29", changeMap = "top", custom = TryGather }, 
                        { map = "24,-30", changeMap = "top", custom = TryGather }, 
                        { map = "23,-36", changeMap = "top", custom = TryGather }, 
                        { map = "24,-31", changeMap = "right", custom = TryGather }, 
                        { map = "25,-29", changeMap = "bottom", custom = TryGather }, 
                        { map = "26,-31", changeMap = "top", custom = TryGather }, 
                        { map = "26,-32", changeMap = "left", custom = TryGather }, 
                        { map = "25,-32", changeMap = "left", custom = TryGather }, 
                        { map = "24,-32", changeMap = "top", custom = TryGather }, 
                        { map = "24,-33", changeMap = "right", custom = TryGather }, 
                        { map = "25,-33", changeMap = "top", custom = TryGather }, 
                        { map = "25,-34", changeMap = "left", custom = TryGather },
                        { map = "24,-34", custom = pandalaTP1},
                        { map = "23,-34", changeMap = "left", custom = TryGather }, 
                        { map = "22,-34", changeMap = "top", custom = TryGather }, 
                        { map = "22,-35", changeMap = "left", custom = TryGather }, 
                        { map = "21,-35", changeMap = "top", custom = TryGather }, 
                        { map = "21,-36", changeMap = "top", custom = TryGather }, 
                        { map = "21,-37", changeMap = "left", custom = TryGather }, 
                        { map = "20,-37", changeMap = "bottom", custom = TryGather }, 
                        { map = "20,-36", changeMap = "left", custom = TryGather }, 
                        { map = "19,-36", changeMap = "bottom", custom = TryGather }, 
                        { map = "19,-35", changeMap = "bottom", custom = TryGather }, 
                        { map = "19,-34", changeMap = "bottom", custom = TryGather }, 
                        { map = "19,-33", changeMap = "bottom", custom = TryGather }, 
                        { map = "19,-32", changeMap = "right", custom = TryGather }, 
                        { map = "20,-32", changeMap = "bottom", custom = TryGather }, 
                        { map = "20,-31", changeMap = "left", custom = TryGather }, 
                        { map = "19,-31", changeMap = "bottom", custom = TryGather }, 
                        { map = "19,-30", changeMap = "bottom", custom = TryGather }, 
                        { map = "19,-29", changeMap = "bottom", custom = TryGather }, 
                        { map = "19,-28", changeMap = "right", custom = TryGather }, 
                        { map = "20,-28", changeMap = "right", custom = TryGather }, 
                        { map = "21,-28", changeMap = "right", custom = TryGather }, 
                        { map = "22,-28", changeMap = "right", custom = TryGather }, 
                        { map = "23,-28", changeMap = "bottom", custom = TryGather }, 
                        { map = "23,-27", changeMap = "left", custom = TryGather }, 
                        { map = "22,-27", changeMap = "left", custom = TryGather }, 
                        { map = "21,-27", changeMap = "left", custom = TryGather }, 
                        { map = "20,-27", changeMap = "bottom", custom = TryGather }, 
                        { map = "20,-26", changeMap = "left", custom = TryGather }, 
                        { map = "19,-26", changeMap = "bottom", custom = TryGather }, 
                        { map = "19,-25", changeMap = "bottom", custom = TryGather }, 
                        { map = "19,-24", changeMap = "right", custom = TryGather }, 
                        { map = "20,-24", changeMap = "top", custom = TryGather}, 
                        { map = "20,-25", changeMap = "right", custom = TryGather }, 
                        { map = "21,-25", changeMap = "top", custom = TryGather }, 
                        { map = "21,-26", changeMap = "right", custom = TryGather },
                        { map = "22,-26", custom = pandalaReturn}
                    }
                end
            },
        },
        ["bucheron"] = {
            [1] = { -- Otomai
                name = "Zone Ebene #2",
                tags = {
                    "Ebene"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,154642)") -- Zaap astrub [5,-18]
                    end
                end,
                ["PATH"] = function()
                    return{
                        { map = "154642", changeMap = "bottom", custom = TryGather },
                        { map = "154643", changeMap = "left", custom = TryGather },
                        { map = "155155", changeMap = "left", custom = TryGather },
                        { map = "155667", changeMap = "left", custom = TryGather },
                        { map = "156179", changeMap = "left", custom = TryGather },
                        { map = "156691", changeMap = "bottom", custom = TryGather },
                        { map = "156692", changeMap = "bottom", custom = TryGather },
                        { map = "156693", changeMap = "left", custom = TryGather },
                        { map = "157205", changeMap = "top", custom = TryGather },
                        { map = "63965696", changeMap = "top", custom = TryGather },
                        { map = "63965953", changeMap = "left", custom = TryGather }, -- Reboucle
                        { map = "63965441", changeMap = "left", custom = TryGather },
                        { map = "63964929", changeMap = "top", custom = TryGather },
                        { map = "63964930", changeMap = "left", custom = TryGather },
                        { map = "63964418", changeMap = "left", custom = TryGather },
                        { map = "63963906", changeMap = "top", custom = TryGather },
                        { map = "63963907", changeMap = "right", custom = TryGather },
                        { map = "63964419", changeMap = "top", custom = TryGather },
                        { map = "63964420", changeMap = "left", custom = TryGather },
                        { map = "63963908", changeMap = "left", custom = TryGather },
                        { map = "63963396", changeMap = "top", custom = TryGather },
                        { map = "63963397", changeMap = "top", custom = TryGather },
                        { map = "63963398", changeMap = "right", custom = TryGather },
                        { map = "63963910", changeMap = "right", custom = TryGather },
                        { map = "63964422", changeMap = "right", custom = TryGather },
                        { map = "63964934", changeMap = "bottom", custom = TryGather },
                        { map = "63964933", changeMap = "right", custom = TryGather },
                        { map = "63965445", changeMap = "top", custom = TryGather },
                        { map = "63965446", changeMap = "right", custom = TryGather },
                        { map = "63965958", changeMap = "bottom", custom = TryGather },
                        { map = "63965957", changeMap = "right", custom = TryGather },
                        { map = "63966469", changeMap = "bottom", custom = TryGather },
                        { map = "63966468", changeMap = "left", custom = TryGather },
                        { map = "63965956", changeMap = "bottom", custom = TryGather },
                        { map = "63965955", changeMap = "right", custom = TryGather },
                        { map = "63966467", changeMap = "bottom", custom = TryGather },
                        { map = "63966466", changeMap = "left", custom = TryGather },
                        { map = "63965954", changeMap = "bottom", custom = TryGatherWithBP } -- Reboucle sur 63965953
                    }
                end
            },
            [2] = {
                name = "Zone Noisetier #2",
                tags = {
                    "Noisetier"
                },
                ["TP"] = function()
                    if map:currentMapId() ~= 162791424 then
                        havreSac()

                    elseif map:currentMapId() == 162791424 then
                        teleported = true
                        global:clickPosition(185,290) -- Debug zaap
                        global:delay(baseDelay)
                        map:changeMap("zaap(110,190,154642)") -- Zaap astrub [5,-18]
                    end
                end,
                ["PATH"] = function()
                    return{
                        { map = "154642", changeMap = "bottom", custom = TryGather },
                        { map = "154643", changeMap = "left", custom = TryGather },
                        { map = "155155", changeMap = "left", custom = TryGather },
                        { map = "155667", changeMap = "left", custom = TryGather },
                        { map = "156179", changeMap = "left", custom = TryGather },
                        { map = "156691", changeMap = "bottom", custom = TryGather },
                        { map = "156692", changeMap = "bottom", custom = TryGather },
                        { map = "156693", changeMap = "left", custom = TryGather },
                        { map = "157205", changeMap = "top", custom = TryGather },
                        { map = "63965696", changeMap = "left", custom = TryGather }, -- Reboucle
                        { map = "63965184", changeMap = "left", custom = TryGather },
                        { map = "63964672", changeMap = "bottom", custom = TryGather },
                        { map = "63964673", changeMap = "left", custom = TryGather },
                        { map = "63964161", changeMap = "top", custom = TryGather },
                        { map = "63964160", changeMap = "left", custom = TryGather },
                        { map = "63963648", changeMap = "left", custom = TryGather },
                        { map = "63963136", changeMap = "top", custom = TryGather },
                        { map = "63963393", changeMap = "top", custom = TryGather },
                        { map = "63963394", changeMap = "top", custom = TryGather },
                        { map = "63963395", changeMap = "top", custom = TryGather },
                        { map = "63963396", changeMap = "top", custom = TryGather },
                        { map = "63963397", changeMap = "right", custom = TryGather },
                        { map = "63963909", changeMap = "bottom", custom = TryGather },
                        { map = "63963908", changeMap = "bottom", custom = TryGather },
                        { map = "63963907", changeMap = "right", custom = TryGather },
                        { map = "63964419", changeMap = "top", custom = TryGather },
                        { map = "63964420", changeMap = "top", custom = TryGather },
                        { map = "63964421", changeMap = "top", custom = TryGather },
                        { map = "63964422", changeMap = "top", custom = TryGather },
                        { map = "63964423", changeMap = "left", custom = TryGather },
                        { map = "63963911", changeMap = "top", custom = TryGather },
                        { map = "63963912", changeMap = "top", custom = TryGather },
                        { map = "63963913", changeMap = "top", custom = TryGather },
                        { map = "63963914", changeMap = "top", custom = TryGather },
                        { map = "63963915", changeMap = "right", custom = TryGather },
                        { map = "63964427", changeMap = "right", custom = TryGather },
                        { map = "63964939", changeMap = "bottom", custom = TryGather },
                        { map = "63964938", changeMap = "bottom", custom = TryGather },
                        { map = "63964937", changeMap = "right", custom = TryGather },
                        { map = "63965449", changeMap = "bottom", custom = TryGather },
                        { map = "63965448", changeMap = "bottom", custom = TryGather },
                        { map = "63965447", changeMap = "right", custom = TryGather },
                        { map = "63965959", changeMap = "bottom", custom = TryGather },
                        { map = "63965958", changeMap = "bottom", custom = TryGather },
                        { map = "63965957", changeMap = "bottom", custom = TryGather },
                        { map = "63965956", changeMap = "bottom", custom = TryGather },
                        { map = "63965955", changeMap = "bottom", custom = TryGather },
                        { map = "63965954", changeMap = "bottom", custom = TryGather },
                        { map = "63965953", changeMap = "bottom", custom = TryGatherWithBP } -- Reboucle sur 63965696
                    }
                end
            },

        }
    }

    local PATH_CRAFT = {
        ["paysan"] = {
            ["TP"] = function()
                if map:currentMapId() ~= 162791424 then
                    havreSac()

                elseif map:currentMapId() == 162791424 then
                    teleported = true
                    global:printMessage("[INFO] Go craft !")
                    global:clickPosition(185,290) -- Debug zaap
                    global:delay(baseDelay)
                    map:changeMap("zaap(110,190,191105026)")
                end
            end,
            ["PATH"] = function()
                return {
                    { map = "191105026", changeMap = "left" },
                    { map = "191104002", changeMap = "top" },
                    { map = "191104000", changeMap = "top" },
                    { map = "188745218", changeMap = "top" },
                    { map = "188745217", changeMap = "right" },
                    { map = "188745729", changeMap = "344" },
                    { map = "192939008", custom = craft },
                }
            end
        },
        ["alchimiste"] = {
            ["TP"] = function()
                if map:currentMapId() ~= 162791424 then
                    havreSac()

                elseif map:currentMapId() == 162791424 then
                    teleported = true
                    global:printMessage("[INFO] Go craft !")
                    global:clickPosition(185,290) -- Debug zaap
                    global:delay(baseDelay)
                    map:changeMap("zaap(110,190,191105026)")
                end
            end,
            ["PATH"] = function()
                return {
                    { map = "191105026", changeMap = "left" },
                    { map = "191104002", changeMap = "top" },
                    { map = "191104000", changeMap = "top" },
                    { map = "188745218", changeMap = "top" },
                    { map = "188745217", changeMap = "left" },
                    { map = "188744705", changeMap = "413" },
                    { map = "192937988", custom = craft },
                }
            end
        },
        ["mineur"] = {
            ["TP"] = function()
                if map:currentMapId() ~= 162791424 then
                    havreSac()

                elseif map:currentMapId() == 162791424 then
                    teleported = true
                    idZaapi = "atelierMineur"
                    global:printMessage("[INFO] Go craft !")
                    global:clickPosition(185,290) -- Debug zaap
                    global:delay(baseDelay)
                    map:changeMap("zaap(110,190,147768)")
                end
            end,
            ["PATH"] = function()
                return {
                    { map = "147768", custom = zaapiToPath },
                    { map = "145209", changeMap = "354" },
                    { map = "7340551", custom = craft },
                }
            end
        },
        ["bucheron"] = {
            ["TP"] = function()
                if map:currentMapId() ~= 162791424 then
                    havreSac()

                elseif map:currentMapId() == 162791424 then
                    teleported = true
                    global:printMessage("[INFO] Go craft !")
                    global:clickPosition(185,290) -- Debug zaap
                    global:delay(baseDelay)
                    map:changeMap("zaap(110,190,191105026)") -- Zaap Astrub [5,-18]
                end
            end,
            ["PATH"] = function()
                return {
                    { map = "191105026", changeMap = "left" },
                    { map = "191104002", changeMap = "top" },
                    { map = "191104000", changeMap = "top" },
                    { map = "188745218", changeMap = "top" },
                    { map = "188745217", changeMap = "top" },
                    { map = "189792777", changeMap = "top" },
                    { map = "189792776", changeMap = "top" },
                    { map = "189792775", changeMap = "top" },
                    { map = "189792774", changeMap = "left" },
                    { map = "189792262", changeMap = "left" },
                    { map = "189532164", changeMap = "left" },
                    { map = "189531652", changeMap = "left" },
                    { map = "189531140", custom = useClick },
                    { map = "192940042", custom = craft },
                }
            end
        } 
    }

    local RETOUR_BANK = {
        ["TP"] = function()
            if map:currentMapId() ~= 162791424
            and map:currentMapId() ~= 191105026
            and map:currentMapId() ~= 191104002
            and map:currentMapId() ~= 192415750 then
                havreSac()

            elseif map:currentMapId() == 191105026
            or map:currentMapId() == 191104002
            or map:currentMapId() == 192415750
            and not teleported then
                teleported = true

            elseif map:currentMapId() == 162791424 then
                global:printMessage("[INFO] Go bank !")
                teleported = true
                global:clickPosition(185,290) -- Debug zaap
                global:delay(baseDelay)
                map:changeMap("zaap(110,190,191105026)")
            end
        end,
        ["PATH"] = function()
            return {
            { map = "191105026", changeMap = "left" },
            { map = "191104002", custom = useClick },
            { map = "192415750", custom = useBank },
	    }
        end
    }

    local RETOUR_MAISON = {
        ["TP"] = function()
            if map:currentMapId() ~= 162791424 then
                havreSac()

            elseif map:currentMapId() == 162791424 then
                global:printMessage("[INFO] Go bank !")
                teleported = true
                global:clickPosition(185,290) -- Debug zaap
                global:delay(baseDelay)
                map:changeMap("zaap(110,190,xxxxxxxxxx)") -- Zaap de destination
            end
        end,
        ["PATH"] = function()
            idZaapi = "maison"
            return {
            { map = "xxxxxx", custom = zaapiToPath }, -- Début du retour maison
            { map = "xxxxxx", changeMap = "bottom" },
            { map = "xxxxxx", changeMap = "right" },
            { map = "xxxxxx", custom = maison }, -- A lancer devant la maison
            { map = "xxxxxx", custom = maison}, -- A lancer dedans la maison
            { map = "xxxxxx", custom = maison }, -- A lancer devant la maison
            { map = "xxxxxx", custom = maison}, -- A lancer dedans la maison
	    }
        end
    }

    local tblIndexAddedPath = {}


function equipItem()
    --global:printMessage("equipItem()")
end

function maison()
    if map:currentMapId() == 147251 then
        global:delay(baseDelay)
        global:clickPosition(70,195) -- Porte
        global:delay(longDelay)
        global:sendKey(xxxxxx)
        global:sendKey(xxxxxx)
        global:sendKey(xxxxxx)
        global:sendKey(xxxxxx)
        global:sendKey(xxxxxx)
        global:sendKey(xxxxxx)
        global:sendKey(xxxxxx)
        global:sendKey(xxxxxx)
        global:delay(baseDelay)
        global:clickPosition(325,340) -- Valide

    elseif map:currentMapId() == 4718594 then
        global:delay(baseDelay)
        global:clickPosition(110,270) -- Escalier
        global:delay(veryLongDelay)

    elseif map:currentMapId() == 4719618 then
        if coffreEtage1 then
            global:delay(baseDelay)
            global:clickPosition(385,210) -- Coffre maison
            global:delay(longDelay)
            global:sendKey(xxxxxx)
            global:sendKey(xxxxxx)
            global:sendKey(xxxxxx)
            global:sendKey(xxxxxx)
            global:sendKey(xxxxxx)
            global:sendKey(xxxxxx)
            global:sendKey(xxxxxx)
            global:sendKey(xxxxxx)
            global:delay(baseDelay)
            global:clickPosition(325,340) -- Valide
            global:delay(veryLongDelay)
            storage:putAllItems()
            global:delay(longDelay)
            inCoffre()
        else
            global:delay(longDelay)
            global:clickPosition(545,285) -- Escalier
            global:delay(veryLongDelay)
        end
    elseif map:currentMapId() == 4720642 then
        global:delay(baseDelay)
        global:clickPosition(440,220) -- Coffre maison
        global:delay(mediumDelay)
        global:sendKey(xxxxxx)
        global:sendKey(xxxxxx)
        global:sendKey(xxxxxx)
        global:sendKey(xxxxxx)
        global:sendKey(xxxxxx)
        global:sendKey(xxxxxx)
        global:sendKey(xxxxxx)
        global:sendKey(xxxxxx)
        global:delay(baseDelay)
        global:clickPosition(325,340) -- Valide
        global:delay(veryLongDelay)
        storage:putAllItems()
        global:delay(longDelay)
        inCoffre()
    end
end

function move()
    currentMapId = map:currentMapId()
    heure, minute = Time() 
    
    if lastMinute ~= minute and checkRessource and not goCraft then
        if levelJob == 10 or
        levelJob == 20 or
        levelJob == 30 or
        levelJob == 40 or
        levelJob == 50 or
        levelJob == 60 or
        levelJob == 70 or
        levelJob == 80 or
        levelJob == 90 or
        levelJob == 100 or
        levelJob == 110 or
        levelJob == 120 or
        levelJob == 130 or
        levelJob == 140 or
        levelJob == 150 or
        levelJob == 160 or
        levelJob == 170 or
        levelJob == 180 or
        levelJob == 190 or
        levelJob == 200 then
            sortCraft()
        end
        lastMinute = minute
        assignWork()
    end

    if lastCurrentMode ~= currentMode then
        lastCurrentMode = currentMode
        started = false
    end

    if not initScript then
        start()
    end

    if resetLoop then
        resetInfiniteLoop()
    end

    if not checkRessource then
        if DEPOT_MAISON then
            if not teleported then
                RETOUR_MAISON.TP()
            end
            return RETOUR_MAISON.PATH()
        else
            if not teleported then
                RETOUR_BANK.TP()
            end
            return RETOUR_BANK.PATH()
        end
    end

    if goCraft then
        for kPath, vPath in pairs(PATH_CRAFT) do
            if kPath == currentJob then
                if not teleported then
                    vPath.TP()
                end
                return vPath.PATH()
            end
        end
    end

    if currentJob == "leveling" or currentJob == "combat" then
        return fightMode()
    else
        return gatherMode()
    end
end

function bank()
    heure, minute = Time()    

    if lastMinute ~= minute and checkRessource and not goCraft then
        lastMinute = minute
        assignWork()
    end

    if not initScript then
        start()
    end

    checkBag()

    if not messageBank then
        global:printMessage("[INFO]["..string.upper(currentJob).."] Full POD !")
        teleported = false
        messageBank = true
    end

    if DEPOT_MAISON then
        if not teleported then
            RETOUR_MAISON.TP()
        end
        return RETOUR_MAISON.PATH()
    else
        if not teleported then
            RETOUR_BANK.TP()
        end
        return RETOUR_BANK.PATH()
    end
end

function lost()
    currentMapId = map:currentMapId()
    global:printMessage("[INFO]["..string.upper(currentJob).."] Bot perdu ! MapId = " ..currentMapId)
    global:delay(baseDelay)
    finDeBoucle()
end

function gatherMode()

    if not started then
        pathIndex =  nil
        lastNameZone = nil
        beforeLastNameZone = nil
        started = true
    end

    if goCheckStock then
        checkStock()
    end

    if not filterPathByTags then
        filterPath()
    end

    if not goCraft and AUTO_OPEN_BAG then
        checkBag()
    end

    if timeZoneMode then
        timeZone()
        jobTime = diffTime
    else
        jobTime = nbBoucle
    end

    if not setPathToFarm then
        setPath(PATH_FILTERED)
    end

    if jobTime >= tbLimit then
        global:printMessage("[INFO]["..string.upper(currentJob).."] Changement de zone !")
        if lastTotalGather ~= totalGather then
            lastTotalGather = totalGather
            global:printMessage("[INFO]["..string.upper(currentJob).."] Vous avez fait au minimum " ..totalGather.. " recolte")
        end
        finDeBoucle()
    end
    
    if not teleported then
        PATH_FILTERED[pathIndex].TP()
    end
    return PATH_FILTERED[pathIndex].PATH()
end

function fightMode()
    --global:printMessage('Current subArea = '.. map:subArea())
    --global:printMessage('Current ZoneToFarm = '..ZoneToFarm)
    local lastXp = character.getLastXpGain()
    if lastXpGain ~= lastXp and teleported then
        lastXpGain = lastXp
        totalXp = totalXp + lastXp
        totalFight = totalFight + 1
        global:printMessage("[INFO]["..string.upper(currentJob).."] Niveau courant : " ..currentLevelCharacter)
        global:printMessage("[INFO]["..string.upper(currentJob).."] Combat effectue : " ..totalFight)
        global:printMessage("[INFO]["..string.upper(currentJob).."] Xp gagne au dernier combat : " ..lastXp)
        global:printMessage("[INFO]["..string.upper(currentJob).."] Xp total gagne : " ..totalXp)
        global:printMessage("[INFO]["..string.upper(currentJob).."] Niveau total gagne : " ..(currentLevelCharacter - startLevelCharacter))
    end

    timeZone()

    if not started then
        lastXpGain = character.getLastXpGain()
        pathIndex =  nil
        lastNameZone = nil
        beforeLastNameZone = nil
        started = true
    end

    if not setFightZone then
        setZoneToFarm()
    end

    if diffTime >= tbLimit then
        global:printMessage("[INFO]["..string.upper(currentJob).."] Changement de zone !")
        finDeBoucle()
    end

    if not teleported then
        FIGHT_FILTERED[pathIndex].SET_PARAMS()
        FIGHT_FILTERED[pathIndex].TP()
    end

    if currentLevelCharacter ~= character.level() then
        currentLevelCharacter = character.level()
        FIGHT_FILTERED[pathIndex].SET_PARAMS()
    end

    FIGHT_FILTERED[pathIndex].EQUIP_ITEM()

	if map:subArea() == ZoneToFarm then
        return{ {map = map:currentMapId(), custom = TryFight} }
    else
    	return { {map = map:currentMapId(), custom = GoBack} }
	end
end

function setZoneToFarm()
    local levelCharacter = character.level()
    MIN_MONSTERS = 1
    MAX_MONSTERS = 8
    MANDATORY_MONSTERS = {}
    FORBIDDEN_MONSTERS = {}

    for kJob, vTableFight in pairs(PATH_FIGHT) do
        if kJob == currentJob then
            for kLevel, vTablePath in pairs(vTableFight) do
                if levelCharacter < tonumber(kLevel) then
                    for _, vPath in pairs(vTablePath) do
                        --global:printMessage(vPath.name.. " inserted")
                        table.insert(FIGHT_FILTERED, vPath)
                    end
                end
            end
        end
    end

    setPath(FIGHT_FILTERED)
    setFightZone = true
end

function setMonsters(tbl, minMax)
    --global:printMessage("In setMonsters")
    for kLevel, vSet in pairs(tbl) do
        local goodChoice = character.maxLifePoints() >= tonumber(kLevel)
        if minMax == 'min' and goodChoice then
            --global:printMessage("Min = " ..vSet)
            MIN_MONSTERS = vSet
        elseif minMax == 'max' and goodChoice then
            --global:printMessage("Max = " ..vSet)
            MAX_MONSTERS = vSet
        end
    end
end

function setPath(tbl)
    local lastPathIndex
    if pathIndex ~= nil then
        beforeLastNameZone = lastNameZone
        lastNameZone = tbl[pathIndex].name
        lastPathIndex = pathIndex
    end

    if #tbl > 3 and lastNameZone ~= nil and beforeLastNameZone ~= nil and pathIndex ~= nil and pathIndex ~= lastPathIndex then
        while lastNameZone == tbl[pathIndex].name and beforeLastNameZone == tbl[pathIndex].name do
            pathIndex = math.random(1, #tbl)
        end
    elseif #tbl > 2 and lastNameZone ~= nil and pathIndex ~= nil and pathIndex ~= lastPathIndex then
        while lastNameZone == tbl[pathIndex].name do
            pathIndex = math.random(1, #tbl)
        end
    else
        pathIndex = math.random(1, #tbl)
    end


    local boucleMax = math.random(bMin, bMax)
    local timeMaxZone = math.random(tMin, tMax)
    global:printMessage("[INFO]["..string.upper(currentJob).."] Go " ..tbl[pathIndex].name)
    if timeZoneMode or currentMode == "fight" then
        tbLimit = timeMaxZone
        if currentMode == "fight" then
            ZoneToFarm = tbl[pathIndex].subArea
            --global:printMessage(ZoneToFarm)
        end
        global:printMessage("[INFO]["..string.upper(currentJob).."] Vous allez passez " ..timeMaxZone.. " minutes dans la zone !")
    else
        tbLimit = boucleMax
        global:printMessage("[INFO]["..string.upper(currentJob).."] Vous allez faire " ..boucleMax.. " boucle dans la zone !")
    end

    setPathToFarm = true
end

function filterPath()
    global:printMessage("[INFO]["..string.upper(currentJob).. "] Filtrage des PATH a farm")
    killDoubleValue(TO_FARM)
    --printSimpleTable(TO_FARM)
    PATH_FILTERED = {}
    tblIndexAddedPath = {}
    while true do
        if #TO_FARM > 0 then
            for kJob, vTable in pairs(PATH_JOB) do
                local match = false
                if kJob == currentJob then
                    match = true
                    local step = 0
                    for iTag, vTag in pairs(TO_FARM) do
                        if step > 2 then
                            resetLoop = true
                            resetInfiniteLoop()
                        end
                        --global:printMessage("step : "..step)
                        if iTag >= lastItag then
                            lastItag = iTag
                            step = step + 1
                            for iPath, vPath in pairs(vTable) do
                                if not alreadyAdded(iPath) then
                                    --global:printMessage("Looking for add "..vPath.name)
                                    local goBreak = false
                                    for _, vTagPath in pairs(vPath.tags) do
                                        if goBreak then
                                            break
                                        end
                                        if vTag == vTagPath then
                                            table.insert(tblIndexAddedPath, iPath)
                                            table.insert(PATH_FILTERED, vPath)
                                            --global:printMessage(vPath.name.." added vTag : "..vTag.." vTagPath : "..vTagPath)
                                            goBreak = true
                                            break                                                               
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if match then
                    break
                end
            end
        end
        if #PATH_FILTERED == 0 then
            for k, vTbl in pairs(ITEM) do
                if currentJob == k then
                    for _, v in pairs(vTbl) do
                        if v.lvlToFarm <= job:level(currentIdJob) then
                            table.insert(TO_FARM, v.name)
                        end
                    end
                end
            end
        else
            break
        end
    end
    lastItag = 0
    filterPathByTags = true
end

function alreadyAdded(index)
    if #tblIndexAddedPath > 0 then
        for _, v in pairs(tblIndexAddedPath) do
            if v == index then
                return true
            end
        end
    end
    return false
end

function checkStock()
    local levelJob = job:level(currentIdJob)
    if GATHER_ALL_RESOURCES_OF_JOB then
        global:printMessage("[INFO] GATHER_ALL_RESOURCES_OF_JOB et sur true, recolte de toutes les ressource possible du metier actuelle !")
        for keyTable, vTable in pairs(ITEM) do
            if keyTable == currentJob then
                for _, vItem in pairs(vTable) do
                    if levelJob >= vItem.lvlToFarm then
                        table.insert(ELEMENTS_TO_GATHER, vItem.gatherId)
                        table.insert(TO_FARM, vItem.name)
                    end
                end
            end
        end
    else
        killDoubleValue(TO_FARM)
        --global:printMessage("check stock lenght : "..#TO_FARM)
        for keyTable, vTable in pairs(ITEM) do
            if keyTable == currentJob then
                for _, vItem in pairs(vTable) do
                    local tmpN = ""
                    if vItem.minStock ~= nil and vItem.lvlToFarm ~= nil then
                        if vItem.current < vItem.minStock and levelJob >= vItem.lvlToFarm then
                            global:printMessage("[INFO]["..string.upper(currentJob).."] Stock de " ..vItem.name.. " incomplet ! minStock = " ..vItem.minStock.. ", Ajout des path contenant " ..vItem.name)
                            tmpN = vItem.name
                            table.insert(ELEMENTS_TO_GATHER, vItem.gatherId)
                            table.insert(TO_FARM, vItem.name)
                        end
                    end
                    if vItem.maxStock ~= nil then
                        --global:printMessage("[DEV] maxStock de " ..vItem.name.. " different de nil vItem.current = " ..vItem.current.. " vItem.maxStock = " ..vItem.maxStock.. " vItem.forceFarm = " ..tostring(vItem.forceFarm).. " tmpN = " ..tmpN.. " lvlToFarm = " ..vItem.lvlToFarm.. " currentLevelJob = " ..levelJob)
                        if vItem.forceFarm and vItem.current < vItem.maxStock and vItem.name ~= tmpN and levelJob >= vItem.lvlToFarm then
                            global:printMessage("[INFO]["..string.upper(currentJob).."] ForceFarm de " ..vItem.name.. " Activer et maxStock = " ..vItem.maxStock.. " non atteint ! Ajout des path contenant " ..vItem.name)
                            table.insert(ELEMENTS_TO_GATHER, vItem.gatherId)
                            table.insert(TO_FARM, vItem.name)
                        end
                    end
                end

            end
        end
        setETG()
    end
    --global:printMessage("check stock lenght : "..#TO_FARM)
    lastItag = 0
    unsetETG()
    pathReplace()
    goCheckStock = false
    global:delay(baseDelay)
    global:sendKey(72)
    global:delay(longDelay)
end

function setETG() -- Assigne les ressources a recolter dans ELEMENTS_TO_GATHER
    for kTable, vTable in pairs(ITEM) do
        if kTable == currentJob then
            if #TO_FARM > 0 then
                for iTag, vTag in pairs(TO_FARM) do
                    --global:printMessage('Looking for '..vTag)
                    if iTag > lastItag or lastItag == 0 then
                        for _, vItem in pairs(vTable) do
                            --global:printMessage('vTag : '..vTag..' vItem : '..vItem.name)
                            if vItem.name == vTag then
                                --global:printMessage(vItem.name..' added SetETG : '..vItem.gatherId)
                                table.insert(ELEMENTS_TO_GATHER, vItem.gatherId)
                                lastItag = iTag
                                break
                            end
                        end 
                    end
                end
            end
        end
    end
end

function unsetETG() -- Desactive la recolte d'une ressource si maxStock atteint
    for keyTable, vTable in pairs(ITEM) do
        if keyTable == currentJob then
            for kItem, vItem in pairs(vTable) do
                if vItem.gatherId ~= nil and vItem.maxStock ~= nil and (vItem.maxStock <= vItem.current) then
                    global:printMessage("[INFO]["..string.upper(currentJob).."] Desactivation de la recolte de " ..vItem.name.. " maxStock atteint !")
                    vItem.forceFarm = false
                    for i, v in pairs(TO_FARM) do
                        if v == vItem.name then
                            table.remove(TO_FARM, i)
                            --global:printMessage("TO_FARM removed")
                        end
                    end
                    for iGather, vGather in pairs(ELEMENTS_TO_GATHER) do
                        if vGather == vItem.gatherId then
                            table.remove(ELEMENTS_TO_GATHER, iGather)
                            --global:printMessage("ELEMENTS_TO_GATHER removed")
                            break
                        end
                    end
                end
            end
        end
    end
end

function pathReplace()
    local levelJob = job:level(currentIdJob)

    if currentJob == "mineur" then
        if levelJob >= 20 then
            table.remove(PATH_JOB.mineur, 3)
            table.insert(PATH_JOB.mineur, 3, PATH_REPLACE.mineur[2])
            table.remove(PATH_JOB.mineur, 4)
            table.insert(PATH_JOB.mineur, 4, PATH_REPLACE.mineur[1])
        end
        if levelJob >= 40 then
            table.remove(PATH_JOB.mineur, 4)
            table.insert(PATH_JOB.mineur, 4, PATH_REPLACE.mineur[3])
            table.remove(PATH_JOB.mineur, 6)
            table.insert(PATH_JOB.mineur, 6, PATH_REPLACE.mineur[4])
        end
        if levelJob >= 60 then
            table.remove(PATH_JOB.mineur, 3)
            table.insert(PATH_JOB.mineur, 3, PATH_REPLACE.mineur[5])
            table.remove(PATH_JOB.mineur, 4)
            table.insert(PATH_JOB.mineur, 4, PATH_REPLACE.mineur[6])
            table.remove(PATH_JOB.mineur, 13)
            table.insert(PATH_JOB.mineur, 13, PATH_REPLACE.mineur[7])
        end
        if levelJob >= 80 then
            table.remove(PATH_JOB.mineur, 3)
            table.insert(PATH_JOB.mineur, 3, PATH_REPLACE.mineur[8])
            table.remove(PATH_JOB.mineur, 4)
            table.insert(PATH_JOB.mineur, 4, PATH_REPLACE.mineur[9])
            table.remove(PATH_JOB.mineur, 2)
            table.insert(PATH_JOB.mineur, 2, PATH_REPLACE.mineur[10])
        end
        if levelJob >= 120 then
            table.remove(PATH_JOB.mineur, 4)
            table.insert(PATH_JOB.mineur, 4, PATH_REPLACE.mineur[11])
        end
        if levelJob >= 160 then
            table.remove(PATH_JOB.mineur, 2)
            table.insert(PATH_JOB.mineur, 2, PATH_REPLACE.mineur[12])
        end
    end

    if PANDALA and not pandalaInsert then
        table.insert(PATH_JOB.mineur, PATH_REPLACE.mineur[13])
        table.insert(PATH_JOB.paysan, PATH_REPLACE.paysan[1])
        table.insert(PATH_JOB.alchimiste, PATH_REPLACE.alchimiste[1])
        pandalaInsert = true
    end

    if SAHARACH and not saharachInsert then
        table.insert(PATH_JOB.mineur, PATH_REPLACE.mineur[14])
        saharachInsert = true
    end

    if FRIGOST1 or FRIGOST2 or FRIGOST3 and not frigost1Insert then
        table.insert(PATH_JOB.mineur, PATH_REPLACE.mineur[15])
        table.insert(PATH_JOB.mineur, PATH_REPLACE.mineur[16])
        table.insert(PATH_JOB.mineur, PATH_REPLACE.mineur[17])       
        frigost1Insert = true
    end

    if FRIGOST2 or FRIGOST3 and not frigost2Insert then
        table.insert(PATH_JOB.mineur, PATH_REPLACE.mineur[18])
        frigost2Insert = true
    end
end

function start()
    assignWork()
    global:printMessage("[INFO] Bonjour " ..character:name().. " !")
    global:printMessage("[INFO] Trajet MultiMetier realiser par yaya#6140")
    global:printMessage("[INFO] Pour tout probleme critique avec le trajet merci de me mp en m'envoyant l'erreur indique dans la console, le metier et le niveau courant")
    global:printMessage("[IMPORTANT] Ne pas lancez dans la banque !")
    global:printMessage("[IMPORTANT] Changer le raccourci 'Fermer les infobulle epingle' par la touche F10 !")
    global:printMessage("[INFO] Bon bottage ^-^ !")

    if minute >= 10 then
        global:printMessage("[INFO] Il est " ..heure.. ":" ..minute.. " metier selectionner " ..currentJob)
    else
        global:printMessage("[INFO] Il est " ..heure.. ":0" ..minute.. " metier selectionner " ..currentJob)
    end

    math.randomseed(generateRandomSeed())
    tmpAutoCraft = AUTO_CRAFT
    currentLevelCharacter, startLevelCharacter = character.level(), character.level()
    if currentMode == "gather" then
        sortCraft()
    end
    initScript = true
    --map:waitMovementFinish(20000)
end

function sortCraft()
    if tmpAutoCraft then
        local levelJob = job:level(currentIdJob)
        CRAFT_FILTERED = {}
        AUTO_CRAFT = true

        for kJob, vTable in pairs(CRAFT) do
            if kJob == currentJob then
                for _, vCraft in pairs(vTable) do
                    if vCraft.active and ( levelJob >= vCraft.lvlToDesactive ) then -- Desactivation
                        global:printMessage("[INFO]["..string.upper(currentJob).."] Desactivation du craft " ..vCraft.name.. " lvlToDesactive atteint")
                        vCraft.active = false
                    else
                        if levelJob >= vCraft.minLevel and vCraft.active then
                            global:printMessage("[INFO]["..string.upper(currentJob).."] Ajout du craft " ..vCraft.name.. " a la table de craft")
                            vCraft.waitItemOfAnotherJob = false
                            table.insert(CRAFT_FILTERED, vCraft)
                        end
                    end
                end
            end
        end
    end
end

function setItem()
    for _, vTable in pairs(ITEM) do
        for _, vItem in pairs(vTable) do
            if storage:itemCount(vItem.id) ~= nil then
                vItem.current = storage:itemCount(vItem.id)
                --global:printMessage(vItem.name.. " = " ..vItem.current)
            end
        end
    end
end

function getItem(idItem, nbItem)
    while inventory:itemCount(idItem) < nbItem do
        storage:getItem(idItem, nbItem - inventory:itemCount(idItem))
    end
    global:delay(smallDelay)
    global:sendKey(121) -- F10
end

function missingIngredient(vCraft, vIngredient, iIngredient)
    local notNull = vCraft.ingredient[iIngredient].job ~= nil 

    if notNull and vCraft.ingredient[iIngredient].job == currentJob then
        global:printMessage("[INFO]["..string.upper(currentJob).."] Manque de " ..vIngredient.name.. " pour craft " ..vCraft.name)
        table.insert(TO_FARM, vIngredient.name) -- Insert 2x bug tbl 
        table.insert(TO_FARM, vIngredient.name)
    elseif notNull and vCraft.ingredient[iIngredient].job == 'divers' then
        global:printMessage("[INFO]["..string.upper(currentJob).."] Manque d'une ressource non recoltable ou craftable, ressource = " ..vIngredient.name.. " desactivation du craft " ..vCraft.name)
        vCraft.active = false
    else
        if notNull and vCraft.ingredient[iIngredient].job == 'substrat' then
            global:printMessage("[INFO]["..string.upper(currentJob).."] Manque de " ..vIngredient.name.. " pour craft " ..vCraft.name)
            vCraft.next = true
        else
            global:printMessage("[INFO]["..string.upper(currentJob).."] Manque d'une ressource d'un autre metier, ressource = " ..vIngredient.name.. " desactivation temporaire du craft " ..vCraft.name)
            vCraft.waitItemOfAnotherJob = true
        end
    end
end

function resetInfiniteLoop()
    local currentMap = map:currentMapId()
    if currentMap == 162791424 then
        global:printMessage("[INFO] Retour havre")
        resetLoop = false
    else
        global:printMessage("[INFO] Tp havre debug boucle infinie")        
    end
    map:havenbag()
    global:delay(baseDelay)
end

function inCoffre() -- Verifie si des craft son disponible si aucun craft dispo assigne les ressource a recolte pour la recette, si craft dispo recupere les item
    local levelJob
    local reCheck = false

    if currentMode ~= 'fight' then
         levelJob = job:level(currentIdJob)
    end
    -- Remise a zero des var et update ITEM
        TO_FARM = {}
        ELEMENTS_TO_GATHER = {}
        setItem()
    --Vérif si craft disponible et assignation des path si aucun craft disponible
        if AUTO_CRAFT and currentMode ~= 'fight' then
            local countTryCraft = 0

            for iCraft, vCraft in pairs(CRAFT_FILTERED) do
                if iCraft > lastIcraft or lastIcraft == 0 then
                    local next = false

                    if goCraft then
                        break
                    end

                    if countTryCraft > 1 then
                        global:leaveDialog()
                        global:delay(baseDelay)
                        resetLoop = true
                        resetInfiniteLoop()
                    end

                    if currentJob == "bucheron" then
                        if storage:itemCount(vCraft.idItem) >= vCraft.nbItemsBeforeNextCraft then
                            if vCraft.name == "Substrat de buisson" then
                                CRAFT.bucheron[2].next = true
                            elseif vCraft.name == "Substrat de bocage" then
                                CRAFT.bucheron[4].next = true
                            elseif vCraft.name == "Substrat de futaie" then
                                CRAFT.bucheron[6].next = true
                            elseif vCraft.name == "Substrat de fascine" then
                                CRAFT.bucheron[8].next = true
                            end
                        end
                    end

                    if vCraft.next ~= nil then
                        next = vCraft.next
                    end

                    --global:printMessage('[DEBUG] countTryCraft : '..countTryCraft..' itemCount : '..storage:itemCount(vCraft.idItem).. ' nbItemsBeforeNextCraft : '..vCraft.nbItemsBeforeNextCraft)
                    --global:printMessage('[DEBUG] name : '..vCraft.name.. ' active : '..tostring(vCraft.active)..' next : '..tostring(vCraft.next)..' waitItem : '..tostring(vCraft.waitItemOfAnotherJob)..' itemCount : '..storage:itemCount(vCraft.idItem).. ' nbItemsBeforeNextCraft : '..vCraft.nbItemsBeforeNextCraft)

                    if vCraft.active and storage:itemCount(vCraft.idItem) < vCraft.nbItemsBeforeNextCraft and not next and not vCraft.waitItemOfAnotherJob then
                        countTryCraft = countTryCraft + 1
                        local lot, canCraft, tblIngredient = canCraft(vCraft.name, currentJob)
                        global:printMessage("[INFO]["..string.upper(currentJob).."] Looking for craft " ..vCraft.name)

                        if lot or canCraft then
                            global:printMessage("[INFO]["..string.upper(currentJob).."] Craft de " ..vCraft.name.. " disponible !")
                            goCraft = true
                        end

                        for iIngredient, vIngredient in ipairs(vCraft.ingredient) do
                            if goCraft then -- PickItem si craft disponible
                                getItem(vIngredient.idItem, tblIngredient[iIngredient])
                            elseif tblIngredient[iIngredient] == 0 then -- Sinon Ajout a la table de recolte  
                                missingIngredient(vCraft, vIngredient, iIngredient)
                            end
                        end                                        
                    end
                    lastIcraft = iCraft
                    --global:printMessage('remove '..CRAFT_FILTERED[iCraft].name)
                    if #TO_FARM > 0 then
                        break
                    end
                end
            end
            
            lastIcraft = 0

            if #TO_FARM == 0 and not goCraft then
                iBoucleCraft = iBoucleCraft + 1

                if iBoucleCraft < 2 then
                    global:printMessage("[INFO]["..string.upper(currentJob).."] Boucle de craft faite on recommence ( re tp pour eviter boucle infini) !")
                    CRAFT.bucheron[2].next = false
                    CRAFT.bucheron[4].next = false
                    CRAFT.bucheron[6].next = false
                    CRAFT.bucheron[8].next = false
                    for kTblCraft, vTblCraft in pairs(CRAFT) do
                        if currentJob == "bucheron" and levelJob < 10 then
                            table.insert(TO_FARM, "Frene")
                            break
                        end
                        if kTblCraft == currentJob then
                            for _, vCraft in pairs(vTblCraft) do
                                if vCraft.tmpMax == nil then
                                    vCraft.tmpMax = vCraft.nbItemsBeforeNextCraft
                                end
                                vCraft.nbItemsBeforeNextCraft = vCraft.nbItemsBeforeNextCraft + vCraft.tmpMax
                                if not vCraft.active and vCraft.lvlToDesactive > levelJob then
                                    vCraft.active = true
                                end
                                if vCraft.next then
                                    vCraft.next = false
                                end
                            end
                        end
                    end
                    reCheck = true
                else
                    global:printMessage("[INFO]["..string.upper(currentJob).."] Aucun craft disponible desactivation temporaire de l'autoCraft !")
                    AUTO_CRAFT = false
                end
            end
        elseif currentMode == 'gather' then
            for kTable, vTable in pairs(ITEM) do
                if kTable == currentJob then
                    for _, vItem in pairs(vTable) do
                        if vItem.name == tag then
                            table.insert(TO_FARM, vItem.gatherId)
                        end
                    end
                end
            end
        end
    -- Fin fonction
        global:leaveDialog()
        teleported = false
        messageBank = false
        filterPathByTags = false
        messageBank = false

        goCheckStock = true
        if reCheck then
            checkRessource = false
        else
            checkRessource = true
        end
        if goCraft then
            MAX_PODS = 100
            if currentJob == "alchimiste" or currentJob == "paysan" and not DEPOT_MAISON then
                teleported = true
                map:changeMap("424")
                global:delay(mediumDelay)
            else
                havreSac()
            end
        else
            MAX_PODS = 90
            finDeBoucle()
        end
end

function Time() -- Renvoie l'heure sous forme de number
    local currentTime = global:time()
    local heure = tonumber(string.match(currentTime, "%d%d"))
    local minutes = tonumber(string.match(currentTime, "%d%d", 2))

    if heure == 0 then
        heure = 24
    end
    return heure, minutes
end

function timeZone() -- Verifie le temps passez dans une zone
    if not timeInit then
        initTime = minute
        timeInit = true
    end

    global:delay(baseDelay)
    diffTime = minute - initTime

    if diffTime < 0 then
        initTime = minute
        diffTime = lastGoodTime + 2
    end

    lastGoodTime = diffTime
end

function generateRandomSeed() -- Genere une seed et la renvoie
    local time = global:time() 
    local match = string.match(time, "%d%d")
    local match2 = string.match(time, "%d%d", 2)
    local concact = tostring(match).. tostring(match2)
    time = tonumber(concact) * 1000000000

    local k = character:kamas() * time
    local p = inventory:pods() * time
    local c = character:cellId() * time
    local name = character.name()
    local seed = (k * k) * (p * p) * (c * c) * time * inventory:podsP() * inventory:podsMax() * #name * character.level() * character.lifePoints() * character.energyPoints() * math.random(0, time)
    local a, b, m = 3, 3, 2100000000
    for _ = 0, 15 do
        seed = ( a * seed + b ) % m
    end
    --global:printMessage("[SCRIPT] Seed = " ..seed)
    return seed
end

function assignWork() -- Assigne le metier en fonction de l'heure actuelle

    --global:printMessage("ici")

    local lastJob = nil

    if currentJob ~= nil then
        lastJob = currentJob
    end

    for _, v in ipairs(WORKTIME) do

        if #WORKTIME == 1 then
            currentJob = v.job
            break
        else
            local heureDebut, minuteDebut = tonumber(string.match(v.debut, "%d%d")), tonumber(string.match(v.debut, "%d%d", 2))
            local heureFin, minuteFin = tonumber(string.match(v.fin, "%d%d")), tonumber(string.match(v.fin, "%d%d", 2))

            if heureFin == 0 then
                heureFin = 24
            end
            if heureDebut == 0 then
                heureDebut = 24
            end

            if ((heure == heureDebut and minute >= minuteDebut) or heure > heureDebut) and (( heure == heureFin and minute < minuteFin) or heure < heureFin) then
                currentJob = v.job
                break
            elseif heureDebut > heureFin and ((heure == heureDebut and minute >= minuteDebut) or (heure > heureDebut or heure < heureFin)) and ((heure == heureFin and minute < minuteFin) or (heure >= heureDebut or heure < heureFin)) then
                currentJob = v.job
                break
            end
        end       
    end

    if currentJob == "mineur" then
        currentIdJob = 24
        currentMode = "gather"
    elseif currentJob == "bucheron" then
        currentIdJob = 2
        currentMode = "gather"
    elseif currentJob == "alchimiste" then
        currentIdJob = 26
        currentMode = "gather"
    elseif currentJob == "paysan" then
        currentIdJob = 28
        currentMode = "gather"
    else
        currentMode = "fight"
    end

    if lastJob ~= nil then
        if lastJob ~= currentJob then
            global:printMessage("[INFO] Changement de metier ! Go farm " ..currentJob)
            checkRessource = false
            pathIndex = nil
            sortCraft()
            finDeBoucle()
        end
    end
    --global:printMessage(currentJob)
end

function checkBag()

    while inventory:itemCount(7941) > 0 -- Sac de blé
    or inventory:itemCount(7942) > 0 -- Sac d'Orge
    or inventory:itemCount(7943) > 0 -- Sac d'Avoine
    or inventory:itemCount(7944) > 0 -- Sac de Houblon
    or inventory:itemCount(7945) > 0 -- Sac de Lin
    or inventory:itemCount(7946) > 0 -- Sac de Seigle
    or inventory:itemCount(7947) > 0 -- Sac de Riz
    or inventory:itemCount(7948) > 0 -- Sac de Malt
    or inventory:itemCount(7949) > 0 -- Sac de Chanvre
    or inventory:itemCount(16532) > 0 -- Sac de Maïs
    or inventory:itemCount(16533) > 0 -- Sac de Millet
    or inventory:itemCount(11113) > 0 do -- Sac de Frostiz
        openBag()
    end

    while inventory:itemCount(7964) > 0 -- Sac d'ortie
    or inventory:itemCount(7965) > 0 -- Sac de sauge
    or inventory:itemCount(7966) > 0 -- Sac de trefle
    or inventory:itemCount(7967) > 0 -- Sac de menthe
    or inventory:itemCount(7968) > 0 -- Sac d'orchidee
    or inventory:itemCount(7969) > 0 -- Sac d'Edelweiss
    or inventory:itemCount(7970) > 0 -- Sac de Pandouille
    or inventory:itemCount(16528) > 0 -- Sac de Ginseng
    or inventory:itemCount(16529) > 0 -- Sac de Belladone
    or inventory:itemCount(16530) > 0 -- Sac de Mandragore
    or inventory:itemCount(11103) > 0 do -- Sac de Perce-Neige
        openBag()
    end

    while inventory:itemCount(7971) > 0 -- Sac de fer
    or inventory:itemCount(7972) > 0 -- Sac de cuivre
    or inventory:itemCount(7973) > 0 -- Sac de bronze
    or inventory:itemCount(7974) > 0 -- Sac de Kobalte
    or inventory:itemCount(7975) > 0 -- Sac de manganese
    or inventory:itemCount(7976) > 0 -- Sac d'etain
    or inventory:itemCount(7977) > 0 -- Sac de silicate
    or inventory:itemCount(7978) > 0 -- Sac d'argent
    or inventory:itemCount(7979) > 0 -- Sac de Bauxite
    or inventory:itemCount(7980) > 0 -- Sac d'or
    or inventory:itemCount(7981) > 0 -- Sac de dolomite
    or inventory:itemCount(11114) > 0 do -- Sac d'Obsidienne
        openBag()
    end

    while inventory:itemCount(7950) > 0 -- Frene
    or inventory:itemCount(7951) > 0 -- Chataignier
    or inventory:itemCount(7952) > 0 -- Noyer
    or inventory:itemCount(7953) > 0 -- Chene
    or inventory:itemCount(7954) > 0 --Bombu
    or inventory:itemCount(7955) > 0 -- Oliviolet
    or inventory:itemCount(7956) > 0 -- Erable
    or inventory:itemCount(7957) > 0 -- If
    or inventory:itemCount(7958) > 0 -- Bambou
    or inventory:itemCount(7959) > 0 -- Merisier
    or inventory:itemCount(16531) > 0 -- Noisetier
    or inventory:itemCount(7960) > 0 -- Ebene
    or inventory:itemCount(7961) > 0 -- Bambou Sombre
    or inventory:itemCount(7962) > 0 do -- Bois d'Orme
        openBag()
    end
end

function openBag()
    global:delay(baseDelay)
    global:sendKey(73) -- I
    global:delay(mediumDelay)
    global:clickPosition(545,65) -- Consomable
    global:delay(baseDelay)
    global:rightClickPosition(485, 105) -- Sac de ressource
    global:delay(baseDelay)
    global:clickPosition(440,75) -- Utiliser
    global:delay(baseDelay)
    global:sendKey(73) -- I
    global:delay(mediumDelay)
end

function killDoubleValue(tbl)
    if #tbl > 1 then
        local tblCompare = tbl

        for _, vComp in pairs(tblCompare) do
            local count = 0
            for iTbl, vTbl in pairs(tbl) do
                if vComp == vTbl then
                    count = count + 1
                end
                if vComp == vTbl and count > 1 then
                    --global:printMessage("[DEV] " ..vTbl.. " removed ! Count = " ..count) 
                    table.remove(tbl, iTbl)
                end
            end
        end
    end
end

function finDeBoucle() -- Reset de variables et teleporte au havre pour une nouvelle boucle
    nbBoucle = 0
    MULTIPLE_MAP:Reset()
    setPathToFarm = false
    teleported = false
    resetFuncTimeZone()
    havreSac()
    global:delay(mediumDelay)
end

function resetFuncTimeZone() -- Reset les variable de la fonction timeZone
    timeInit = false
    oneHourPassed = false
    diffTime = 0
    tmpTime = 0
    lastGoodTime = 0
end

function canCraft(itemName, job) -- Verifie si un craft et possible en fonction du nom de l'item passez en parametre et le metier actuelle passez en parametre
    local currentItem, clc = 0, 0
    local cantCraft, lotActive = false, false
    local tblIngredient = {}
    for kJob, vTable in pairs(CRAFT) do -- Cherche le metier actuelle
        if kJob == job then 
            for _, vItem in pairs(vTable) do -- Cherche l'item
                if itemName == vItem.name then

                    if vItem.toolCraft ~= nil then
                        toolCraft = vItem.toolCraft
                    end
                    for iIngredient, vIngredient in pairs(vItem.ingredient) do -- Parcours les ingredient
                        for keyTable, itemTable in pairs(ITEM) do -- Calcul currentItem
                            for _, j in pairs(itemTable) do
                                if j.name == vIngredient.name then
                                    if j.minStock ~= nil then
                                        currentItem = j.current - j.minStock
                                    else
                                        currentItem = j.current
                                    end
                                end
                            end
                        end
                        --global:printMessage(currentItem)
                        if vItem.lot then -- Calcul du nombre d'ingredient a retourner si lot
                            clc = vItem.lot * vIngredient.nbIng
                            lotActive = true
                        else -- Sinon calcul en fonction des pods disponible
                            clc = calculMaxItemInInventory(vItem.weight, vIngredient.nbIng)
                            clc = math.round(clc, 10)
                            --global:printMessage("[DEV] Clc = " ..clc)
                        end
                        if clc > currentItem then
                            cantCraft = true
                            table.insert(tblIngredient, 0)
                        else
                            table.insert(tblIngredient, clc)
                        end
                    end
                end
            end
        end
    end
    --printSimpleTable(tblIngredient)
    if not cantCraft and lotActive then
        return true, false, tblIngredient
    elseif not cantCraft and not lotActive then
        return false, true, tblIngredient
    else
        return false, false, tblIngredient
    end              
end

function printSimpleTable(tbl)
    for i, v in pairs(tbl) do
        global:printMessage("[PRINT]" ..v)
    end
end

function podsRestant() -- Calcul les pods et les arrondi 
    return  math.round((inventory:podsMax() - inventory:pods()), 100) - 400
end

function calculMaxItemInInventory(poidTotalDesRessource, nbRessource) -- Calcul le nombre de ressource que peut porter le bot
    return (podsRestant() / poidTotalDesRessource) * nbRessource
end

function useClick() -- clickPosition
    if map:currentMapId() == 191104002 then
	    global:clickPosition(405,180)
	    global:delay(longDelay)
    elseif map:currentMapId() == 189531140 then
    	global:clickPosition(390,215)
	    global:delay(longDelay)
    end
end

function useBank() -- Ouvre la banque
    global:delay(baseDelay)
    if PNJ_BANK == "left" then
        global:clickPosition(340,190) -- Hiboux blanc
    elseif  PNJ_BANK == "right" then
        global:clickPosition(405,225) -- Hiboux noir
    end
    global:delay(mediumDelay)
    global:clickPosition(300,385) -- Consulter coffre
    global:delay(mediumDelay)
    storage:putAllItems()
    inCoffre()
end

function havreSac() -- Teleporte dans le havresac
    currentMapId = map:currentMapId()
    -- ChangeMap si havre indispo
        if currentMapId == 11111111
        or currentMapId == 11111111 then
            map:changeMap("top")
        end

        if currentMapId == 11111111
        or currentMapId == 11111111 then
            map:changeMap("bottom")
        end

        if currentMapId == 165153537
        or currentMapId == 11111111 then
            map:changeMap("left")
        end

        if currentMapId == 11111111
        or currentMapId == 11111111 then
            map:changeMap("right")
        end
        -- Mine Ebbernar
            if currentMapId == 29622275
            or currentMapId == 29622272
            or currentMapId == 29622531 then
                map:changeMap("450")
            end
            if currentMapId == 29622534 then
                map:changeMap("424")
            end
        -- Mine manganese ile dragoeuf
            if currentMapId == 86246410 then
                map:changeMap("431")
            end
        -- Mine Bwork
            if currentMapId == 104860165
            or currentMapId == 104859139 then
                map:changeMap("444")
            end
            if currentMapId == 104860169 then
                map:changeMap("263")
            end
            if currentMapId == 104861193 then
                map:changeMap("254")
            end
            if currentMapId == 104859145 then
                map:changeMap("457")
            end
            if currentMapId == 104858121 then
                map:changeMap("507")
            end
            if currentMapId == 104861189 then
                map:changeMap("451")
            end
            if currentMapId == 104862213 then
                map:changeMap("376")
            end
            if currentMapId == 104858119 then
                map:changeMap("207")
            end
        -- Mine Maksage
            if currentMapId == 57017861 then
                map:changeMap("270")
            end
            if currentMapId == 56886787 then
                map:changeMap("396")
            end
            if currentMapId == 56885763 then
                map:changeMap("436")
            end
            if currentMapId == 57016837 then
                map:changeMap("401")
            end
            if currentMapId == 57016835 then
                map:changeMap("409")
            end
            if currentMapId == 57017859 then
                map:changeMap("395")
            end

    if map:currentMapId() ~= 162791424 then
        global:delay(baseDelay)
        global:sendKey(72)
        global:delay(veryLongDelay)
    end
end

function transporteurFrigostien()
    global:delay(mediumDelay)
    global:clickPosition(355,320) -- PNJ
    global:delay(longDelay * 2)

    if idTransporteur == "sakai" then
        if FRIGOST1 or FRIGOST2 or FRIGOST3 then
            global:clickPosition(300,395) -- Sakai                     
        end
    elseif idTransporteur == "maksage" or idTransporteur == "hissoire" then
        if FRIGOST3 then
            global:clickPosition(300,355) -- Berceau alma                               
        elseif FRIGOST2 then
            global:clickPosition(300,370) -- Berceau alma                     
        elseif FRIGOST1 then
            global:clickPosition(300,385) -- Berceau alma          
        end
    elseif idTransporteur == "ouronigride" then
        if FRIGOST3 then
            global:clickPosition(300,370) -- Ouronigride                     
        elseif FRIGOST2 then
            global:clickPosition(300,385) -- Ouronigride                     
        end
       
    end
end

function zaapiToPath()
    global:delay(veryLongDelay * 2)

    if idZaapi == "hative" or idZaapi == "oliviolet" then -- Zaapi Brakmar vers la grotte Hative ou zone oliviolet
        global:clickPosition(490,220) -- Zaapi
        global:delay(veryLongDelay)
        global:clickPosition(400,90) -- Divers
        global:delay(mediumDelay)
        global:clickPosition(485,350) -- Barre de defilement
        global:delay(mediumDelay)
        global:clickPosition(300,320) -- Taverne du chatbrulé

    elseif idZaapi == "ebbernard" then -- Zaapi Brakmar vers la mine Ebbernar
        global:clickPosition(490,220) -- Zaapi
        global:delay(veryLongDelay)
        global:clickPosition(220,90) -- Ateliers
        global:delay(mediumDelay)
        global:clickPosition(300,325) -- Atelier des paysans

    elseif idZaapi == "mineSecrete" then -- Zaapi vers mine secrete de bronze
        global:clickPosition(490,220) -- Zaapi
        global:delay(veryLongDelay)
        global:clickPosition(300,90) -- Hotel de vente
        global:delay(mediumDelay)
        global:clickPosition(310,180) -- Hotel de vente des consomable

    elseif idZaapi == "atelierMineur" then -- Zaapi vers mine secrete de bronze
        global:clickPosition(65,90) -- Zaapi
        global:delay(veryLongDelay)
        global:clickPosition(220,95) -- Hotel de vente
        global:delay(mediumDelay)
        global:clickPosition(250,300) -- Hotel de vente des consomable

    elseif idZaapi == "maison" then -- Zaapi vers Maison
        global:clickPosition(65,90) -- Zaapi
        global:delay(veryLongDelay)
        global:clickPosition(220,90) -- Ateliers
        global:delay(mediumDelay)
        global:clickPosition(250,230) -- Atelier des chasseur

    end

    global:delay(mediumDelay)
    global:clickPosition(320,390) -- Se teleporte
    global:delay(veryLongDelay)
end

function bouclePlus() -- Incremente une boucle
    nbBoucle = nbBoucle + 1
    MULTIPLE_MAP:Reset()
end

function clickMap()
    local currentMapId = map:currentMapId()
    -- Mine Hipouce
        if currentMapId == 178782208 then
	        global:delay(mediumDelay)
	        global:clickPosition(370,280)
	        global:delay(mediumDelay)
        elseif currentMapId == 178782210 then
	        global:delay(mediumDelay)
	        global:clickPosition(170,110)
	        global:delay(mediumDelay)
        elseif currentMapId == 178782218 then
	        global:delay(mediumDelay)
	        global:clickPosition(460,30)
	        global:delay(mediumDelay)
        elseif currentMapId == 178783234 then
	        global:delay(mediumDelay)
	        global:clickPosition(355,115)
	        global:delay(mediumDelay)
        end
    -- Mine plaine rocheuse
        if currentMapId == 147590151 then
	        global:delay(mediumDelay)
	        global:clickPosition(75,55)
	        global:delay(mediumDelay)
        end
    -- Mine du chemin vers kartonpath
        if currentMapId == 88087305 then
	        global:delay(mediumDelay)
	        global:clickPosition(530,250)
	        global:delay(mediumDelay)
        end
    -- Mine Estrone
        if currentMapId == 171966987 then
	        global:delay(mediumDelay)
	        global:clickPosition(240,290)
	        global:delay(mediumDelay)
        end
    -- Mine ile dragoeuf
        if currentMapId == 84411392 then
	        global:delay(mediumDelay)
	        global:clickPosition(5,250)
	        global:delay(mediumDelay)
        elseif currentMapId == 84410368 then
	        global:delay(mediumDelay)
	        global:clickPosition(540,295)
	        global:delay(longDelay)
	        global:clickPosition(290,280)
	        global:delay(longDelay)
        end
    -- Mine Haut hurlement
        if currentMapId == 171707908 then
	        global:delay(mediumDelay)
	        global:clickPosition(600,100)
	        global:delay(mediumDelay)
        end
    -- Mine Campement Bwork
        if currentMapId == 88212751 then
	        global:delay(mediumDelay)
	        global:clickPosition(200,200)
	        global:delay(mediumDelay)
        elseif currentMapId == 104071168 then
	        global:delay(mediumDelay)
	        global:clickPosition(160,140)
	        global:delay(mediumDelay)
        elseif currentMapId == 104071425 then
	        global:delay(mediumDelay)
	        global:clickPosition(160,130)
	        global:delay(mediumDelay)
        elseif currentMapId == 104072452 then
	        global:delay(mediumDelay)
	        global:clickPosition(510,165)
	        global:delay(mediumDelay)
        end
    -- Mine du bois arak'hai
        if currentMapId == 147852290 then
	        global:delay(mediumDelay)
	        global:clickPosition(490,190)
	        global:delay(mediumDelay)
        end
    -- Mine Imale
        if currentMapId == 172491782 then
	        global:delay(mediumDelay)
	        global:clickPosition(410,280)
	        global:delay(mediumDelay)
        end
end

function craft() -- clickPosition dans les atelier
    global:delay(veryLongDelay)

    if currentJob == "paysan" then
        if toolCraft == "four" then
            global:clickPosition(200,230) -- Atelier
        elseif toolCraft == "atelier" then
            global:clickPosition(265,220) -- Atelier
        end
        global:delay(veryLongDelay)
        global:clickPosition(10,380) -- Afficher uniquement les recette possible
        global:delay(longDelay)
        global:clickPosition(120,115) -- Item a craft
        global:delay(longDelay)
        global:clickPosition(350,210) -- Quantité
        global:delay(longDelay)
        global:sendKey(13) -- Valide les quantité
        global:delay(longDelay)
        global:clickPosition(350,250) -- Craft
    elseif currentJob == "alchimiste" then
        global:clickPosition(200,200) -- Atelier
        global:delay(veryLongDelay)
        global:clickPosition(10,380) -- Afficher uniquement les recette possible
        global:delay(longDelay)
        global:clickPosition(120,115) -- Item a craft
        global:delay(longDelay)
        global:clickPosition(350,210) -- Quantité
        global:delay(longDelay)
        global:sendKey(13) -- Valide les quantité
        global:delay(longDelay)
        global:clickPosition(350,250) -- Craft
    elseif currentJob == "mineur" then
        global:clickPosition(480,200) -- Atelier
        global:delay(veryLongDelay)
        global:clickPosition(10,380) -- Afficher uniquement les recette possible
        global:delay(longDelay)
        global:clickPosition(120,115) -- Item a craft
        global:delay(longDelay)
        global:clickPosition(350,210) -- Quantit�
        global:delay(longDelay)
        global:sendKey(13) -- Valide les quantit�
        global:delay(longDelay)
        global:clickPosition(350,250) -- Craft
    elseif currentJob == "bucheron" then
        global:clickPosition(300,200) -- Atelier
        global:delay(veryLongDelay)
        global:clickPosition(10,380) -- Afficher uniquement les recette possible
        global:delay(longDelay)
        global:clickPosition(120,115) -- Item a craft
        global:delay(longDelay)
        global:clickPosition(350,210) -- Quantit�
        global:delay(longDelay)
        global:sendKey(13) -- Valide les quantit�
        global:delay(longDelay)
        global:clickPosition(350,250) -- Craft

    end

    global:delay(longDelay)
    global:clickPosition(630,40) -- Quitte atelier
    global:delay(longDelay)
    goCraft = false
    checkRessource = false
    teleported = false
    havreSac()
end

function mainGather()
    for i = 1 , gatherAttemptByMap do
        local g = gather()
        --global:printMessage("Tentative gather : "..i)
        gatherCount(g)
        global:delay(delayToRetryGather)
    end
end

function TryGather()
    mainGather()
end

function TryGatherWithBP()
    mainGather()
    bouclePlus()
end

function TryGatherWithFDB()
    mainGather()
    finDeBoucle()
end

function TryGatherWithCM()
    mainGather()
    clickMap()
end

function gatherCount(isGather)
    if not isGather then
        totalGather = totalGather + 1
    end
end

-- TOM LA VACHETTE FUNCTION

function MULTIPLE_MAP:Run(tab)
	currentPos = map.currentPos()
	currentMapId = tostring(map.currentMapId())

	if not self.CurrentSteps[currentMapId] then
		self.CurrentSteps[currentMapId] = 0
	end

	self.CurrentSteps[currentMapId] = self.CurrentSteps[currentMapId] + 1

	action = nil
	firstAction = nil
	count = 0
	for _, v in pairs(tab) do
		if v.map == currentPos or v.map == currentMapId then
			count = count + 1
			if count == self.CurrentSteps[currentMapId] then
				action = v
				break
			elseif count == 1 then
				firstAction = v
			end
		end
	end

	if not action then
		if firstAction then
			action = firstAction
			self.CurrentSteps[currentMapId] = 1
		else
			global.printMessage("[AVERTISSEMENT] Aucune action ne donne d'indications pour la carte " .. currentPos .. " (" .. currentMapId .. ").")
			return lost()
		end
	end

	if type(action.changeMap) == "function" then
		action.custom = action.changeMap
		action.changeMap = nil
	end

	return { action }
end

function MULTIPLE_MAP:Reset(tab)
	self.CurrentSteps = {}
end

-- Lmoony ZONE FARMER SCRIPT

function Rand()
	-- global:printMessage('Rand()')
    local U = X2*A2
    local V = (X1*A2 + X2*A1) % D20
    V = (V*D20 + U) % D40
    X1 = math.floor(V/D20)
    X2 = V - X1*D20
    return V/D40
end

function GetOppositeDirection(dir)
	-- global:printMessage('GetOppositeDirection()')
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
	-- global:printMessage('DisableDirection()')
	for i, v in ipairs(dirArray) do
		if v == dir then
			table.remove(dirArray, i)
		end
	end
end

function GetRandomDirection(dirArray)
	-- global:printMessage('GetRandomDirection()')
	local randomDir = math.floor(Rand()*#dirArray) + 1
	for i, v in ipairs(dirArray) do
		if i == randomDir then
			return v
		end
	end
end

function TryChangeMap()
	--global:printMessage('TryChangeMap()')
	local dir
	local possibleDirections = {
		Directions.left,
		Directions.top, 
		Directions.right, 
		Directions.bottom
	}
	if G_dir ~= nil then
		DisableDirection(possibleDirections, GetOppositeDirection(G_dir))
	end
	dir = GetRandomDirection(possibleDirections)
	G_dir = dir

	while not(map:changeMap(dir)) do
		DisableDirection(possibleDirections, dir)
		dir = GetRandomDirection(possibleDirections)
		G_dir = dir
		global:delay(10000)
	end
end

function GoBack()
	-- global:printMessage('goBack()')
	local tmp
	if G_dir ~= nil then
		tmp = GetOppositeDirection(G_dir)
		G_dir = tmp
		map:changeMap(tmp)
	end
end

function TryFight()
	--global:printMessage('TryFight()')
	local i = 0
	while not(fight.fight()) do
		global:delay(2000)
		i = i + 1
		if i == 3 then
			TryChangeMap()
			return 
		end
	end
end

-- Fonction trouver sur google

function math.sign(v) -- Dependance de math.round
    return (v >= 0 and 1) or -1
end

function math.round(v, bracket) -- Sert a arrondir un nombre
    bracket = bracket or 1
    return math.floor(v/bracket + math.sign(v) * 0.5) * bracket
end