### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ 06240e71-df45-4f63-b797-4042432e6716
using FFTW, Plots, SampledSignals

# ╔═╡ f8ba933c-a1e3-11eb-2263-17f14870c1fa
md"# Basic Waveforms
First let's see what basic waveforms can be made directly."

# ╔═╡ bfacded1-6007-4e18-aba1-1b7325878dd2
begin
    fs = 8000
	freqs = SampleBuf(Array(LinRange(0, 2*pi*220, fs)), fs)
	t = Array(0:1/100:1) * 2 * pi
end

# ╔═╡ 65dbcdfe-2dbd-4b28-ab59-fb12425913ca
function plotfreqs(tone, title)
	freqs = fft(tone) |> fftshift
	domain = FFTW.fftfreq(length(tone), fs) |> fftshift  
    plot(domain, 10*log10.(abs.(freqs)/fs), title=title,
		xlimit=(0, fs/2), ylimit=(-50, 0))
end

# ╔═╡ 4bd75a55-4457-4625-a184-a2f7490cbf0e
md"## Sinusoid wave
The builtin sin() and cos() functions produce sinusoidal waves, they are roughly
equivalent for this, being phase shifted versions of each other."

# ╔═╡ 664b9502-13de-4fdf-971c-66cf0ea47c3b
plot(t, sin.(t))

# ╔═╡ 5e805acc-c6b1-4de5-8bc1-5bdcbd84ca04
sine_tone = sin.(freqs)

# ╔═╡ 2a51d397-322b-414b-9d9f-a1e8ba6b2364
plotfreqs(sine_tone, "Sine Spectrum")

# ╔═╡ dd813478-66a1-4d3e-9872-322e7b521e11
md"## Modulo waveforms: Sawtooth
Using the periodic behavior modular division we get a sawtooth wave.
However, making a sawtooth directly like this causes aliasing due to the discontinuity in the waveform. The aliasing shows up as noise in the signal that is visible on the frequency graph."

# ╔═╡ a2357e48-116a-4df1-a52d-100533bad25d
function saw(t)
	t/pi % 2 - 1
end

# ╔═╡ 50824ffc-622d-4a00-acce-558cecf79e55
plot(t, saw.(t))

# ╔═╡ 3ae066cb-b5f2-4913-8a73-20348a401026
saw_tone = saw.(freqs)

# ╔═╡ 7bd89cfd-9894-4644-b0e4-cae8a63cda9a
plotfreqs(saw_tone, "Aliased Saw Spectrum")

# ╔═╡ dfa8eb03-2955-4bb6-b9ca-eb7cd6583e57
md"### Modulo waveforms: Triangle
If add a ramp down to the sawtooth wave we remove the discontinuity and get a triangle wave. Most of the aliasing is gone but there is still some from the sharp cusp."

# ╔═╡ a9f4a512-c8b4-474a-a93c-2cef99db534c
function tri(t)
	abs(t/pi%2-1)*2-1
end

# ╔═╡ f6f28913-cbfa-48f8-98ab-0d5ed267b350
plot(t, tri.(t))

# ╔═╡ 231185ea-8913-490d-8fe8-261983552457
tri_tone = tri.(freqs)

# ╔═╡ b627d7af-55d1-4d97-8f15-7f0d172f9b5a
plotfreqs(tri_tone, "Triangle Spectrum")

# ╔═╡ 99708158-d74e-4311-a10f-d0ac4f79d4f2
md" ### Polynomial waveforms
We can use polynomials to get continuous waveforms of various shapes by
wrapping the input modulo 2 pi and ensuring that the two endpoints are equal.
We can get a smooth waveform by setting the derivitives of the endpoints equal.
"

# ╔═╡ 1f127661-47b0-4498-9fc2-857f314b6869
function poly2(t)
	""" 
	We set the first and last coefficients to 1 and 0 respectively as our result
	will be normalized to the range [-1,1] anyway
	f = x^2 + bx
	1 + b = f(-1) = f(-1) = 1-b
	2b = 0, b = 0
	f = x^2
	then we scale and shift into [-1, 1]
	2(t*t) - 1
	Note that since f' = 2x + b is linear we can't make a smooth function
	"""
	t = t/pi %2 -1
	2*t*t - 1
