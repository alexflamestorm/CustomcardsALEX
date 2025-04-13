--Blaze Accelerator Meteor
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id) -- Solo 1 copia en el campo

    -- Este nombre se trata como "Tri-Blaze Accelerator" en la Zona de Magia/Trampa
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_SZONE)
    e0:SetValue(21420702) -- ID de "Tri-Blaze Accelerator"
    c:RegisterEffect(e0)

    -- Protección para cartas que mencionan "Tri-Blaze Accelerator"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_ONFIELD,0)
    e1:SetTarget(s.protecttg)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)

    -- Negar la Invocación de un monstruo
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_SUMMON)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.negcost)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON)
    c:RegisterEffect(e3)

    -- Efecto de Cementerio: Invocar Especialmente un "Volcanic"
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCountLimit(1,id+100)
    e4:SetCost(aux.bfgcost) -- Se destierra como costo
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

-- **Efecto 1: Protección para cartas que mencionan "Tri-Blaze Accelerator"**
function s.protecttg(e,c)
    return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:ListsCode(21420702)
end

-- **Efecto 2: Negar la Invocación**
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_COST) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateSummon(eg)
    Duel.Destroy(eg,REASON_EFFECT)
end

-- **Efecto 3: Invocar un "Volcanic" desde la mano**
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_VOLCANIC) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
