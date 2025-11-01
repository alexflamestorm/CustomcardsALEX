-- Black Luster Soldier, the Chaos Blue Magician
-- ID: 100000028
local s,id=GetID()
local CHAOS_FORM = 21082832
local BLS_ARCHETYPE = 0x10cf -- Generic BLS name ID (used by many BLS forms)
local GAIA_ARCHETYPE = 0xbd

function s.initial_effect(c)
	c:EnableReviveLimit()
	
	-- E1: Ritual Summon Condition (Chaos Form only)
	Ritual.AddProc(c, s.RitualProcFilter)
	
	-- E2: Used as entire requirement for Chaos Ritual Summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_RITUAL_MATERIAL_E)
	e2:SetCondition(s.r_mat_con)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetValue(99) -- Used as entire requirement
	c:AddEffect(e2)

	-- E3: Place Spell Counter on Spell Activation
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD_QUICK_O)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.spccon3)
	e3:SetOperation(s.spcop3)
	c:AddEffect(e3)

	-- E4 (HOPT Quick Effect): Tribute for SS mass
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id) -- HOPT for this effect
	e4:SetCost(s.sscost4)
	e4:SetTarget(s.sstg4)
	e4:SetOperation(s.ssop4)
	c:AddEffect(e4)

	-- E5: Spell Counter Max Limit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_COUNTER_PERMIT)
	e5:SetValue(s.counterfilter)
	c:AddEffect(e5)
end
s.listed_names={BLS_ARCHETYPE, GAIA_ARCHETYPE}

-- E1: Ritual Summon Condition (Chaos Form only)
function s.RitualProcFilter(e, c)
	-- Only can be Summoned by "Chaos Form" (Must be used with the card itself)
	return Duel.GetMZoneCount(c:GetControler())>0
		and Duel.IsExistingMatchingCard(Card.IsCode, c:GetControler(), LOCATION_HAND+LOCATION_DECK, 0, 1, nil, 21082832)
end

-- E2: Use as entire requirement
function s.r_mat_con(e, c)
	local rc = c:GetReasonCard()
	-- Check if the summoning card requires monsters as material (cost)
	return rc and rc:IsCode(21082832) and Duel.GetSummonTarget(c, EFFECT_RITUAL_PROC) and Duel.GetSummonTarget(c, EFFECT_RITUAL_PROC):IsType(TYPE_RITUAL) and Duel.GetSummonTarget(c, EFFECT_RITUAL_PROC):IsSetCard(0xcf) -- Chaos Ritual Mon
end

-- E3: Place Spell Counter
function s.counterfilter(e, c)
	-- Max 3 Spell Counters
	return c:IsSetCard(0x20) and c:GetCounter(0x20) < 3
end

function s.spccon3(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	-- Activated Spell Card, and resolution was successful
	return re:IsSpell() and re:IsHasType(TYPE_ACTIVATE) and c:IsRelateToChain(ev)
end
function s.spcop3(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x20, 1) -- 0x20 is the code for Spell Counter
	end
end

-- E4: Tribute for SS mass
function s.sscost4(e, tp, eg, ep, ev, re, r, rp, chk)
	local c=e:GetHandler()
	-- Must have at least 1 Spell Counter
	if chk==0 then return c:GetCounter(0x20) > 0 and c:IsAbleToTributeAsCost() end
	e:SetLabel(c:GetCounter(0x20)) -- Store the number of Spell Counters
	Duel.Release(c, REASON_COST)
end

function s.ssfilter4(c, e, tp)
	-- Black Luster Soldier or Gaia the Fierce Knight
	return (c:IsSetCard(0x10cf) or c:IsSetCard(0xbd))
		and c:IsMonster()
		-- Must be able to SS while ignoring conditions
		and Duel.IsCanBeSpecialSummoned(c, 0, tp, false, false)
end

function s.sstg4(e, tp, eg, ep, ev, re, r, rp, chk)
	local count = e:GetLabel()
	local g=Duel.GetMatchingGroup(s.ssfilter4, tp, LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE, 0, nil, e, tp)
	
	if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and #g >= 1 end -- Must be able to summon at least 1
	
	-- Max possible summons is min(counters, available M Zone, target count)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.ssop4(e, tp, eg, ep, ev, re, r, rp)
	local count = e:GetLabel()
	local max_ss = math.min(count, Duel.GetLocationCount(tp, LOCATION_MZONE))
	if max_ss <= 0 then return end
	
	local g=Duel.GetMatchingGroup(s.ssfilter4, tp, LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE, 0, nil, e, tp)
	if #g==0 then return end
	
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	-- Select up to the stored counter count (capped by M Zone)
	local sg=g:Select(tp, 1, max_ss, nil)

	if #sg>0 then
		for _, tc in ipairs(sg:GetCards()) do
			-- Special Summon ignoring conditions
			local res=Duel.SpecialSummon(tc, SUMMON_BY_EFFECT, tp, tp, false, false, POS_FACEUP)
			if res > 0 then
				-- Granting an effect to treat the summon as ignoring conditions
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_BE_EFFECT_MATERIAL)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
				e1:SetValue(SUMMON_TYPE_FUSION|SUMMON_TYPE_SYNCHRO|SUMMON_TYPE_XYZ|SUMMON_TYPE_LINK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1, true)
			end
		end
	end
end