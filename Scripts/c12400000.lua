-- Crystal Demon Yubel
local s,id=GetID()
function s.initial_effect(c)
 -- Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,1,1)

    -- Requisitos de invocación (Link-3, 2+ "Crystal" incluyendo un DARK)
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(s.matfilter),2,3)

    -- Negar ataque e infligir daño
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_BE_BATTLE_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.dmgcon)
    e1:SetOperation(s.dmgop)
    c:RegisterEffect(e1)
    local e1b=e1:Clone()
    e1b:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1b:SetCondition(s.dmgcon2)
    c:RegisterEffect(e1b)

    -- Invocar "Rainbow Dark Dragon" si es destruido
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- Convertirse en una Carta de Continuo en la Spell/Trap Zone
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
    e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e3:SetCondition(s.tocond)
    e3:SetOperation(s.toop)
    c:RegisterEffect(e3)

    -- Invocar "Crystal Beast" desde la Spell/Trap Zone
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,id)
    e4:SetTarget(s.sptg2)
    e4:SetOperation(s.spop2)
    c:RegisterEffect(e4)
end

-- **Material de Link (2+ "Crystal" incluyendo DARK)**
function s.matfilter(c,lc,sumtype,tp)
    return c:IsSetCard(0x1034,lc,sumtype,tp) or c:IsAttribute(ATTRIBUTE_DARK,lc,sumtype,tp)
end

-- **Negar ataque e infligir daño**
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetAttackTarget()==e:GetHandler() and e:GetHandler():GetLinkedGroupCount()>0
end
function s.dmgcon2(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler()==Duel.GetAttacker() and e:GetHandler():GetLinkedGroupCount()>0
end
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.NegateAttack()
    local g=c:GetLinkedGroup()
    local sum_atk=g:GetSum(Card.GetAttack)
    if sum_atk>0 then
        Duel.Damage(1-tp,sum_atk,REASON_EFFECT)
    end
end

-- **Invocar "Rainbow Dark Dragon"**
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.spfilter(c,e,tp)
    return c:IsCode(79856792) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
    end
end

-- **Convertirse en una Continuous Spell en la Spell/Trap Zone**
function s.tocond(e)
    return e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT) and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.toop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
end

-- **Invocar "Crystal Beast" desde la Spell/Trap Zone**
function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_SZONE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_SZONE,0,nil,e,tp)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,3,nil)
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        local tc=sg:GetFirst()
        for tc in aux.Next(sg) do
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(LOCATION_DECKSHF)
            e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
            tc:RegisterEffect(e1)
        end
    end
end
