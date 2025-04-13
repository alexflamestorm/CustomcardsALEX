--Primathmech Lagrange Theorem
local s,id=GetID()
function s.initial_effect(c)
 -- Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,1,1)

    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_CYBERSE),2,99,s.lcheck)

    -- Gana 500 ATK por cada "Mathmech" que apunte
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    -- Evita activaciones en batalla en la Extra Monster Zone
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,1)
    e2:SetCondition(s.actcon)
    e2:SetValue(s.aclimit)
    c:RegisterEffect(e2)

    -- Recuperar un Spell/Trap "Mathmech" si es destruido
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

-- Requisito de Link: debe incluir un monstruo "Mathmech"
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(Card.IsSetCard,1,nil,0x12f)
end

-- Gana 500 ATK por cada "Mathmech" apuntado
function s.atkval(e,c)
    return e:GetHandler():GetLinkedGroup():FilterCount(Card.IsSetCard,nil,0x12f)*500
end

-- No se pueden activar Spell/Trap si está en la Extra Monster Zone y batalla
function s.actcon(e)
    local c=e:GetHandler()
    local bt=Duel.GetAttacker()
    if c==bt then bt=Duel.GetAttackTarget() end
    return c:IsLocation(LOCATION_MZONE) and c:IsControler(c:GetOwner()) and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsInExtraMZone()
end
function s.aclimit(e,re,tp)
    return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end

-- Recuperar 1 Spell/Trap "Mathmech" si es destruido
function s.thfilter(c)
    return c:IsSetCard(0x12f) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
