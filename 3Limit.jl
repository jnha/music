### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ c21d05c1-bd10-46cc-bc5a-d737d047131f
using SampledSignals

# ╔═╡ 99422a59-ffe4-4dc0-bb80-2245d41aaa74
include("NoteNames.jl")

# ╔═╡ f3cf3e66-b414-11eb-129f-1f82995a6e8e
md"# 3-Limit
One measure of the harmonic complexity of a system is
how much of the harmonic series it uses.
A 3-limit system treats the first 3 harmonics as important,
and so treats octaves and fifths as important intervals,
and also includes intervals derived from octaves and fifths."

# ╔═╡ 21ad163c-9031-4ebb-8dd2-a1a297f97456
fs = 48000

# ╔═╡ 5dedb960-1524-475b-b870-61a8254c7993
function tone(t)
	t = t/pi%2-1
	t = 3/2*sqrt(3)*t*(t*t-1)
end

# ╔═╡ e0aff7b7-a355-4138-87cd-d5113ee82623
function note(freq)
	return SampleBuf(tone.(Array(LinRange(1, 2*pi*freq, fs))), fs)
end

# ╔═╡ 752a031e-7c58-4af6-a2ab-965a1e43760e
md"## Important intervals
our important intervals are the octave, fifth, and fourth"

# ╔═╡ 8882303c-4ae7-44a5-8d38-8c4e73f15892
# Octave
note(C)/2 + note(2*C)/2

# ╔═╡ 87212fe7-ac94-4173-b3b6-a9afe58783ea
# Fifth
note(C)/2 + note(G)/2

# ╔═╡ 61482b04-b6fb-495a-94ae-92a84317f6f5
md"## General 3-limit intervals
Using octaves and fifths it is possible to construct any interval
that has integers made up of powers of $2$ and $3$: $2^n:3^m$ as a reduced ratio.
There are infinitely many intervals, most of which aren't very consonant.

### Tonality
A music system is tonal if all its pitches are in relation to single note,
the tonic.
The general tonal 3-limit system has a tonic note,
and includes all pitches that are a 3-limit interval from that note

### 3-limit note names
Western music note names can be put in 1-1 correspondance with
the general 3-limit system pitches where the tonic is the pitch standard.
Starting with $A4=440$ as a pitch standard
all octaves of $A$ are notated as equivalents
or by their octave number (i.e. $A3$ is one octave below $A4$).
The note names $A$ through $G$ are ordered by fifth as
$F$ $C$ $G$ $D$ $A$ $E$ $B$. Then for more fifths after the note names are repeated with sharps, then double sharps. And for the earlier fifths flats then double flats.
Note that in 3-limit tuning no notes are enharmonic unlike in 12-TET.
"

# ╔═╡ 799e0825-ac5c-46e5-a34a-685a5382cf63
# An octave normalized cycle of fifths limited to single flats/sharps
vcat([note.(freq) for freq=[Fb, Cb, Gb, Db, Ab, Eb, Bb, F, C, G, D, A, E, B, Fs, Cs, Gs, Ds, As, Es, Bs]]...)

# ╔═╡ 69e54625-9e7a-4a62-995d-ff4550e9167b
md"## Scales
Commonly a specific set of pitches, a scale, is used.
This is both to structure the music to be more cohesive by repeating the same
notes instead of drifting harmonically throughout a piece,
and also so that instruments don't have to be tuned to infinite different notes.

### Octave repeating scales
A scale can be defined by the notes in a single octave
and repeated across all octaves.
This is convenient since any number of octaves is harmonious
so sounds in different registers will still sound nice together in the scale.

### Scales from stacked fifths
Scales made from stacking fifths
will have the most pure fifths possible
for the number of notes in the scale.
"

# ╔═╡ 61f66f37-1568-4fb6-b0b0-ae6d13110c73
# One fifth leaves large gaps
vcat([note.(freq) for freq=[C, G, 2C]]...)

# ╔═╡ 20b4c50b-39f8-494e-be2b-d9f9f81fa8e5
# Two fifths has one whole step but two large 4ths
vcat([note.(freq) for freq=[C, D, G, 2C]]...)

# ╔═╡ 4a6d05fb-341a-4487-9685-d6092dea902c
# Three fifths splits one fourth but not the other
vcat([note.(freq) for freq=[C, D, G, A, 2C]]...)

