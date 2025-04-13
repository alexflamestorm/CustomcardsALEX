-- Rainbow Crystal Beast Cobalt Eagle
local s,id=GetID()
function s.initial_effect(c)
    -- Invocación especial si controlas una "Crystal" Spell/Trap
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- Convertirse en Continuous Spell en lugar de ser destruido
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_SEND_REPLACE)
    e2:SetTarget(s.reptg)
    c:RegisterEffect(e2)

    -- Agregar "Rainbow Bridge" al ser Invocado
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.srtg)
    e3:SetOperation(s.srop)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)

    -- Enviar como Continuous Spell al GY para Invocar un "Crystal Beast" no WIND
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_SZONE)
    e5:SetCountLimit(1,id+1)
    e5:SetCondition(s.spcon2)
    e5:SetCost(s.spcost2)
    e5:SetTarget(s.sptg2)
    e5:SetOperation(s.spop2)
    c:RegisterEffect(e5)
end

-- **Condición de Invocación Especial**
function s.spcon(e,c)
    if c==nil then return true end
    return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x1034),c:GetControler(),LOCATION_SZONE,0,1,nil)
end

-- **Convertirse en Continuous Spell en vez de destruirse**
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    return true
end

-- **Buscar "Rainbow Bridge" al ser Invocado**
function s.srfilter(c)
    return c:IsCode(12644061) and c:IsAbleToHand()
end
function s.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.srfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.srop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstMatchingCard(s.srfilter,tp,LOCATION_DECK,0,nil)
    if tc then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    end
end

-- **Enviar como Continuous Spell al GY para Invocar un "Crystal Beast" no WIND**
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsType(TYPE_SPELL) and e:GetHandler():IsLocation(LOCATION_SZONE)
end
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x1034) and not c:IsAttribute(ATTRIBUTE_WIND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    if tc then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end
