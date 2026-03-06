--[[
    Station Service - Server Side
    NPC Spawning, Interaction & Purchase Logic
]]

-- ============================================================
-- NETWORK STRINGS
-- ============================================================

util.AddNetworkString("StationService_Open")
util.AddNetworkString("StationService_Buy")
util.AddNetworkString("StationService_BuyCart")

-- ============================================================
-- SONS (téléchargement client)
-- ============================================================

resource.AddFile("sound/stationservice/buttonnav.wav")
resource.AddFile("sound/stationservice/cash.wav")
resource.AddFile("materials/stationservice/logo.png")

-- ============================================================
-- NPC SPAWN FUNCTION
-- ============================================================

local function SpawnStationServiceNPC(pos, ang)
    local npc = ents.Create("npc_stationservice")
    if not IsValid(npc) then
        print("[Station Service] ERREUR: Impossible de créer le NPC !")
        return nil
    end

    npc:SetPos(pos)
    npc:SetAngles(ang or Angle(0, 0, 0))
    npc:Spawn()
    npc:Activate()

    -- Persistant après cleanup
    npc:SetPersistent(true)

    print("[Station Service] NPC spawné à " .. tostring(pos))
    return npc
end

-- ============================================================
-- COMMANDES ADMIN
-- ============================================================

-- Spawn le NPC
concommand.Add("stationservice_spawn", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsSuperAdmin() then
        ply:ChatPrint("[Station Service] Vous devez être SuperAdmin pour spawn le PNJ.")
        return
    end

    local tr = ply:GetEyeTrace()
    if not tr.Hit then
        ply:ChatPrint("[Station Service] Visez un endroit valide.")
        return
    end

    local spawnPos = tr.HitPos + Vector(0, 0, 5)
    local spawnAng = Angle(0, (ply:GetPos() - tr.HitPos):Angle().y, 0)

    local npc = SpawnStationServiceNPC(spawnPos, spawnAng)
    if IsValid(npc) then
        ply:ChatPrint("[Station Service] PNJ spawné avec succès !")
    else
        ply:ChatPrint("[Station Service] ERREUR lors du spawn du PNJ.")
    end
end, nil, "[SuperAdmin] Spawn un PNJ Station Service où vous visez.")

-- Supprimer le NPC visé
concommand.Add("stationservice_remove", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsSuperAdmin() then
        ply:ChatPrint("[Station Service] Vous devez être SuperAdmin.")
        return
    end

    local tr = ply:GetEyeTrace()
    if IsValid(tr.Entity) and tr.Entity:GetClass() == "npc_stationservice" then
        tr.Entity:SetPersistent(false)
        tr.Entity:Remove()
        ply:ChatPrint("[Station Service] PNJ supprimé !")
    else
        ply:ChatPrint("[Station Service] Visez un PNJ Station Service.")
    end
end, nil, "[SuperAdmin] Supprime le PNJ Station Service visé.")

-- Ouvrir le menu à distance (SuperAdmin uniquement)
concommand.Add("stationservice_menu", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsSuperAdmin() then
        ply:ChatPrint("[Station Service] Vous devez être SuperAdmin pour utiliser cette commande.")
        return
    end

    net.Start("StationService_Open")
    net.Send(ply)
    ply:ChatPrint("[Station Service] Menu ouvert (mode admin).")
end, nil, "[SuperAdmin] Ouvre le menu Station Service à distance.")

-- ============================================================
-- L'interaction Use est gérée directement par l'entité npc_stationservice

-- ============================================================
-- ACHAT - Fonctions
-- ============================================================

-- Chercher un item dans la config
local function FindConfigItem(categoryID, entityClass)
    for _, cat in ipairs(StationService.Config.Categories) do
        if cat.id == categoryID then
            for _, item in ipairs(cat.items) do
                if item.entity == entityClass then
                    return item, cat
                end
            end
        end
    end
    return nil, nil
end

-- Acheter un seul item pour un joueur (retourne true si succès)
local function PurchaseItem(ply, foundItem, entityClass)
    -- Vérifier l'argent
    if not ply:canAfford(foundItem.price) then
        return false, "Pas assez d'argent"
    end

    -- Retirer l'argent
    ply:addMoney(-foundItem.price)

    -- Si give = true ou arme tfa_, donner directement au joueur
    if foundItem.give or string.StartWith(entityClass, "tfa_") or string.StartWith(entityClass, "weapon_") then
        ply:Give(entityClass)
    else
        -- Sinon, spawn l'entité devant le joueur
        local spawnPos = ply:GetPos() + ply:GetForward() * 80 + Vector(0, 0, 20)
        local ent = ents.Create(entityClass)
        if IsValid(ent) then
            ent:SetPos(spawnPos)
            ent:SetAngles(Angle(0, ply:EyeAngles().y, 0))
            ent:Spawn()
            ent:Activate()

            if ent.Setowning_ent then
                ent:Setowning_ent(ply)
            end
        else
            -- Rembourser si l'entité n'a pas pu être créée
            ply:addMoney(foundItem.price)
            return false, "Erreur création entité"
        end
    end

    return true
end

