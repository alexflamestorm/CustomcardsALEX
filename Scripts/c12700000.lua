-- Rainbow Crystal Beast Amethyst Cat
local s,id=GetID()
function s.initial_effect(c)
    -- Colocarse en la Zona de Magias/Trampas si es destruido
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCondition(s.stzcon)
    e1:SetOperation(s.stzop)
    c:RegisterEffect(e1)

    -- Activar efecto de un "Crystal Beast" en la S/T Zone durante el turno del oponente
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.actcon)
    e2:SetTarget(s.acttg)
    e2:SetOperation(s.actop)
    c:RegisterEffect(e2)

    -- Enviar 2 "Crystal Beast" no-EARTH al Cementerio
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCost(s.tgcost)
    e3:SetTarget(s.tgtg)
    e3:SetOperation(s.tgop)
    c:RegisterEffect(e3)
end

-- **Colocarse en la Zona de Magias/Trampas si es destruido**
function s.stzcon(e)
    local c=e:GetHandler()
    return c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.stzop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        c:SetCardData(CARDDATA_TYPE,TYPE_SPELL+TYPE_CONTINUOUS)
    end
end

-- **Activar efecto de un "Crystal Beast" en la S/T Zone en el turno del oponente**
function s.cbfilter(c)
    return c:IsSetCard(0x1034) and c:IsType(TYPE_SPELL) and c:IsAbleToGrave() and c:CheckActivateEffect(false,true,false)~=nil
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsTurnPlayer(1-tp)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cbfilter,tp,LOCATION_SZONE,0,1,nil) end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local tc=Duel.SelectMatchingCard(tp,s.cbfilter,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if tc then
        local te,eg,ep,ev,re,r,rp=tc:CheckActivateEffect(false,true,true)
        Duel.SendtoGrave(tc,REASON_EFFECT)
        if te then
            Duel.BreakEffect()
            te:UseCountLimit(tp,1)
            local op=te:GetOperation()
            if op then
                op(te,tp,eg,ep,ev,re,r,rp)
            end
        end
    end
end

-- **Enviar 2 "Crystal Beast" no-EARTH al Cementerio**
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.tgfilter(c)
    return c:IsSetCard(0x1034) and not c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,2,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,2,2,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

