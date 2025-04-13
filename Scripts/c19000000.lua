-- Armor of Fighting Flames
local s,id=GetID()
function s.initial_effect(c)
    -- Equip to FIRE or Warrior
    aux.AddEquipProcedure(c,nil,function(c) return c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_WARRIOR) end)

    -- Battle destruction protection (1 per turn)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id)==0 end)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    -- Count the once per turn indestructible battle
    local e1reset=Effect.CreateEffect(c)
    e1reset:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e1reset:SetCode(EVENT_BATTLED)
    e1reset:SetRange(LOCATION_SZONE)
    e1reset:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        if e:GetHandler():GetEquipTarget() and e:GetHandler():GetEquipTarget():IsRelateToBattle() then
            e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
        end
    end)
    c:RegisterEffect(e1reset)

    -- Return from GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.retcost)
    e2:SetTarget(s.rettg)
    e2:SetOperation(s.retop)
    c:RegisterEffect(e2)

    -- Destroy equipped monster to Special Summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- Cost filter
function s.costfilter(c)
    return c:IsAttribute(ATTRIBUTE_FIRE) and (c:IsSetCard(0xFF1) or c:IsRace(RACE_WARRIOR)) and c:IsAbleToDeck()
end
function s.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,2,nil) end
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    return chk==0 or e:GetHandler():IsAbleToHand()
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SendtoHand(e:GetHandler(),tp,REASON_EFFECT)~=0 then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetTargetRange(1,0)
        e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsAttribute(ATTRIBUTE_FIRE) end)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

-- Target to destroy equipped monster
function s.spfilter(c,e,tp)
    return (c:IsCode(34460851) or c:IsCode(90876561) or (c:IsCode(45231177) and c:IsLevelBelow(5)))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ec=e:GetHandler():GetEquipTarget()
    if chk==0 then
        return ec and ec:IsDestructable()
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,ec,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ec=c:GetEquipTarget()
    if ec and Duel.Destroy(ec,REASON_EFFECT)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
        local tc=g:GetFirst()
        if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
            -- Cannot attack directly
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
        end
    end
end
