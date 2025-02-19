/datum/species/dullahan
	name = "Dullahan"
	id = "dullahan"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	inherent_traits = list(TRAIT_NOHUNGER,TRAIT_NOBREATH)
	default_features = MANDATORY_FEATURE_LIST
	use_skintones = TRUE
	limbs_id = "human"
	skinned_type = /obj/item/stack/sheet/animalhide/human
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN
	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain/dullahan,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/dullahan,
		ORGAN_SLOT_EARS = /obj/item/organ/ears/dullahan,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue/dullahan,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
		ORGAN_SLOT_ANUS = /obj/item/organ/filling_organ/anus,
		)
	var/obj/item/dullahan_relay/myhead


/datum/species/dullahan/check_roundstart_eligible()
//	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
//		return TRUE
	return FALSE

/datum/species/dullahan/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.flags_1 &= ~HEAR_1
	var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		head.drop_limb()
		head.flags_1 = HEAR_1
		head.throwforce = 25
		myhead = new /obj/item/dullahan_relay (head, H)
		H.put_in_hands(head)

/datum/species/dullahan/on_species_loss(mob/living/carbon/human/H)
	H.flags_1 |= ~HEAR_1
	H.reset_perspective(H)
	if(myhead)
		var/obj/item/dullahan_relay/DR = myhead
		myhead = null
		DR.owner = null
		qdel(DR)
	H.regenerate_limb(BODY_ZONE_HEAD,FALSE)
	..()

/datum/species/dullahan/spec_life(mob/living/carbon/human/H)
	if(QDELETED(myhead))
		myhead = null
		H.gib()
	var/obj/item/bodypart/head/head2 = H.get_bodypart(BODY_ZONE_HEAD)
	if(head2)
		myhead = null
		H.gib()

/datum/species/dullahan/proc/update_vision_perspective(mob/living/carbon/human/H)
	var/obj/item/organ/eyes/eyes = H.getorganslot(ORGAN_SLOT_EYES)
	if(eyes)
		H.update_tint()
		if(eyes.tint)
			H.reset_perspective(H)
		else
			H.reset_perspective(myhead)

/obj/item/organ/brain/dullahan
	decoy_override = TRUE
	organ_flags = 0

/obj/item/organ/tongue/dullahan
	zone = "abstract"
	modifies_speech = TRUE

/obj/item/organ/tongue/dullahan/handle_speech(datum/source, list/speech_args)
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.dna.species.id == "dullahan")
			var/datum/species/dullahan/D = H.dna.species
			if(isobj(D.myhead.loc))
				var/obj/O = D.myhead.loc
				O.say(speech_args[SPEECH_MESSAGE])
	speech_args[SPEECH_MESSAGE] = ""

/obj/item/organ/ears/dullahan
	zone = "abstract"

/obj/item/organ/eyes/dullahan
	name = "head vision"
	desc = ""
	actions_types = list(/datum/action/item_action/organ_action/dullahan)
	zone = "abstract"

/datum/action/item_action/organ_action/dullahan
	name = "Toggle Perspective"
	desc = ""

/datum/action/item_action/organ_action/dullahan/Trigger()
	. = ..()
	var/obj/item/organ/eyes/dullahan/DE = target
	if(DE.tint)
		DE.tint = 0
	else
		DE.tint = INFINITY

	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.dna.species.id == "dullahan")
			var/datum/species/dullahan/D = H.dna.species
			D.update_vision_perspective(H)

/obj/item/dullahan_relay
	var/mob/living/owner
	flags_1 = HEAR_1

/obj/item/dullahan_relay/Initialize(mapload,new_owner)
	. = ..()
	owner = new_owner
	START_PROCESSING(SSobj, src)

/obj/item/dullahan_relay/process()
	if(!istype(loc, /obj/item/bodypart/head) || QDELETED(owner))
		. = PROCESS_KILL
		qdel(src)

/obj/item/dullahan_relay/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode, original_message)
	. = ..()
	if(!QDELETED(owner))
		message = compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mode)
		to_chat(owner,message)
	else
		qdel(src)


/obj/item/dullahan_relay/Destroy()
	if(!QDELETED(owner))
		var/mob/living/carbon/human/H = owner
		if(H.dna.species.id == "dullahan")
			var/datum/species/dullahan/D = H.dna.species
			D.myhead = null
			owner.gib()
	owner = null
	..()
