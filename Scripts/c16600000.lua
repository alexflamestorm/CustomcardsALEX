-- Nordic Relic Andvaranaut
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon 1 "Aesir" Synchro Monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Destroy 1 card if you control an "Aesir" monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE+LOCATION_SZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.descon)
    e2:SetCost(aux.bfgcost) -- Banish this card as cost
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

-- Condition: You must control no "Aesir" monsters
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x42),tp,LOCATION_MZONE,0,1,nil)
end

-- Filter for "Nordic" and "Aesir" monsters that can be banished
function s.rmfilter(c)
    return c:IsAbleToRemove() and c:IsMonster() and (c:IsSetCard(0x42) or c:IsSetCard(0x4b))
end

-- Targeting for Special Summon effect
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
        return g:GetClassCount(Card.GetLevel)>=2 and Duel.IsExistingMatchingCard(s.aesirfilter,tp,LOCATION_EXTRA,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_MZONE+LOCATION_GRAVE)
end

-- Function to filter "Aesir" Synchro Monsters
function s.aesirfilter(c)
    return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x42) and c:IsSummonableCard()
end

-- Special Summon operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    if g:GetClassCount(Card.GetLevel)<2 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local rg=g:SelectSubGroup(tp,aux.CheckSumEqual, false, 2, 3, 10) -- Adjust Level Sum Here
    if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
        local lv=rg:GetSum(Card.GetLevel)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sc=Duel.SelectMatchingCard(tp,s.aesirfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
        if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
            sc:CompleteProcedure()
            -- Send to GY at End Phase
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EVENT_PHASE+PHASE_END)
            e1:SetCountLimit(1)
            e1:SetOperation(function() Duel.SendtoGrave(sc,REASON_EFFECT) end)
            Duel.RegisterEffect(e1,tp)
        end
    end
end

-- Condition: If you control an "Aesir" monster
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x42),tp,LOCATION_MZONE,0,1,nil)
end

-- Targeting for Destruction effect
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- Destroy target
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end

