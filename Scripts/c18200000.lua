-- Flame Manipulating Fusion
local s,id=GetID()
function s.initial_effect(c)
    -- Activar: Fusion Summon
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- GY: Reemplazo de destrucción
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.reptg)
    e2:SetValue(s.repval)
    e2:SetOperation(s.repop)
    c:RegisterEffect(e2)
end

-- Fusion filter
function s.filter(c,e,tp)
    return c:IsType(TYPE_FUSION) and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,c,tp)
end
function s.matfilter(c,fc,tp)
    return c:IsCanBeFusionMaterial(fc) and c:IsAbleToGrave()
end

-- Fusion Summon with optional Deck materials if "Flame Swordsman"
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) 
    end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    if #g==0 then return end
    local tc=g:GetFirst()
    Duel.ConfirmCards(1-tp,tc)

    local chkDeck = tc:IsCodeListed(45231177) or tc:ListsCode(45231177) -- Flame Swordsman
    local mg1=Duel.GetFusionMaterial(tp)
    local mg2=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_DECK,0,nil,tc,tp)

    if chkDeck then mg1:Merge(mg2) end

    local sg=Duel.GetMatchingGroup(Card.IsCanBeFusionMaterial,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,nil,tc)
    local chkf=tp
    local res=Duel.FusionSummon(tp,tc,nil,mg1,nil,SUMMON_TYPE_FUSION)

    if not res and chkDeck then
        Duel.SendtoGrave(mg2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
    end
end

-- Destruction replacement
function s.repfilter(c,tp)
    return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE)
        and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
        and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and e:GetHandler():IsAbleToDeck() end
    return Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,1))
end
function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end