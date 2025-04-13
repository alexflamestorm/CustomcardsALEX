-- Red-Eyes Metalmorph
local s,id=GetID()
function s.initial_effect(c)
    -- Activate & Equip
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.eqtg)
    e1:SetOperation(s.eqop)
    c:RegisterEffect(e1)

    -- ATK/DEF Boost + Indestructible
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(300)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_EQUIP)
    e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e4:SetValue(1)
    c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(e5)

    -- Fusion Summon during opponent's Main Phase
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,1))
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e6:SetCode(EVENT_SPSUMMON_SUCCESS)
    e6:SetRange(LOCATION_SZONE)
    e6:SetCondition(s.fuscon)
    e6:SetTarget(s.fustg)
    e6:SetOperation(s.fusop)
    e6:SetCountLimit(1,id)
    c:RegisterEffect(e6)
end

-- Equip filter
function s.eqfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x3b) -- Red-Eyes
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.eqfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and s.eqfilter(tc) then
        Duel.Equip(tp,c,tc)
    end
end

-- Fusion Summon Condition
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsTurnPlayer(1-tp) and Duel.IsMainPhase()
        and eg:IsExists(Card.IsType,1,nil,TYPE_EFFECT)
end

function s.fusfilter(c,e,tp,matchk)
    return c:IsType(TYPE_FUSION) and c:ListsCode(74677422) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
        and (not match or c:CheckFusionMaterial(match,nil,tp))
end

function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        -- Only equipped monster + Normal Monsters
        local eqc=c:GetEquipTarget()
        if not eqc then return false end
        local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,eqc)
        g:AddCard(eqc)
        return Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- Material filter
function s.matfilter(c)
    return c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end

function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local eqc=c:GetEquipTarget()
    if not eqc then return end
    local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,eqc)
    mg:AddCard(eqc)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
    local sc=sg:GetFirst()
    if sc then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
        local mat=Duel.SelectFusionMaterial(tp,sc,mg,eqc,tp)
        sc:SetMaterial(mat)
        Duel.SendtoGrave(mat,REASON_MATERIAL+REASON_FUSION)
        Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        sc:CompleteProcedure()
    end
end
