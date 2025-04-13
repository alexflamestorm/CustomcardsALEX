-- Fortune Lady Any
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    
    -- Condición de Invocación Especial (Usando 2 "Fortune Lady" con diferencia de Nivel 1)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Ajustar ATK/DEF = Nivel x 300
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_SET_ATTACK)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_SET_DEFENSE)
    c:RegisterEffect(e3)

    -- Aumentar Nivel en Standby Phase + Regresar 1 carta a la mano
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_TODECK)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetOperation(s.lvop)
    c:RegisterEffect(e4)

    -- Modificar Niveles de Magos en mano
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,{id,1})
    e5:SetCost(s.lvcost)
    e5:SetOperation(s.lvmod)
    c:RegisterEffect(e5)
end

-- **Condición de Invocación Especial**
function s.spfilter(c,tp,sc)
    return c:IsFaceup() and c:IsSetCard(0x31) and c:IsMonster()
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=e:GetHandlerPlayer()
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,tp,c)
    return g:CheckSubGroup(aux.dncheck,2,2,function(g) return math.abs(g:GetFirst():GetLevel() - g:GetNext():GetLevel())==1 end)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,tp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2,function(g) return math.abs(g:GetFirst():GetLevel() - g:GetNext():GetLevel())==1 end)
    if sg then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    end
    return false
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local sg=e:GetLabelObject()
    Duel.SendtoGrave(sg,REASON_MATERIAL+REASON_SYNCHRO)
    sg:DeleteGroup()
end

-- **Ajustar ATK/DEF**
function s.atkval(e,c)
    return c:GetLevel()*300
end

-- **Aumentar Nivel y regresar 1 carta a la mano**
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFaceup() and c:GetLevel()<12 then
        local lvup=Effect.CreateEffect(c)
        lvup:SetType(EFFECT_TYPE_SINGLE)
        lvup:SetCode(EFFECT_UPDATE_LEVEL)
        lvup:SetValue(1)
        lvup:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(lvup)
    end

    -- Elegir 1 carta en el campo y regresarla a la mano
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
    end
end

-- **Modificar Niveles de Magos en la mano**
function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)
    if chk==0 then return ct>0 end
    local bct=math.min(ct,12)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_GRAVE,0,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local sg=g:Select(tp,1,bct,nil)
    Duel.Remove(sg,POS_FACEUP,REASON_COST)
    e:SetLabel(#sg)
end

function s.lvmod(e,tp,eg,ep,ev,re,r,rp)
    local val=e:GetLabel()
    local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_HAND,0,nil,RACE_SPELLCASTER)
    if #g>0 then
        for tc in g:Iter() do
            local lvup=Effect.CreateEffect(e:GetHandler())
            lvup:SetType(EFFECT_TYPE_SINGLE)
            lvup:SetCode(EFFECT_UPDATE_LEVEL)
            lvup:SetValue(val)
            lvup:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
            tc:RegisterEffect(lvup)
        end
    end
end

