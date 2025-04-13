-- Salamandra Soul, the Fighting Flame Dragon
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon from hand by shuffling target into Deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Send Flame Swordsman or related Fusion from Extra Deck and change name
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.nametg)
    e2:SetOperation(s.nameop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- Fusion Material bonus
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_MATERIAL_CHECK)
    e4:SetValue(s.matcheck)
    c:RegisterEffect(e4)
end

-- E1: Special Summon this and shuffle target
function s.filter1(c)
    return c:IsAbleToDeck() and c:IsType(TYPE_MONSTER)
        and (c:IsCode(45231177) or aux.IsCodeListed(c,45231177)) -- "Flame Swordsman"
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsRelateToEffect(e) then
        Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end

-- E2: Send Flame Swordsman Fusion from Extra Deck and change name
function s.fsfusfilter(c)
    return c:IsType(TYPE_FUSION) and c:IsAbleToGrave()
        and (c:ListsCode(45231177)) -- mentions "Flame Swordsman"
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.fsfusfilter,tp,LOCATION_EXTRA,0,1,nil) end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.fsfusfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
        local fus=g:GetFirst()
        local mat=fus.material
        local codes={}
        if type(mat)=="function" then return end -- safeguard
        for i=1,#mat do
            local mc=mat[i]
            if type(mc)=="number" then table.insert(codes,mc) end
        end
        if #codes>0 then
            -- Choose 1 material's code to copy name
            local code=codes[1]
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_CODE)
            e1:SetValue(code)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
            c:RegisterEffect(e1)
        end
    end
end

-- Fusion Material Bonus
function s.matcheck(e,c)
    local g=c:GetMaterial()
    if g:IsExists(Card.IsCode,1,nil,e:GetHandler():GetCode()) and c:IsAttribute(ATTRIBUTE_FIRE) then
        -- Efecto bonus para la fusión
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetCondition(s.bonuscon)
        e1:SetValue(aux.tgoval)
        c:RegisterEffect(e1)

        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_CANNOT_ACTIVATE)
        e2:SetRange(LOCATION_MZONE)
        e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e2:SetTargetRange(0,1)
        e2:SetCondition(s.bonuscon)
        e2:SetValue(s.aclimit)
        c:RegisterEffect(e2)
    end
end

