-- Veda the Cubic Vessel
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon from hand if Vijam is on field or in GY
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- On Normal or Special Summon: Summon 1 Cubic that can be Normal Summoned/Set
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- If a card is banished from your field or GY: return it to hand
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_REMOVE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.thcon)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)
end

-- Vijam check
function s.vijamfilter(c)
    return c:IsCode(15610297) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.IsExistingMatchingCard(s.vijamfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end

-- Cubic summonable filter
function s.cubicfilter(c,e,tp)
    return c:IsSetCard(0xe3) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and aux.NecroValleyFilter(aux.FilterNormalSummonableMonster)(c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cubicfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.cubicfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
    end
end

-- Banished from field or GY
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsControler,1,nil,tp) and eg:IsExists(function(c) return c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_GRAVE) end,1,nil)
end
function s.thfilter(c,tp)
    return c:IsFaceup() and c:IsAbleToHand() and (c:IsControler(tp) and (c:IsPreviousLocation(LOCATION_ONFIELD) or c:IsPreviousLocation(LOCATION_GRAVE)))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=eg:Filter(s.thfilter,nil,tp)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(s.thfilter,nil,tp)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
    end
end
