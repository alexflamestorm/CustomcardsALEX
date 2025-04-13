--Necrovalley Tribute Shrine
local s,id=GetID()
function s.initial_effect(c)
    -- This card becomes "Necrovalley" on the field
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_SZONE)
    e0:SetValue(CARD_NECROVALLEY)
    c:RegisterEffect(e0)

    -- Protection effect
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.prottg)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Special Summon Ra or Level 10 Gravekeeper's monster
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.spcon)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- Target protection filter
function s.prottg(e,c)
    return c:IsSetCard(0x2e) or (c:IsSummonType(SUMMON_TYPE_RITUAL) or c:IsSummonType(SUMMON_TYPE_ADVANCE)) and c:GetMaterial():IsExists(Card.IsSetCard,1,nil,0x2e)
end

-- Condition: once only (built-in with countlimit)

-- Cost: Tribute 3 Gravekeeper's, Serket, or Apophis monsters
function s.cfilter(c)
    return (c:IsSetCard(0x2e) or c:IsCode(CARD_SANCTUARY_IN_THE_SKY, CARD_METAL_REFLECT_SLIME)) and c:IsReleasable()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.CheckReleaseGroup(tp,s.cfilter,3,nil) 
    end
    local g=Duel.SelectReleaseGroup(tp,s.cfilter,3,3,nil)
    local atk=g:GetSum(Card.GetAttack)
    local def=g:GetSum(Card.GetDefense)
    e:SetLabel(atk)
    e:SetLabelObject(def)
    Duel.Release(g,REASON_COST)
end

-- Targeting for Ra or Gravekeeper's Level 10
function s.spfilter(c,e,tp)
    return (c:IsCode(10000020) or (c:IsSetCard(0x2e) and c:IsLevel(10))) 
        and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

-- Special Summon operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local atk=e:GetLabel()
    local def=e:GetLabelObject()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
    if sc and Duel.SpecialSummon(sc,0,tp,tp,true,true,POS_FACEUP)~=0 then
        if sc:IsFaceup() then
            -- Set ATK/DEF
            local e1=Effect.CreateEffect(sc)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_BASE_ATTACK)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            sc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_SET_BASE_DEFENSE)
            e2:SetValue(def)
            sc:RegisterEffect(e2)
        end
        -- Send 1 Divine-Beast from Deck to GY (optional)
        local g=Duel.GetMatchingGroup(function(c) return c:IsRace(RACE_DIVINE) and c:IsAbleToGrave() end,tp,LOCATION_DECK,0,nil)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local tg=g:Select(tp,1,1,nil)
            Duel.SendtoGrave(tg,REASON_EFFECT)
        end
    end
end
