def in_paragraphs(str)  
  paragraph_arr = str.split("\n\n")

  id_num = 0
  paragraph_arr.map! do |substr| 
    id_num += 1
    "<p id=\"#{id_num}\">#{substr}</p>" 
  end
  
  paragraph_arr.join
end


chapter = File.read("./data/chp1.txt")

puts in_paragraphs(chapter)

puts in_paragraphs(chapter).scan(/<p\sid="\d+">[a-zA-Z\s."\-\\!?,.';:]+<\/p>/).to_s