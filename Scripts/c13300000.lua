-- Crystal Beast Diamond Hippogriff
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Debe ser Invocado por Fusión o Tributando los materiales en el campo
    Fusion.AddProcMix(c,true,true,aux.FilterBoolFunction(Card.IsSetCard,0x1034),aux.FilterBoolFunction(Card.IsSetCard,0x1034))
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetValue(aux.fuslimit)
    c:RegisterEffect(e1)
    
    -- Special Summon por Tributo en lugar de Fusión
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.spcon)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- Colocar un monstruo en la Zona de Spell/Trap como Continuous Spell/Trap
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_LEAVE_GRAVE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.settg)
    e3:SetOperation(s.setop)
    c:RegisterEffect(e3)
end

-- **Condición para Special Summon mediante Tributo**
function s.spfilter(c,tp)
    return c:IsSetCard(0x1034) and c:IsReleasable()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL) and
           Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,2,nil,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_MZONE,0,2,2,nil,tp)
    if #g>0 then
        Duel.Release(g,REASON_COST)
    end
end

-- **Colocar un monstruo en la Zona de Spell/Trap como Continuous Spell/Trap**
function s.setfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil):GetFirst()
    if tc then
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end
