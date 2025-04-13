-- Red-Eyes Flame Swordsman
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon itself and buff ally
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Equip Normal Monster from Deck/Extra Deck
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_EQUIP)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.eqtg)
    e2:SetOperation(s.eqop)
    c:RegisterEffect(e2)

    -- Self-destruct if ATK is 0
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ADJUST)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.sdcon)
    e3:SetOperation(s.sdop)
    c:RegisterEffect(e3)
end

-- Special Summon from hand and give ATK
function s.filter1(c)
    return c:IsFaceup() and c:IsSetCard(0x3b) and not c:IsCode(id)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
            and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        -- This card loses 600 ATK
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-600)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
        -- Target gains 600 ATK
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_UPDATE_ATTACK)
        e2:SetValue(600)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        tc:RegisterEffect(e2)
    end
end

-- Equip from Deck/Extra
function s.eqfilter(c)
    return c:IsType(TYPE_NORMAL) and not c:IsType(TYPE_EFFECT) and c:IsLevelBelow(6) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil)
            and Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,e:GetHandler())
            and e:GetHandler():IsAttackAbove(600)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:GetAttack()<600 then return end
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
    local ec=g:GetFirst()
    if not ec then return end
    -- Reduce ATK of this card
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(-600)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
    c:RegisterEffect(e1)
    -- Equip the card
    if Duel.Equip(tp,ec,tc,false) then
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_EQUIP)
        e2:SetCode(EFFECT_UPDATE_ATTACK)
        e2:SetValue(600)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        ec:RegisterEffect(e2)
    end
end

-- Self-destruct if ATK is 0
function s.sdcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsAttack(0)
end
function s.sdop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

