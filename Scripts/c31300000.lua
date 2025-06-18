--Earthbound Prisoner Lizard Engraver
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon itself from hand if you control an "Earthbound" monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LVCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Copy activation effect of Harmonic Synchro Fusion or related Spell/Trap in GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.copycon)
    e2:SetTarget(s.copytg)
    e2:SetOperation(s.copyop)
    c:RegisterEffect(e2)
end

-- e1: Special Summon from hand if control "Earthbound" monster
function s.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x21) -- Earthbound archetype
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.lvfilter(c)
    return c:IsFaceup() and c:GetLevel()>2
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
            and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) 
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local g=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
        local tc=g:GetFirst()
        if tc then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_LEVEL)
            e1:SetValue(-2)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
            tc:RegisterEffect(e1)
        end
    end
end

-- e2: Copy effect from GY Spell/Trap
function s.copycon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.copyfilter(c)
    return (c:IsCode(07473735) or (c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.IsCodeListed(c,07473735)))
        and c:IsAbleToRemoveAsCost() and c:CheckActivateEffect(false,true,false)~=nil
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.copyfilter,tp,LOCATION_GRAVE,0,1,nil) 
    end
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local tc=Duel.SelectMatchingCard(tp,s.copyfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
    if tc then
        local te=tc:CheckActivateEffect(false,true,true)
        if te then
            Duel.Remove(tc,POS_FACEUP,REASON_COST)
            local tg=te:GetTarget()
            if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
            Duel.BreakEffect()
            local op=te:GetOperation()
            if op then op(e,tp,eg,ep,ev,re,r,rp) end
        end
    end
end
