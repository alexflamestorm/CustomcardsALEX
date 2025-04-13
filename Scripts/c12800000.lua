-- Rainbow Crystal Beast Topaz Tiger
local s,id=GetID()
function s.initial_effect(c)
    -- Convertirse en Continuous Spell en vez de destruirse
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EFFECT_SEND_REPLACE)
    e1:SetTarget(s.reptg)
    c:RegisterEffect(e1)

    -- Recuperar "Crystal Beast" desterrado al ser Invocado
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.rbtg)
    e2:SetOperation(s.rbop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- Enviar como Continuous Spell al GY para Invocar hasta 2 "Crystal Beast" no EARTH
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,id+1)
    e4:SetCondition(s.spcon)
    e4:SetCost(s.spcost)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

-- **Convertirse en Continuous Spell en vez de destruirse**
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    return true
end

-- **Recuperar "Crystal Beast" desterrado**
function s.rbfilter(c)
    return c:IsSetCard(0x1034) and c:IsFaceup() and (c:IsAbleToHand() or c:IsSSetable())
end
function s.rbtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rbfilter,tp,LOCATION_REMOVED,0,1,nil) end
end
function s.rbop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
    local tc=Duel.SelectMatchingCard(tp,s.rbfilter,tp,LOCATION_REMOVED,0,1,1,nil):GetFirst()
    if tc then
        local opt=0
        if tc:IsAbleToHand() and tc:IsSSetable() then
            opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
        elseif tc:IsAbleToHand() then
            opt=0
        else
            opt=1
        end
        if opt==0 then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        else
            Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        end
    end
end

-- **Enviar como Continuous Spell al GY para Invocar hasta 2 "Crystal Beast" no EARTH**
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsType(TYPE_SPELL) and e:GetHandler():IsLocation(LOCATION_SZONE)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x1034) and not c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<=0 then return end
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,math.min(2,ft),nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
