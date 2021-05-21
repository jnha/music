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

# ╔═╡ 93c3b8d4-b33e-11eb-335d-2b51a80e19df
using FFTW, Plots, PlutoUI, Random, SampledSignals

# ╔═╡ 0b19c3d5-a429-4fd8-9636-fca0417139f9
include("definitions/SoundPlots.jl")

# ╔═╡ d2818fb6-fb0d-4362-9aed-151f2076a8de
fs = 48000

# ╔═╡ 55962503-6a3f-4caf-99e1-0f3b542ef5e4
md"# White noise
Generating sound using random samples gives white noise.
It has no distinct pitch"

# ╔═╡ 76f78ca5-b6bc-4fb0-9a62-edb03a0b2f17
white = SampleBuf([2*rand()-1 for _ in 1:fs], fs)

# ╔═╡ c0441dfb-58bb-468d-8c41-ca3d514322bf
plotfreqs(white, "White Noise Spectrum")

# ╔═╡ 67790146-df44-40ec-abaf-1b4dfccb8b7b
md"# Periodic Noise
What happens if random noise is repeated?"

# ╔═╡ 30289b86-dd11-45f3-a61b-7257b6539fa9
white1hz = repeat(white, 5)

# ╔═╡ d297644a-27e1-4581-912f-e91f2ee28685
plotfreqs(white1hz, "1 Hz repeated noise")

# ╔═╡ 025f27c1-9dc6-4e7b-ae73-72a298ac93cc
md"With a period of one second the sound is still noise.
You may be able to hear artifacts at regular intervals.
I've listened to several random versions
and it can be easier or harder to pick out the repetition
depending on the particular sound generated. 

What about shorter periods?
The repetitions will become faster and more noticable.
At around 30hz it will start to have an audible pitch.
At higher frequencies the pulses smooth out into a buzzy noise with a definite pitch. 
At periods of low hundreds of frames the frequency graph shows clearly
the lines of the individual harmonics.
First at the frequency of the repetition,
and with overtones at integer multiples of that frequency."

# ╔═╡ fa4d47c8-6bea-4a57-a9e6-6809c3507b9e
@bind period Slider(100:500:8100)

# ╔═╡ ee695155-4cc7-45b6-8fae-fba482de61b1
period

# ╔═╡ f31f99a8-292e-4525-a6a6-8d0d39a5b088
frequency = fs/period

# ╔═╡ 67007aff-ffd1-4602-8768-80facb50221b
# The sound has a distinct pitch
begin
   reps = fs ÷ period
   base = white[1:period]
   repeated = repeat(base, reps)
end

# ╔═╡ 9b0fa656-52bc-45b8-8721-52ff8d01eb48
plotfreqs(repeated, "Periodic Noise")

# ╔═╡ 9fb202c3-620b-4490-9bfb-25feeda655ae
md"There is no fall off in harmonics,
their amplitude seems randomly distributed arround a flat value.
I was suprised to see how clean the spectrum is
despite using white noise as the base of the sound. 
The frequency components of any periodic sound are integer multiples
of the fundamental frequency, which is the inverse of the period."

# ╔═╡ f642114c-5d34-4cf9-843d-35999d2f1587
md"# Odd harmonics with periodic noise
We can remove the even harmonics by making the second half of the waveform
the same as the first half but flipped upside down, call this an odd sound for short. Every even partial is an even repetition, so it splits into two equal parts on the first and second halves of the waveform. To be equal to its own negative on the second half an even partial has to be $0$. Every odd partial reaches the midpoint of the waveform halfway through its own period, and so the second half is the first half offset in phase by half a period. But $\text{sin}(x+\pi) = -\text{sin}(x)$ and so odd harmonics always give odd sounds.
Since a periodic sound is the sum of its even and odd partials
and the odd partials already give an odd sound,
a sound is odd whenever the sum of its even partials are also odd,
but that only happens when the even partials are $0$.

This becomes very useful when imitating natural instruments that only contain odd harmonics, like many wind instruments."

# ╔═╡ 5c8e0d8e-b0a0-4fb6-b43f-41354a4e1ddc
oddnoise = repeat([base; -base], reps÷2)

# ╔═╡ 8c2520cc-e6ad-48d3-bd94-6cb1b8999fed
plotfreqs(oddnoise, "Odd Noise Spectrum")

# ╔═╡ Cell order:
# ╠═93c3b8d4-b33e-11eb-335d-2b51a80e19df
# ╠═d2818fb6-fb0d-4362-9aed-151f2076a8de
# ╠═0b19c3d5-a429-4fd8-9636-fca0417139f9
# ╟─55962503-6a3f-4caf-99e1-0f3b542ef5e4
# ╠═76f78ca5-b6bc-4fb0-9a62-edb03a0b2f17
# ╠═c0441dfb-58bb-468d-8c41-ca3d514322bf
# ╟─67790146-df44-40ec-abaf-1b4dfccb8b7b
# ╠═30289b86-dd11-45f3-a61b-7257b6539fa9
# ╠═d297644a-27e1-4581-912f-e91f2ee28685
# ╟─025f27c1-9dc6-4e7b-ae73-72a298ac93cc
# ╠═fa4d47c8-6bea-4a57-a9e6-6809c3507b9e
# ╠═ee695155-4cc7-45b6-8fae-fba482de61b1
# ╠═f31f99a8-292e-4525-a6a6-8d0d39a5b088
# ╟─67007aff-ffd1-4602-8768-80facb50221b
# ╠═9b0fa656-52bc-45b8-8721-52ff8d01eb48
# ╟─9fb202c3-620b-4490-9bfb-25feeda655ae
# ╟─f642114c-5d34-4cf9-843d-35999d2f1587
# ╠═5c8e0d8e-b0a0-4fb6-b43f-41354a4e1ddc
# ╠═8c2520cc-e6ad-48d3-bd94-6cb1b8999fed