# ╔═╡ 28fe6d6b-bbab-4cde-b437-001f7894a2f0
# Four fifths make a pentatonic scale
vcat([note.(freq) for freq=[C, D, E, G, A, 2C]]...)

# ╔═╡ 1619d9c4-d151-4060-9172-954500935545
# five fifths introduce a semitone but leave a gap larger than a whole tone
vcat([note.(freq) for freq=[C, D, E, Fs, G, A, 2C]]...)

# ╔═╡ fe4516c3-2008-492f-8563-3daa92470175
# six fifths give a heptatonic scale with two semitones and 5 whole tones
vcat([note.(freq) for freq=[C, D, E, Fs, G, A, B, 2C]]...)

# ╔═╡ 9a19129d-3b2a-4a59-aa72-0f8f6a349e53
# Adding fifths splits whole tones into semitones until 11 when everything is semitones
vcat([note.(freq) for freq=[C, Cs, D, Ds, E, Es, Fs, G, Gs, A, As, B, 2C]]...)

# ╔═╡ cf4fe547-f2e1-4e2f-8e52-168cce001061
#Adding anything else leads to a very small interval that sounds more out of tune than like a distinct note
vcat([note.(freq) for freq=[Bs, 2C]]...)

# ╔═╡ 876750d7-d1c2-44d4-a367-984d060870c4
md"To get even intervals, 5 note, 7 note and 12 note scales
are the most natural to make from stacking fifths in octaves.
We can make modes of these scales by starting down some of the fifths instead of up.
This gives us the pentatonic scale and it's modes, the heptatonic modes, and the chromatic scale"

# ╔═╡ bbdace00-0b8e-4963-af37-528b2a4aaafc
# Pentationic major (all fifths)
vcat([note.(freq) for freq=[C, D, E, G, A, 2C]]...)

# ╔═╡ 0ea9acfe-4045-4804-bc78-c802cf0f5577
# 3 fifths one fourth
vcat([note.(freq) for freq=[C, D, F, G, A, 2C]]...)

# ╔═╡ 834e0df6-c976-4c22-b1c4-95e9c8d3cade
# 2 fifths 2 fourths
vcat([note.(freq) for freq=[C, D, F, G, Bb, 2C]]...)

# ╔═╡ a83525a3-1228-4d50-8f85-df63ee11552b
# one fifth 3 fourths
vcat([note.(freq) for freq=[C, Eb, F, G, Bb, 2C]]...)

# ╔═╡ 4708c80b-3166-4c21-992a-8d07ceb52bf2
# all fourths
vcat([note.(freq) for freq=[C, Eb, F, Gb, Bb, 2C]]...)

# ╔═╡ ee828da7-05f1-4fc2-9db7-589a9c1b735d
# Lydian
vcat([note.(freq) for freq=[C, D, E, Fs, G, A, B, 2C]]...)

# ╔═╡ 83223d7d-fd40-4043-ae12-77b501fe1136
# Ionian (major)
vcat([note.(freq) for freq=[C, D, E, F, G, A, B, 2C]]...)

# ╔═╡ b1d1a608-7474-4ee4-8b75-1459a848b188
# Myxolydian
vcat([note.(freq) for freq=[C, D, E, F, G, A, Bb, 2C]]...)

# ╔═╡ 8c45ec80-a4dc-4ebd-a296-8739a1eb86ff
# Dorian
vcat([note.(freq) for freq=[C, D, Eb, F, G, A, Bb, 2C]]...)

# ╔═╡ b6f61f04-f944-4030-91f3-f75e15dc7fc6
# Aeolian (minor)
vcat([note.(freq) for freq=[C, D, Eb, F, G, Ab, Bb, 2C]]...)

# ╔═╡ 52782ffe-02e8-4dd1-886a-97e8a3615560
# Phrygian
vcat([note.(freq) for freq=[C, Db, Eb, F, G, Ab, Bb, 2C]]...)

# ╔═╡ d2a2ebb6-3f2a-4165-a56a-d8a2a0cd5312
# Locrian
vcat([note.(freq) for freq=[C, Db, Eb, F, Gb, Ab, Bb, 2C]]...)

# ╔═╡ 90035d61-3dba-480e-8b4f-200b65b8f3f7
md"Generally speaking the more fifths are used in the scale the bighter it sounds
and the more fourths the darker.
This depends only on the relation to the tonic,
since modes by definition contain all the same intervals."

