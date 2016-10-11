require "id3tag"


# format:
#	bpm [Title] - (Artist) - KEY

mp3_file = File.open('01 Give It To Me Twice (feat. Sean K - [Am] 8A.mp3', "rb")

tag = ID3Tag.read(mp3_file)

# set the BPM; if it's less than 100, then pad with zeros
bpm = tag.get_frame(:TBPM).content.to_i.to_s
while (bpm.length < 3)
	bpm = '0' + bpm
end

title = tag.title


artist = tag.artist

key = tag.get_frame(:COMM).content

puts "#{bpm} - [#{title}] - (#{artist}) - #{key}"


