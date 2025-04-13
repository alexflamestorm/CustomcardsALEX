-- The Phantom Knights of Half Blade
-- Editado por DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    -- Invocación por Xyz (Edit-DrakayStudios)
    Xyz.AddProcedure(c,s.xyzfilter,nil,2,nil,nil,nil,nil,false)
    c:EnableReviveLimit()

    -- Puede atacar directamente, pero el daño se reduce a la mitad
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DIRECT_ATTACK)
    c:RegisterEffect(e1)
    -- Reducir daño de batalla al atacar por su efecto (Edit-DrakayStudios)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(s.rdcon)
	e2:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e2)

    -- Efecto rápido: Reducir el ATK a la mitad
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCost(s.atkcost)
    e3:SetTarget(s.atktg)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)

    -- Si es destruido con un "Phantom Knights" como material, reducir LP del oponente a la mitad
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCondition(s.lpcon)
    e4:SetOperation(s.lpop)
    c:RegisterEffect(e4)
end

-- **Filtro para Xyz Summon**
function s.xyzfilter(c,xyz,tp)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_WARRIOR) and c:IsLevel(4)
end
    -- Reducir daño de batalla al atacar por su efecto (Edit-DrakayStudios)
function s.rdcon(e)
	local c,tp=e:GetHandler(),e:GetHandlerPlayer()
	return Duel.GetAttackTarget()==nil and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- **Efecto 1: Reducir ATK**
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsFaceup() and chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local atk=tc:GetAttack()
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(math.ceil(atk/2))
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end

-- **Efecto 2: Si es destruido con un "Phantom Knights" como material, reducir LP del oponente a la mitad**
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) and c:GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0xdb)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
    local lp=Duel.GetLP(1-tp)
    Duel.SetLP(1-tp,math.ceil(lp/2))
end
