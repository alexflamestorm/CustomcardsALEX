-- Meklord Army of Mekanikle
local s,id=GetID()
function s.initial_effect(c)
    -- Destroy this and another Meklord to summon Astro Mekanikle
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Replace destruction
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

-- Check for valid Meklord in hand
function s.cfilter(c)
    return c:IsSetCard(0x3013) and c:IsAbleToGrave()
end

-- Check for Meklord Astro Mekanikle
function s.spfilter(c,e,tp)
    return c:IsCode(63468625) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function s.synfilter(c,e,tp)
    return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsForbidden()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil)
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 and c:IsRelateToEffect(e) then
        g:AddCard(c)
        if Duel.Destroy(g,REASON_EFFECT)==2 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
            if sc and Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)>0 then
                -- Look at opponent's Extra Deck
                local exg=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_EXTRA,nil,TYPE_SYNCHRO)
                if #exg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
                    Duel.ConfirmCards(tp,exg)
                    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                    local sg=exg:FilterSelect(tp,s.synfilter,1,1,nil,e,tp)
                    if #sg>0 then
                        Duel.SpecialSummon(sg,0,tp,1-tp,false,false,POS_FACEUP)
                        local tc=sg:GetFirst()
                        -- Negate its effects
                        local e1=Effect.CreateEffect(c)
                        e1:SetType(EFFECT_TYPE_SINGLE)
                        e1:SetCode(EFFECT_DISABLE)
                        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                        tc:RegisterEffect(e1)
                        local e2=e1:Clone()
                        e2:SetCode(EFFECT_DISABLE_EFFECT)
                        tc:RegisterEffect(e2)
                    end
                end
            end
        end
    end
end

-- Replacement condition
function s.repfilter(c,tp)
    return c:IsFaceup() and c:IsControler(tp)
        and (c:IsSetCard(0x3013) or c:IsSetCard(0x13)) -- Meklord Emperor / Astro
        and c:IsOnField() and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.syncond(c)
    return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsDestructable()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
        and (e:GetHandler():IsAbleToRemove() or Duel.IsExistingMatchingCard(s.syncond,tp,0,LOCATION_MZONE,1,nil)) end
    return true
end
function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    local b1=e:GetHandler():IsAbleToRemove()
    local b2=Duel.IsExistingMatchingCard(s.syncond,tp,0,LOCATION_MZONE,1,nil)
    if b1 and (not b2 or Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==0) then
        Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,s.syncond,tp,0,LOCATION_MZONE,1,1,nil)
        if #g>0 then
            Duel.Destroy(g,REASON_EFFECT)
        end
    end
end
