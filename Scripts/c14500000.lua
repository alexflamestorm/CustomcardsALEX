-- Meklord Astro Mekanikle - The Cube of Despair
local s,id=GetID()
function s.initial_effect(c)
    -- No puede ser Normal Summoned/Set
    c:EnableUnsummonable()
    
    -- Special Summon desde la mano o el GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    
    -- Solo puedes controlar 1 "Meklord Astro Mekanikle"
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_SUMMON)
    e2:SetCondition(s.limitcon)
    c:RegisterEffect(e2)
    
    -- Equipar un Synchro del oponente
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_EQUIP)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.eqtg)
    e3:SetOperation(s.eqop)
    c:RegisterEffect(e3)
    
    -- Ganar ATK por cada equipo
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetValue(s.atkval)
    c:RegisterEffect(e4)
    
    -- Protección contra destrucción
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_DESTROY_REPLACE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTarget(s.reptg)
    e5:SetOperation(s.repop)
    c:RegisterEffect(e5)
    
    -- Copiar el nombre y efectos de otro Meklord
    local e6=Effect.CreateEffect(c)
    e6:SetCategory(CATEGORY_TOGRAVE)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCountLimit(1,id)
    e6:SetTarget(s.copytg)
    e6:SetOperation(s.copyop)
    c:RegisterEffect(e6)
    
    -- Infligir daño al enviar Synchro equipado al GY
    local e7=Effect.CreateEffect(c)
    e7:SetCategory(CATEGORY_DAMAGE)
    e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e7:SetCode(EVENT_PHASE+PHASE_END)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCountLimit(1)
    e7:SetTarget(s.damtg)
    e7:SetOperation(s.damop)
    c:RegisterEffect(e7)
end

-- Condición de Invocación Especial (3 Meklord Emperor con distintos atributos)
function s.spfilter(c,attr)
    return c:IsSetCard(0x601) and c:IsAbleToRemoveAsCost() and (attr==0 or c:GetAttribute()~=attr)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,0)
    return g:CheckWithSumEqual(Card.GetAttribute,0x1F,3,3)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,0)
    local sg=g:SelectWithSumEqual(tp,Card.GetAttribute,0x1F,3,3)
    Duel.Remove(sg,POS_FACEUP,REASON_COST)
end

-- Solo puedes controlar 1 "Meklord Astro Mekanikle"
function s.limitcon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,id),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

-- Equipar un Synchro del oponente
function s.eqfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,0,LOCATION_MZONE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.SelectMatchingCard(tp,s.eqfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
    if tc and Duel.Equip(tp,tc,e:GetHandler(),true) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetValue(s.eqlimit)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end
function s.eqlimit(e,c)
    return e:GetOwner()==c
end

-- Ganar ATK por los monstruos equipados
function s.atkval(e,c)
    local g=c:GetEquipGroup()
    return g:GetSum(Card.GetAttack)
end

-- Protección contra destrucción
function s.repfilter(c)
    return c:IsSetCard(0x601) and c:IsAbleToRemove()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_GRAVE,0,1,nil) end
    return true
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end

-- Copiar nombre y efectos de otro Meklord
function s.copyfilter(c)
    return c:IsSetCard(0x601) and c:IsMonster()
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.copyfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.SelectMatchingCard(tp,s.copyfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
    if tc then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetValue(tc:GetCode())
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        e:GetHandler():RegisterEffect(e1)
    end
end

-- Infligir daño al enviar Synchro equipado al GY
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=e:GetHandler():GetEquipGroup()
    local tg=g:Filter(Card.IsType,nil,TYPE_SYNCHRO)
    if chk==0 then return #tg>0 end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tg:GetSum(Card.GetAttack))
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetHandler():GetEquipGroup()
    local tg=g:Filter(Card.IsType,nil,TYPE_SYNCHRO)
    if #tg>0 then
        Duel.SendtoGrave(tg,REASON_EFFECT)
        Duel.Damage(1-tp,tg:GetSum(Card.GetAttack),REASON_EFFECT)
    end
end
