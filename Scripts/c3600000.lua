--Dragon Destruction Swordstress
local s,id=GetID()
function s.initial_effect(c)
    --All monsters in its column and adjacent columns become Dragons
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_RACE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e1:SetTarget(s.racetg)
    e1:SetValue(RACE_DRAGON)
    c:RegisterEffect(e1)

    --Special Summon from hand or GY by banishing 2 Dragons
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    --Destroy 1 Dragon on Summon and gain ATK
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)

    --GY Effect: Turn all monsters in GY into Dragons until the end of the next turn
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1,{id,2})
    e4:SetCondition(s.gycon)
    e4:SetOperation(s.gyop)
    c:RegisterEffect(e4)
end

--All monsters in this card's column and adjacent columns become Dragons
function s.racetg(e,c)
    local seq=e:GetHandler():GetSequence()
    local cseq=c:GetSequence()
    return c:IsLocation(LOCATION_MZONE) and (cseq==seq or cseq==seq+1 or cseq==seq-1)
end

--Cost: Banish 2 Dragon monsters from either GY
function s.costfilter(c)
    return c:IsRace(RACE_DRAGON) and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,nil) end
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,2,2,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

--Special Summon this card
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

--Target and destroy 1 Dragon monster, then gain ATK
function s.desfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and s.desfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
        local atk=tc:GetBaseAttack()//2
        if atk>0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            e:GetHandler():RegisterEffect(e1)
        end
    end
end

--Condition: If sent to GY as cost for "Destruction Sword" effect or destroyed on field
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return (r&REASON_DESTROY)~=0 or (re and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:IsSetCard(SET_DESTRUCTION_SWORD))
end

--All monsters in GY become Dragons until the end of the next turn
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_RACE)
    e1:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
    e1:SetValue(RACE_DRAGON)
    e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
    Duel.RegisterEffect(e1,tp)
end
