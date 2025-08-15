# Narration-friendly Ending Definitions
static var endings = [
	{"key": "benevolent", "morality_range": [50, 100], "bond_range": [30, 100]},  # hero who helps others
	{"key": "predatory", "morality_range": [-100, -50], "bond_range": [50, 100]}, # ruthless but bonded to godling
	{"key": "tyrant", "morality_range": [-100, -50], "bond_range": [0, 49]},      # selfish, evil, low bond
	{"key": "trickster", "morality_range": [-49, -20], "bond_range": [30, 100]},  # clever manipulator / shared merge
	{"key": "mortal", "morality_range": [-19, 49], "bond_range": [0, 100]},       # average choices, survives but not divine
	{"key": "lost", "morality_range": [-100, 100], "bond_range": [0, 100]}        # fallback
]

static func determine_ending(morality:int, bond:int, flags:Dictionary) -> String:
	# Predatory override: ruthless + high bond
	if morality < -50 and bond >= 50:
		return "predatory"
	# Tyrant: ruthless + low bond
	if morality < -50 and bond < 50:
		return "tyrant"
	# Trickster: cunning choices flagged
	if flags.get("shared_merge", false) and morality < 0:
		return "trickster"
	# Benevolent: high morality + high bond
	if morality >= 50 and bond >= 50:
		return "benevolent"
	# Mortal: normal human path
	if morality >= -20 and morality < 50:
		return "mortal"
	# Fallback
	return "lost"
