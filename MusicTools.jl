module MusicTools

function envalope(levels, lengths)
    return 2 .^ reduce(vcat, 
			[range(levels[i], levels[i+1], length=lengths[i]) 
			  for i=1:length(lengths)]) .- 1
end

end
