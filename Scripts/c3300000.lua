--Radiant Destruction Swordstress
local s,id=GetID()
function s.initial_effect(c)
    -- Cannot control more than 1 copy
    c:SetUniqueOnField(1,0,id)

    -- Special Summon & Equip from GY/field
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)

    -- Prevent Set & Activation of Set S/T
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SSET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,LOCATION_HAND+LOCATION_DECK)
    e2:SetCondition(s.lockcon)
    c:RegisterEffect(e2)

    local e3=e2:Clone()
    e3:SetCode(EFFECT_CANNOT_ACTIVATE)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetTargetRange(0,1)
    e3:SetValue(s.aclimit)
    c:RegisterEffect(e3)

    -- ATK Boost when Equipped
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_EQUIP)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetValue(500)
    c:RegisterEffect(e4)
end

-- Condition: Opponent has a Dragon in field/GY
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_DRAGON),tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
end

-- Target: Select a "Destruction Sword" monster from Field/GY
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_MZONE+LOCATION_GRAVE)
end

-- Equip filter
function s.eqfilter(c,tp)
    return c:IsSetCard(SET_DESTRUCTION_SWORD) and c:IsAbleToChangeControler()
end

-- Special Summon & Equip operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
        local tc=g:GetFirst()
        if tc then
            Duel.Equip(tp,tc,c,true)
            -- Equip boost effect
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_EQUIP)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(500)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    end
end

-- Lock Condition: While controlling a "Destruction Sword" Equip
function s.lockcon(e)
    return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsType,TYPE_EQUIP),e:GetHandlerPlayer(),LOCATION_SZONE,0,1,nil)
end

-- Prevent Activation of Set S/T
function s.aclimit(e,re,tp)
    return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:IsLocation(LOCATION_SZONE)
end