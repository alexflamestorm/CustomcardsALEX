-- Salamangreat Bomber Calupoh
local s,id=GetID()
function s.initial_effect(c)
    -- Fusion Summon procedure
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,s.ffilter1,s.ffilter2)
    Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)

    -- Add "Fusion of Fire" to hand
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- Destroy 1 monster
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DECKDES)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetCost(s.descost)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

-- Fusion Material Filters
function s.ffilter1(c,fc,sumtype,tp)
    return c:IsSetCard(0x119,fc,sumtype,tp)
end
function s.ffilter2(c,fc,sumtype,tp)
    return c:IsRace(RACE_CYBERSE,fc,sumtype,tp) and c:IsSummonLocation(LOCATION_EXTRA)
end

-- Contact Fusion (Alternative Summon Condition)
function s.contactfil(tp)
    return Duel.IsExistingMatchingCard(s.ffilter1,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.ffilter2,tp,LOCATION_MZONE,0,1,nil)
end
function s.contactop(g,tp)
    Duel.Release(g,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
    return e:GetHandler():IsLocation(LOCATION_EXTRA)
end

-- Condition: Special Summoned
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

-- Effect: Add "Fusion of Fire" from Deck/GY
function s.thfilter(c)
    return c:IsCode(4516625) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Cost: Send 1 "Salamangreat" card from Deck to GY
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,1,nil,0x119) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,1,1,nil,0x119)
    Duel.SendtoGrave(g,REASON_COST)
end

-- Target: Destroy 1 monster
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- Effect: Destroy monster(s)
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
    if #g==0 then return end

    if c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsPreviousLocation(LOCATION_MZONE) then
        -- If "Salamangreat Bomber Calupoh" was used as material, destroy all monsters
        Duel.Destroy(g,REASON_EFFECT)
    else
        -- Otherwise, destroy only 1
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local sg=g:Select(tp,1,1,nil)
        Duel.Destroy(sg,REASON_EFFECT)
    end
end

