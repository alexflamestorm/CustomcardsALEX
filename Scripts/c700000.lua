-- Dark Flamvell Archfiend
local s,id=GetID()
function s.initial_effect(c)
    -- Requisitos de Sincronía
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_PYRO),1,1,Synchro.NonTuner(Card.IsRace,RACE_PYRO),1,99)

    -- Quemar 300 LP por cada monstruo Pyro en el GY al ser Synchro Summoned
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,{id,1})
    e1:SetCondition(s.damcon)
    e1:SetTarget(s.damtg)
    e1:SetOperation(s.damop)
    c:RegisterEffect(e1)

    -- Banish hasta 3 cartas del Cementerio del oponente cuando active un efecto de monstruo
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,2})
    e2:SetCondition(s.rmcon)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)

    -- Mientras haya 3+ "Flamvell" en el GY, cualquier carta enviada desde el campo del oponente al GY es desterrada
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_TO_GRAVE_REDIRECT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0,LOCATION_ONFIELD)
    e3:SetCondition(s.bancon)
    e3:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e3)
end

-- 🔥 Efecto 1: Infligir daño al ser Synchro Summoned
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local ct=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_PYRO)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_PYRO)
    if ct>0 then
        Duel.Damage(1-tp,ct*300,REASON_EFFECT)
    end
end

-- 🔥 Efecto 2: Desterrar hasta 3 cartas del Cementerio del oponente si activa un efecto de monstruo
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsActiveType(TYPE_MONSTER) and re:GetHandlerPlayer()==1-tp
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local sg=g:Select(tp,1,3,nil)
        Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
    end
end

-- 🔥 Efecto 3: Mientras haya 3+ "Flamvell" en el GY, cartas del campo del oponente van al destierro en vez del GY
function s.bancon(e)
    return Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsSetCard,0x205),e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)>=3
end