# ╔═╡ fc024776-6567-481b-bcce-c87d10460243
md"### Simple tetrachord constructions
If we put the closest intervals to the root, up and down a fifth,
we get an octave split into two intervals of a fourth."

# ╔═╡ e8f1a177-9a0e-48a0-9fd7-8c00defd286a
vcat([note.(freq) for freq=[C, F, G, 2C]]...)

# ╔═╡ ce64e368-01c3-49d3-ae11-ac889edfcff0
md"The interval in the middle, between the fourth and fifth, is $9:8$.
This gives a nice sounding interval that is small enough to use in melodic lines (as a step). We can fill in the remaining fourths with whole steps to bridge gaps in melodic lines.
If we use one whole step per fourth we get 4 of the pentatonic scales again,
and it is always one of the pentatonic modes derived from stacking.

If we use two whole steps per fourth
we get 7 note scalse with a semitone per fourth.
This is one kind of tuning by tetrachords: 4 notes to a 4th.
Tetrachord constructions include but go beyond this 3-limit construction using two whole steps and a semitone.
Using two whole steps there are 3 options per tetrachord, w w s, w s w, and s w w.
I call them major, dorian, and phrygian,
because if you use two major tetrachords you get a major scale,
two dorian and it's a dorian scale,
two phrygian and it's a phrygian scale.
We get 9 scales in total combining tetrachords,
only 5 of which are modes (the modes with both a fourth and fifth).
The four remaining scales are:"

# ╔═╡ ae376c87-f212-4e19-8c2d-af79875ef79f
# (s w w) (w w s) Neopolitan major
vcat([note.(freq) for freq=[C, Db, Eb, F, G, A, B, 2C]]...)

# ╔═╡ f8ff6af6-10f2-4f13-a5f4-b0e1a94ca95d
# (w s w) (w w s) Melodic minor
vcat([note.(freq) for freq=[C, D, Eb, F, G, A, B, 2C]]...)

# ╔═╡ c377016e-121a-4c9a-99c7-c81119576e52
# (w w s) (s w w) Myxolydian b6
vcat([note.(freq) for freq=[C, D, E, F, G, Ab, Bb, 2C]]...)

# ╔═╡ 8b82955f-3456-4e7a-a238-8e8a8690a718
# (s w w) (w s w) Dorian b2
vcat([note.(freq) for freq=[C, Db, Eb, F, G, A, Bb, 2C]]...)

# ╔═╡ 913b0f4d-b5cd-40c6-8148-1a227128a384
md"These have fewer perfect fifths
but still have the perfect intervals of the tonic
and good melodic structure.
Perhaps more importantly the modes which are also tetrachord scales
are the most used modes, with lydian and locrian being harder to use as they lack
either the perfect fourth or fifth of the tonic"

# ╔═╡ 65751878-9c60-4104-81b8-e4d07f77700a
md"## 3-Limit Harmony
Since the important intervals in 3-limit are the the fifth,
and by octave the fourth,
these are the intervals that are harmonic.
This doesn't allow the construction of triad based chords,
which are properly part of 5-limit harmony which includes thirds.
Because of this 3-limit harmony is fairly limited.
There are fewer notes which are consonant, limiting harmonic motion
and the number of voices that can be used at once compared to 5-limit.
Harmony is constructed by stacking 4ths or 5ths.
With 4 notes stacked we get 8 options for chords:"

# ╔═╡ 09210adf-a9f7-4c3c-99fa-99e41dc96e6c
# Stacked fifths, brightest
sum(note.(freq) for freq in [C, G, 2*D, 2*A])/4

# ╔═╡ 2d8892d1-c82c-4ec7-99c5-aad3059ce4d5
# 1 3/2 9/4 3 (5 5 4) octave on the 5th
# Probably best thought of as an inversion of (5 4 4)
sum(note.(freq) for freq in [C, G, 2*D, 2*G])/4

# ╔═╡ 02011bda-c1a0-4c30-a670-63bc4125fb44
# 1 3/2 2 3 (5 4 5) power chord w 5
sum(note.(freq) for freq in [C, G, 2*C, 2*G])/4

