-- Chimeratech Confinement Dragon
local s,id=GetID()
function s.initial_effect(c)
    -- Fusion Material
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,70095154,s.matfilter)

    -- Permitir Invocación por Tributo en el campo de cualquier jugador
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    e1:SetValue(SUMMON_TYPE_FUSION)
    c:RegisterEffect(e1)

    -- Quick Effect: Tributar y revivir "Cyber Dragon"
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)

    -- Restricción de invocación: Solo máquinas
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(1,0)
    e3:SetTarget(s.splimit)
    c:RegisterEffect(e3)
end

-- Material de Fusión: Cualquier Máquina en la misma columna
function s.matfilter(c,fc,sumtype,tp)
    return c:IsRace(RACE_MACHINE) and c:IsColumn(fc,tp)
end

-- Condición de Invocación por Tributo (Ambos campos)
function s.spfilter(c,tp,fc)
    return c:IsFaceup() and (c:IsControler(tp) or c:IsControler(1-tp)) and (c:IsCode(70095154) or c:IsRace(RACE_MACHINE) and c:IsColumn(fc,tp))
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,c)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,99,nil,tp,c)
    if #g>0 then
        c:SetMaterial(g)
        Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,#g,0,0)
        return true
    end
    return false
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=c:GetMaterial()
    Duel.Release(g,REASON_MATERIAL+REASON_FUSION)
end

-- Quick Effect: Tributar y revivir "Cyber Dragon"
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end

function s.spfilter2(c,e,tp)
    return c:IsCode(70095154) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=e:GetHandler():GetMaterialCount()
    if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,ct,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetHandler():GetMaterialCount()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,ct,ct,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- Restricción de Invocación: Solo Máquinas
function s.splimit(e,c)
    return not c:IsRace(RACE_MACHINE)
end
