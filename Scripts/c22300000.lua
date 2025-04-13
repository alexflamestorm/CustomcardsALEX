-- Meteor Alternative Black Dragon
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,s.fusmatfilter1,s.fusmatfilter2)

    -- (Quick Effect) Equip from GY and destroy
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP+CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)

    -- Effect on sent to GY if Alternative was used
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- Fusion Materials
function s.fusmatfilter1(c,fc,sumtype,tp)
    return c:IsSetCard(0x3b) and c:IsLevel(7)
end
function s.fusmatfilter2(c,fc,sumtype,tp)
    return c:IsRace(RACE_DRAGON) and c:IsDefense(2000)
end

-- (Quick) Equip GY + Destroy + Burn
function s.eqfilter(c)
    return c:IsSetCard(0x3b) and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget()
end
function s.destfilter(c,atk)
    return c:IsFaceup() and c:IsAttackBelow(atk)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    e:SetLabelObject(g:GetFirst())
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=e:GetLabelObject()
    if not tc or not tc:IsRelateToEffect(e) or not c:IsRelateToEffect(e) then return end
    local atk=tc:GetAttack()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,s.destfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
    if #dg>0 and Duel.Destroy(dg,REASON_EFFECT)>0 then
        if Duel.Equip(tp,tc,c) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_EQUIP)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(600)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            Duel.Damage(1-tp,600,REASON_EFFECT)
        end
    end
end

-- Condition for GY effect
function s.matfilter(c)
    return c:IsCode(74677422) or c:IsName("Red-Eyes Alternative Black Dragon")
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetMaterial():IsExists(s.matfilter,1,nil)
end

-- Special Summon from Deck + Destroy
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x3b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
    if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
        local atk=sc:GetAttack()
        local g=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsAttackAbove(atk) end,tp,0,LOCATION_MZONE,nil)
        if #g>0 then
            Duel.Destroy(g,REASON_EFFECT)
        end
    end
end