end

# ╔═╡ 8802e5fe-8416-4c67-a1f0-b99bb6af3e3f
plot(t, poly2.(t))

# ╔═╡ 99f21cb1-b50f-4e8b-9d97-8bf5297afbec
poly2_tone = poly2.(freqs)

# ╔═╡ b561d76e-e2a7-4c3d-9677-42f8b5661b7c
# poly2 still has >-40db aliasing
# It's kind of like a triangle wave but with even harmonics
plotfreqs(poly2_tone, "Poly2 Spectrum")

# ╔═╡ e060b886-4af2-4692-8882-79ceabe64ff1
function normalize(tone)
	""" Normalizing polynomial waveforms directly is annoying
	so we will just use this function"""
	m = minimum(tone)
	M = maximum(tone)
	2*(tone.-m)/(M-m) .-1
end

# ╔═╡ aff77549-c6da-4329-8e92-5f1fb561ece6
function poly3(t)
	"""
	With a cubic we can get a smooth function

	f(x) = x^3 + bx^2 + cx
	function is continuous when
	1 + b + c = f(1) = f(-1) = -1 + b - c
	2c = -2, c = -1
	
	f'(x) = 3x^2 + 2bx - 1
	function is smooth when
    3 + 2b - 1 = f'(1) = f'(-1) = 3 - 2b - 1
	4b = 0, b = 0

	f(x) = x^3 - x
	f'(x) = 3x^2-1 = 0  when x = +-sqrt(1/3)
	f(sqrt(3)/3) = sqrt(3)/9-sqrt(3)/3 = -2sqrt(3)/9 
	
	"""
	b = 0
	t = t/pi%2-1
	x = t*(t*(t+b) - 1)
end

# ╔═╡ 6880cf94-23ee-4a96-8b9f-0417fc239374
plot(t, 9/2/sqrt(3)*poly3.(t))

# ╔═╡ e91b624c-cef9-4f74-8bf0-76a484c9c895
poly3_tone = normalize(poly3.(freqs))

# ╔═╡ 4caa26e8-c5ce-4d30-b80b-d3ed7659efa0
# Here there is no >-40db aliasing, so the aliasing is now negligible
plotfreqs(poly3_tone, "Poly3 Spectrum")

# ╔═╡ 85236c40-9c9c-4e00-b8e8-54787a5760af
function poly4(t, b)
	"""
	f = x^4 + bx^3 + cx^2 + dx
	1+b+c+d = f(1) = f(-1) = 1-b+c-d
	2(b+d) = 0, b+d = 0, d = -b
	-4+3b+2c-b = f'(1) = f'(-1) = -4+3b-2c-b
	2(4+2c) = 0, 4+2c = 0, c = -2
	f = x^4 + bx^3 - 2x^2 - bx
	"""
	t = t/pi%2-1
	t = (((t + b)*t -2)*t - b)*t
end

# ╔═╡ 788ec89e-c1d0-498b-8e8c-82de0bc4eda6
plot(t, normalize(poly4.(t, 0)))

# ╔═╡ f1a60f5c-53c6-4533-b3ed-e715fb67d7ba
poly4_tone = normalize(poly4.(freqs, 0))

# ╔═╡ e24388fa-d474-4770-95a0-d34627ae7a04
# No overtones reach the niquist rate, no aliasing at all
plotfreqs(poly4_tone, "Poly4 Spectrum")

