--[[
    Station Service - Client Side
    Style EraStaff Glassmorphism — Violet (#6c63ff) theme
    Système de panier intégré
]]

-- ============================================================
-- COULEURS
-- ============================================================

local COLORS = {
    bg_main       = Color(7, 10, 20, 245),
    bg_sidebar    = Color(10, 14, 28, 255),
    bg_content    = Color(7, 10, 20, 250),
    bg_header     = Color(22, 16, 52, 115),
    bg_footer     = Color(7, 10, 20, 255),
    bg_item       = Color(12, 14, 28, 255),
    bg_item_hover = Color(20, 22, 42, 255),
    border        = Color(108, 99, 255, 107),
    border_light  = Color(255, 255, 255, 18),
    border_subtle = Color(255, 255, 255, 15),
    accent        = Color(108, 99, 255, 255),
    accent_soft   = Color(108, 99, 255, 46),
    accent_glow   = Color(108, 99, 255, 77),
    text_primary  = Color(232, 237, 255, 255),
    text_secondary= Color(159, 177, 212, 255),
    text_dim      = Color(90, 105, 140, 255),
    green         = Color(34, 197, 94, 255),
    green_dark    = Color(22, 163, 74, 255),
    green_soft    = Color(34, 197, 94, 33),
    red           = Color(239, 68, 68, 255),
    gold          = Color(248, 209, 90, 255),
    white         = Color(255, 255, 255, 255),
    black         = Color(0, 0, 0, 255),
}

-- ============================================================
-- PANIER (état global par session menu)
-- ============================================================

local SS_Cart = {}  -- { {catId, entity, name, price, qty}, ... }
local SS_MAX_QTY = 5

local function CartGetTotal()
    local total = 0
    for _, item in ipairs(SS_Cart) do
        total = total + (item.price * item.qty)
    end
    return total
end

local function CartGetCount()
    local count = 0
    for _, item in ipairs(SS_Cart) do
        count = count + item.qty
    end
    return count
end

local function CartAddItem(catId, entity, name, price, qty)
    qty = qty or 1
    -- Chercher si l'item est déjà dans le panier
    for _, item in ipairs(SS_Cart) do
        if item.entity == entity then
            item.qty = math.Clamp(item.qty + qty, 0, SS_MAX_QTY)
            if item.qty <= 0 then
                table.RemoveByValue(SS_Cart, item)
            end
            return
        end
    end
    -- Sinon ajouter
    if qty > 0 then
        table.insert(SS_Cart, {
            catId = catId,
            entity = entity,
            name = name,
            price = price,
            qty = math.Clamp(qty, 1, SS_MAX_QTY)
        })
    end
end

local function CartGetItemQty(entity)
    for _, item in ipairs(SS_Cart) do
        if item.entity == entity then return item.qty end
    end
    return 0
end

local function CartSetItemQty(entity, qty)
    for i, item in ipairs(SS_Cart) do
        if item.entity == entity then
            if qty <= 0 then
                table.remove(SS_Cart, i)
            else
                item.qty = math.Clamp(qty, 0, SS_MAX_QTY)
            end
            return
        end
    end
end

local function CartClear()
    SS_Cart = {}
end

-- ============================================================
-- UTILITAIRES DE DESSIN
-- ============================================================

local function DrawGradientLine(x, y, w, h)
    local steps = math.min(w, 200)
    local stepW = w / steps
    for i = 0, steps - 1 do
        local frac = i / steps
        local a, r, g, b = 0, 108, 99, 255
        if frac < 0.15 then
            a = frac / 0.15
        elseif frac < 0.5 then
            local t = (frac - 0.15) / 0.35
            r, g = Lerp(t, 108, 100), Lerp(t, 99, 200)
            a = 1
        elseif frac < 0.85 then
            r, g = 100, 200
            a = 1
        else
            a = (1 - frac) / 0.15
            r, g, b = 100, 200, 255
        end
        surface.SetDrawColor(r, g, b, a * 255)
        surface.DrawRect(x + i * stepW, y, math.ceil(stepW), h)
    end
end

local function DrawRadialGlow(cx, cy, radius, col)
    local steps = 20
    for i = steps, 1, -1 do
        local frac = i / steps
        local size = radius * frac
        local alpha = col.a * (1 - frac) * 0.8
        draw.RoundedBox(size, cx - size, cy - size, size * 2, size * 2, Color(col.r, col.g, col.b, alpha))
    end
end

-- ============================================================
-- LOGO
-- ============================================================

local SS_Logo = Material("stationservice/logo.png", "noclamp smooth")

-- ============================================================
-- POLICES
-- ============================================================

surface.CreateFont("SS_Title", { font = "Segoe UI", size = 22, weight = 900, antialias = true })
surface.CreateFont("SS_NavItem", { font = "Segoe UI", size = 14, weight = 600, antialias = true })
surface.CreateFont("SS_ItemName", { font = "Segoe UI", size = 14, weight = 600, antialias = true })
surface.CreateFont("SS_ItemPrice", { font = "Segoe UI", size = 13, weight = 700, antialias = true })
surface.CreateFont("SS_Button", { font = "Segoe UI", size = 12, weight = 700, antialias = true })
surface.CreateFont("SS_CategoryTitle", { font = "Segoe UI", size = 17, weight = 800, antialias = true })
surface.CreateFont("SS_Small", { font = "Segoe UI", size = 11, weight = 600, antialias = true })
surface.CreateFont("SS_SmallDim", { font = "Segoe UI", size = 10, weight = 400, antialias = true })
surface.CreateFont("SS_PreviewName", { font = "Segoe UI", size = 20, weight = 800, antialias = true })
surface.CreateFont("SS_PreviewPrice", { font = "Segoe UI", size = 24, weight = 900, antialias = true })
surface.CreateFont("SS_PreviewCategory", { font = "Segoe UI", size = 12, weight = 700, antialias = true })
surface.CreateFont("SS_CartCount", { font = "Segoe UI", size = 10, weight = 800, antialias = true })
surface.CreateFont("SS_CartTitle", { font = "Segoe UI", size = 16, weight = 800, antialias = true })
surface.CreateFont("SS_CartTotal", { font = "Segoe UI", size = 18, weight = 900, antialias = true })
surface.CreateFont("SS_QtyBtn", { font = "Segoe UI", size = 18, weight = 900, antialias = true })
surface.CreateFont("SS_QtyNum", { font = "Segoe UI", size = 16, weight = 800, antialias = true })

-- ============================================================
-- SONS
-- ============================================================

local SS_SND_NAV = "stationservice/buttonnav.wav"

local function PlayNavSound()
    surface.PlaySound(SS_SND_NAV)
end

local function PlayCashSound()
    -- Utilise le même son nav pour le paiement en attendant un meilleur fichier
    surface.PlaySound(SS_SND_NAV)
end

-- ============================================================
-- POPUP PANIER
-- ============================================================

local function OpenCartPopup()
    if IsValid(StationService.CartFrame) then
        StationService.CartFrame:Remove()
    end

    if #SS_Cart == 0 then return end

    local scrW, scrH = ScrW(), ScrH()
    local popW, popH = 400, math.Clamp(120 + #SS_Cart * 44, 200, 450)
    local radius = 14

    local overlay = vgui.Create("DPanel")
    overlay:SetSize(scrW, scrH)
    overlay:SetPos(0, 0)
    overlay:MakePopup()
    overlay:SetMouseInputEnabled(true)
    overlay.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 178))
    end
    StationService.CartFrame = overlay

    overlay.OnMousePressed = function(self, keyCode)
        if keyCode == MOUSE_LEFT then
            self:AlphaTo(0, 0.1, 0, function()
                if IsValid(self) then self:Remove() end
            end)
        end
    end

    function overlay:OnKeyCodePressed(key)
        if key == KEY_ESCAPE then
            self:AlphaTo(0, 0.1, 0, function()
                if IsValid(self) then self:Remove() end
            end)
        end
    end

    overlay:SetAlpha(0)
    overlay:AlphaTo(255, 0.15, 0)

    local popup = vgui.Create("DPanel", overlay)
    popup:SetSize(popW, popH)
    popup:SetPos((scrW - popW) / 2, (scrH - popH) / 2)
    popup:SetMouseInputEnabled(true)
    popup.OnMousePressed = function() end

    popup.Paint = function(self, w, h)
        draw.RoundedBox(radius + 4, -8, -8, w + 16, h + 16, Color(0, 0, 0, 70))
        draw.RoundedBox(radius, -1, -1, w + 2, h + 2, COLORS.border)
        draw.RoundedBox(radius, 0, 0, w, h, Color(10, 12, 26, 250))
        DrawGradientLine(0, 0, w, 2)
    end

    -- Header du panier
    local cartHeader = vgui.Create("DPanel", popup)
    cartHeader:Dock(TOP)
    cartHeader:SetTall(42)
    cartHeader.Paint = function(self, w, h)
        draw.SimpleText("🛒 Votre Panier", "SS_CartTitle", 16, h / 2, COLORS.text_primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(CartGetCount() .. " article" .. (CartGetCount() > 1 and "s" or ""), "SS_SmallDim", w - 16, h / 2, COLORS.text_secondary, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(COLORS.border_light)
        surface.DrawRect(0, h - 1, w, 1)
    end

    -- Liste des items du panier
    local scroll = vgui.Create("DScrollPanel", popup)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 6, 10, 6)

    local sbar = scroll:GetVBar()
    sbar:SetWide(3)
    sbar:SetHideButtons(true)
    sbar.Paint = function(self, w, h) draw.RoundedBox(2, 0, 0, w, h, Color(255, 255, 255, 8)) end
    sbar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(2, 0, 0, w, h, COLORS.accent) end

    local function RefreshCartList()
        scroll:Clear()
        for _, cartItem in ipairs(SS_Cart) do
            local row = vgui.Create("DPanel", scroll)
            row:Dock(TOP)
            row:SetTall(38)
            row:DockMargin(0, 2, 0, 2)
            row.Paint = function(self, w, h)
                draw.RoundedBox(6, -1, -1, w + 2, h + 2, COLORS.border_light)
                draw.RoundedBox(6, 0, 0, w, h, COLORS.bg_item)
                draw.SimpleText(cartItem.name, "SS_ItemName", 12, h / 2, COLORS.text_primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText("x" .. cartItem.qty, "SS_Small", w - 110, h / 2, COLORS.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText("$" .. string.Comma(cartItem.price * cartItem.qty), "SS_ItemPrice", w - 50, h / 2, COLORS.green, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end

            -- Bouton supprimer
            local delBtn = vgui.Create("DButton", row)
            delBtn:SetSize(24, 24)
            delBtn:SetText("")
            local delHover = false
            delBtn.Paint = function(self, w, h)
                local col = delHover and Color(239, 68, 68, 60) or Color(255, 255, 255, 8)
                draw.RoundedBox(5, 0, 0, w, h, col)
                draw.SimpleText("✕", "SS_SmallDim", w / 2, h / 2, delHover and COLORS.red or COLORS.text_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            delBtn.OnCursorEntered = function() delHover = true end
            delBtn.OnCursorExited = function() delHover = false end
            delBtn.DoClick = function()
                CartSetItemQty(cartItem.entity, 0)
                RefreshCartList()
                if #SS_Cart == 0 then
                    if IsValid(overlay) then overlay:Remove() end
                end
            end
            row.PerformLayout = function(self, w, h)
                delBtn:SetPos(w - 32, (h - 24) / 2)
            end
        end
    end

    RefreshCartList()

    -- Footer du panier
    local cartFooter = vgui.Create("DPanel", popup)
    cartFooter:Dock(BOTTOM)
    cartFooter:SetTall(70)
    cartFooter.Paint = function(self, w, h)
        surface.SetDrawColor(COLORS.border_light)
        surface.DrawRect(0, 0, w, 1)
        draw.SimpleText("Total :", "SS_Small", 16, 16, COLORS.text_secondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("$" .. string.Comma(CartGetTotal()), "SS_CartTotal", 70, 16, COLORS.green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    -- Bouton Valider l'achat
    local validateBtn = vgui.Create("DButton", cartFooter)
    validateBtn:SetText("")
    local valHover = false
    validateBtn.Paint = function(self, w, h)
        local money = LocalPlayer():getDarkRPVar("money") or 0
        local canAfford = money >= CartGetTotal()
        if canAfford then
            local bgCol = valHover and COLORS.green_dark or COLORS.green
            draw.RoundedBox(8, 0, 0, w, h, bgCol)
            draw.SimpleText("Valider l'achat ($" .. string.Comma(CartGetTotal()) .. ")", "SS_Button", w / 2, h / 2, COLORS.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.RoundedBox(8, -1, -1, w + 2, h + 2, Color(239, 68, 68, 65))
            draw.RoundedBox(8, 0, 0, w, h, Color(239, 68, 68, 25))
            draw.SimpleText("Fonds insuffisants", "SS_Button", w / 2, h / 2, COLORS.red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    validateBtn.OnCursorEntered = function() valHover = true end
    validateBtn.OnCursorExited = function() valHover = false end
    validateBtn.DoClick = function()
        local money = LocalPlayer():getDarkRPVar("money") or 0
        if money < CartGetTotal() then return end
        if #SS_Cart == 0 then return end

        PlayCashSound()

        -- Envoyer le panier entier en un seul message
        net.Start("StationService_BuyCart")
            net.WriteUInt(#SS_Cart, 8)
            for _, cartItem in ipairs(SS_Cart) do
                net.WriteString(cartItem.catId)
                net.WriteString(cartItem.entity)
                net.WriteUInt(cartItem.qty, 4)
            end
        net.SendToServer()

        CartClear()
        if IsValid(overlay) then
            overlay:AlphaTo(0, 0.1, 0, function()
                if IsValid(overlay) then overlay:Remove() end
            end)
        end
    end

    cartFooter.PerformLayout = function(self, w, h)
        validateBtn:SetSize(w - 32, 32)
        validateBtn:SetPos(16, 32)
    end
end

-- ============================================================
-- POPUP PREVIEW D'ITEM (avec +/- quantité)
-- ============================================================

local function OpenItemPreview(itemData, catData)
    if IsValid(StationService.PreviewFrame) then
        StationService.PreviewFrame:Remove()
    end

    local scrW, scrH = ScrW(), ScrH()
    local popW, popH = 440, 300
    local modelSize = 190
    local radius = 14

    local overlay = vgui.Create("DPanel")
    overlay:SetSize(scrW, scrH)
    overlay:SetPos(0, 0)
    overlay:MakePopup()
    overlay:SetMouseInputEnabled(true)
    overlay.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 178))
    end
    StationService.PreviewFrame = overlay

    overlay.OnMousePressed = function(self, keyCode)
        if keyCode == MOUSE_LEFT then
            self:AlphaTo(0, 0.1, 0, function()
                if IsValid(self) then self:Remove() end
            end)
        end
    end

    function overlay:OnKeyCodePressed(key)
        if key == KEY_ESCAPE then
            self:AlphaTo(0, 0.1, 0, function()
                if IsValid(self) then self:Remove() end
            end)
        end
    end

    overlay:SetAlpha(0)
    overlay:AlphaTo(255, 0.15, 0)

    local popup = vgui.Create("DPanel", overlay)
    popup:SetSize(popW, popH)
    popup:SetPos((scrW - popW) / 2, (scrH - popH) / 2)
    popup:SetMouseInputEnabled(true)
    popup.OnMousePressed = function() end

    popup.Paint = function(self, w, h)
        draw.RoundedBox(radius + 4, -8, -8, w + 16, h + 16, Color(0, 0, 0, 70))
        draw.RoundedBox(radius, -1, -1, w + 2, h + 2, COLORS.border)
        draw.RoundedBox(radius, 0, 0, w, h, Color(10, 12, 26, 247))
        DrawGradientLine(0, 0, w, 2)
    end

    -- Model bg
    local modelBg = vgui.Create("DPanel", popup)
    modelBg:SetPos(12, 14)
    modelBg:SetSize(modelSize, popH - 28)
    modelBg:SetZPos(-1)
    modelBg.Paint = function(self, w, h)
        draw.RoundedBox(10, -1, -1, w + 2, h + 2, COLORS.border_light)
        draw.RoundedBox(10, 0, 0, w, h, Color(255, 255, 255, 6))
    end

    local modelPanel = vgui.Create("DModelPanel", popup)
    modelPanel:SetPos(12, 14)
    modelPanel:SetSize(modelSize, popH - 28)
    modelPanel:SetMouseInputEnabled(false)  -- Empêcher le model panel de voler les clics
    modelPanel:SetZPos(-1)

    local modelPath = itemData.model
    if not modelPath then
        local entTable = scripted_ents.Get(itemData.entity)
        if entTable and entTable.WorldModel then modelPath = entTable.WorldModel
        elseif entTable and entTable.Model then modelPath = entTable.Model end
    end

    if modelPath then
        modelPanel:SetModel(modelPath)
        local mn, mx = modelPanel.Entity:GetRenderBounds()
        local center = (mn + mx) * 0.5
        local size = (mx - mn):Length()
        local camDist = size * 1.2
        modelPanel:SetCamPos(center + Vector(camDist * 0.6, camDist * 0.6, camDist * 0.3))
        modelPanel:SetLookAt(center)
        modelPanel:SetFOV(45)
        local rotAngle = 0
        modelPanel.LayoutEntity = function(self, ent)
            rotAngle = rotAngle + FrameTime() * 30
            ent:SetAngles(Angle(0, rotAngle, 0))
        end
    else
        modelPanel.Paint = function() end
        local noModel = vgui.Create("DPanel", popup)
        noModel:SetPos(12, 14)
        noModel:SetSize(modelSize, popH - 28)
        noModel:SetZPos(2)
        noModel.Paint = function(self, w, h)
            draw.SimpleText("Aperçu", "SS_ItemName", w / 2, h / 2 - 8, COLORS.text_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("indisponible", "SS_SmallDim", w / 2, h / 2 + 10, COLORS.text_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    -- Infos droite
    local infoX = modelSize + 28
    local infoW = popW - infoX - 16

    -- Badge catégorie
    local catBadge = vgui.Create("DPanel", popup)
    catBadge:SetPos(infoX, 18)
    surface.SetFont("SS_PreviewCategory")
    local catTextW = surface.GetTextSize(catData.name)
    catBadge:SetSize(catTextW + 18, 22)
    catBadge.Paint = function(self, w, h)
        draw.RoundedBox(5, -1, -1, w + 2, h + 2, ColorAlpha(catData.color, 60))
        draw.RoundedBox(5, 0, 0, w, h, ColorAlpha(catData.color, 30))
        draw.SimpleText(catData.name, "SS_PreviewCategory", w / 2, h / 2, catData.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Nom
    local nameLabel = vgui.Create("DPanel", popup)
    nameLabel:SetPos(infoX, 48)
    nameLabel:SetSize(infoW, 24)
    nameLabel.Paint = function(self, w, h)
        draw.SimpleText(itemData.name, "SS_PreviewName", 0, h / 2, COLORS.text_primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    -- Séparateur
    local sep = vgui.Create("DPanel", popup)
    sep:SetPos(infoX, 80)
    sep:SetSize(infoW, 1)
    sep.Paint = function(self, w, h)
        surface.SetDrawColor(COLORS.border_light)
        surface.DrawRect(0, 0, w, h)
    end

    -- Prix unitaire
    local priceLabel = vgui.Create("DPanel", popup)
    priceLabel:SetPos(infoX, 88)
    priceLabel:SetSize(infoW, 38)
    priceLabel.Paint = function(self, w, h)
        draw.SimpleText("Prix unitaire", "SS_SmallDim", 0, 2, COLORS.text_secondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("$" .. string.Comma(itemData.price), "SS_PreviewPrice", 0, 16, COLORS.green, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    -- Quantité +/-
    local previewQty = math.max(CartGetItemQty(itemData.entity), 1)

    -- Panel quantité
    local qtyPanel = vgui.Create("DPanel", popup)
    qtyPanel:SetPos(infoX, 134)
    qtyPanel:SetSize(infoW, 36)
    qtyPanel:SetZPos(10)
    qtyPanel:SetMouseInputEnabled(true)

    local qtyLabel = nil  -- forward declare

    qtyPanel.Paint = function(self, w, h)
        draw.SimpleText("Quantité", "SS_SmallDim", 0, h / 2, COLORS.text_secondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    -- Bouton -
    local minusBtn = vgui.Create("DButton", qtyPanel)
    minusBtn:SetSize(30, 30)
    minusBtn:SetText("")
    local minusHover = false
    minusBtn.Paint = function(self, w, h)
        local col = minusHover and Color(239, 68, 68, 60) or Color(255, 255, 255, 10)
        draw.RoundedBox(6, -1, -1, w + 2, h + 2, minusHover and Color(239, 68, 68, 40) or Color(255, 255, 255, 15))
        draw.RoundedBox(6, 0, 0, w, h, col)
        draw.SimpleText("−", "SS_QtyBtn", w / 2, h / 2, minusHover and COLORS.red or COLORS.text_primary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    minusBtn.OnCursorEntered = function() minusHover = true end
    minusBtn.OnCursorExited = function() minusHover = false end
    minusBtn.DoClick = function()
        previewQty = math.max(previewQty - 1, 1)
        PlayNavSound()
    end

    -- Affichage quantité
    qtyLabel = vgui.Create("DPanel", qtyPanel)
    qtyLabel:SetSize(36, 30)
    qtyLabel:SetMouseInputEnabled(false)
    qtyLabel.Paint = function(self, w, h)
        draw.SimpleText(tostring(previewQty), "SS_QtyNum", w / 2, h / 2, COLORS.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Bouton +
    local plusBtn = vgui.Create("DButton", qtyPanel)
    plusBtn:SetSize(30, 30)
    plusBtn:SetText("")
    local plusHover = false
    plusBtn.Paint = function(self, w, h)
        local col = plusHover and Color(34, 197, 94, 60) or Color(255, 255, 255, 10)
        draw.RoundedBox(6, -1, -1, w + 2, h + 2, plusHover and Color(34, 197, 94, 40) or Color(255, 255, 255, 15))
        draw.RoundedBox(6, 0, 0, w, h, col)
        draw.SimpleText("+", "SS_QtyBtn", w / 2, h / 2, plusHover and COLORS.green or COLORS.text_primary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    plusBtn.OnCursorEntered = function() plusHover = true end
    plusBtn.OnCursorExited = function() plusHover = false end
    plusBtn.DoClick = function()
        previewQty = math.min(previewQty + 1, SS_MAX_QTY)
        PlayNavSound()
    end

    -- Sous-total
    local subtotalLabel = vgui.Create("DPanel", qtyPanel)
    subtotalLabel:SetSize(55, 30)
    subtotalLabel:SetMouseInputEnabled(false)  -- Ne pas bloquer les clics
    subtotalLabel.Paint = function(self, w, h)
        draw.SimpleText("$" .. string.Comma(itemData.price * previewQty), "SS_ItemPrice", w, h / 2, COLORS.gold, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    qtyPanel.PerformLayout = function(self, w, h)
        local startX = 65
        minusBtn:SetPos(startX, (h - 30) / 2)
        qtyLabel:SetPos(startX + 32, (h - 30) / 2)
        plusBtn:SetPos(startX + 68, (h - 30) / 2)
        subtotalLabel:SetPos(w - 55, (h - 30) / 2)
    end

    -- Bouton Ajouter au panier
    local addBtn = vgui.Create("DButton", popup)
    addBtn:SetPos(infoX, popH - 56)
    addBtn:SetSize(infoW, 38)
    addBtn:SetText("")
    addBtn:SetZPos(10)

    local addHover = false
    addBtn.Paint = function(self, w, h)
        local bgCol = addHover and COLORS.green_dark or COLORS.green
        draw.RoundedBox(8, 0, 0, w, h, bgCol)
        if addHover then
            draw.RoundedBox(8, -2, -2, w + 4, h + 4, Color(34, 197, 94, 25))
        end
        draw.SimpleText("Ajouter au panier (" .. previewQty .. ")", "SS_Button", w / 2, h / 2, COLORS.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    addBtn.OnCursorEntered = function() addHover = true end
    addBtn.OnCursorExited = function() addHover = false end

    addBtn.DoClick = function()
        CartSetItemQty(itemData.entity, 0)
        CartAddItem(catData.id, itemData.entity, itemData.name, itemData.price, previewQty)
        PlayNavSound()
        if IsValid(overlay) then
            overlay:AlphaTo(0, 0.1, 0, function()
                if IsValid(overlay) then overlay:Remove() end
            end)
        end
    end
end

-- ============================================================
-- MENU PRINCIPAL
-- ============================================================

local function OpenStationServiceMenu()
    if IsValid(StationService.MenuFrame) then
        StationService.MenuFrame:Remove()
    end

    -- Reset du panier à l'ouverture
    CartClear()

    local scrW, scrH = ScrW(), ScrH()
    local menuW = math.Clamp(scrW * 0.55, 700, 1000)
    local menuH = math.Clamp(scrH * 0.6, 420, 600)
    local sidebarW = 200
    local headerH = 62
    local radius = 14

    local frame = vgui.Create("DFrame")
    frame:SetSize(menuW, menuH)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame:SetAlpha(0)
    frame:AlphaTo(255, 0.18, 0)
    StationService.MenuFrame = frame

    frame.Paint = function(self, w, h)
        draw.RoundedBox(radius + 6, -10, -10, w + 20, h + 20, Color(0, 0, 0, 55))
        draw.RoundedBox(radius + 3, -5, -5, w + 10, h + 10, Color(0, 0, 0, 40))
        draw.RoundedBox(radius, -1, -1, w + 2, h + 2, COLORS.border)
        draw.RoundedBox(radius, 0, 0, w, h, COLORS.bg_main)
        DrawRadialGlow(w * 0.05, h * 0.05, 250, Color(140, 130, 255, 18))
        DrawRadialGlow(w * 0.95, h * 0.95, 200, Color(100, 200, 255, 10))
        DrawGradientLine(0, 0, w, 2)
    end

    function frame:OnKeyCodePressed(key)
        if key == KEY_ESCAPE then
            self:AlphaTo(0, 0.15, 0, function()
                if IsValid(self) then self:Remove() end
            end)
        end
    end

    -- ============================
    -- HEADER
    -- ============================
    local header = vgui.Create("DPanel", frame)
    header:Dock(TOP)
    header:SetTall(headerH)

    header.Paint = function(self, w, h)
        draw.RoundedBoxEx(0, 0, 0, w, h, COLORS.bg_header, false, false, false, false)
        surface.SetDrawColor(COLORS.border_light)
        surface.DrawRect(0, h - 1, w, 1)

        -- Logo 7-Eleven
        local iconSize = 40
        local iconX, iconY = 14, (h - iconSize) / 2
        draw.RoundedBox(8, iconX, iconY, iconSize, iconSize, COLORS.white)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(SS_Logo)
        surface.DrawTexturedRect(iconX + 2, iconY + 2, iconSize - 4, iconSize - 4)

        draw.SimpleText("Station Service", "SS_Title", iconX + iconSize + 14, h / 2 - 9, COLORS.text_primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Achetez vos fournitures", "SS_SmallDim", iconX + iconSize + 14, h / 2 + 10, COLORS.text_secondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    -- Bouton Panier (à gauche du X)
    local cartBtn = vgui.Create("DButton", header)
    cartBtn:SetSize(90, 30)
    cartBtn:SetText("")

    local cartHover = false
    cartBtn.Paint = function(self, w, h)
        local count = CartGetCount()
        if cartHover then
            draw.RoundedBox(8, -1, -1, w + 2, h + 2, Color(34, 197, 94, 120))
            draw.RoundedBox(8, 0, 0, w, h, Color(34, 197, 94, 50))
        elseif count > 0 then
            draw.RoundedBox(8, -1, -1, w + 2, h + 2, Color(34, 197, 94, 90))
            draw.RoundedBox(8, 0, 0, w, h, Color(34, 197, 94, 35))
        else
            draw.RoundedBox(8, -1, -1, w + 2, h + 2, Color(34, 197, 94, 60))
            draw.RoundedBox(8, 0, 0, w, h, Color(34, 197, 94, 20))
        end

        -- Texte "Panier"
        draw.SimpleText("Panier", "SS_Button", w / 2, h / 2, COLORS.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Badge compteur (cercle bleu/violet en haut à droite)
        if count > 0 then
            local badgeSize = 18
            local bx = w - 6
            local by = -5
            draw.RoundedBox(badgeSize / 2, bx - badgeSize / 2, by, badgeSize, badgeSize, COLORS.accent)
            draw.SimpleText(tostring(count), "SS_CartCount", bx, by + badgeSize / 2, COLORS.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    cartBtn.OnCursorEntered = function() cartHover = true end
    cartBtn.OnCursorExited = function() cartHover = false end
    cartBtn.DoClick = function()
        PlayNavSound()
        OpenCartPopup()
    end

    -- Bouton fermer
    local closeBtn = vgui.Create("DButton", header)
    closeBtn:SetSize(30, 30)
    closeBtn:SetText("")

    header.PerformLayout = function(self, w, h)
        closeBtn:SetPos(w - 44, (h - 30) / 2)
        cartBtn:SetPos(w - 144, (h - 30) / 2)
    end

    local closeBtnHover = false
    closeBtn.Paint = function(self, w, h)
        if closeBtnHover then
            draw.RoundedBox(8, -1, -1, w + 2, h + 2, Color(239, 68, 68, 150))
            draw.RoundedBox(8, 0, 0, w, h, Color(239, 68, 68, 60))
            draw.SimpleText("✕", "SS_Button", w / 2, h / 2, COLORS.white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.RoundedBox(8, -1, -1, w + 2, h + 2, Color(239, 68, 68, 90))
            draw.RoundedBox(8, 0, 0, w, h, Color(239, 68, 68, 30))
            draw.SimpleText("✕", "SS_Button", w / 2, h / 2, COLORS.red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    closeBtn.OnCursorEntered = function() closeBtnHover = true end
    closeBtn.OnCursorExited = function() closeBtnHover = false end
    closeBtn.DoClick = function()
        frame:AlphaTo(0, 0.15, 0, function()
            if IsValid(frame) then frame:Remove() end
        end)
    end

    -- ============================
    -- FOOTER
    -- ============================
    local footer = vgui.Create("DPanel", frame)
    footer:Dock(BOTTOM)
    footer:SetTall(40)

    footer.Paint = function(self, w, h)
        draw.RoundedBoxEx(0, 0, 0, w, h, COLORS.bg_footer, false, false, true, true)
        surface.SetDrawColor(COLORS.border_light)
        surface.DrawRect(0, 0, w, 1)

        local money = LocalPlayer():getDarkRPVar("money") or 0
        draw.SimpleText("Votre solde : ", "SS_Small", 16, h / 2, COLORS.text_secondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetFont("SS_Small")
        local stw = surface.GetTextSize("Votre solde : ")
        draw.SimpleText("$" .. string.Comma(money), "SS_ItemPrice", 16 + stw, h / 2, COLORS.green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Afficher le total du panier à droite
        local cartTotal = CartGetTotal()
        if cartTotal > 0 then
            draw.SimpleText("Panier : $" .. string.Comma(cartTotal), "SS_ItemPrice", w - 16, h / 2, COLORS.gold, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end

    -- ============================
    -- BODY
    -- ============================
    local body = vgui.Create("DPanel", frame)
    body:Dock(FILL)
    body.Paint = function() end

    -- SIDEBAR
    local sidebar = vgui.Create("DPanel", body)
    sidebar:Dock(LEFT)
    sidebar:SetWide(sidebarW)

    sidebar.Paint = function(self, w, h)
        draw.RoundedBoxEx(0, 0, 0, w, h, COLORS.bg_sidebar, false, false, false, false)
        surface.SetDrawColor(COLORS.border_light)
        surface.DrawRect(w - 1, 0, 1, h)
    end

    local navLabel = vgui.Create("DLabel", sidebar)
    navLabel:Dock(TOP)
    navLabel:DockMargin(16, 14, 8, 8)
    navLabel:SetTall(14)
    navLabel:SetText("NAVIGATION")
    navLabel:SetFont("SS_SmallDim")
    navLabel:SetTextColor(COLORS.text_dim)

    local contentPanels = {}
    local navButtons = {}
    local selectedCategory = 1

    -- CONTENU
    local contentArea = vgui.Create("DPanel", body)
    contentArea:Dock(FILL)
    contentArea.Paint = function(self, w, h)
        draw.RoundedBoxEx(0, 0, 0, w, h, COLORS.bg_content, false, false, false, false)
    end

    local function CreateCategoryContent(parent, catData)
        local panel = vgui.Create("DPanel", parent)
        panel:Dock(FILL)
        panel:DockMargin(18, 14, 18, 14)
        panel:SetVisible(false)
        panel.Paint = function() end

        local titleBar = vgui.Create("DPanel", panel)
        titleBar:Dock(TOP)
        titleBar:SetTall(48)
        titleBar.Paint = function(self, w, h)
            draw.SimpleText("◆ " .. catData.name, "SS_CategoryTitle", 0, 8, COLORS.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(#catData.items .. " article" .. (#catData.items > 1 and "s" or "") .. " disponible" .. (#catData.items > 1 and "s" or ""), "SS_SmallDim", 0, 30, COLORS.text_secondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            surface.SetDrawColor(COLORS.border_light)
            surface.DrawRect(0, h - 1, w, 1)
        end

        local tableHeader = vgui.Create("DPanel", panel)
        tableHeader:Dock(TOP)
        tableHeader:SetTall(30)
        tableHeader:DockMargin(0, 4, 0, 0)
        tableHeader.Paint = function(self, w, h)
            draw.SimpleText("Article", "SS_SmallDim", 14, h / 2, COLORS.text_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Prix", "SS_SmallDim", w - 180, h / 2, COLORS.text_dim, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Action", "SS_SmallDim", w - 65, h / 2, COLORS.text_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local scroll = vgui.Create("DScrollPanel", panel)
        scroll:Dock(FILL)
        scroll:DockMargin(0, 2, 0, 0)

        local sbar = scroll:GetVBar()
        sbar:SetWide(4)
        sbar:SetHideButtons(true)
        sbar.Paint = function(self, w, h) draw.RoundedBox(2, 0, 0, w, h, Color(255, 255, 255, 8)) end
        sbar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(2, 0, 0, w, h, COLORS.accent) end

        for i, itemData in ipairs(catData.items) do
            local itemBtn = vgui.Create("DButton", scroll)
            itemBtn:Dock(TOP)
            itemBtn:SetTall(48)
            itemBtn:DockMargin(0, 2, 0, 2)
            itemBtn:SetText("")

            local itemHover = false

            itemBtn.Paint = function(self, w, h)
                local bgCol = itemHover and COLORS.bg_item_hover or COLORS.bg_item
                local borderCol = itemHover and COLORS.border or COLORS.border_light
                draw.RoundedBox(8, -1, -1, w + 2, h + 2, borderCol)
                draw.RoundedBox(8, 0, 0, w, h, bgCol)

                draw.RoundedBox(2, 4, 10, 3, h - 20, catData.color)
                draw.SimpleText(itemData.name, "SS_ItemName", 18, h / 2, COLORS.text_primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText("$" .. itemData.price, "SS_ItemPrice", w - 180, h / 2, COLORS.green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                -- Afficher quantité dans le panier si > 0
                local inCart = CartGetItemQty(itemData.entity)
                if inCart > 0 then
                    draw.RoundedBox(4, w - 140, (h - 16) / 2, 24, 16, COLORS.accent_soft)
                    draw.SimpleText("x" .. inCart, "SS_CartCount", w - 128, h / 2, COLORS.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                if itemHover then
                    draw.SimpleText("Cliquez pour l'aperçu", "SS_SmallDim", w / 2, h - 4, Color(159, 177, 212, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
                end
            end

            itemBtn.OnCursorEntered = function() itemHover = true end
            itemBtn.OnCursorExited = function() itemHover = false end

            itemBtn.DoClick = function()
                PlayNavSound()
                OpenItemPreview(itemData, catData)
            end

            -- Bouton Ajouter (+1 au panier)
            local addBtn = vgui.Create("DButton", itemBtn)
            addBtn:SetSize(85, 28)
            addBtn:SetText("")

            local addHover = false

            addBtn.Paint = function(self, w, h)
                if addHover then
                    draw.RoundedBox(7, -2, -2, w + 4, h + 4, Color(34, 197, 94, 20))
                    draw.RoundedBox(7, 0, 0, w, h, COLORS.green)
                else
                    draw.RoundedBox(7, -1, -1, w + 2, h + 2, Color(34, 197, 94, 75))
                    draw.RoundedBox(7, 0, 0, w, h, Color(34, 197, 94, 30))
                end
                local textCol = addHover and COLORS.white or COLORS.green
                local inCart = CartGetItemQty(itemData.entity)
                if inCart >= SS_MAX_QTY then
                    draw.SimpleText("Max (" .. SS_MAX_QTY .. ")", "SS_Button", w / 2, h / 2, COLORS.gold, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                else
                    draw.SimpleText("Ajouter", "SS_Button", w / 2, h / 2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end

            addBtn.OnCursorEntered = function() addHover = true; itemHover = true end
            addBtn.OnCursorExited = function() addHover = false; itemHover = false end

            addBtn.DoClick = function()
                local inCart = CartGetItemQty(itemData.entity)
                if inCart < SS_MAX_QTY then
                    CartAddItem(catData.id, itemData.entity, itemData.name, itemData.price, 1)
                    PlayNavSound()
                end
            end

            itemBtn.PerformLayout = function(self, w, h)
                addBtn:SetPos(w - 105, (h - 28) / 2)
            end
        end

        return panel
    end

    for i, catData in ipairs(StationService.Config.Categories) do
        contentPanels[i] = CreateCategoryContent(contentArea, catData)
    end

    local function SelectCategory(index)
        selectedCategory = index
        for i, panel in ipairs(contentPanels) do panel:SetVisible(i == index) end
        for i, btn in ipairs(navButtons) do btn.isSelected = (i == index) end
    end

    for i, catData in ipairs(StationService.Config.Categories) do
        local navBtn = vgui.Create("DButton", sidebar)
        navBtn:Dock(TOP)
        navBtn:SetTall(38)
        navBtn:DockMargin(8, 1, 8, 1)
        navBtn:SetText("")
        navBtn.isSelected = (i == 1)

        local navHover = false
        local iconMat = Material(catData.icon or "icon16/folder.png")

        navBtn.Paint = function(self, w, h)
            if self.isSelected then
                draw.RoundedBox(8, -1, -1, w + 2, h + 2, COLORS.border)
                draw.RoundedBox(8, 0, 0, w, h, COLORS.accent_soft)
            elseif navHover then
                draw.RoundedBox(8, -1, -1, w + 2, h + 2, Color(255, 255, 255, 15))
                draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, 10))
            end

            surface.SetDrawColor(self.isSelected and COLORS.white or COLORS.text_secondary)
            surface.SetMaterial(iconMat)
            surface.DrawTexturedRect(12, (h - 16) / 2, 16, 16)

            local textCol = self.isSelected and COLORS.white or (navHover and COLORS.text_primary or COLORS.text_secondary)
            draw.SimpleText(catData.name, "SS_NavItem", 36, h / 2, textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            local badgeText = tostring(#catData.items)
            surface.SetFont("SS_SmallDim")
            local tw = surface.GetTextSize(badgeText)
            local badgeW = math.max(tw + 10, 20)
            local badgeBg = self.isSelected and Color(255, 255, 255, 30) or Color(255, 255, 255, 8)
            local badgeCol = self.isSelected and COLORS.white or COLORS.text_dim
            draw.RoundedBox(5, w - badgeW - 8, (h - 16) / 2, badgeW, 16, badgeBg)
            draw.SimpleText(badgeText, "SS_SmallDim", w - badgeW / 2 - 8, h / 2, badgeCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        navBtn.OnCursorEntered = function() navHover = true end
        navBtn.OnCursorExited = function() navHover = false end
        navBtn.DoClick = function() SelectCategory(i); PlayNavSound() end

        navButtons[i] = navBtn
    end

    SelectCategory(1)
end

-- ============================================================
-- NET
-- ============================================================

net.Receive("StationService_Open", function()
    OpenStationServiceMenu()
end)

-- ============================================================
-- OVERHEAD NPC
-- ============================================================

hook.Add("PostDrawTranslucentRenderables", "StationService_DrawOverhead", function()
    for _, ent in ipairs(ents.FindByClass("npc_stationservice")) do
        if IsValid(ent) then
            local pos = ent:GetPos() + Vector(0, 0, 82)
            local ang = (pos - LocalPlayer():EyePos()):Angle()
            ang:RotateAroundAxis(ang:Up(), -90)
            ang:RotateAroundAxis(ang:Forward(), 90)

            local dist = LocalPlayer():GetPos():Distance(ent:GetPos())
            if dist > 400 then continue end

            local scale = math.Clamp(1 - (dist / 400), 0.3, 1)

            cam.Start3D2D(pos, ang, 0.08 * scale)
                local bgW, bgH = 500, 80
                draw.RoundedBox(12, -bgW / 2 - 1, -bgH / 2 - 1, bgW + 2, bgH + 2, COLORS.border)
                draw.RoundedBox(12, -bgW / 2, -bgH / 2, bgW, bgH, Color(7, 10, 20, 210))
                DrawGradientLine(-bgW / 2, -bgH / 2, bgW, 2)

                local logoX = -bgW / 2 + 16
                draw.RoundedBox(8, logoX, -20, 40, 40, COLORS.white)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(SS_Logo)
                surface.DrawTexturedRect(logoX + 2, -18, 36, 36)

                draw.SimpleText("Station Service", "DermaLarge", logoX + 54, -10, COLORS.text_primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText("Appuyez sur E pour interagir", "DermaDefault", logoX + 54, 15, COLORS.text_secondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            cam.End3D2D()
        end
    end
end)

-- ============================================================
-- COMMANDES CONSOLE (autocomplete client)
-- ============================================================

local SS_Commands = {
    "stationservice_spawn",
    "stationservice_remove",
    "stationservice_save",
    "stationservice_menu",
}

local function SS_Autocomplete(cmd, argStr)
    local results = {}
    local search = string.lower(string.Trim(argStr or ""))
    for _, c in ipairs(SS_Commands) do
        if search == "" or string.find(c, search, 1, true) then
            table.insert(results, c)
        end
    end
    return results
end

-- Enregistrer uniquement l'autocomplete sans écraser la commande serveur
-- On utilise une seule commande "helper" pour l'autocomplete
concommand.Add("stationservice", function(ply, cmd, args)
    if args[1] then
        -- Redirige vers la vraie commande
        RunConsoleCommand("stationservice_" .. args[1])
    else
        print("[Station Service] Commandes disponibles :")
        print("  stationservice_spawn  — Spawn un PNJ où vous visez (SuperAdmin)")
        print("  stationservice_remove — Supprime le PNJ visé (SuperAdmin)")
        print("  stationservice_save   — Sauvegarde les positions des PNJ (SuperAdmin)")
        print("  stationservice_menu   — Ouvre le menu à distance (SuperAdmin)")
    end
end, SS_Autocomplete, "[Station Service] Liste des commandes disponibles.")
