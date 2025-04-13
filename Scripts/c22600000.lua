-- Noh-P.U.N.K. Mask Opera
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,s.pfilter1,s.pfilter2)

    -- Negate monster effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.negcon)
    e1:SetCost(s.negcost)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)

    -- Pay LP and Special Summon P.U.N.K.s
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- Fusion Materials
function s.pfilter1(c)
    return c:IsSetCard(0x1f8)
end
function s.pfilter2(c)
    return c:IsLevel(3) or c:IsLevel(5) or c:IsLevel(8)
end

-- Negate: only turn of or after Fusion Summon
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return re:IsActiveType(TYPE_MONSTER) and ep==1-tp
        and Duel.IsChainNegatable(ev)
        and c:GetTurnID()<=Duel.GetTurnCount()
end

function s.cfilter(c)
    return c:IsSetCard(0x1f8) and c:IsAbleToGraveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_DECK,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end

-- Special Summon P.U.N.K.s
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local lp=Duel.GetLP(tp)
    local max_pay=math.floor(lp/600)
    if chk==0 then return max_pay>0 end
    Duel.Hint(HINT_NUMBER,tp,1)
    local val=Duel.AnnounceNumber(tp,table.unpack(s.make600table(max_pay)))
    e:SetLabel(val*600)
    Duel.PayLPCost(tp,val*600)
end

function s.make600table(n)
    local t={}
    for i=1,n do
        table.insert(t,i)
    end
    return t
end

function s.spfilter(c,e,tp,lvlist)
    return c:IsSetCard(0x1f8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
        and not lvlist[c:GetLevel()]
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=e:GetLabel()//600
    if chk==0 then
        local lvlist={}
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct and
            Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,lvlist)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetLabel()//600
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<ct then return end
    local lvlist={}
    local g=Group.CreateGroup()
    for i=1,ct do
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,function(c) return s.spfilter(c,e,tp,lvlist) end,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
        if #sg==0 then break end
        local lv=sg:GetFirst():GetLevel()
        lvlist[lv]=true
        g:Merge(sg)
    end
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
    end
end
