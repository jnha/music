### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ 82abdf71-6f38-4957-8bf7-044d36008bbd
using FFTW, SampledSignals, Plots

# ╔═╡ 02e74af4-b5ac-11eb-3971-e79cdb113be1
md"# Discrete Summation fomulas
Discrete summation fomulas can be used to create waveforms with
harmonics at regular intervals.
Discrete summation formulae can be parameterized and combined to make a variety of spectra but here we will look at basic every harmonic (saw-like) and an odd harmonic (square-like) tones"

# ╔═╡ f1e8126d-02c0-42c7-9b84-f84cfc17b391
begin
    fs = 8000
	freqs = SampleBuf(Array(LinRange(0, 2*pi*220, fs)), fs)
	t = Array(0:1/100:1) * 2 * pi
end

# ╔═╡ 65e90c08-5ca0-4ea6-a9d5-2eb2a5a85c81
# A naive sin sum
function sine_sum(a, t, b, n)
	sum(a^i*sin(t + i*b) for i=0:n)
end

# ╔═╡ 94bf7a3f-752c-4130-b908-c8c14a32e247
# An equivalent closed form calculation
function dsf(a, t, b, n)
	"""
	a: ratio between adjacent harmonics
	t: base frequency
	b: frequency offset between harmonics
	   (harmonics of t + mb for 0 <= m <= n)
	n: number of harmonics
	"""
	out = sin(t) - a*sin(t-b)
	out -= a^(n+1)*(sin(t + (n+1)*b) - a*sin(t + n*b))
	out /= 1 + a*a - 2*a*cos(b)
end

# ╔═╡ ea9f553a-b624-46d0-a3db-df1ec5a1dc7b
begin
	# Demonstration that they are the same, try random values
	a, t2, b, n = .234, .34534, .234, 34
	sine_sum(a, t2, b, n), dsf(a, t2, b, n)
end

# ╔═╡ 09eec3c8-55c6-4b69-8c6a-21f64d261713
function normalize(tone)
	m = minimum(tone)
	M = maximum(tone)
	2*(tone.-m)/(M-m) .-1
end

# ╔═╡ 4e5cc60c-5d67-4cd3-afa0-6ab938e22f65
function plotfreqs(tone, title)
	freqs = fft(tone) |> fftshift
	domain = FFTW.fftfreq(length(tone), fs) |> fftshift  
    plot(domain, 10*log10.(abs.(freqs)/fs), title=title,
		xlimit=(0, fs/2), ylimit=(-50, 0))
end

# ╔═╡ ed2e86f6-17cd-4ae7-821a-ab935111aca6
function dsfsaw(t)
	dsf(.8, t, t, 16)/3
end

# ╔═╡ c377d413-6dbc-4175-b418-0f71bf2b29aa
dsfsaw_tone = normalize(dsfsaw.(freqs))

# ╔═╡ 989d247f-84d8-46b9-ba18-abaaec50a94d
plotfreqs(dsfsaw_tone, "DSF saw Spectrum")

# ╔═╡ e6930c81-3007-4e35-a695-a8b13f32b0e9
md"DSF can be used to create very bright sounds like a saw or square without aliasing. It also can mimic the sharp cutoff above a limit that a filter would produce. However the amplitude of the harmonics is geometric $(a^n)$ rather than harmonic $(1/n)$ so an exact bandlimited saw or square can't be replicated"

# ╔═╡ Cell order:
# ╟─02e74af4-b5ac-11eb-3971-e79cdb113be1
# ╠═82abdf71-6f38-4957-8bf7-044d36008bbd
# ╠═f1e8126d-02c0-42c7-9b84-f84cfc17b391
# ╠═65e90c08-5ca0-4ea6-a9d5-2eb2a5a85c81
# ╠═94bf7a3f-752c-4130-b908-c8c14a32e247
# ╠═ea9f553a-b624-46d0-a3db-df1ec5a1dc7b
# ╟─09eec3c8-55c6-4b69-8c6a-21f64d261713
# ╟─4e5cc60c-5d67-4cd3-afa0-6ab938e22f65
# ╠═ed2e86f6-17cd-4ae7-821a-ab935111aca6
# ╠═c377d413-6dbc-4175-b418-0f71bf2b29aa
# ╠═989d247f-84d8-46b9-ba18-abaaec50a94d
# ╟─e6930c81-3007-4e35-a695-a8b13f32b0e9
