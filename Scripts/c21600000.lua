-- Archfiend Alternative Black Skull Dragon
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2)

    -- Take control of lower DEF monster
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_CONTROL+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,{id,1})
    e1:SetCondition(s.concon)
    e1:SetTarget(s.contg)
    e1:SetOperation(s.conop)
    c:RegisterEffect(e1)

    -- Special Summon from GY by banishing Red-Eyes Fusion
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,2})
    e2:SetCondition(function(_,tp) return Duel.IsMainPhase() end)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- Fusion Material filters
function s.matfilter1(c)
    return c:IsLevel(7) and c:IsSetCard(0x3b)
end
function s.matfilter2(c)
    return c:IsSetCard(0x45) -- "Archfiend"
end

-- Condition: was summoned by Fusion using Alternative or via own effect
function s.concon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_FUSION) and c:GetMaterial():IsExists(function(c) return c:IsCode(76922029) end,1,nil)
        or re and re:GetHandler()==c
end

-- Control target with lower DEF
function s.confilter(c,e,tp,atk)
    return c:IsControler(1-tp) and c:IsFaceup() and c:IsDefenseBelow(atk) and c:IsAbleToChangeControler()
end
function s.contg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local atk=e:GetHandler():GetAttack()
    if chkc then return s.confilter(chkc,e,tp,atk) end
    if chk==0 then return Duel.IsExistingTarget(s.confilter,tp,0,LOCATION_MZONE,1,nil,e,tp,atk) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g=Duel.SelectTarget(tp,s.confilter,tp,0,LOCATION_MZONE,1,1,nil,e,tp,atk)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.conop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp) then
        local atk=tc:GetAttack()
        Duel.Damage(1-tp,atk,REASON_EFFECT)
        -- Destroy it during End Phase
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        e1:SetOperation(function() Duel.Destroy(tc,REASON_EFFECT) end)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

-- GY revive cost
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.fucfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.fucfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.fucfilter(c)
    return c:IsCode(6172122) and c:IsAbleToRemoveAsCost()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

