--Heroic Challenger - Double Bolas (Custom)
local s,id=GetID()
function s.initial_effect(c)
    -- Allow use as Xyz material from hand
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_XYZ_MATERIAL)
    e1:SetRange(LOCATION_HAND)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.matfilter)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- Effect when detached
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.detcon)
    e2:SetTarget(s.dettg)
    e2:SetOperation(s.detop)
    c:RegisterEffect(e2)
end

function s.matfilter(e,c)
    return c:IsFaceup() and c:IsSetCard(0x6f) -- "Heroic" monsters
end

function s.detcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsReason(REASON_COST) and c:GetReasonCard() and c:GetReasonCard():IsType(TYPE_XYZ)
end

function s.dettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingTarget(aux.FilterFaceup(Card.IsMonster),tp,0,LOCATION_MZONE,1,nil)
            and Duel.IsExistingTarget(aux.FilterFaceup(Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0x6f)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g1=Duel.SelectTarget(tp,aux.FilterFaceup(Card.IsMonster),tp,0,LOCATION_MZONE,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g2=Duel.SelectTarget(tp,aux.FilterFaceup(Card.IsSetCard),tp,LOCATION_MZONE,0,1,1,nil,0x6f)
end

function s.detop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    local og=tg:Filter(Card.IsControler,nil,1-tp):GetFirst()
    local fg=tg:Filter(Card.IsControler,nil,tp):GetFirst()
    if og and fg and og:IsRelateToEffect(e) and fg:IsRelateToEffect(e) then
        -- Negate opponent's monster
        Duel.NegateRelatedChain(og,RESET_TURN_SET)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        og:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        og:RegisterEffect(e2)
        -- Double Heroic's ATK
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_UPDATE_ATTACK)
        e3:SetValue(fg:GetAttack())
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        fg:RegisterEffect(e3)
    end
end
