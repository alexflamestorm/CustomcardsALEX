--Psi-Caller
local s,id=GetID()
function s.initial_effect(c)
    -- Tribute to summon Synchro listed on /Assault Mode
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Revive if Synchro or /Assault Mode tributed for Spell/Trap effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_RELEASE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.revcon)
    e2:SetTarget(s.revtg)
    e2:SetOperation(s.revop)
    c:RegisterEffect(e2)
end

-- Tribute cost
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end

-- Target: Reveal 1 "/Assault Mode" in Deck and summon referenced Synchro
function s.assaultfilter(c,tp)
    return c:IsCodeListed() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x21) -- "/Assault Mode"
        and Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,c)
end
function s.synfilter(c,assault)
    local code=c:GetOriginalCode()
    return assault:ListsCode(code) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(nil,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.assaultfilter,tp,LOCATION_DECK,0,1,nil,tp) 
    end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.assaultfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
    if #g==0 then return end
    local card=g:GetFirst()
    Duel.ConfirmCards(1-tp,card)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,card)
    if #sg>0 then
        local sc=sg:GetFirst()
        if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
            -- Disable its effects
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            sc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            sc:RegisterEffect(e2)
        end
    end
    Duel.SendtoDeck(card,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
end

-- Revival trigger
function s.revfilter(c,tp)
    return c:IsPreviousControler(tp)
        and (c:IsType(TYPE_SYNCHRO) or (c:IsSetCard(0x21) and c:IsType(TYPE_MONSTER))) 
end
function s.revcon(e,tp,eg,ep,ev,re,r,rp)
    return re and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
        and eg:IsExists(s.revfilter,1,nil,tp)
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end
