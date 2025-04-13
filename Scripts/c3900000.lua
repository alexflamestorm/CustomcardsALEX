--True Destruction Sword Flash
local s,id=GetID()
function s.initial_effect(c)
    --Banish cards in this and adjacent columns
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.rmcon)
    e1:SetTarget(s.rmtg)
    e1:SetOperation(s.rmop)
    c:RegisterEffect(e1)

    --Set from GY if "Buster Blader" is summoned
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.setcon)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
end

-- Check if the player controls a "Buster Blader" Fusion Monster
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsType,TYPE_FUSION),tp,LOCATION_MZONE,0,1,nil) 
        and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.ListsCode,78193831),tp,LOCATION_MZONE,0,1,nil)
end

-- Target all cards in this card's column and adjacent columns
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=Group.CreateGroup()
    for p=0,1 do
        for i=0,4 do
            local colgroup=Duel.GetMatchingGroup(Card.IsInColumn,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,i)
            g:Merge(colgroup)
        end
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*300)
end

-- Banish the cards and inflict damage
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g=Group.CreateGroup()
    for p=0,1 do
        for i=0,4 do
            local colgroup=Duel.GetMatchingGroup(Card.IsInColumn,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,i)
            g:Merge(colgroup)
        end
    end
    local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    if ct>0 then
        Duel.Damage(1-tp,ct*300,REASON_EFFECT)
    end
end

-- Check if a "Buster Blader" is summoned
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsCode,1,nil,78193831)
end

-- Target to set this card from the GY
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsSSetable() end
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end

-- Set this card, but banish it when it leaves the field
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SSet(tp,c)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1)
    end
end
