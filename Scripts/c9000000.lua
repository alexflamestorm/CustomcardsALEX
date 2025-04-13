--Volcanic Ferocity
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon desde la mano
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- Banish para enviar "Volcanic" o "Blaze Accelerator" al GY
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.gycon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)
end

-- **Efecto 1: Invocación Especial desde la Mano**
function s.spcon(e,c)
    if c==nil then return true end
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_PYRO),c:GetControler(),LOCATION_MZONE,0,1,nil)
end

-- **Efecto 2: Enviar "Volcanic" o "Blaze Accelerator" al GY**
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x32),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.gyfilter(c)
    return (c:IsSetCard(0x32) or c:IsSetCard(0x37)) and c:IsAbleToGrave()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

