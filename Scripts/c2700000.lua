--Blackwing Tamer - Darkrage Falcon Black
local s,id=GetID()
function s.initial_effect(c)
    --Synchro Summon
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_BLACKWING),1,1,Synchro.NonTuner(nil),1,99)

    -- Special Summon Blackwing monsters
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Special Summon Synchro Blackwing monster
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.synchrotg)
    e2:SetOperation(s.synchroop)
    c:RegisterEffect(e2)
end

-- Condition to activate (ensures opponent has at least 2 cards)
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND+LOCATION_ONFIELD,0)>=2
end

-- Special Summon Blackwing monsters
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local gct=math.floor(Duel.GetFieldGroupCount(1-tp,LOCATION_HAND+LOCATION_ONFIELD,0)/2)
    if chk==0 then return gct>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,gct,tp,LOCATION_DECK)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_BLACKWING) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local gct=math.floor(Duel.GetFieldGroupCount(1-tp,LOCATION_HAND+LOCATION_ONFIELD,0)/2)
    if gct<=0 then return end
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
    if #g>=gct then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,gct,gct,nil)
        for tc in aux.Next(sg) do
            Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
        end
        Duel.SpecialSummonComplete()
    end
end

-- Quick Effect to Synchro Summon a Blackwing Synchro
function s.synchrotg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.synchrofilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.synchrofilter(c,e,tp)
    return (c:IsCode(69031175) or c:IsCode(100000004) or c:IsCode(100000005)) -- IDs de "Black-Winged Dragon", "Black-Winged Assault Dragon" y "Blackfeather Darkrage Dragon"
        and c:IsSynchroSummonable(nil)
end
function s.synchroop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.synchrofilter,tp,LOCATION_EXTRA,0,nil,e,tp)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        Duel.SynchroSummon(tp,sg:GetFirst(),nil)
    end
end