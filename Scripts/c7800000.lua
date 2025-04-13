--Archfiend Skull Master of Apocalypse
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Ritual Summon usando "Contract with the Abyss" o cualquier efecto "Archfiend"
    local e1=aux.AddRitualProcEqual(c,aux.FilterBoolFunction(Card.IsCode,100000054),nil,aux.Stringid(id,0))

    -- Se trata como "Summoned Skull" y "Archfiend"
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_ADD_CODE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetValue(70781052) -- Código de "Summoned Skull"
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_ADD_SETCODE)
    e3:SetValue(SET_ARCHFIEND)
    c:RegisterEffect(e3)

    -- Devolver cartas del oponente a la mano
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1,id)
    e4:SetTarget(s.rthtg)
    e4:SetOperation(s.rthop)
    c:RegisterEffect(e4)

    -- Invocar Especialmente cuando un Ritual es enviado al Cementerio
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_TO_GRAVE)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCountLimit(1,{id,1})
    e5:SetCondition(s.spcon)
    e5:SetTarget(s.sptg)
    e5:SetOperation(s.spop)
    c:RegisterEffect(e5)
end

-- **Devolver cartas del oponente a la mano dependiendo de la cantidad de cartas "Archfiend"**
function s.rthfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_ARCHFIEND)
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetMatchingGroupCount(s.rthfilter,tp,LOCATION_ONFIELD,0,nil)
    if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,ct,1-tp,LOCATION_ONFIELD)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetMatchingGroupCount(s.rthfilter,tp,LOCATION_ONFIELD,0,nil)
    if ct>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,ct,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
        end
    end
end

-- **Condición para invocar si un Ritual se envía al Cementerio**
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsPreviousControler(tp) 
        and e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.spfilter(c,e,tp)
    return c:IsMonster() and (c:ListsCode(70781052) or c:ListsSet(SET_ARCHFIEND)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        -- El monstruo invocado no puede atacar
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetDescription(3206)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_ATTACK)
        e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        g:GetFirst():RegisterEffect(e1)
    end
end
