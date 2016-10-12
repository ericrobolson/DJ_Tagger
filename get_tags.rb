require "id3tag"
require 'FileUtils'

# format:
#	bpm [Title] - (Artist) - KEY

MAX_LENGTH = -1

def Format(originalStr, length, padChar)
	str = originalStr
	
	if (length != -1)
		while (str.length > length)
			str = str.chop
		end
		
		padBefore = false
		while (str.length < length)
			if (padBefore == true)
				padBefore = false
				str = padChar + str
			else
				padBefore = true
				str = str + padChar
			end
		end	
	end
	
	return str.gsub(/[^0-9A-Za-z\[\] ]/i, '')
end
	
folder_path = 'mp3_files/'

completed = 0

Dir.glob(folder_path + '*.mp3') do |file|
	mp3_file = File.open(file, "rb")
	
	tag = ID3Tag.read(mp3_file)
		
	# set the BPM; if it's less than 100, then pad with zeros
	bpm = tag.get_frame(:TBPM).content.to_i.to_s
	while (bpm.length < 3)
		bpm = '0' + bpm
	end
		
	title = Format(tag.title, MAX_LENGTH, ' ')
	artist = Format(tag.artist, MAX_LENGTH, ' ')
	key = Format(tag.get_frame(:COMM).content, MAX_LENGTH, ' ')
		
	updatedFileName = "#{bpm} - [#{title}] - (#{artist}) - #{key}"
	
	newFile = folder_path + updatedFileName + File.extname(file)

	mp3_file.close
	
	File.rename(file, newFile)
	completed +=1
	puts 'Completed: ' + completed.to_s
end

puts 'FIN.'