# ╔═╡ 403ee651-c86d-4ad7-b13d-5c0042a52d81
# 1 3/2 2 8/3 (5 4 4) 5 in octave 4 on top, most standard chord
sum(note.(freq) for freq in [C, G, 2*C, 2*F])/4

# ╔═╡ 55d4a2ed-4e28-43c2-b7ac-142d2c49f78a
# 1 4/3 2 3 (4 5 5) 4 in octave 5 on top, inverted (5 4 4) they have the same notes
sum(note.(freq) for freq in [C, F, 2*C, 2*G])/4

# ╔═╡ 53064534-4623-44a5-91d0-38f78b1092dd
# 1 4/3 2 8/3 (4 5 4) power chord w 4
sum(note.(freq) for freq in [C, F, 2*C, 2*F])/4

# ╔═╡ d307813b-9f62-4dc5-bc62-c0bdb07d4974
# 1 4/3 16/9 8/3 (4 4 5) octave on 4
# Probably best thought of as an inversion of (4 5 5)
sum(note.(freq) for freq in [C, F, Bb, 2*F])/4

# ╔═╡ 8921e867-7a01-4a2c-8704-a3469a4739af
# stacked 4ths
sum(note.(freq) for freq in [C, F, Bb, Eb])/4

# ╔═╡ da1614c8-08e6-499f-b97a-41da62e67fd2
md"We get stacked 5ths, power chords, balanced chords, and stacked 4ths,
not including the inversions.
Dropping powerchords as a simplification 
we chose between 3 different chord qualities
for each chord:
the bright stacked 5ths,
the balanced chords with 4 and 5
and the dark stacked 4ths.
The harmony can be simplified with power chords,
and the balanced chords have inversions to help smooth root motion."

# ╔═╡ 1d078418-f252-403b-8205-dab834a2536a
# Stacked fifths
sum(note.(freq) for freq in [C, G, 2*D, 2*A])/4

# ╔═╡ b9eeff90-d4f2-4d7d-bf0f-7387922e1572
# balanced chord
sum(note.(freq) for freq in [C, G, 2*C, 2*F])/4

# ╔═╡ a13cfc17-3c9d-408d-a672-34ca1a28466d
# stacked 4ths
sum(note.(freq) for freq in [C, F, Bb, Eb])/4

# ╔═╡ dd3d10ca-8a70-417a-95cc-2398178403b1
md"## Building 3-limit chords on the C major scale"

# ╔═╡ 9158df86-039c-4497-90e9-cf3b1ad753d2
# I chord
sum(note.(freq) for freq in [C, F, 2*C, 2*G])/4

# ╔═╡ e1ca3cb4-f933-4895-9195-16f82a0cf8c8
# II chord
sum(note.(freq) for freq in [D, A, 2*D, 2*G])/4

# ╔═╡ 7f59447f-bfca-4d82-83d4-c9ffca771931
# III chord
sum(note.(freq) for freq in [E, A, 2*E, 2*B])/4

# ╔═╡ 79c5e37e-95d4-43d2-9972-ff69be40d97a
# IV chord
sum(note.(freq) for freq in [F, 2*C, 2*G, 2*D])/4

# ╔═╡ 2d5be56b-7f23-4a11-b29b-75559bf02af8
# V chord
sum(note.(freq) for freq in [G, 2*C, 2*G, 2*D])/4

# ╔═╡ 780a0596-9020-4195-89e1-9035c5d1ee43
# VI chord
sum(note.(freq) for freq in [A, E, 2*A, 2*D])/4

# ╔═╡ 6bfe1534-4844-4ec1-aef4-1e56b2667228
# VII chord
sum(note.(freq) for freq in [B, E, 2*A, 2*D])/4

