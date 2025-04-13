-- Memento Bone Supply
local s,id=GetID()
function s.initial_effect(c)
    -- Redirect banish to GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_ONFIELD,0)
    e1:SetTarget(s.rmtg)
    e1:SetValue(LOCATION_GRAVE)
    c:RegisterEffect(e1)

    -- Draw 1 when Memento is sent to GY or banished
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.drcon)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    e2:SetCountLimit(1,id)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_REMOVE)
    c:RegisterEffect(e3)

    -- Negate opponent's Spell by destroying your own Memento Fusion
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,{id,1})
    e4:SetCondition(s.negcon)
    e4:SetTarget(s.negtg)
    e4:SetOperation(s.negop)
    c:RegisterEffect(e4)
end

function s.rmtg(e,c)
    return c:IsSetCard(0x1f49) and c:IsControler(e:GetHandlerPlayer()) and c:IsLocation(LOCATION_ONFIELD)
end

function s.cfilter(c,tp)
    return c:IsSetCard(0x1f49) and c:IsControler(tp) and (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED))
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Draw(tp,1,REASON_EFFECT)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return ep==1-tp and re:IsActiveType(TYPE_SPELL) and Duel.IsChainDisablable(ev)
        and not Duel.IsDamageCalculated()
end
function s.fusfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x1f49) and c:IsType(TYPE_FUSION) and c:IsDestructable()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_MZONE,0,1,1,nil)
    if #g>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
        Duel.NegateActivation(ev)
    end
end
