-- Heroic Champion - Durendal
-- Edición por DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    -- Invocación por Xyz usando un Rango 4 Heroic (Edit-DrakayStudios)
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WARRIOR),5,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
    c:EnableReviveLimit()

    -- No puede usarse como material Xyz
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    e0:SetValue(1)
    c:RegisterEffect(e0)

    -- Si tiene un Xyz "Heroic" como material, dobla su ATK y es inmune a efectos de monstruos del oponente
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetCondition(s.atkcon)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetCondition(s.atkcon)
    e2:SetValue(s.efilter)
    c:RegisterEffect(e2)

    -- Copiar nombre y efectos de un Xyz "Heroic" en el GY
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCost(s.copycost)
    e3:SetTarget(s.copytg)
    e3:SetOperation(s.copyop)
    c:RegisterEffect(e3)
end

-- Permitir Xyz Summon usando un Rank 4 "Heroic"
function s.ovfilter(c,tp,lc)
    return c:IsFaceup() and c:IsSetCard(0x6f) and c:GetRank()==4 and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	return true
end

-- Verificar si tiene un "Heroic" Xyz como material
function s.atkcon(e)
    local c=e:GetHandler()
    return c:GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x6f)
end

-- Duplicar ATK
function s.atkval(e,c)
    return c:GetBaseAttack()
end

-- Inmunidad a efectos de monstruos del oponente
function s.efilter(e,te)
    return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- Costo de copiar efectos (detachar 2 materiales)
function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end

-- Seleccionar un Xyz "Heroic" Rank 4 o menor en el GY
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingMatchingCard(s.copyfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.copyfilter(c)
    return c:IsSetCard(0x6f) and c:IsType(TYPE_XYZ) and c:IsRankBelow(4)
end

-- Copiar nombre y efectos
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectMatchingCard(tp,s.copyfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
    if tc then
        local code=tc:GetOriginalCode()
        c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
        -- Cambia su nombre
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetValue(code)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end
