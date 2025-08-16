# EndingDeterminer.gd
extends Node

static func determine_ending(flags: Dictionary) -> String:
	# This function returns the simplified key for endings.json based on flags.
	# The order of these checks matters; more specific or "final" endings should be checked first.

	# --- Low-Bond Paths (Final Confrontation) ---
	# These are the direct results of defying the godling.

	if flags.has("assimilated_godling"):
		return "ending:godling_absorbed_dark"

	if flags.has("obliterated_godling"):
		return "ending:godling_obliterated_dark"

	if flags.has("forced_submission"):
		return "ending:godling_dominated_bold"

	if flags.has("attacked_head_on"):
		return "ending:godling_slain_bold"

	if flags.has("attempted_sever_connection"):
		return "ending:godling_slain_cautious"

	if flags.has("pleaded_peaceful_separation"):
		return "ending:godling_negotiated_cautious"

	# --- High-Bond Paths (Final Merge) ---
	# These are the results of submitting to the godling's influence.
	
	if flags.has("final_submissive_dark"):
		return "ending:predatory_dark"

	if flags.has("final_equal_merge_dark"):
		return "ending:trickster_dark"

	if flags.has("final_submissive_bold"):
		return "ending:predatory_bold"

	if flags.has("final_equal_merge_bold"):
		return "ending:trickster_bold"
		
	if flags.has("final_submissive_cautious"):
		return "ending:predatory_cautious"

	if flags.has("final_equal_merge_cautious"):
		return "ending:trickster_cautious"

	# --- Fallback (Lowest Priority) ---
	# If no specific ending conditions are met, default to a 'lost' ending.
	# This can be a useful debugging tool.
	return "ending:godling_obliterated_dark"
