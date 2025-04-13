-- Raider's Warrior
-- Edición por DrakayStudios
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon (Edit-DrakayStudios)
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),4,2)
    c:EnableReviveLimit()

    -- Considerar como "Phantom Knights" y "Raidraptor"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetValue(0xdb) -- The Phantom Knights
    c:RegisterEffect(e0)
    local e1=e0:Clone()
    e1:SetValue(0xba) -- Raidraptor
    c:RegisterEffect(e1)

    -- Invocar otro Xyz usando esta carta como material
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

-- **Costo: Quitar 2 materiales**
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST) end
    c:RemoveOverlayCard(tp,2,2,REASON_COST)
end

-- **Filtrar Xyz Monsters válidos**
function s.xyzfilter(c,e,tp)
    return (c:IsSetCard(0xdb) or c:IsSetCard(0xba) or c:IsSetCard(0x48)) -- Phantom Knights, Raidraptor, Xyz Dragon
        and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end

-- **Objetivo: Invocar otro Xyz Monster**
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- **Operación: Hacer una Xyz Summon usando esta carta**
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCountFromEx(tp,tp,c)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
    if tc then
        local mg=c:GetOverlayGroup()
        if #mg>0 then
            Duel.Overlay(tc,mg) -- Transferir materiales
        end
        Duel.Overlay(tc,Group.FromCards(c))
        Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
        tc:CompleteProcedure()
        
        -- Destruirlo en la End Phase
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetRange(LOCATION_MZONE)
        e1:SetCountLimit(1)
        e1:SetOperation(s.desop)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end

-- **Destruir el monstruo invocado en la End Phase**
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFaceup() then
        Duel.Destroy(c,REASON_EFFECT)
    end
end
