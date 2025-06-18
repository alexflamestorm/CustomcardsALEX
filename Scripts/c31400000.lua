--Earthbound Prisoner Chain Seal Breaker
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon from hand if Field Spell is on the field
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    --Trigger when destroyed: Special Summon from Deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

function s.spcon(e,c)
    if c==nil then return true end
    return Duel.IsExistingMatchingCard(Card.IsType,c:GetControler(),LOCATION_FZONE,LOCATION_FZONE,1,nil,TYPE_FIELD)
        and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_EFFECT+REASON_BATTLE)
end

function s.efilter(c,e,tp)
    return c:IsSetCard(0x21a) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end

function s.immfilter(c,e,tp)
    return c:IsSetCard(0x21) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(s.efilter,tp,LOCATION_DECK,0,1,nil,e,tp)
    local b2=Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil,TYPE_FIELD)
        and Duel.IsExistingMatchingCard(s.immfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
    if chk==0 then return b1 or b2 end
    local op=0
    if b1 and b2 then
        op=Duel.SelectEffect(tp,
            {b1,aux.Stringid(id,2)},
            {b2,aux.Stringid(id,3)})
    elseif b1 then
        op=1
    else
        op=2
    end
    e:SetLabel(op)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    if op==1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.efilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_DEFENSE)
        end
    elseif op==2 then
        local c=e:GetHandler()
        if not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil,TYPE_FIELD) then return end
        if Duel.Remove(c,POS_FACEUP,REASON_EFFECT)==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.immfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
        if #g>0 and Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)>0 then
            local tc=g:GetFirst()
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
        end
    end
end
