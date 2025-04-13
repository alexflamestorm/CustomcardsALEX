-- Borrelguard eXecution Dragon
-- Edición por DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    -- Requiere 3 Level 4 Monsters
    c:EnableReviveLimit()
    Xyz.AddProcedure(c,nil,4,3)
    
    -- Efecto al ser Xyz Summoned: Destruye todo excepto a sí mismo, (Edit-DrakayStudios)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.descon)
    e1:SetTarget(s.limtg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- No puede atacar el turno en que usa su efecto de destrucción
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_ATTACK)
    e2:SetCondition(s.atkcon)
    c:RegisterEffect(e2)

    -- Daño si es destruido (Quick Effect) (Error en procedimiento)
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e3:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER_E)
    e3:SetCondition(function(_,tp) return Duel.IsTurnPlayer(1-tp) end)
    e3:SetCountLimit(1,id)
    e3:SetCost(s.dmgcost)
    e3:SetOperation(s.dmgop)
    c:RegisterEffect(e3)
end

-- Condición de destrucción masiva (Xyz Summon)
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
    -- No generar cadena por tu adversario (Edit-DrakayStudios)
function s.limtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetChainLimit(s.chainlm)
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
    if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
    -- Evita Battle Phase este turno
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_BP)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetTargetRange(1,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
-- Verificar si activó su efecto este turno
function s.atkcon(e)
    return Duel.GetTurnCount()~=e:GetHandler():GetTurnID()
end

-- Costo: Desacoplar material para daño si es destruido
function s.dmgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- Si es destruido, inflige 500 de daño
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetOperation(function(_,_,_,_,_,_,_,_,_) Duel.Damage(1-tp,500,REASON_EFFECT) end)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e1)
end
