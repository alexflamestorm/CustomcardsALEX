--Volcanic Cartridge
local s,id=GetID()
function s.initial_effect(c)
    -- Destruir 1 Spell/Trap si es enviado al GY por "Blaze Accelerator"
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.descon)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- Activar 1 "Blaze Accelerator" desde la mano o Deck
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(aux.exccon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.acttg)
    e2:SetOperation(s.actop)
    c:RegisterEffect(e2)
end

-- **Condición: Fue enviado al GY por "Blaze Accelerator"**
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return re and re:GetHandler():IsSetCard(SET_BLAZE_ACCELERATOR)
end

-- **Target: Destruir 1 Spell/Trap**
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end

-- **Efecto: Destruir Spell/Trap**
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end

-- **Filtro para "Blaze Accelerator" Continuous**
function s.actfilter(c,tp)
    return c:IsSetCard(SET_BLAZE_ACCELERATOR) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsContinuousSpellTrap() and not c:IsForbidden()
end

-- **Target: Activar "Blaze Accelerator" desde el Deck**
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,tp) end
end

-- **Efecto: Activar "Blaze Accelerator" desde el Deck**
function s.actop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tp)
    if #g>0 then
        Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end
