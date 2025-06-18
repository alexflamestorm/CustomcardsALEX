--Earthbound Altar
local s,id=GetID()
function s.initial_effect(c)
    -- Activate: Activate 1 Earthbound Field Spell and add 1 Earthbound card
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Rule change: only 1 Earthbound Immortal with the same name
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SUMMON)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(1,1)
    e2:SetTarget(s.sumlimit)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    c:RegisterEffect(e3)

    -- Token + Extra Normal Summon
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOKEN+CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.tktg)
    e4:SetOperation(s.tkop)
    c:RegisterEffect(e4)
end

-- Activation effect
function s.fieldfilter(c)
    return c:IsType(TYPE_FIELD) and c:IsSetCard(0x21) and c:CheckActivateEffect(false,true,false)~=nil
end
function s.addfilter(c)
    return (c:IsSetCard(0x21) or aux.Stringid(0x21,0)) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Activate Field Spell
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,s.fieldfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_FZONE,POS_FACEUP,true)
        local te=g:GetFirst():GetActivateEffect()
        if te then
            te:UseCountLimit(tp,1,true)
            local tpe=te:GetType()
            local co=te:GetCost()
            if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
            local tg=te:GetTarget()
            if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
            Duel.BreakEffect()
            local op=te:GetOperation()
            if op then op(te,tp,eg,ep,ev,re,r,rp) end
        end
    end
    -- Add card
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #sg>0 then
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
    end
end

-- Rule Limit: only 1 face-up Earthbound Immortal with the same name
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
    return c:IsFaceup() and c:IsSetCard(0x21) and c:IsCodeListed(61557074) and Duel.IsExistingMatchingCard(function(tc)
        return tc:IsFaceup() and tc:IsSetCard(0x21) and tc:IsCodeListed(61557074) and not tc:IsCode(c:GetCode())
    end,c:GetControler(),LOCATION_MZONE,0,1,nil)
end

-- Token Summon + Extra Normal Summon
s.listed_names=(82340057) --Cerimonial Token
s.listed_series=(SET_EARTHBOUND_IMMORTAL)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
            and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_ROCK,ATTRIBUTE_EARTH)
            and Duel.IsExistingMatchingCard(function(c) return c:IsSetCard(0x21) and c:IsType(TYPE_MONSTER) end,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
    for i=1,2 do
        local token=Duel.CreateToken(tp,id+1)
        Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
    end
    Duel.SpecialSummonComplete()

    -- Extra Normal Summon
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
    e1:SetTarget(function(e,c) return c:IsSetCard(0x21) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
