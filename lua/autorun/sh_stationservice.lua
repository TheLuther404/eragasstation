--[[
    Station Service - Shared Configuration
    Addon by Era Framework Style
]]

StationService = StationService or {}

-- ============================================================
-- CONFIGURATION - Modifie ici pour ajouter/retirer des items
-- ============================================================

StationService.Config = {
    -- NPC Settings
    NPCModel = "models/humans/group01/male_07.mdl",
    NPCName = "Station Service",
    InteractionDistance = 150, -- Distance max pour interagir

    -- Catégories et items
    -- model = chemin du modèle 3D pour la preview
    -- give = true pour donner l'item au joueur (armes), false/nil pour spawn l'entité
    Categories = {
        {
            id = "nourriture",
            name = "Nourriture",
            icon = "icon16/cake.png",
            color = Color(76, 175, 80),
            items = {
                { entity = "bread5", name = "Pain", price = 25, icon = "icon16/basket.png", model = "models/foodnhouseholditems/bread_loaf.mdl" },
            }
        },
        {
            id = "utilitaires",
            name = "Utilitaires",
            icon = "icon16/phone.png",
            color = Color(33, 150, 243),
            items = {
                { entity = "mc_phone", name = "Téléphone", price = 250, icon = "icon16/phone.png", model = "models/mosi/props/phone/phone.mdl" },
                { entity = "mc_phone_lm", name = "Téléphone LM", price = 300, icon = "icon16/phone.png", model = "models/mosi/props/phone/phone.mdl" },
                { entity = "mc_phone_bg", name = "Téléphone BG", price = 350, icon = "icon16/phone.png", model = "models/mosi/props/phone/phone.mdl" },
            }
        },
        {
            id = "outils",
            name = "Outils",
            icon = "icon16/wrench.png",
            color = Color(255, 152, 0),
            items = {
                { entity = "tfa_nmrih_kknife", name = "Couteau", price = 500, icon = "icon16/wrench.png", model = "models/weapons/tfa_nmrih/w_me_kitknife.mdl", give = true },
                { entity = "tfa_nmrih_clever", name = "Hachoir", price = 650, icon = "icon16/wrench.png", model = "models/weapons/tfa_nmrih/w_me_cleaver.mdl", give = true },
                { entity = "tfa_nmrih_bcd", name = "Pied de biche", price = 450, icon = "icon16/wrench.png", model = "models/weapons/tfa_nmrih/w_me_crowbar.mdl", give = true },
            }
        },
    }
}

-- Network strings sont dans sv_stationservice.lua
