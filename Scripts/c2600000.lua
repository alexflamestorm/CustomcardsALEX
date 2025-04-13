--Scorpion that Eliminates the Millennium Enemies
local s,id=GetID()
function s.initial_effect(c)
    --ATK reduction
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetValue(-500)
    c:RegisterEffect(e1)

    --Place in Spell/Trap Zone
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.sttg)
    e2:SetOperation(s.stop)
    c:RegisterEffect(e2)

    --Special Summon from S/T Zone
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- Place in Spell & Trap Zone
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        local e1=Effect.CreateEffect(c)
        e1:SetCode(EFFECT_CHANGE_TYPE)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
        c:RegisterEffect(e1)
        Duel.RaiseEvent(c,EVENT_CUSTOM+id,e,0,tp,0,0)
    end
end

-- Cost for Special Summon (pay LP or reveal "Millennium Ankh")
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,2000) or Duel.IsExistingMatchingCard(s.ankhfilter,tp,LOCATION_HAND,0,1,nil) end
    if Duel.CheckLPCost(tp,2000) and (not Duel.IsExistingMatchingCard(s.ankhfilter,tp,LOCATION_HAND,0,1,nil) or Duel.SelectYesNo(tp,aux.Stringid(id,0))) then
        Duel.PayLPCost(tp,2000)
    else
        Duel.ConfirmCards(1-tp,Duel.SelectMatchingCard(tp,s.ankhfilter,tp,LOCATION_HAND,0,1,1,nil))
    end
end
function s.ankhfilter(c)
    return c:IsCode(100000003) -- Reemplaza con el ID correcto de "Millennium Ankh"
end

-- Special Summon from Spell/Trap Zone
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        -- Shuffle back and draw
        local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
        if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
            local sg=g:Select(tp,1,#g,nil)
            Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
            Duel.Draw(tp,#sg,REASON_EFFECT)
        end
    end
end
function s.tdfilter(c)
    return c:IsAbleToDeck() and (c:IsSetCard(SET_MILLENNIUM) or c:IsSetCard(SET_FORBIDDEN_ONE))
end