# ╔═╡ bf89825a-944b-4771-a619-e4c5d1220f61
function poly5(t)
	"""
	f = ax^5 + bx^4 + cx^3 + dx^2 + ex + f
	f(-1) = 0 = -a + b -c + d + -e + f
	a+c+e = b+d+f
	f(1) = 0 = a+b+c+d+e+f = 2*(a+c+e) => a+c+e = 0
	5a-4b+3c-2d+e = f'(-1) = f'(1) = 5a+4b+3c+2d+e
	<=> 4b + 2d = 0 <=> d = -2b
	b - 2b + f = 0
	f = b
	20a+12b+6c+2d = f''(1) = f''(-1) = -20a +12b -6c +2d
	40a + 12 c = 0
	c = -10/3a
	60a+24b+6c = f'''(1) = f'''(-1) = 60a -24b + 6c
	b = 0
	"""
    t = t/pi%2-1
	a = 1
	c = -10/3*a
	b = 0
	((((a*t + b)*t + c)*t - 2*b)*t-(c + a))*t + b
end

# ╔═╡ 076a215e-1335-4974-b61e-06fa4c9e9295
begin
	plot(t, -normalize(poly5.(t)))
	plot!(t, sin.(t))
end

# ╔═╡ e5ac5d3e-1240-4a3c-bc9a-d8e8e6fec60f
poly5_tone = normalize(poly5.(freqs))

# ╔═╡ 82c3a459-0944-4637-a481-cafd15402afe
# We can see the progression of higher degree waveforms approaching the sine wave spectrum
plotfreqs(poly5_tone, "Poly5 Spectrum")

# ╔═╡ 36e284d1-a982-45c2-a0cc-dae1cc355362
md"## Odd harmonics
To get only odd harmonics 
we need the second half of the waveform 
to be the negative of the first half.
This sounds like we need an odd function where $f(-x) = -f(x)$,
but this would have the second half in reverse order.
We actually need a function where for some a, $f(x+a) = -f(x)$.
The only functions like that everywhere are already periodic,
since $f(x+2a) = -f(x+a) = f(x)$. 
So we can't solve for polynomials like before.

However a waveform with this property can be constructed very easily piecewise
as $g(x) = \{f(x)$ if $x > 0$ else $-f(x+1)\}$ from any function defined on the interval $[0,1]$.
Using the sign of $x$ we can remove the if statement by taking
$g(x) = \text{sign}(x)f(2x-\text{sign}(x))$ on the interval $[-1, 1]$, 
for a function $f(x)$ on $[-1, 1]$.

For the resulting function to be connected we need $f(-1) = f(1) = 0$.
For this function to be smooth we need $f'(-1) = -f'(1)$ as well.
Any even function ($f(x) = f(-x)$ everywhere) has both these properties,
provided that it is smooth on the interval and it is translated so that it's
endpoints are $0$.
"



# ╔═╡ 3e73b73b-79a3-4ba6-bfc5-94f39816680f
function para(t)
	""" f(x) = x^2-1
	g(x) = sign(x)f(2x-sign(x)) 
	= sign(x)((2x-sign(x))^2-1) = sign(x)((4x^2 -4xsign(x) + 1)-1)
	= 4*x(abs(x)-1)
	"""
	t = t/pi%2-1
	4*t*(abs(t)-1)
end

# ╔═╡ 97ec7198-36e8-410b-9602-d6b61f31db6b
begin
	plot(t, para.(t))
	plot!(t, sin.(t))
end

# ╔═╡ 2765c9be-3636-45de-9804-7fecb69f4a7b
para_tone = para.(freqs)

# ╔═╡ 52f4cba9-6eb4-42fe-bef5-8ea1a0f4e18a
plotfreqs(para_tone, "Parabola Spectrum")

# ╔═╡ 0ade700b-6193-4518-8470-bb787f87ba47
function ecubic(t)
	""" 
	f(x) = abs(x)^3-1
	g(x) = sign(x)f(2x-sign(x))
         = sign(x)(abs(2x-sign(x))^3-1)
	"""
	t = t/pi%2-1
	s = sign(t)
	t = s*(abs(2*t-s)^3-1)
end

# ╔═╡ f116f443-0643-4cbb-8da8-4f9a312fd82f
plot(t, ecubic)

# ╔═╡ 35acdceb-34f5-4a39-aa06-569ab6f16205
ecubic_tone = ecubic.(freqs)

# ╔═╡ d7f37c37-a912-4324-8ca2-063f7c1f3ebc
plotfreqs(ecubic_tone, "Even Cubic Spectrum")

