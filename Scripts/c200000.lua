-- The Winged Dragon of Horus
local s2, id2 = GetID()
function s2.initial_effect(c)
-- Xyz Summon
    c:EnableReviveLimit()
    Xyz.AddProcedure(c,nil,8,2,nil,nil,99) 

    -- Protección si "King's Sarcophagus" está en el campo
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetCondition(s2.immcon)
    e1:SetValue(s2.immval)
    c:RegisterEffect(e1)
    
    -- Cambiar efecto del oponente
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s2.negcon)
    e2:SetCost(s2.negcost)
    e2:SetOperation(s2.negop)
    c:RegisterEffect(e2)
    
    -- Revivir si una carta se destruye
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCondition(s2.spcon)
    e3:SetTarget(s2.sptg)
    e3:SetOperation(s2.spop)
    c:RegisterEffect(e3)
end

function s2.immcon(e)
    return Duel.IsExistingMatchingCard(Card.IsCode, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil, 12345678)
end

function s2.immval(e, te)
    return te:GetOwnerPlayer() ~= e:GetHandlerPlayer()
end

function s2.negcon(e, tp, eg, ep, ev, re, r, rp)
    return re:IsActiveType(TYPE_MONSTER) and ep == 1 - tp
end

function s2.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckRemoveOverlayCard(tp, 1, 0, 1, REASON_COST) end
    Duel.RemoveOverlayCard(tp, 1, 0, 1, 1, REASON_COST)
end

function s2.negop(e, tp, eg, ep, ev, re, r, rp)
    Duel.NegateEffect(ev)
end

function s2.spcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(Card.IsControler, 1, nil, tp)
end

function s2.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s2.spop(e, tp, eg, ep, ev, re, r, rp)
    Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP)
end
