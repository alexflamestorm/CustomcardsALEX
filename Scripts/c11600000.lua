-- The Phantom Knights of Sabbath Knight
-- Edición por DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon alternativa (usando un Rango 4 o menor de "The Phantom Knights" o "Rebellion"), (Edit-DrakayStudios)
    Xyz.AddProcedure(c,nil,5,2,s.xyzfilter,aux.Stringid(id,0),3)
    c:EnableReviveLimit()

    -- Efecto al ser Invocado: Cambia todos los monstruos a Defensa y reduce su DEF a la mitad
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.defcon)
    e1:SetOperation(s.defop)
    c:RegisterEffect(e1)

    -- Atacar a todos los monstruos una vez cada uno (Edit-DrakayStudios)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.allcon)
    e2:SetCost(s.cost)
    e2:SetOperation(s.operation)
	e2:SetValue(1)
	c:RegisterEffect(e2)
    c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
    -- Causar daño de penetración (Edit-DrakayStudios)
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
    e3:SetCondition(s.indcon)
	c:RegisterEffect(e3)
end

-- **Filtro para Xyz Summon alternativa**
function s.xyzfilter(c,xyz,tp)
    return c:IsSetCard(0xdb) or c:IsSetCard(0xba) -- "The Phantom Knights" o "Rebellion" (Raidraptor)
end

-- **Efecto 1: Cambiar a Defensa y reducir DEF**
function s.defcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetSummonType()==SUMMON_TYPE_XYZ
end
function s.defop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(Card.IsAttackPos,tp,LOCATION_MZONE,LOCATION_MZONE,c)
    if #g>0 then
        for tc in aux.Next(g) do
            Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
            -- Reducir DEF a la mitad
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
            e1:SetValue(math.ceil(tc:GetDefense()/2))
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    end
end

-- **Efecto 2: Gana efectos según el material**

function s.imfilter(c)
	return c:IsSetCard(0xdb) and c:IsType(TYPE_XYZ)
end
function s.allcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(s.imfilter,1,nil) and Duel.IsAbleToEnterBP() and not e:GetHandler():IsHasEffect(EFFECT_ATTACK_ALL)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ATTACK_ALL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

-- Efecto 3: Causar daño por penetración
function s.imfilter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ)
end
function s.indcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(s.imfilter,1,nil)
end