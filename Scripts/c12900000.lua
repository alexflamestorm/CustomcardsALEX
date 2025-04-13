-- Rainbow Crystal Beast Sapphire Pegasus
local s,id=GetID()
function s.initial_effect(c)
    -- Convertirse en Continuous Spell en vez de destruirse
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EFFECT_SEND_REPLACE)
    e1:SetTarget(s.reptg)
    c:RegisterEffect(e1)

    -- Invocación Especial desde la mano
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- Enviar como Continuous Spell al GY para robar cartas
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(s.drcon)
    e3:SetCost(s.drcost)
    e3:SetTarget(s.drtg)
    e3:SetOperation(s.drop)
    c:RegisterEffect(e3)
end

-- **Convertirse en Continuous Spell en vez de destruirse**
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    return true
end

-- **Invocar Especial desde la mano**
function s.spfilter(c)
    return c:IsSetCard(0x1034) and not c:IsAttribute(ATTRIBUTE_WIND) and c:IsFaceup()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    if tc and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end

-- **Enviar como Continuous Spell al GY para robar**
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsType(TYPE_SPELL) and e:GetHandler():IsLocation(LOCATION_SZONE)
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.drfilter(c)
    return c:IsSetCard(0x1034) and (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED) or c:IsLocation(LOCATION_ONFIELD)) and c:IsFaceup()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.drfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    local count=math.floor(g:GetClassCount(Card.GetCode)/3)
    if chk==0 then return count>0 and Duel.IsPlayerCanDraw(tp,count) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,count)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.drfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    local count=math.floor(g:GetClassCount(Card.GetCode)/3)
    if count>0 then
        Duel.Draw(tp,count,REASON_EFFECT)
    end
end

