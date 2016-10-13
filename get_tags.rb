require 'id3tag'
require 'FileUtils'
require 'andand'

# format:
#	BPM - KEY - [Title] - (Artist)

MAX_LENGTH = -1

# Return a formatted string, only allowing certain whitelisted characters
def Format(originalStr, length, padChar, useSplit = true)
	if (originalStr.nil?)
		return 'UNDEFINED'
	end
	
	# The key finder that I use adds the key to the file name, which is not needed on the tagged version
	str = originalStr
	
	if (useSplit == true)
		str = str.split('-').first
	end
	str = str.rstrip.gsub(/[^0-9A-Za-z\_\'\&\(\)\,\.\-\[\] ]/i, '')
	
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
	
	return str
end
	
folder_path = 'mp3_files/'

completed = 0

# Go through the folder path, and for each MP3 file, rename it using the given file name template
Dir.glob(folder_path + "**/*/") do |folder|
	Dir.glob(folder + '*.mp3') do |file|
		mp3_file = File.open(file, "rb")
				
		tag = ID3Tag.read(mp3_file)
		
		# set the BPM; if it's less than 100, then pad with zeros
		bpm = tag.get_frame(:TBPM).andand.content.to_i.to_s
		if (bpm.nil?)
			bpm = 'UNDEFINED_BPM'
		end
		
		while (bpm.length < 3)
			bpm = '0' + bpm
		end
			
		title = Format(tag.title, MAX_LENGTH, ' ')
		artist = Format(tag.artist, MAX_LENGTH, ' ')
					
		keyFrames = tag.frames.select{|f| f.id == :COMM}
		key = Format(keyFrames.first.andand.content, 10, ' ', false)
		if (key.length == 0)
			key = 'UNDEFINED_KEY set key in comments section'
		end
			
		updatedFileName = "#{bpm} - #{key} - [#{title}] - (#{artist})"
		
		newFile = folder + '/' + updatedFileName + File.extname(file)
	
		mp3_file.close
		
		File.rename(file, newFile)
		
		completed +=1
		puts 'Completed: ' + completed.to_s
	end
end

puts 'FIN.'