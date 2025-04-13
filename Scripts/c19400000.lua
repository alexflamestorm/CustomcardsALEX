-- Darklord's Forbidden Chalice
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon from Deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- GY Effect when targeted by "Darklord" effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.gycon)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
end

-- FILTERS
function s.spfilter(c,e,tp,lvlist)
    return c:IsSetCard(0xef) and c:IsType(TYPE_MONSTER) and not lvlist[c:GetLevel()]
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- TARGET: Special Summon
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local lvlist={}
    for _,loc in ipairs({LOCATION_GRAVE,LOCATION_MZONE}) do
        local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,loc,0,nil)
        for tc in aux.Next(g) do
            lvlist[tc:GetLevel()]=true
        end
    end
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,lvlist)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- OP: Special Summon & modify ATK + Protection
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local lvlist={}
    for _,loc in ipairs({LOCATION_GRAVE,LOCATION_MZONE}) do
        local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,loc,0,nil)
        for tc in aux.Next(g) do
            lvlist[tc:GetLevel()]=true
        end
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lvlist)
    local tc=g:GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
        -- Set ATK 0
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(0)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        -- Cannot be targeted
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        e2:SetRange(LOCATION_MZONE)
        e2:SetValue(aux.tgoval)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e2)
    end
end

-- GY effect: Triggered when targeted by "Darklord" monster effect
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and re:IsActiveType(TYPE_MONSTER)
        and rc:IsSetCard(0xef) and re:GetHandlerPlayer()==tp
        and aux.GetChainInfo(ev,CHAININFO_TARGET_CARDS):IsContains(e:GetHandler())
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
    Duel.BreakEffect()
    local dc=Duel.GetOperatedGroup():GetFirst()
    Duel.ConfirmCards(1-tp,dc)
    if dc:IsSetCard(0xef) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.SendtoGrave(dc,REASON_EFFECT+REASON_DISCARD)
        Duel.Recover(tp,1000,REASON_EFFECT)
    end
end
