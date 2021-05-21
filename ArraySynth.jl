### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 20e7b5fd-0414-4998-935b-84708e1ea89e
using Plots, PlutoUI, SampledSignals

# ╔═╡ 42a53dad-e443-4292-8f35-18f7c85631e4
include("definitions/SoundPlots.jl")

# ╔═╡ 45c3da18-ba84-11eb-12d8-b30f345e6ddd
md"# Array synthesis 
The experiment in the notebook PeriodicPitch.jl suggests 
a simple way to synthesize complicated sounds at a given pitch.
First generate an array with the waveform of the required length,
then repeat it to get a note.
This seems especially attractive for waveforms that are expensive to compute,
since it is only computed once.
Also the repetitions perfectly matching the framerate give sounds without aliasing,
or at least only aliasing that overlaps with the harmonics,
as seen in the white noise examples."

# ╔═╡ ebfb2aac-3d80-497a-8b58-4e0c235439b3
fs = 48000

# ╔═╡ 13c78f70-2b94-4330-a819-f286d0f75f20
array = 2*Array(1:400)/400 .- 1

# ╔═╡ f67e7cb4-6f7a-401e-897e-d64adb029c2b
sawtooth = SampleBuf(repeat(array, fs÷200), fs)

# ╔═╡ e8a156ce-735e-4946-a243-9970f3640756
plotfreqs(sawtooth, fs; title="Sawtooth wave by repetition")

# ╔═╡ 8e9daa59-4e89-41ca-8a80-e357f0b67c5e
md"There are two major downsides to the technique:
- The waveform needs to be recalculated for each frequency
- The waveform can only be made at periods of $n/\text{fs}$ seconds,
  which means its frequencies can only be $\text{fs}/n$ Hz where $n$ is an integer"

# ╔═╡ 67bb4c8c-8ab2-4dc7-a43a-79b00dd07657
md"## Using Lookup Tables
Instead of just repeating the waveform we can use it as a lookup table.
Then we can change how much we increment the lookup index 
to change the frequency of the note."

# ╔═╡ 45bbd3c6-2a2a-45d3-a4da-8ff1fd25d118
function sawlookup(t)
   return array[t % 400 + 1]
end

# ╔═╡ 42a5616a-ff89-4b55-8ec3-d025b01c30c4
@bind step Slider(1:10)

# ╔═╡ 9cfc65bb-c195-49da-8a11-176b54124224
plot(sawlookup.(step*(1:400)))

# ╔═╡ 36ae8b23-e946-469a-bba9-142e45421517
lookupsaw = SampleBuf(Array(step*sawlookup.(step*(1:fs))), fs)

# ╔═╡ 9446699f-6d9f-4d7d-9096-9f4e75d52aee
plotfreqs(lookupsaw, fs; title="Lookup table sawtooth wave")

# ╔═╡ bef54180-d713-4a32-a526-10a3aa5d8cfa
md"Sometimes there's a very regular pattern of aliasing and other times there isn't.
To understand this consider the pattern created by the increment.
If the increment is a divisor of the array's length it will loop around only part of the array.
If the increment is coprime it won't repeat until all array elements have been touched, and so the fundamental period is the period of the array and there can be aliasing at any of the original harmonics: This happens at increment 3 for an array of length 400. At any non-coprime non-factor a mix of the two happen and there is aliasing at a subset of the harmonics.

Lookup tables allow for frequencies of $\text{fs}/n$ and $\text{fs}/d$ where $d$ is a divisor of $n$ to be played without aliasing using the same array. Knowing this we can use array lengths that have lots of factors to get a selection of pitches from a single array. We are still limited by only getting fractions of the samplerate as freqencies and not being able to change pitch smoothly.
To overcome these limitations more sophisticated methods must be used."

# ╔═╡ Cell order:
# ╟─45c3da18-ba84-11eb-12d8-b30f345e6ddd
# ╠═20e7b5fd-0414-4998-935b-84708e1ea89e
# ╠═42a53dad-e443-4292-8f35-18f7c85631e4
# ╠═ebfb2aac-3d80-497a-8b58-4e0c235439b3
# ╠═13c78f70-2b94-4330-a819-f286d0f75f20
# ╠═f67e7cb4-6f7a-401e-897e-d64adb029c2b
# ╟─e8a156ce-735e-4946-a243-9970f3640756
# ╟─8e9daa59-4e89-41ca-8a80-e357f0b67c5e
# ╟─67bb4c8c-8ab2-4dc7-a43a-79b00dd07657
# ╠═45bbd3c6-2a2a-45d3-a4da-8ff1fd25d118
# ╠═42a5616a-ff89-4b55-8ec3-d025b01c30c4
# ╠═9cfc65bb-c195-49da-8a11-176b54124224
# ╠═36ae8b23-e946-469a-bba9-142e45421517
# ╠═9446699f-6d9f-4d7d-9096-9f4e75d52aee
# ╟─bef54180-d713-4a32-a526-10a3aa5d8cfa
