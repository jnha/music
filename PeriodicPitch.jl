### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ 93c3b8d4-b33e-11eb-335d-2b51a80e19df
using FFTW, Plots, Random, SampledSignals

# ╔═╡ d2818fb6-fb0d-4362-9aed-151f2076a8de
fs = 48000

# ╔═╡ 13f5d9f2-e81c-4513-baa8-6d6b3708d82a
function plotfreqs(tone, title)
	freqs = fft(tone) |> fftshift
	domain = fftfreq(length(tone), fs) |> fftshift
	# Shift by a little bit to avoid taking the log of 0
	decebels = 10*log10.((abs.(freqs).+0.01)/fs) 
    plot(domain, decebels, title=title, xlimit=(0, fs/2), ylimit=(-50, 0))
end

# ╔═╡ 55962503-6a3f-4caf-99e1-0f3b542ef5e4
md"# White noise
Generating a completely random sound clip with a uniform distribution gives white noise, a sound with equal amounts of every frequency."

# ╔═╡ 76f78ca5-b6bc-4fb0-9a62-edb03a0b2f17
white = SampleBuf([rand()-.5 for _ in 1:fs], fs)

# ╔═╡ 1de5a3f9-7570-4bda-b796-225bfe31fc4e
plot(white)

# ╔═╡ c0441dfb-58bb-468d-8c41-ca3d514322bf
plotfreqs(2*white, "White Noise Spectrum")

# ╔═╡ 67790146-df44-40ec-abaf-1b4dfccb8b7b
md"# Periodic Noise
What happens if instead of using completely random noise, we repeat a short sample of white noise?"

# ╔═╡ fa4d47c8-6bea-4a57-a9e6-6809c3507b9e
period = 120

# ╔═╡ a4b1e0b8-3988-495c-b0ed-992ee2f8acac
frequency = fs ÷ period

# ╔═╡ 67007aff-ffd1-4602-8768-80facb50221b
# The sound has a distinct pitch
begin
   base = [rand()-.5 for _ in 1:period]
   repeated = SampleBuf(repeat(base, frequency), fs)
end

# ╔═╡ e1b0967b-712e-4070-9f70-b9df70325ebe
# The plot is now noticably more regular
plot(repeated)

# ╔═╡ 9b0fa656-52bc-45b8-8721-52ff8d01eb48
plotfreqs(repeated, "Periodic Noise")

# ╔═╡ 9fb202c3-620b-4490-9bfb-25feeda655ae
md"We still have roughly equal power in all of the frequencies, but now the frequencies in the spectrum are all multiples of the frequency of repetition.
A perfectly periodic signal contains only frequencies in the harmonic series of its base frequency."

# ╔═╡ f642114c-5d34-4cf9-843d-35999d2f1587
md"# Odd harmonics with periodic noise
We can remove the even harmonics by making the second half of the waveform
the negative of the first half of the waveform."


# ╔═╡ 5c8e0d8e-b0a0-4fb6-b43f-41354a4e1ddc
begin
	oddbase = [base[1:period÷2]; -base[1:period÷2]]
	oddnoise = SampleBuf(repeat(oddbase,frequency÷2), fs)
end

# ╔═╡ 8c2520cc-e6ad-48d3-bd94-6cb1b8999fed
plotfreqs(oddnoise, "Odd Noise Spectrum")

# ╔═╡ 69b45396-dc69-4499-b8ae-62417b89c81c
md"# Conclusion

Any periodic waveform has a pitch (base frequency) and overtones that are multiples of that pitch.

Sounds made with completely random waveforms are uncomfortably bright
and can only be made conveniently at frequencies of $\text{fs}/n$ for integer $n$.
however this experiment shows how the harmonic series gives the overtones of any arbitrary periodic signal,no matter how convoluted, as well as what conditions will give only odd harmonics. This shows why the sawtooth (all harmonics) and square wave (odd harmonics) are so useful as starting points for approximating a large class of pitched sounds, since they contain the same harmonics but at the wrong porportions.

It's important to note that there are sounds with distinct pitches that aren't perfectly periodic, but contain multiple periodic signals whose periods don't line up to create a simple repeating pattern (i.e. frequencies that are irrational ratios to each other). Pitched drums provide important examples of these sorts of sounds.
"

# ╔═╡ Cell order:
# ╠═93c3b8d4-b33e-11eb-335d-2b51a80e19df
# ╠═d2818fb6-fb0d-4362-9aed-151f2076a8de
# ╠═13f5d9f2-e81c-4513-baa8-6d6b3708d82a
# ╠═55962503-6a3f-4caf-99e1-0f3b542ef5e4
# ╠═76f78ca5-b6bc-4fb0-9a62-edb03a0b2f17
# ╠═1de5a3f9-7570-4bda-b796-225bfe31fc4e
# ╠═c0441dfb-58bb-468d-8c41-ca3d514322bf
# ╠═67790146-df44-40ec-abaf-1b4dfccb8b7b
# ╠═fa4d47c8-6bea-4a57-a9e6-6809c3507b9e
# ╠═a4b1e0b8-3988-495c-b0ed-992ee2f8acac
# ╠═67007aff-ffd1-4602-8768-80facb50221b
# ╠═e1b0967b-712e-4070-9f70-b9df70325ebe
# ╠═9b0fa656-52bc-45b8-8721-52ff8d01eb48
# ╠═9fb202c3-620b-4490-9bfb-25feeda655ae
# ╠═f642114c-5d34-4cf9-843d-35999d2f1587
# ╠═5c8e0d8e-b0a0-4fb6-b43f-41354a4e1ddc
# ╠═8c2520cc-e6ad-48d3-bd94-6cb1b8999fed
# ╠═69b45396-dc69-4499-b8ae-62417b89c81c
