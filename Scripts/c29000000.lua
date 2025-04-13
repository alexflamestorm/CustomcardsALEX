--Arms of Genex Reset
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Synchro Summon procedure
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_TUNER),1,1,aux.FilterBoolFunction(Card.IsType,TYPE_MONSTER),1,99,s.matfilter,aux.NonTuner(nil),1,1)
    
    -- Special Summon limit
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetValue(s.splimit)
    c:RegisterEffect(e0)

    -- Send 1 Genex to GY, then add Genex Controller
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)

    -- Destroy in battle if matching Attribute
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DAMAGE_STEP_START)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

-- Extra Synchro material from banished zone
function s.matfilter(c,scard,sumtype,tp)
    return c:IsSetCard(0x2) and c:IsLocation(LOCATION_REMOVED)
end

function s.splimit(e,se,sp,st)
    return e:GetHandler():GetFlagEffect(id)==0
end

-- Send 1 Genex to GY and add Genex Controller
function s.tgfilter(c)
    return c:IsSetCard(0x2) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
            and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,68505803)
    end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
        local gc=Duel.GetFirstMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,nil,68505803)
        if gc then
            Duel.SendtoHand(gc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,gc)
        end
    end
end

-- Condition: If your Genex battles and opp has same Attribute in your GY
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    if not d then return false end
    if a:IsControler(1-tp) then a,d=d,a end
    return a:IsSetCard(0x2) and d:IsControler(1-tp) and Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,d:GetAttribute())
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttackTarget(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local d=Duel.GetAttackTarget()
    if d and d:IsRelateToBattle() then
        Duel.Destroy(d,REASON_EFFECT)
    end
end
