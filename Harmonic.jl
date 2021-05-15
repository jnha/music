### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ b7433dc1-846b-4173-ad51-f7598cd263a1
using FFTW, Plots, SampledSignals

# ╔═╡ 37f59728-aeae-4b15-ba8c-a90368dfa8f0
begin
    fs = 48000
	freqs = Array(LinRange(0, 2*pi*200, fs))
end

# ╔═╡ cfc3b26d-d2da-4128-9ef2-a9494c4c25e5
function plotfreqs(tone, title)
	freqs = fft(tone) |> fftshift
	domain = fftfreq(length(tone), fs) |> fftshift
	plot(domain, 10*log10.(abs.(freqs)/fs), title=title, xlimit=(0, 2000), ylimit=(-50, 0))
end

# ╔═╡ b70c60fd-b29a-46f3-8daf-e6d7277156ca
function plotfreqs!(tone, title)
	freqs = fft(tone) |> fftshift
	domain = fftfreq(length(tone), fs) |> fftshift
	plot!(domain, 10*log10.(abs.(freqs)/fs), title=title, xlimit=(0, 2000), ylimit=(-50, 0))
end

# ╔═╡ baafd0a2-b449-11eb-0654-172c64b81fd6
md"# The Harmonic Series
Periodic sounds have a base frequency that is the reciprocal of the period,
and also contain components (overtones) of integer multiples of the base frequency.
The amplitudes of the overtones determine the timbre of the sound.
"

# ╔═╡ 7a4f0f06-6b37-4a3c-81e4-8004462da33a
function note(t)
	t = t/pi%2-1
	t = 3*sqrt(3)/2*t*(t*t-1)
end

# ╔═╡ ef073029-a63e-4625-aecf-0cde96af5686
tone = SampleBuf(note.(freqs), fs)

# ╔═╡ 9997ac3d-3cae-4bb5-8290-6ca53f431533
plotfreqs(tone, "Frequencies of a single 200 Hz note")

# ╔═╡ dcd90ce9-dfc0-42ed-990a-55710c32b34e
md"## Intervals
If we play two unrelated notes at the same time we get two harmonic series"

# ╔═╡ 7f363c48-a194-4494-bb59-d5e00db70bd2
begin
   ratio=1+rand()
   plotfreqs(note.(freqs), "First note")
   plotfreqs!(note.(ratio*freqs), "Second note")
end

# ╔═╡ 9e45b6c3-a674-4b1f-b93e-11b4a99a22da
dissonant = SampleBuf((note.(freqs) + note.(ratio*freqs))/2, fs) 

# ╔═╡ 07312f0d-59d9-45ee-b60a-c6ecfc2bc0df
# The frequencies of the combined note is the sum of each notes frequencies
plotfreqs(dissonant, "Two notes frequencies")

# ╔═╡ bfd2d6b6-2863-41ee-9b6a-c99ed19f8d7d
md"""## Octave
If we use frequencies in a $1:2$ ratio the harmonic series line up.
Every frequency is an overtone of the lower note.
This single harmonic series has more pronounced even overtones.
Because there is a single harmonic series,
these two notes combined are equivalent to a single note
with a different timbre.
With real world sounds different timbres, the sound source locations,
and innacuracies of analog tuning make this equivalence inexact.
"""

# ╔═╡ 3813605c-e5c8-4bd3-9813-f553d22d47b2
begin
   plotfreqs(note.(freqs), "")
   plotfreqs!(note.(2*freqs), "Octave")
end

# ╔═╡ 6a831a92-a222-48e8-abfb-72bc9f3e0fb9
octave = SampleBuf(note.(freqs)/2 + note.(2*freqs)/2, fs)

# ╔═╡ 0b9c89bf-291e-4b93-8632-f2d5117d25a4
md"If we take a tone with only odd harmonics we can construct an octave with no harmonics in common but that still sounds like a single note because of the shared harmonic series. The notes have to be scaled so that the curve of the harmonics line up to sound cohesive."

# ╔═╡ a4882ae0-32ed-4db4-ba0c-165081128f2d
function odd(t)
	t = t/pi%2-1
	t = 4*t*(abs(t)-1)
end

# ╔═╡ e3faa985-c01a-471c-ae10-0aaaee8a6b43
odd_octave = SampleBuf(odd.(freqs) + odd.(2*freqs)/8 + odd.(4*freqs)/64, fs) 

