-- Rainbow Crystal Beast Emerald Tortoise
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon si controlas una Crystal Spell/Trap
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- Convertirse en Continuous Spell en vez de destruirse
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_SEND_REPLACE)
    e2:SetTarget(s.reptg)
    c:RegisterEffect(e2)

    -- Cambiar un monstruo a Defensa y buscar 1 Crystal Beast del mismo Atributo
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_POSITION+CATEGORY_SEARCH+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.postg)
    e3:SetOperation(s.posop)
    c:RegisterEffect(e3)

    -- Enviar este como Continuous Spell para Invocar un "Crystal Beast" no-WATER
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,id+1)
    e4:SetCost(s.spcost)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

-- **Special Summon si controlas una "Crystal" Spell/Trap**
function s.spfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.spcon(e,c)
    if c==nil then return true end
    return Duel.IsExistingMatchingCard(s.spfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end

-- **Convertirse en Continuous Spell en vez de destruirse**
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    return true
end

-- **Cambiar un monstruo a Defensa y buscar 1 Crystal Beast del mismo Atributo**
function s.posfilter(c)
    return c:IsFaceup() and c:IsCanChangePosition() and not c:IsPosition(POS_DEFENSE)
end
function s.thfilter(c,att)
    return c:IsSetCard(0x1034) and c:IsAttribute(att) and c:IsAbleToHand()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,LOCATION_MZONE)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local tc=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    if tc and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)~=0 then
        local att=tc:GetAttribute()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,att):GetFirst()
        if sc then
            Duel.SendtoHand(sc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sc)
        end
    end
end

-- **Enviar este como Continuous Spell para Invocar un "Crystal Beast" no-WATER**
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x1034) and not c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_SZONE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_SZONE,0,1,1,nil,e,tp):GetFirst()
    if tc then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end
