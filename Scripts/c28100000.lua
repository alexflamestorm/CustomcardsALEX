--Arrival of the Skull Archfiends
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Filters
function s.atkdefmatch(c)
    return c:IsMonster() and ((c:GetAttack()==2500 and c:GetDefense()==1200) or c:GetAttack()==2500 or c:GetDefense()==1200)
end
function s.fiendfilter(c)
    return c:IsRace(RACE_FIEND) and s.atkdefmatch(c) and c:IsAbleToHand()
end
function s.archfiendfilter(c)
    return c:IsRace(RACE_FIEND) and c:IsSetCard(0x23) and s.atkdefmatch(c) and c:IsAbleToHand()
end
function s.skullfilter(c)
    return c:IsCode(70781052) or c:IsName("Summoned Skull")
end
function s.ssfilter(c)
    return s.atkdefmatch(c) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
end

-- Target
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

-- Operation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local b1=Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) 
        and Duel.IsExistingMatchingCard(s.fiendfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
        and Duel.IsExistingMatchingCard(s.archfiendfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)

    local b2=Duel.IsExistingMatchingCard(s.skullfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
        and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil)

    if not (b1 or b2) then return end
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,
            aux.Stringid(id,0), -- Search
            aux.Stringid(id,1)) -- Summon
    elseif b1 then
        Duel.SelectOption(tp,aux.Stringid(id,0))
        op=0
    else
        Duel.SelectOption(tp,aux.Stringid(id,1))
        op=1
    end

    if op==0 then
        -- Search
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local costCard=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler()):GetFirst()
        if Duel.SendtoGrave(costCard,REASON_COST)~=0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g1=Duel.SelectMatchingCard(tp,s.fiendfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g2=Duel.SelectMatchingCard(tp,s.archfiendfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,g1:GetFirst())
            g1:Merge(g2)
            if #g1>0 then
                Duel.SendtoHand(g1,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g1)
            end
        end
    else
        -- Special Summon
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
        local sc=Duel.SelectMatchingCard(tp,s.skullfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil):GetFirst()
        if sc then
            Duel.ConfirmCards(1-tp,sc)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
            if sc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and sg:GetCount()>0 then
                Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
                Duel.SpecialSummonStep(sg:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
                Duel.SpecialSummonComplete()
            end
        end
    end
end