# ╔═╡ 6049ed44-b19f-41a9-b017-860e80d62017
begin
    plotfreqs(odd.(freqs), "")
    plotfreqs!(odd.(2*freqs)/8, "")
	plotfreqs!(odd.(4*freqs)/64, "Odd harmonics combined")
end

# ╔═╡ ccb62252-fcf1-4fc8-b486-1df69ea0c1e3
md"Any $1:n$ ratio gives a similar lining up like the octave.
Unison $1:1$ being a special case that gives the exact original sound but louder.
However, since for natural timbres the higher harmonics sound less loud,
higher intervals harmonics blend less and stand out more from their root note.
If the higher note is made softer they start to blend again.
For example a $1:3$ ratio, or tritive sounds like this."

# ╔═╡ 14af9192-4b8a-49c3-9775-b4dfef343780
tritive = SampleBuf(note.(freqs)/2 + note.(3*freqs)/2, fs)

# ╔═╡ 02a98eb5-4021-4ea0-a0f8-b43c811d87b2
blend_tritive = SampleBuf(note.(freqs)/2 + note.(3*freqs)/8, fs)

# ╔═╡ 31b44424-b3f9-4ea0-8d99-28738f1fc857
md"## Fifth
Though only integer ratios will give harmonics that line up exactly
any rational ratio will have overlap.
A $2:3$ ratio, the simplest non-integer interval, gives a fifth.
The fifth is an octave below a tritave
and so the fifth and the tritave have a similar quality.
Going up a fifth $(3/2)$ is the inverse of going down a fifth $(2/3)$
a characteristic shared by all intervals."

# ╔═╡ 82582e9b-fcc0-49ae-9f3b-558e70d8f0b8
fifth = SampleBuf(note.(freqs)/2 + note.(3/2*freqs)/2, fs)

# ╔═╡ db7c4951-972b-43db-a647-6e61c8ebdf03
begin
   plotfreqs(note.(freqs), "")
   plotfreqs!(note.(3/2*freqs), "Fifth")
end

# ╔═╡ 53773643-1b58-4eee-ac11-bb30b7535fec
md"Every second harmonic of the higher note lines up 
with every third harmonic of the lower note.
Unlike playing notes in unison or octaves,
the two notes have distinct pitches, 
but unlike a random interval it's consonant.
"

# ╔═╡ 151b3663-524e-465f-9426-3f85689e9e27
md"## The Fundamental
Because of how the overtones line up,
every overtone is part of the harmonic series 
of a note that isn't being played.
for the fifth this is one octave below the lower note.
This corresponds to the period of the combined sounds,
which repeats whenever the period of both notes line up.

For an interval $n:m$ that is rational and in reduced terms,
the fundamental is as $1$ in the ratio: $1:n:m$.
So the fundamental is at the inteval 1/n from the first note 
and 1/m from the second.
The ratio $1:n$ is a measure of consonance and is equivalent to the porportion of harmonics in the second note that are also in the first.
Alternately the ratio $1:m$ is is another measure and is equivalent to the porportion
of harmonics of the first note present in the second.
Normally the lowest note of a collection
is chosen as the root, the reference point for calculating intervals,
but for chord inversions using a different note is often more convenient. 
This measure extends naturally to collections of more than 2 notes."

# ╔═╡ 24e5caba-ce1c-4436-8ca2-647b5438658a
begin
    plotfreqs(note.(freqs), "")
    plotfreqs!(note.(3/2*freqs), "")
    plotfreqs!(note.(freqs/2), "Fifth with fundamental")
end

# ╔═╡ 8adb4c0a-a29e-4cee-bb49-ee285f90ff70
md"""## The Common Overtone
Like the fundamental of a collection of notes 
is the highest note that has all of the notes as harmonics,
the dual to the fundamental is the common overtone:
The lowest note that is a harmonic of all of the notes.
The harmonic series of this note contains the frequencies
common to all the harmonic series of the other notes.

For an interval $n:m$ that is rational and in reduced terms,
the ratio with the dual fundamental is $n:m:nm$.
This is the least common multiple of $n,m,$ dual to the fundamental
which is the greatest common denominator.
The ratios $n:nm = 1:m$, and $m:nm = 1:n$ so the
common overtone gives the same measures of consonance as the
fundamental but compared with the opposite notes.
For collections of more than two notes this difference leads to
collections with simple ratios to the fundamental being different
from collections with simple ratios to their common overtone."""

# ╔═╡ 8378910d-3a2c-441e-a3b3-716d819eced9
begin
    plotfreqs(note.(freqs), "")
    plotfreqs!(note.(3/2*freqs), "")
    plotfreqs!(note.(freqs*3), "Fifth with common overtone")
