-- Fabled Andromalith
local s,id=GetID()
function s.initial_effect(c)
    -- Debe ser Invocado por Sincronía
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_FABLED),1,1,Synchro.NonTuner(nil),1,99)

    -- Efecto al ser Invocado por Sincronía: Hacer que el jugador con más cartas descarte hasta igualar al rival
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_HANDES)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.syncon)
    e1:SetTarget(s.syntg)
    e1:SetOperation(s.synop)
    c:RegisterEffect(e1)

    -- Protección al ser atacado o si el oponente activa un efecto
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.protcon)
    e2:SetCost(s.protcost)
    e2:SetOperation(s.protop)
    c:RegisterEffect(e2)
    
    local e3=e2:Clone()
    e3:SetCode(EVENT_CHAINING)
    e3:SetCondition(s.protcon2)
    c:RegisterEffect(e3)
end

-- Condición para activar el efecto de descarte al ser Invocado por Sincronía
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- Seleccionar al jugador con más cartas en la mano
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
    local p1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    local p2=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
    if chk==0 then return p1~=p2 end
end

-- Hacer que el jugador con más cartas descarte hasta igualar al rival
function s.synop(e,tp,eg,ep,ev,re,r,rp)
    local p1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    local p2=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
    local dif=math.abs(p1-p2)
    local plr=p1>p2 and tp or 1-tp
    if dif>0 then
        Duel.Hint(HINT_SELECTMSG,plr,HINTMSG_DISCARD)
        local g=Duel.SelectMatchingCard(plr,aux.TRUE,plr,LOCATION_HAND,0,dif,dif,nil)
        if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)~=0 then
            -- Negar efectos de las cartas descartadas y sus copias mientras esta carta esté en el Campo
            local c=e:GetHandler()
            local tc=g:GetFirst()
            while tc do
                if not tc:IsSetCard(SET_FABLED) then
                    local e1=Effect.CreateEffect(c)
                    e1:SetType(EFFECT_TYPE_FIELD)
                    e1:SetCode(EFFECT_DISABLE)
                    e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
                    e1:SetTarget(s.distg(tc:GetCode()))
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                    Duel.RegisterEffect(e1,tp)
                end
                tc=g:GetNext()
            end
        end
    end
end

-- Función para negar efectos de cartas descartadas y sus copias
function s.distg(code)
    return function(e,c)
        return c:IsCode(code) and not c:IsSetCard(SET_FABLED)
    end
end

-- Condición para activar el efecto de protección si se declara un ataque
function s.protcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end

-- Condición para activar el efecto de protección si el oponente activa un efecto
function s.protcon2(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp
end

-- Costo de descartar 1 carta
function s.protcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_COST+REASON_DISCARD)
end

-- Activar la protección e indicar que robarás en la End Phase
function s.protop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- No puede ser destruido en esta fase
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT+RESETS_S
