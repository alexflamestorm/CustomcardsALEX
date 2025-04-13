--Flamathmech Circle-Power
local s,id=GetID()
function s.initial_effect(c)
 -- Synchro Summon
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_TUNER),1,1,Synchro.NonTuner(nil),1,99)

    -- Quick Effect durante el turno del oponente
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e1:SetCondition(s.atkcon)
    e1:SetTarget(s.atktg)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)

    -- Buscar 1 "Mathmech" cuando es destruido
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

-- Condición para activar en el turno del oponente
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsTurnPlayer(1-tp)
end

-- Seleccionar una carta en la misma columna que un "Mathmech"
function s.filter(c,tp)
    return c:IsOnField() and c:IsControler(1-tp) and Duel.IsExistingMatchingCard(s.mathmechfilter,tp,LOCATION_ONFIELD,0,1,nil,c:GetColumnGroup())
end
function s.mathmechfilter(c,colgroup)
    return c:IsSetCard(0x12f) and c:IsOnField() and colgroup:IsContains(c)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_ONFIELD,1,nil,tp) end
end

-- Aumentar ATK y negar efectos en zonas afectadas
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
    if #g==0 then return end
    local tc=g:GetFirst()

    -- Encontrar el "Mathmech" en la misma columna
    local mg=Duel.GetMatchingGroup(s.mathmechfilter,tp,LOCATION_ONFIELD,0,nil,tc:GetColumnGroup())
    if #mg==0 then return end
    local mc=mg:GetFirst()

    -- Calcular cantidad de zonas entre ellos
    local zones_between=math.abs(tc:GetSequence()-mc:GetSequence())
    if tc:IsLocation(LOCATION_SZONE) then zones_between=zones_between+1 end
    if mc:IsLocation(LOCATION_SZONE) then zones_between=zones_between+1 end

    -- Aumentar ATK
    if c:IsRelateToEffect(e) and zones_between>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(zones_between*300)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end

    -- Negar efectos en las zonas intermedias
    local disable_group=Duel.GetMatchingGroup(s.zonefilter,tp,0,LOCATION_ONFIELD,nil,mc:GetSequence(),tc:GetSequence())
    for dc in aux.Next(disable_group) do
        Duel.NegateRelatedChain(dc,RESET_TURN_SET)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        dc:RegisterEffect(e2)
        local e3=e2:Clone()
        e3:SetCode(EFFECT_DISABLE_EFFECT)
        dc:RegisterEffect(e3)
    end
end

-- Buscar un "Mathmech" si es destruido
function s.thfilter(c)
    return c:IsSetCard(0x12f) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Encuentra cartas en zonas entre dos posiciones
function s.zonefilter(c,seq1,seq2)
    local pos=c:GetSequence()
    return pos>math.min(seq1,seq2) and pos<math.max(seq1,seq2)
end