# ╔═╡ f86cda73-edd8-4905-81e0-83a6529daacc
function quart(t)
	""" 
	f(x) = x^4-1
	g(x) = sign(x)((2x-sign(x))^4-1)
	"""
	t = t/pi%2-1
	s = sign(t)
	t = s*((2*t-s)^4-1)
end

# ╔═╡ 89fee0e4-7e7f-400b-9cc2-8b3186ab0384
plot(t, quart.(t))

# ╔═╡ b649ead1-acf8-4390-bb9e-ae876a1c7f48
quart_tone = quart.(freqs)

# ╔═╡ c492d40f-fc0d-4b06-a925-7c75bff32503
plotfreqs(quart_tone, "Quartic Spectrum")

# ╔═╡ d5e54701-36a3-45f9-ac2c-8917b2e3a09d
md"Polynomial methods are cheap to compute and have more tone than a pure sine wave but aren't inherently bandlimited and so can't make brighter sounds similar to analog square or saw waves without aliasing."

# ╔═╡ 70df2c12-dff7-49c5-b489-f8c20be01c85
md"## Combining sine waves
Since our only waveform that is bandlimited by default is sin (and cos)
we can make other waveforms with little to know aliasing by combining multiple
sin waves in various ways."

# ╔═╡ 0c0816cd-8555-4283-bce4-0c00773cbbff
md"### Discrete Summation fomulas
Discrete summation fomulas can be used to create waveforms with
harmonics at regular intervals.
Discrete summation formulae can be parameterized and combined to make a variety of spectra but here we will look at basic every harmonic (saw-like) and an odd harmonic (square-like) tones"


# ╔═╡ 68554d76-6906-4271-9dc4-a4e405a3214a
# A naive sin sum
function sine_sum(a, t, b, n)
	sum(a^i*sin(t + i*b) for i=0:n)
end

# ╔═╡ c2d1d0e0-7bac-4287-8487-022691dd8c42
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

# ╔═╡ e773e9b8-2e0c-4e99-9c5a-494a5cfb1c94
begin
	# Demonstration that they are the same, try random values
	a, t2, b, n = .234, .34534, .234, 34
	sine_sum(a, t2, b, n), dsf(a, t2, b, n)
end

# ╔═╡ 1152ff30-eb29-4550-8503-44df407838eb
function dsfsaw(t)
	dsf(.8, t, t, 16)/3
end

# ╔═╡ cb45d234-0e1d-4ce6-9dce-86320d269be2
plot(t, dsfsaw.(t))

# ╔═╡ 5dd7f92f-bcf1-4373-91f9-de25487c0e95
dsfsaw_tone = normalize(dsfsaw.(freqs))

# ╔═╡ e2520f9b-66e0-488f-8a47-ddefdd161d62
plotfreqs(dsfsaw_tone, "DSF saw Spectrum")

# ╔═╡ 7087e2d5-e66e-4d19-9478-6bf13a8cfed6
md"DSF can be used to create very bright sounds like a saw or square without aliasing. It also can mimic the sharp cutoff above a limit that a filter would produce. However the amplitude of the harmonics is geometric $(a^n)$ rather than harmonic $(1/n)$ so an exact bandlimited saw or square can't be replicated"

