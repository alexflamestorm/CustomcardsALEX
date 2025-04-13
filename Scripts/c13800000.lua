-- Elemental HERO Burning Nova Master
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Debe ser Invocado por Fusión
    Fusion.AddProcMix(c,true,true,aux.FilterBoolFunction(Card.IsSetCard,0x8),aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE))

    -- Tratar su nombre como "Elemental HERO Nova Master" en el campo y GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e1:SetValue(29095552) -- ID de "Elemental HERO Nova Master"
    c:RegisterEffect(e1)

    -- Efecto al ser Invocado: Robar 1 carta y hacer daño
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DRAW+CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)

    -- Efecto al salir del campo: Destruir todas las Mágicas/Trampas del oponente
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
end

-- **Efecto: Robar 1 carta y hacer daño**
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
    local tc=Duel.GetOperatedGroup():GetFirst()
    Duel.ConfirmCards(1-tp,tc)
    if tc:IsMonster() then
        Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
    end
    Duel.ShuffleHand(tp)
end

-- **Efecto: Destruir todas las Mágicas/Trampas del oponente**
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end
