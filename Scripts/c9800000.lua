--Volcanic Round
local s,id=GetID()
function s.initial_effect(c)
    -- Buscar "Volcanic" cuando es enviado al GY
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
end

-- **Filtro para Pyro Monsters en el GY o Campo**
function s.rmfilter(c)
    return c:IsRace(RACE_PYRO) and c:IsAbleToRemove()
end

-- **Filtro para "Volcanic" con 500 o menos ATK**
function s.thfilter(c)
    return c:IsSetCard(SET_VOLCANIC) and c:IsAttackBelow(500) and c:IsAbleToHand()
end

-- **Target: Banish hasta 2 Pyro y buscar "Volcanic"**
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g1=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    local g2=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
    if chk==0 then return #g1>0 and #g2>0 end
    
    local ct=math.min(#g1,#g2,2)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local rg=g1:Select(tp,1,ct,nil)
    e:SetLabel(#rg)
    Duel.Remove(rg,POS_FACEUP,REASON_COST)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,#rg,tp,LOCATION_DECK)
end

-- **Efecto: Buscar "Volcanic"**
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetLabel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,ct,ct,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

