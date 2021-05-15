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
md"## Sinusoids
The builtin sin() and cos() functions produce sinusoidal waves, they are roughly
equivalent for this, being phase shifted versions of each other."

# ╔═╡ 664b9502-13de-4fdf-971c-66cf0ea47c3b
plot(t, sin.(t))

# ╔═╡ 5e805acc-c6b1-4de5-8bc1-5bdcbd84ca04
sine_tone = sin.(freqs)

# ╔═╡ 2a51d397-322b-414b-9d9f-a1e8ba6b2364
plotfreqs(sine_tone, "Sine Spectrum")

# ╔═╡ dd813478-66a1-4d3e-9872-322e7b521e11
md"## Modulo waveforms
### Sawtooth
Using the periodic behavior of the remainder operator we get a sawtooth wave.
However, making a sawtooth directly like this gives aliasing
since this equivalent to sampling an analog sawtooth wave with all harmonics.
Harmonics higher than half the sampling rate cannot accurately be represented
and appear as lower frequencies when reproducing the sound.
This aliasing shows up as noise in the signal that is visible on the frequency graph.
"

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
md"
### Triangle
The jagged shape of the sawtooth wave, with it's sharp discontinuity,
is why it's higher harmonics are so loud.
If we use two ramps to remove the discontinuity we get a triangle wave 
with harmonics that fall off more quickly.
The aliasing is reduced since the harmonics are softer by the time they reach the frequency limit. It also no longer has even harmonics, since the second half is the first half upside down."

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
We can use polynomials of a sawtooth wave to get various periodic waveforms.
If the two endpoints are equal the wave will be continuous.
If the derivitives at the endpoints are equal the waveform will be smooth.
Smooth waveforms have harmonics that fall off even faster than continuous waveforms.

Using a parabola we get harmonic roll-off similar to a triangle wave
but including the even harmonics:
"

# ╔═╡ 1f127661-47b0-4498-9fc2-857f314b6869
function poly2(t)
	"""
	Parabolic waveform
	since t^2 gives output in [0, 1] we use 2t^2-1 to get output in [-1,1]
	
	Note that since f' = 2x + b is linear we can't make a smooth function
	since no two points can be equal
	"""
	t = t/pi %2 -1
	2*t*t - 1
end

# ╔═╡ 99f21cb1-b50f-4e8b-9d97-8bf5297afbec
poly2_tone = poly2.(freqs)

# ╔═╡ 8802e5fe-8416-4c67-a1f0-b99bb6af3e3f
plot(t, poly2.(t))

# ╔═╡ b561d76e-e2a7-4c3d-9677-42f8b5661b7c
# Kind of like a triangle wave but with even harmonics
plotfreqs(poly2_tone, "Poly2 Spectrum")

# ╔═╡ 09d7e4f3-fed8-4fc8-b598-03ecc8e75d6f
md"With a cubic we can get a smooth function.
This has harmonics that fall off quickly enough that there is no noticable aliasing,
even at this low of a samplerate.
"

# ╔═╡ aff77549-c6da-4329-8e92-5f1fb561ece6
function poly3(t)
	"""
	f(x) = x^3 + bx^2 + cx
	function is continuous when
	1 + b + c = f(1) = f(-1) = -1 + b - c
	2c = -2, c = -1
	
	f'(x) = 3x^2 + 2bx - 1
	function is smooth when
    3 + 2b - 1 = f'(1) = f'(-1) = 3 - 2b - 1
	4b = 0, b = 0

	f(x) = x^3 - x
	f'(x) = 3x^2-1 = 0  when x = +-1/sqrt(3)
	f(-1/sqrt(3)) = -1/sqrt(3)/3+1/sqrt(3) = 2/(3sqrt(3))
	We scale by the inverse 3sqrt(3)/2
	"""
	t = t/pi%2-1
	x = 3*sqrt(3)/2*t*(t*t - 1)
end

