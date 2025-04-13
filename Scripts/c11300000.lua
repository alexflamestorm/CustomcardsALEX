-- The Phantom Knights of Old Axe
local s,id=GetID()
function s.initial_effect(c)
    -- Xyz Summon
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WARRIOR),4,2)
    c:EnableReviveLimit()

    -- Destruir cartas en el campo
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.descost)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- Invocar un Xyz Phantom Knights al ser objetivo de un efecto
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_BECOME_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- **Costo: Detach 1 material**
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- **Objetivo y cantidad de destrucción basada en Warriors desterrados**
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    local ct=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_REMOVED,0,nil,RACE_WARRIOR)
    if chk==0 then return #g>0 and ct>0 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,math.min(#g,ct),0,0)
end

-- **Destruir cartas**
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    local ct=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_REMOVED,0,nil,RACE_WARRIOR)
    if ct>0 and #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local sg=g:Select(tp,1,math.min(#g,ct),nil)
        Duel.Destroy(sg,REASON_EFFECT)
    end
end

-- **Condición: Este monstruo es objetivo de un efecto del oponente**
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsContains(e:GetHandler()) and rp==1-tp
end

-- **Target para invocación de un Xyz Phantom Knights**
function s.xyzfilter(c,e,tp)
    return c:IsSetCard(0xdb) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- **Invocar Xyz Phantom Knights y transferir materiales**
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
    if tc then
        local mg=c:GetOverlayGroup()
        if #mg>0 then
            Duel.Overlay(tc,mg)
        end
        Duel.Overlay(tc,Group.FromCards(c))
        tc:SetMaterial(Group.FromCards(c))
        Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
        tc:CompleteProcedure()

        -- Gana el nombre y efectos del monstruo original
        local e1=Effect.CreateEffect(tc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetValue(id)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)

        local e2=Effect.CreateEffect(tc)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_ADD_SETCODE)
        e2:SetValue(0xdb)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)
    end
end
