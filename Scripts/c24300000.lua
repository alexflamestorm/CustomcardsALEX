-- Sphinx Enigma
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon proc
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Pay 500 LP; gain 3000 ATK
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)

    -- End Phase search
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+100)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)

    -- GY effect: Pyramid of Light gets banish effect
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_ADD_CODE)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetTargetRange(LOCATION_SZONE,0)
    e4:SetTarget(s.potarget)
    e4:SetValue(s.pyramid_effect)
    c:RegisterEffect(e4)
end

-- Filter for Sphinx cards with different names
function s.spfilter(c,code)
    return c:IsSetCard(0x208) and not c:IsCode(code) and c:IsAbleToGrave()
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK,0,nil,0x208)
    return g:GetClassCount(Card.GetCode)>=2
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK,0,nil,0x208)
    local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_TOGRAVE)
    if #sg>0 then
        Duel.SendtoGrave(sg,REASON_COST)
    end
end

-- Gain 3000 ATK
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.CheckLPCost(tp,500) then
        Duel.PayLPCost(tp,500)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(3000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end

-- Search effect
function s.thfilter(c)
    return (c:IsSetCard(0x208) and not c:IsCode(id)) or c:IsCode(53569894) and c:IsAbleToHand() -- Pyramid of Light
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- GY Aura effect for Pyramid of Light
function s.potarget(e,c)
    return c:IsCode(53569894) -- Pyramid of Light
end

function s.pyramid_effect(e,tp,eg,ep,ev,re,r,rp)
    -- Only usable once per turn handled on actual activation script
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    local attr=nil
    for tc in aux.Next(g) do
        if attr==nil then
            attr=tc:GetAttribute()
        elseif attr~=tc:GetAttribute() then
            return
        end
    end
    -- All same Attribute
    Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end
