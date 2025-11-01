-- Psi-Caller
-- ID: 29800000
local s,id=GetID()
function s.initial_effect(c)
	-- Synchro Summon Procedure
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	-- Mark as Tuner
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_ADD_TYPE)
	e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE) -- Tuner in GY too, standard for Synchro Tuners
	e0:SetValue(TYPE_TUNER)
	c:AddEffect(e0)

	-- Effect 1: Tribute self to SS Synchro base of an Assault Mode monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id) -- HOPT for effect 1
	e1:SetCondition(s.costcon1)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:AddEffect(e1)

	-- Effect 2: Special Summon self from GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_COST_SUCCESS) -- Triggers after cost is paid
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1}) -- HOPT for effect 2 using flag 1
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:AddEffect(e2)
end
s.listed_series={0x104f} -- Assault Mode archetype code

-- Helper function to map Assault Mode monsters to their base Synchros
-- You might need to add more pairs if new Assault Mode monsters are created
local assault_pairs={
	[61257789]=44508094, -- Stardust Dragon/Assault Mode -> Stardust Dragon
	[77336644]=70902743, -- Red Dragon Archfiend/Assault Mode -> Red Dragon Archfiend
	[14553285]=31924889, -- Arcanite Magician/Assault Mode -> Arcanite Magician
	[01764972]=06021033, -- Doomkaiser Dragon/Assault Mode -> Doomkaiser Dragon
	[37169670]=95526884, -- Hyper Psychic Blaster/Assault Mode -> Hyper Psychic Blaster
	[38898779]=23693634, -- Colossal Fighter/Assault Mode -> Colossal Fighter
	[101303008]=80321197, -- Crimson Blader/Assault Mode -> Crimson Blader
	[47027714]=97836203, -- T.G. Halberd Cannon/Assault Mode -> T.G. Halberd Cannon
	[101303007]=60800381, -- Junk Warrior/Assault Mode -> Junk Warrior
	[10500000]=51447164, -- T.G. Blade Blaster/Assault Mode -> T.G. Blade Blaster
	[29900000]=29800000 -- Psi-Caller/Assault Mode -> Psi-Caller (Self reference, assuming ID)
	-- Add more pairs here [AssaultModeID] = BaseSynchroID
}
function s.GetBaseSynchroID(assault_code)
	return assault_pairs[assault_code]
end

-- Effect 1: Tribute to SS Synchro
function s.costcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToTributeAsCost() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.tg1_filter_am(c,e,tp)
	local base_id=s.GetBaseSynchroID(c:GetCode())
	if not base_id then return false end
	return c:IsSetCard(0x104f)
		and Duel.IsExistingMatchingCard(s.tg1_filter_synchro,tp,LOCATION_EXTRA,0,1,nil,e,tp,base_id)
end
function s.tg1_filter_synchro(c,e,tp,base_id)
	return c:IsCode(base_id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.tg1_filter_am,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REVEAL)
	local reveal_g=Duel.SelectMatchingCard(tp,s.tg1_filter_am,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local reveal_c=reveal_g:GetFirst()
	if not reveal_c then return end

	Duel.ConfirmCards(1-tp,reveal_g)
	Duel.ShuffleDeck(tp)

	local base_id=s.GetBaseSynchroID(reveal_c:GetCode())
	if not base_id then return end -- Should not happen due to filter

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sync_g=Duel.SelectMatchingCard(tp,s.tg1_filter_synchro,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,base_id)
	local sync_c=sync_g:GetFirst()
	if sync_c and Duel.SpecialSummon(sync_c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- A monster Summoned with this effect cannot activate its effects.
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER) -- Prevents activating effects
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sync_c:RegisterEffect(e1)
		-- Return revealed card to bottom of deck AFTER summon
		Duel.SendtoDeck(reveal_c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	else
		-- If summon failed, send revealed card back to Deck (shuffle)
		Duel.SendtoDeck(reveal_c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_RETURN)
	end
end

-- Effect 2: Special Summon self from GY
function s.costfilter2(c,tp)
	return (c:IsSynchroMonster() or c:IsSetCard(0x104f)) and c:IsPreviousControler(tp)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- Check if the cost payer is tp, the effect is a S/T effect,
	-- and the cost involved tributing a Synchro or /Assault Mode monster
	return ep==tp and re and (re:IsSpellEffect() or re:IsTrapEffect())
		and eg:IsExists(s.costfilter2,1,nil,tp)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- Since it was summoned from GY, it's treated as Tuner by e0
	end
end