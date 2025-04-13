--Exodia Summon
local s,id=GetID()
function s.initial_effect(c)
    c:Activate()

    -- Se trata como "Exodd" y "Obliterate"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_ADD_SETCODE)
    e1:SetRange(LOCATION_FZONE+LOCATION_GRAVE+LOCATION_ONFIELD)
    e1:SetValue(0x203) -- "Exodd" y "Obliterate"
    c:RegisterEffect(e1)
    
    -- Activación: Enviar "Forbidden One" al GY o al tope del Deck
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
    
    -- Descartar para Invocar "Exodia" o "Forbidden One"
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
    
    -- Protección contra la destrucción por batalla o efecto
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EFFECT_SEND_REPLACE)
    e4:SetRange(LOCATION_SZONE)
    e4:SetTarget(s.reptg)
    e4:SetValue(s.repval)
    c:RegisterEffect(e4)
end

-- **Efecto al Activar: Buscar "Forbidden One"**  
function s.exodiafilter(c)
    return c:IsSetCard(0xde) and c:IsMonster()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.exodiafilter,tp,LOCATION_DECK,0,1,nil) end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
    local g=Duel.SelectMatchingCard(tp,s.exodiafilter,tp,LOCATION_DECK,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        local op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1)) -- 0: Enviar al GY, 1: Tope del Deck
        if op==0 then
            Duel.SendtoGrave(tc,REASON_EFFECT)
        else
            Duel.MoveSequence(tc,SEQ_DECKTOP)
        end
    end
end

-- **Efecto de Invocación Especial**  
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

function s.spfilter(c,e,tp)
    return (c:IsSetCard(0xde) or c:IsSetCard(0x40)) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc then
        Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
    end
end

-- **Protección: Regresar a la mano en lugar de al GY**  
function s.repfilter(c,tp)
    return (c:IsSetCard(0xde) or c:IsSetCard(0x40)) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
        and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) end
    return true
end

function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end

