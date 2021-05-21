
using FFTW, Plots, SampledSignals

function plotwave(wave)
    t = 2*pi*(1:100)/100
    # Broadcast map to support plotting a list of functions
    plot(t, map.(wave, Ref(t)))
end

function plotfreqs!(plt, sound, fs; kargs...)
    fs = sound.samplerate
    len = length(sound)
    domain = fftfreq(len, fs) |> fftshift
    freqs = fft(sound) |> fftshift
    # shifted slightly to avoid trying to compute log10(0)
    decibels = 10*log10.((abs.(freqs) .+ 1)/len)
    plot!(plt, domain, decibels; xlimit=(0,fs/2) , ylimit=(min(decibels...), 0), kargs...)
end

function plotfreqs!(sound, fs; kargs...)
	plotfreqs!(Plots.current(), sound, fs; kargs...)
end

function plotfreqs(sound, fs; kargs...)
    plotfreqs!(plot(), sound, fs; kargs...)
end
