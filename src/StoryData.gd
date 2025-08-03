extends Node

# Story nodes with numbered IDs matching your decision tree
const STORY = {
	# 1.0 Awakening
	"1.0": {
		"text": "Kael drags himself to the ancient shrine, ready to die... but a voice stirs within.\nWill you accept the godling's bond or resist?",
		"choices": [
			{"text": "Accept the godling", "next": "1.1", "effects": {"GODLING_BOND": true, "DECAY": 1}},
			{"text": "Resist the godling", "next": "2.0", "effects": {"HUMANITY": 1}}
		]
	},

	# 1) Accept Godling branch
	"1.1": {
		"text": "The godling feeds on your flesh and bone. Hunger grows inside you.\nDo you feed on the unclean, or try to starve the godling?",
		"choices": [
			{"text": "Feed on Rotkin (unclean creatures)", "next": "2.1", "effects": {"DECAY": 1, "KILLS": 1, "MORALITY": -1}},
			{"text": "Spare your companion (the last human you know)", "next": "2.2", "effects": {"MORALITY": 1, "HUMANITY": 1}},
			{"text": "Starve the godling", "next": "2.3"}
		]
	},

	# 2.1 Feed on Unclean - Rotkin feeding
	"2.1": {
		"text": "Feeding on the Rotkin, you feel the corruption spread through your veins.\nWill you fully merge with the godling, or reject it and hunt others?",
		"choices": [
			{"text": "Merge fully with godling", "next": "3.1"},
			{"text": "Reject and hunt others", "next": "3.2", "effects": {"KILLS": 1, "MORALITY": -1}}
		]
	},

	# 3.1 Corrupted Path - merge fully
	"3.1": {
		"text": "You and the godling become one, a creature of shadow and decay.\nWill you embrace this symbiotic ascension?",
		"choices": [
			{"text": "Yes, embrace the ascension", "next": "END_5.1"}
		]
	},

	# 3.2 Reject & Hunt Others - Tyrant Path
	"3.2": {
		"text": "You reject the merging, but hunger drives you to hunt the living relentlessly.",
		"choices": [
			{"text": "Press onward as a tyrant", "next": "END_5.3"}
		]
	},

	# 2.2 Spare Companion branch
	"2.2": {
		"text": "You spare your companion, fighting to keep your humanity alive.\nDo you protect them or sacrifice them for power?",
		"choices": [
			{"text": "Protect companion", "next": "3.3"},
			{"text": "Sacrifice companion", "next": "3.4", "effects": {"KILLS": 1, "MORALITY": -1}}
		]
	},

	# 3.3 Companion Path - protect companion
	"3.3": {
		"text": "Your bond with your companion strengthens. You strive for healing and redemption.",
		"choices": [
			{"text": "Prepare for healing ascension", "next": "END_5.5"}
		]
	},

	# 3.4 Companion Path - sacrifice companion
	"3.4": {
		"text": "You sacrifice your companion to the godling’s hunger. Power surges, but at what cost?",
		"choices": [
			{"text": "Accept betrayal's price", "next": "END_5.6"}
		]
	},

	# 2.3 Starve Godling branch
	"2.3": {
		"text": "You deny the godling sustenance, seeking peace in death or salvation in the shrine.\nRest in the Bone Orchard or search the shrine?",
		"choices": [
			{"text": "Rest in Bone Orchard", "next": "END_5.2", "effects": {"DECAY": 1}},
			{"text": "Search the shrine", "next": "3.6", "effects": {"HUMANITY": 1}}
		]
	},

	# 3.6 Shrine Quest - Search Shrine
	"3.6": {
		"text": "In the shrine, an ancient artifact pulses with power.\nHeal yourself or use it for power?",
		"choices": [
			{"text": "Use artifact to heal", "next": "END_5.5", "effects": {"HUMANITY": 1}},
			{"text": "Use artifact for power", "next": "END_5.1"}
		]
	},

	# 2.0 Resist Godling branch
	"2.0": {
		"text": "You resist the godling's whispers, holding tight to your humanity.\nHide it in Veinwood or attack the scavenger?",
		"choices": [
			{"text": "Hide the godling in Veinwood", "next": "3.7", "effects": {"HUMANITY": 1}},
			{"text": "Attack scavenger", "next": "3.8", "effects": {"KILLS": 1, "MORALITY": -1}}
		]
	},

	# 3.7 Veinwood Path
	"3.7": {
		"text": "Veinwood’s secrets shield you.\nSeek secret power or escape the forest?",
		"choices": [
			{"text": "Seek secret power", "next": "END_5.7"},
			{"text": "Escape Veinwood", "next": "END_5.8"}
		]
	},

	# 3.8 Decay Spike Path - Attack scavenger
	"3.8": {
		"text": "The scavenger fights back fiercely.\nSuccumb to rot or fight back?",
		"choices": [
			{"text": "Succumb to rot", "next": "END_4.7"},
			{"text": "Fight against it", "next": "4.8"}
		]
	},

	# 4.8 Redemption Path
	"4.8": {
		"text": "You fight back the rot, striving for redemption and salvation.",
		"choices": [
			{"text": "Push on toward redemption", "next": "END_5.5"}
		]
	},

	# Bonus True Ending Trigger
	"BONUS_TRIGGER": {
		"text": "You sense a new path opening between you and the godling — a silent communion.",
		"choices": [
			{"text": "Reach out in silence", "next": "4.9"}
		]
	},

	# 4.9 Communion Path
	"4.9": {
		"text": "You and the godling merge as one, a being beyond flesh and soul.",
		"choices": [
			{"text": "Become Flesh-of-the-Forgotten", "next": "END_FLESH_ASCENDANT"}
		]
	}
}

# Separate endings keyed by their special node IDs
const ENDINGS = {
	"END_5.1": {
		"title": "Corpse-Eclipse Ending",
		"description": "You are the eclipse — consuming worlds, bending darkness to your will. A god of rot and shadow."
	},
	"END_5.3": {
		"title": "Tyrant Ending",
		"description": "You are feared and reviled, a god of destruction and pain."
	},
	"END_5.5": {
		"title": "Redemption Ending",
		"description": "You become a beacon of hope — a god who heals rather than destroys."
	},
	"END_5.6": {
		"title": "Betrayal Ending",
		"description": "Your soul is shattered, a god born from treachery and pain."
	},
	"END_5.2": {
		"title": "Stasis Ending",
		"description": "You sleep forever, a ghost among the bones."
	},
	"END_5.7": {
		"title": "Secret Ascension Ending",
		"description": "You become a hidden god, your power whispered only in shadowed corners."
	},
	"END_5.8": {
		"title": "Balanced Ending",
		"description": "You walk the line between light and dark, neither god nor mortal."
	},
	"END_4.7": {
		"title": "Hallucination Ending",
		"description": "You are lost forever in the labyrinth of your own decaying mind."
	},
	"END_FLESH_ASCENDANT": {
		"title": "Flesh Ascendant Ending",
		"description": "There was a boy once. And a hunger. One died. One waited. We became the silence that followed. Now we are the question."
	}
}
