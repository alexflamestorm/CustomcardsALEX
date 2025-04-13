--Volcanic Ignition Beast
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon desde la mano o GY
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Ganar nombre y efecto de una Continuous Trap "Blaze Accelerator"
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.eftg)
    e2:SetOperation(s.efop)
    c:RegisterEffect(e2)
end

-- **Condición: Solo Quick Effect si "Tri-Blaze Accelerator" está en el campo**
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,21420702),tp,LOCATION_ONFIELD,0,1,nil) -- Tri-Blaze Accelerator
end

-- **Costo: Enviar 1 "Blaze Accelerator" que controles al GY**
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_ONFIELD,0,1,nil,SET_BLAZE_ACCELERATOR) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_ONFIELD,0,1,1,nil,SET_BLAZE_ACCELERATOR)
    Duel.SendtoGrave(g,REASON_COST)
end

-- **Target: Special Summon esta carta desde la mano o GY**
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- **Operación: Special Summon**
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- **Filtro para Continuous Trap "Blaze Accelerator" en el GY**
function s.effilter(c)
    return c:IsType(TYPE_TRAP) and c:IsSetCard(SET_BLAZE_ACCELERATOR) and c:IsContinuousSpellTrap()
end

-- **Target: Seleccionar una Continuous Trap "Blaze Accelerator" en el GY**
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.effilter,tp,LOCATION_GRAVE,0,1,nil) end
end

-- **Operación: Ganar el nombre y efectos de esa Continuous Trap**
function s.efop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectMatchingCard(tp,s.effilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
    if tc then
        -- Cambia el nombre de la carta
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetValue(tc:GetCode())
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
        -- Copia los efectos
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetCode(EFFECT_ADD_TYPE)
        e2:SetValue(TYPE_TRAP)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e2)
    end
end
