-- Hati of the Nordic Beasts
local s,id=GetID()
function s.initial_effect(c)
    -- Buscar "Fenrir the Nordic Wolf" o "Nordic Beast"
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.spcon)
    c:RegisterEffect(e2)

    -- Invocar 1 "Nordic Beast Token"
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)

    -- Efectos en el Cementerio
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_POSITION+CATEGORY_CONTROL)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetCountLimit(1,{id,2})
    e4:SetCost(aux.bfgcost)
    e4:SetTarget(s.gytg)
    e4:SetOperation(s.gyop)
    c:RegisterEffect(e4)
end

-- **Buscar "Fenrir the Nordic Wolf" o "Nordic Beast"**
function s.thfilter(c)
    return (c:IsCode(100000098) or c:IsSetCard(0x42)) and c:IsAbleToHand() -- Fenrir o Nordic Beast
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
    if tc then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return re and re:GetHandler():IsSetCard(0x42)
end

-- **Invocar 1 "Nordic Beast Token"**
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1000) end
    Duel.PayLPCost(tp,1000)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,100000099,0,TYPES_TOKEN,0,0,3,RACE_BEAST,ATTRIBUTE_EARTH) end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local token=Duel.CreateToken(tp,100000099)
    Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end

-- **Efectos desde el Cementerio**
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    local op=0
    if chk==0 then return true end
    if Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) then
        op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    else
        op=1
    end
    e:SetLabel(op)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    if op==0 then
        local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
        if #g>0 then
            Duel.ChangePosition(g,POS_FACEUP_ATTACK)
        end
    else
        local g=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
        if #g>0 then
            Duel.SwapControl(g,tp)
        end
    end
end