# ╔═╡ e91b624c-cef9-4f74-8bf0-76a484c9c895
poly3_tone = poly3.(freqs)

# ╔═╡ 6880cf94-23ee-4a96-8b9f-0417fc239374
plot(t, poly3.(t))

# ╔═╡ 4caa26e8-c5ce-4d30-b80b-d3ed7659efa0
# Here there is no aliasing >-40db
plotfreqs(poly3_tone, "Poly3 Spectrum")

# ╔═╡ 1701a11b-b17b-499a-bf5f-0d721c026590
md"As we smooth the function more by setting higher derivitives equal
the polynomials approach a pure sine tone"

# ╔═╡ e060b886-4af2-4692-8882-79ceabe64ff1
function normalize(tone)
	""" Normalizing polynomial waveforms directly is annoying
	so we will use this function instead of calculating minimum and maximums"""
	m = minimum(tone)
	M = maximum(tone)
	2*(tone.-m)/(M-m) .-1
end

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

# ╔═╡ f1a60f5c-53c6-4533-b3ed-e715fb67d7ba
poly4_tone = normalize(poly4.(freqs, 0))

# ╔═╡ 788ec89e-c1d0-498b-8e8c-82de0bc4eda6
plot(t, normalize(poly4.(t, 0)))

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

# ╔═╡ Cell order:
# ╟─f8ba933c-a1e3-11eb-2263-17f14870c1fa
# ╠═06240e71-df45-4f63-b797-4042432e6716
# ╠═bfacded1-6007-4e18-aba1-1b7325878dd2
# ╠═65dbcdfe-2dbd-4b28-ab59-fb12425913ca
# ╟─4bd75a55-4457-4625-a184-a2f7490cbf0e
# ╠═664b9502-13de-4fdf-971c-66cf0ea47c3b
# ╠═5e805acc-c6b1-4de5-8bc1-5bdcbd84ca04
# ╠═2a51d397-322b-414b-9d9f-a1e8ba6b2364
# ╠═dd813478-66a1-4d3e-9872-322e7b521e11
# ╠═a2357e48-116a-4df1-a52d-100533bad25d
# ╠═50824ffc-622d-4a00-acce-558cecf79e55
# ╠═3ae066cb-b5f2-4913-8a73-20348a401026
# ╠═7bd89cfd-9894-4644-b0e4-cae8a63cda9a
# ╠═dfa8eb03-2955-4bb6-b9ca-eb7cd6583e57
# ╠═a9f4a512-c8b4-474a-a93c-2cef99db534c
# ╠═f6f28913-cbfa-48f8-98ab-0d5ed267b350
# ╠═231185ea-8913-490d-8fe8-261983552457
# ╠═b627d7af-55d1-4d97-8f15-7f0d172f9b5a
# ╟─99708158-d74e-4311-a10f-d0ac4f79d4f2
# ╠═1f127661-47b0-4498-9fc2-857f314b6869
# ╠═99f21cb1-b50f-4e8b-9d97-8bf5297afbec
# ╠═8802e5fe-8416-4c67-a1f0-b99bb6af3e3f
# ╠═b561d76e-e2a7-4c3d-9677-42f8b5661b7c
# ╠═09d7e4f3-fed8-4fc8-b598-03ecc8e75d6f
# ╠═aff77549-c6da-4329-8e92-5f1fb561ece6
# ╠═e91b624c-cef9-4f74-8bf0-76a484c9c895
# ╠═6880cf94-23ee-4a96-8b9f-0417fc239374
# ╠═4caa26e8-c5ce-4d30-b80b-d3ed7659efa0
# ╠═1701a11b-b17b-499a-bf5f-0d721c026590
# ╠═e060b886-4af2-4692-8882-79ceabe64ff1
# ╠═85236c40-9c9c-4e00-b8e8-54787a5760af
# ╠═f1a60f5c-53c6-4533-b3ed-e715fb67d7ba
# ╠═788ec89e-c1d0-498b-8e8c-82de0bc4eda6
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
