local BeatMaps = {}

BeatMaps.Default = {
	bpm = 128,
	offset = 0,
	duration = 20,
}

-- Per-track settings. Key = exact Sound name in ReplicatedStorage.Sounds
-- Use explicit `beats = { ... }` for hand-tuned maps, or `bpm` + `offset` for auto grid.
BeatMaps.Tracks = {
	["SIX SEVEN FUNK 67"] = {
		bpm = 140,
		offset = 0.05,
	},
}

function BeatMaps.generateFromBpm(bpm, offset, duration)
	local interval = 60 / bpm
	local beats = {}
	local time = offset or 0

	while time <= duration do
		table.insert(beats, time)
		time += interval
	end

	return beats
end

function BeatMaps.getBeats(trackName)
	local config = BeatMaps.Tracks[trackName] or BeatMaps.Default

	if config.beats then
		return config.beats
	end

	local bpm = config.bpm or BeatMaps.Default.bpm
	local offset = config.offset or BeatMaps.Default.offset
	local duration = config.duration or BeatMaps.Default.duration

	return BeatMaps.generateFromBpm(bpm, offset, duration)
end

return BeatMaps