end

# ╔═╡ 732ab799-970e-4ae7-a81d-cda4c79873f4
md" # Fourth
The fourth $3:4$ is an octave equivalent to the fifth.
Taking a fifth and raising the lower note by an octave
(or equivalently lowering the higher note by an octave)
gives a fourth."

# ╔═╡ df7e7e47-fe34-4250-bb0b-670fee0b56de
fourth = SampleBuf(note.(freqs)/2 + note.(freqs*4/3)/2, fs)

# ╔═╡ 518f1a8b-977b-4008-b1b7-667f0475b42c
begin
    plotfreqs(note.(freqs), "")
    plotfreqs!(note.(4/3*freqs), "")
    plotfreqs!(note.(freqs/3), "Fourth with fundamental")
end

# ╔═╡ 849e0964-2c80-4fa6-9320-5fa0c595d79a
begin
    plotfreqs(note.(freqs), "")
    plotfreqs!(note.(4/3*freqs), "")
    plotfreqs!(note.(freqs*4), "Fourth with common overtone")
end

# ╔═╡ 06b01905-7249-4492-a5b2-b9b43f1908c1
md"Other harmonic intervals work by similar rules.
Each has an integer ratio, where the interval going up is the dual of the interval going down. When treating octaves as equivalent intervals can be normalized by shifting them by octaves into the range $[1, 2]$. 
Each interval $m/n$ in $[1,2]$ has an inverse also in $[1,2]$: $2(n/m)$.
An interval and it's 'octave inverse' combine to give an octave
and they will have similar qualities."

# ╔═╡ Cell order:
# ╠═b7433dc1-846b-4173-ad51-f7598cd263a1
# ╠═37f59728-aeae-4b15-ba8c-a90368dfa8f0
# ╠═cfc3b26d-d2da-4128-9ef2-a9494c4c25e5
# ╠═b70c60fd-b29a-46f3-8daf-e6d7277156ca
# ╟─baafd0a2-b449-11eb-0654-172c64b81fd6
# ╠═7a4f0f06-6b37-4a3c-81e4-8004462da33a
# ╠═ef073029-a63e-4625-aecf-0cde96af5686
# ╟─9997ac3d-3cae-4bb5-8290-6ca53f431533
# ╟─dcd90ce9-dfc0-42ed-990a-55710c32b34e
# ╟─7f363c48-a194-4494-bb59-d5e00db70bd2
# ╠═9e45b6c3-a674-4b1f-b93e-11b4a99a22da
# ╟─07312f0d-59d9-45ee-b60a-c6ecfc2bc0df
# ╟─bfd2d6b6-2863-41ee-9b6a-c99ed19f8d7d
# ╟─3813605c-e5c8-4bd3-9813-f553d22d47b2
# ╠═6a831a92-a222-48e8-abfb-72bc9f3e0fb9
# ╟─0b9c89bf-291e-4b93-8632-f2d5117d25a4
# ╠═a4882ae0-32ed-4db4-ba0c-165081128f2d
# ╠═e3faa985-c01a-471c-ae10-0aaaee8a6b43
# ╠═6049ed44-b19f-41a9-b017-860e80d62017
# ╟─ccb62252-fcf1-4fc8-b486-1df69ea0c1e3
# ╠═14af9192-4b8a-49c3-9775-b4dfef343780
# ╠═02a98eb5-4021-4ea0-a0f8-b43c811d87b2
# ╟─31b44424-b3f9-4ea0-8d99-28738f1fc857
# ╠═82582e9b-fcc0-49ae-9f3b-558e70d8f0b8
# ╟─db7c4951-972b-43db-a647-6e61c8ebdf03
# ╟─53773643-1b58-4eee-ac11-bb30b7535fec
# ╟─151b3663-524e-465f-9426-3f85689e9e27
# ╟─24e5caba-ce1c-4436-8ca2-647b5438658a
# ╟─8adb4c0a-a29e-4cee-bb49-ee285f90ff70
# ╟─8378910d-3a2c-441e-a3b3-716d819eced9
# ╟─732ab799-970e-4ae7-a81d-cda4c79873f4
# ╠═df7e7e47-fe34-4250-bb0b-670fee0b56de
# ╟─518f1a8b-977b-4008-b1b7-667f0475b42c
# ╠═849e0964-2c80-4fa6-9320-5fa0c595d79a
# ╟─06b01905-7249-4492-a5b2-b9b43f1908c1