# ╔═╡ Cell order:
# ╟─f3cf3e66-b414-11eb-129f-1f82995a6e8e
# ╠═c21d05c1-bd10-46cc-bc5a-d737d047131f
# ╠═99422a59-ffe4-4dc0-bb80-2245d41aaa74
# ╠═21ad163c-9031-4ebb-8dd2-a1a297f97456
# ╠═5dedb960-1524-475b-b870-61a8254c7993
# ╠═e0aff7b7-a355-4138-87cd-d5113ee82623
# ╟─752a031e-7c58-4af6-a2ab-965a1e43760e
# ╠═8882303c-4ae7-44a5-8d38-8c4e73f15892
# ╠═87212fe7-ac94-4173-b3b6-a9afe58783ea
# ╟─61482b04-b6fb-495a-94ae-92a84317f6f5
# ╠═799e0825-ac5c-46e5-a34a-685a5382cf63
# ╟─69e54625-9e7a-4a62-995d-ff4550e9167b
# ╠═61f66f37-1568-4fb6-b0b0-ae6d13110c73
# ╠═20b4c50b-39f8-494e-be2b-d9f9f81fa8e5
# ╠═4a6d05fb-341a-4487-9685-d6092dea902c
# ╠═28fe6d6b-bbab-4cde-b437-001f7894a2f0
# ╠═1619d9c4-d151-4060-9172-954500935545
# ╠═fe4516c3-2008-492f-8563-3daa92470175
# ╠═9a19129d-3b2a-4a59-aa72-0f8f6a349e53
# ╠═cf4fe547-f2e1-4e2f-8e52-168cce001061
# ╟─876750d7-d1c2-44d4-a367-984d060870c4
# ╠═bbdace00-0b8e-4963-af37-528b2a4aaafc
# ╠═0ea9acfe-4045-4804-bc78-c802cf0f5577
# ╠═834e0df6-c976-4c22-b1c4-95e9c8d3cade
# ╠═a83525a3-1228-4d50-8f85-df63ee11552b
# ╠═4708c80b-3166-4c21-992a-8d07ceb52bf2
# ╠═ee828da7-05f1-4fc2-9db7-589a9c1b735d
# ╠═83223d7d-fd40-4043-ae12-77b501fe1136
# ╠═b1d1a608-7474-4ee4-8b75-1459a848b188
# ╠═8c45ec80-a4dc-4ebd-a296-8739a1eb86ff
# ╠═b6f61f04-f944-4030-91f3-f75e15dc7fc6
# ╠═52782ffe-02e8-4dd1-886a-97e8a3615560
# ╠═d2a2ebb6-3f2a-4165-a56a-d8a2a0cd5312
# ╟─90035d61-3dba-480e-8b4f-200b65b8f3f7
# ╟─fc024776-6567-481b-bcce-c87d10460243
# ╠═e8f1a177-9a0e-48a0-9fd7-8c00defd286a
# ╟─ce64e368-01c3-49d3-ae11-ac889edfcff0
# ╠═ae376c87-f212-4e19-8c2d-af79875ef79f
# ╠═f8ff6af6-10f2-4f13-a5f4-b0e1a94ca95d
# ╠═c377016e-121a-4c9a-99c7-c81119576e52
# ╠═8b82955f-3456-4e7a-a238-8e8a8690a718
# ╟─913b0f4d-b5cd-40c6-8148-1a227128a384
# ╟─65751878-9c60-4104-81b8-e4d07f77700a
# ╠═09210adf-a9f7-4c3c-99fa-99e41dc96e6c
# ╠═2d8892d1-c82c-4ec7-99c5-aad3059ce4d5
# ╠═02011bda-c1a0-4c30-a670-63bc4125fb44
# ╠═403ee651-c86d-4ad7-b13d-5c0042a52d81
# ╠═55d4a2ed-4e28-43c2-b7ac-142d2c49f78a
# ╠═53064534-4623-44a5-91d0-38f78b1092dd
# ╠═d307813b-9f62-4dc5-bc62-c0bdb07d4974
# ╠═8921e867-7a01-4a2c-8704-a3469a4739af
# ╟─da1614c8-08e6-499f-b97a-41da62e67fd2
# ╠═1d078418-f252-403b-8205-dab834a2536a
# ╠═b9eeff90-d4f2-4d7d-bf0f-7387922e1572
# ╠═a13cfc17-3c9d-408d-a672-34ca1a28466d
# ╟─dd3d10ca-8a70-417a-95cc-2398178403b1
# ╠═9158df86-039c-4497-90e9-cf3b1ad753d2
# ╠═e1ca3cb4-f933-4895-9195-16f82a0cf8c8
# ╠═7f59447f-bfca-4d82-83d4-c9ffca771931
# ╠═79c5e37e-95d4-43d2-9972-ff69be40d97a
# ╠═2d5be56b-7f23-4a11-b29b-75559bf02af8
# ╠═780a0596-9020-4195-89e1-9035c5d1ee43
# ╠═6bfe1534-4844-4ec1-aef4-1e56b2667228
