--Volcanic Caesar
local s,id=GetID()
function s.initial_effect(c)
    -- No puede ser Normal Summoned/Set
    c:EnableUnsummonable()

    -- Special Summon a la cancha del oponente tributando 2 monstruos
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PHASE+PHASE_MAIN1)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- No puede ser usado como Link Material excepto para Pyro
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    e2:SetValue(s.linklimit)
    c:RegisterEffect(e2)

    -- Durante la End Phase: Enviar 1 "Volcanic" al GY o cambiar el control de esta carta
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_CONTROL)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PHASE+PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.eftg)
    e3:SetOperation(s.efop)
    c:RegisterEffect(e3)
end

-- **Condición: Solo se puede Invocar en Main Phase 1**
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end

-- **Coste: Tributar 2 monstruos del oponente**
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)>=2 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectMatchingCard(tp,nil,1-tp,LOCATION_MZONE,0,2,2,nil)
    Duel.Release(g,REASON_COST)
end

-- **Target: Special Summon esta carta al campo del oponente**
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- **Efecto: Invocar y aplicar uno de los dos efectos**
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP) then
        -- El jugador elige: Buscar o recibir daño
        local opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
        if opt==0 then
            -- Buscar 1 "Volcanic"
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
            if #g>0 then
                Duel.SendtoHand(g,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g)
            end
        else
            -- Tomar 1000 de daño
            Duel.Damage(tp,1000,REASON_EFFECT)
        end
    end
end

-- **Filtro para buscar "Volcanic"**
function s.thfilter(c)
    return c:IsSetCard(SET_VOLCANIC) and c:IsAbleToHand()
end

-- **Restricción de Link Material**
function s.linklimit(e,c)
    return not c:IsRace(RACE_PYRO)
end

-- **End Phase: Mandar "Volcanic" al GY o cambiar control**
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    if opt==0 then
        -- Enviar "Volcanic" al GY
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoGrave(g,REASON_EFFECT)
        end
    else
        -- Cambiar el control de "Volcanic Caesar"
        Duel.GetControl(c,1-tp)
    end
end

-- **Filtro para enviar "Volcanic" al GY**
function s.tgfilter(c)
    return c:IsSetCard(SET_VOLCANIC) and c:IsAbleToGrave()
end
