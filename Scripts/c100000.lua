--Seer of the Ice Barrier
local s,id,o=GetID()
function s.initial_effect(c)
 --Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,99,s.lcheck)

  -- No puede ser usado como Material de Enlace el turno en que es Invocado
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    e0:SetCondition(s.lklimit)
    c:RegisterEffect(e0)
    
    -- Protección para Ice Barrier
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(s.protecttg)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    
    -- Activar efectos pagando 1500 LP
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.activate)
    c:RegisterEffect(e2)
end

function s.lklimit(e)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.protecttg(e, c)
    return c:IsSetCard(0x2f) or c == e:GetHandler()
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1500) end
    Duel.PayLPCost(tp, 1500)
end

function s.spfilter(c, e, tp)
    return c:IsSetCard(0x2f) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.thfilter(c)
    return c:IsSetCard(0x2f) and c:IsLevelBelow(4) and c:IsAbleToHand()
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp) or 
               Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil)
    end
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
    local b1 = Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp)
    local b2 = Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil)
    if not (b1 or b2) then return end
    local opt = Duel.SelectOption(tp, aux.Stringid(id, 0), aux.Stringid(id, 1))
    if opt == 0 then
        local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
        if g:GetCount() > 0 then
            Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
        end
    else
        local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
        if g:GetCount() > 0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    end
end
	