-- ============================================================
-- ACHAT UNITAIRE (bouton Ajouter dans la liste)
-- ============================================================

net.Receive("StationService_Buy", function(len, ply)
    if not IsValid(ply) then return end

    if ply.StationServiceBuyCooldown and ply.StationServiceBuyCooldown > CurTime() then
        DarkRP.notify(ply, 1, 4, "Veuillez patienter avant d'acheter à nouveau.")
        return
    end
    ply.StationServiceBuyCooldown = CurTime() + 0.3

    local categoryID = net.ReadString()
    local entityClass = net.ReadString()

    local foundItem, foundCategory = FindConfigItem(categoryID, entityClass)
    if not foundItem then
        DarkRP.notify(ply, 1, 4, "Article introuvable.")
        return
    end

    local success, err = PurchaseItem(ply, foundItem, entityClass)
    if success then
        DarkRP.notify(ply, 0, 4, "Acheté : " .. foundItem.name .. " ($" .. foundItem.price .. ")")
    else
        DarkRP.notify(ply, 1, 4, err or "Erreur d'achat.")
    end
end)

-- ============================================================
-- ACHAT PANIER (validation du panier complet)
-- ============================================================

net.Receive("StationService_BuyCart", function(len, ply)
    if not IsValid(ply) then return end

    if ply.StationServiceCartCooldown and ply.StationServiceCartCooldown > CurTime() then
        DarkRP.notify(ply, 1, 4, "Veuillez patienter avant un nouvel achat.")
        return
    end
    ply.StationServiceCartCooldown = CurTime() + 2

    local itemCount = net.ReadUInt(8)
    if itemCount <= 0 or itemCount > 25 then return end -- Anti-exploit

    -- Lire tous les items du panier
    local cartItems = {}
    for i = 1, itemCount do
        local catId = net.ReadString()
        local entity = net.ReadString()
        local qty = net.ReadUInt(4)
        qty = math.Clamp(qty, 1, 5)

        local foundItem = FindConfigItem(catId, entity)
        if foundItem then
            table.insert(cartItems, { item = foundItem, entity = entity, catId = catId, qty = qty })
        end
    end

    -- Calculer le total
    local totalCost = 0
    for _, cartItem in ipairs(cartItems) do
        totalCost = totalCost + (cartItem.item.price * cartItem.qty)
    end

    -- Vérifier l'argent total
    if not ply:canAfford(totalCost) then
        DarkRP.notify(ply, 1, 4, "Fonds insuffisants ! (Requis: $" .. totalCost .. ")")
        return
    end

    -- Acheter chaque item
    local totalBought = 0
    for _, cartItem in ipairs(cartItems) do
        for q = 1, cartItem.qty do
            local success = PurchaseItem(ply, cartItem.item, cartItem.entity)
            if success then
                totalBought = totalBought + 1
            end
        end
    end

    if totalBought > 0 then
        DarkRP.notify(ply, 0, 4, totalBought .. " article(s) acheté(s) pour $" .. totalCost)
    else
        DarkRP.notify(ply, 1, 4, "Erreur lors de l'achat.")
    end
end)

-- ============================================================
-- SAUVEGARDE / RESTAURATION NPC (persistance)
-- ============================================================

local saveFile = "stationservice/npcs.txt"

local function SaveNPCs()
    local data = {}
    for _, ent in ipairs(ents.FindByClass("npc_stationservice")) do
        if IsValid(ent) then
            local p = ent:GetPos()
            local a = ent:GetAngles()
            table.insert(data, {
                px = p.x, py = p.y, pz = p.z,
                ax = a.p, ay = a.y, az = a.r
            })
        end
    end
    file.CreateDir("stationservice")
    file.Write(saveFile, util.TableToJSON(data, true))
    print("[Station Service] " .. #data .. " NPC(s) sauvegardé(s).")
end

local function LoadNPCs()
    if not file.Exists(saveFile, "DATA") then
        print("[Station Service] Aucune sauvegarde trouvée.")
        return
    end

    local raw = file.Read(saveFile, "DATA")
    if not raw or raw == "" then return end

    local data = util.JSONToTable(raw)
    if not data then
        print("[Station Service] ERREUR: Sauvegarde corrompue.")
        return
    end

    print("[Station Service] Chargement de " .. #data .. " NPC(s)...")
    for _, npcData in ipairs(data) do
        local pos = Vector(npcData.px or 0, npcData.py or 0, npcData.pz or 0)
        local ang = Angle(npcData.ax or 0, npcData.ay or 0, npcData.az or 0)
        SpawnStationServiceNPC(pos, ang)
    end
end

hook.Add("PostCleanupMap", "StationService_Reload", function()
    timer.Simple(2, LoadNPCs)
end)

hook.Add("InitPostEntity", "StationService_Load", function()
    timer.Simple(5, LoadNPCs)
end)

concommand.Add("stationservice_save", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("[Station Service] Vous devez être SuperAdmin.")
        return
    end
    SaveNPCs()
    if IsValid(ply) then
        ply:ChatPrint("[Station Service] Positions des PNJ sauvegardées !")
    end
end, nil, "[SuperAdmin] Sauvegarde les positions des PNJ Station Service.")