# ╔═╡ Cell order:
# ╟─f8ba933c-a1e3-11eb-2263-17f14870c1fa
# ╠═06240e71-df45-4f63-b797-4042432e6716
# ╠═bfacded1-6007-4e18-aba1-1b7325878dd2
# ╠═65dbcdfe-2dbd-4b28-ab59-fb12425913ca
# ╟─4bd75a55-4457-4625-a184-a2f7490cbf0e
# ╠═664b9502-13de-4fdf-971c-66cf0ea47c3b
# ╠═5e805acc-c6b1-4de5-8bc1-5bdcbd84ca04
# ╠═2a51d397-322b-414b-9d9f-a1e8ba6b2364
# ╟─dd813478-66a1-4d3e-9872-322e7b521e11
# ╠═a2357e48-116a-4df1-a52d-100533bad25d
# ╠═50824ffc-622d-4a00-acce-558cecf79e55
# ╠═3ae066cb-b5f2-4913-8a73-20348a401026
# ╠═7bd89cfd-9894-4644-b0e4-cae8a63cda9a
# ╟─dfa8eb03-2955-4bb6-b9ca-eb7cd6583e57
# ╠═a9f4a512-c8b4-474a-a93c-2cef99db534c
# ╠═f6f28913-cbfa-48f8-98ab-0d5ed267b350
# ╠═231185ea-8913-490d-8fe8-261983552457
# ╠═b627d7af-55d1-4d97-8f15-7f0d172f9b5a
# ╟─99708158-d74e-4311-a10f-d0ac4f79d4f2
# ╠═1f127661-47b0-4498-9fc2-857f314b6869
# ╠═8802e5fe-8416-4c67-a1f0-b99bb6af3e3f
# ╠═99f21cb1-b50f-4e8b-9d97-8bf5297afbec
# ╠═b561d76e-e2a7-4c3d-9677-42f8b5661b7c
# ╠═e060b886-4af2-4692-8882-79ceabe64ff1
# ╠═aff77549-c6da-4329-8e92-5f1fb561ece6
# ╠═6880cf94-23ee-4a96-8b9f-0417fc239374
# ╠═e91b624c-cef9-4f74-8bf0-76a484c9c895
# ╠═4caa26e8-c5ce-4d30-b80b-d3ed7659efa0
# ╠═85236c40-9c9c-4e00-b8e8-54787a5760af
# ╠═788ec89e-c1d0-498b-8e8c-82de0bc4eda6
# ╠═f1a60f5c-53c6-4533-b3ed-e715fb67d7ba
# ╠═e24388fa-d474-4770-95a0-d34627ae7a04
# ╠═bf89825a-944b-4771-a619-e4c5d1220f61
# ╠═076a215e-1335-4974-b61e-06fa4c9e9295
# ╠═e5ac5d3e-1240-4a3c-bc9a-d8e8e6fec60f
# ╠═82c3a459-0944-4637-a481-cafd15402afe
# ╠═36e284d1-a982-45c2-a0cc-dae1cc355362
# ╠═3e73b73b-79a3-4ba6-bfc5-94f39816680f
# ╠═97ec7198-36e8-410b-9602-d6b61f31db6b
# ╠═2765c9be-3636-45de-9804-7fecb69f4a7b
# ╠═52f4cba9-6eb4-42fe-bef5-8ea1a0f4e18a
# ╠═0ade700b-6193-4518-8470-bb787f87ba47
# ╠═f116f443-0643-4cbb-8da8-4f9a312fd82f
# ╠═35acdceb-34f5-4a39-aa06-569ab6f16205
# ╠═d7f37c37-a912-4324-8ca2-063f7c1f3ebc
# ╠═f86cda73-edd8-4905-81e0-83a6529daacc
# ╠═89fee0e4-7e7f-400b-9cc2-8b3186ab0384
# ╠═b649ead1-acf8-4390-bb9e-ae876a1c7f48
# ╠═c492d40f-fc0d-4b06-a925-7c75bff32503
# ╟─d5e54701-36a3-45f9-ac2c-8917b2e3a09d
# ╠═70df2c12-dff7-49c5-b489-f8c20be01c85
# ╠═0c0816cd-8555-4283-bce4-0c00773cbbff
# ╠═68554d76-6906-4271-9dc4-a4e405a3214a
# ╠═c2d1d0e0-7bac-4287-8487-022691dd8c42
# ╠═e773e9b8-2e0c-4e99-9c5a-494a5cfb1c94
# ╠═1152ff30-eb29-4550-8503-44df407838eb
# ╠═cb45d234-0e1d-4ce6-9dce-86320d269be2
# ╠═5dd7f92f-bcf1-4373-91f9-de25487c0e95
# ╠═e2520f9b-66e0-488f-8a47-ddefdd161d62
# ╠═7087e2d5-e66e-4d19-9478-6bf13a8cfed6
