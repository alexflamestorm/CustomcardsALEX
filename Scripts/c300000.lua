-- Neo Flamvell Archer
local s3, id3 = GetID()
function s3.initial_effect(c)
--Invocación por Sincronía
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_TUNER),1,1,Synchro.NonTuner(nil),1,99)

    -- Aumenta ATK de "Flamvell"
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(s3.atktg)
    e1:SetValue(500)
    c:RegisterEffect(e1)
    
    -- Destruir un monstruo del oponente si su ATK <= DEF
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s3.destg)
    e2:SetOperation(s3.desop)
    c:RegisterEffect(e2)
end

function s3.atktg(e, c)
    return c:IsSetCard(0x205)
end

function s3.destfilter(c)
    return c:IsFaceup() and c:GetAttack() <= c:GetDefense()
end

function s3.destg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s3.destfilter, tp, 0, LOCATION_MZONE, 1, nil) end
    local g = Duel.GetMatchingGroup(s3.destfilter, tp, 0, LOCATION_MZONE, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s3.desop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.SelectMatchingCard(tp, s3.destfilter, tp, 0, LOCATION_MZONE, 1, 1, nil)
    if #g > 0 then
        Duel.Destroy(g, REASON_EFFECT)
    end
end