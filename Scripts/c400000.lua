-- Neo Flamvell Uruquizas
-- ID: 400000

function c400000.initial_effect(c)
    -- Special Summon from GY if opponent takes effect damage
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(400000,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_DAMAGE)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1,400000)
    e1:SetCondition(c400000.spcon)
    e1:SetTarget(c400000.sptg)
    e1:SetOperation(c400000.spop)
    c:RegisterEffect(e1)

    -- Banish opponent's monsters from GY and deal damage
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(400000,1))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(c400000.rmtg)
    e2:SetOperation(c400000.rmop)
    c:RegisterEffect(e2)

    -- Piercing Battle Damage
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e3)
end

-- Condition for Special Summon
function c400000.spcon(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp and (r&REASON_EFFECT)~=0
end

-- Target for Special Summon
function c400000.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- Special Summon Operation
function c400000.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- Target for Banishing and Damage
function c400000.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_GRAVE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,1-tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,200)
end

-- Banish and Inflict Damage
function c400000.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_GRAVE,nil)
    if #g>0 then
        local sg=g:Select(tp,1,2,nil)
        Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
        local ct=#sg
        Duel.Damage(1-tp,ct*200,REASON_EFFECT)
    end
end
