-- Gazelle Ruler of the Phantom Beasts
local s,id=GetID()
function s.initial_effect(c)
    -- This card is always treated as "Gazelle the King of Mythical Beasts"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_ADD_CODE)
    e0:SetValue(51828629) -- Original "Gazelle the King of Mythical Beasts" ID
    c:RegisterEffect(e0)

    -- Battle Indestructible & No Battle Damage
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Add 1 "Chimera" support card on Summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
    local e3b=e3:Clone()
    e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3b)

    -- GY Quick Effect Protection
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCategory(CATEGORY_DISABLE)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1,{id,1})
    e4:SetCost(aux.bfgcost)
    e4:SetTarget(s.prottg)
    e4:SetOperation(s.protop)
    c:RegisterEffect(e4)
end

-- Search "Chimera" or "Chimera Fusion"
function s.thfilter(c)
    return c:IsAbleToHand() and (c:ListsCode(04796100) or c:ListsCode(100000170)) -- Chimera the Flying Mythical Beast / Chimera Fusion
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Protection from GY
function s.prottg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then 
        return Duel.IsExistingTarget(s.protfilter,tp,LOCATION_MZONE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.protfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.protfilter(c)
    return c:IsFaceup() and (c:IsRace(RACE_BEAST) or c:IsRace(RACE_BEASTWARRIOR) or c:IsRace(RACE_FIEND) or c:IsType(TYPE_ILLUSION))
end
function s.protop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_CANNOT_REMOVE)
        tc:RegisterEffect(e2)
    end
end
