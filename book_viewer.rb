require "sinatra" 
require "sinatra/reloader" if development? # production? and dev? query env variable for RACK_ENV

helpers do
  def highlight(search_term, text)
    text.gsub(search_term, "<strong>#{params[:query]}</strong>")
  end

  def in_paragraphs(str)  
    paragraph_arr = str.split("\n\n")

    pararagraph_hash = {}

    id_num = 0
    paragraph_arr.map! do |substr| 
      id_num += 1
      pararagraph_hash[id_num] = substr
      "<p id=\"#{id_num}\">#{substr}</p>" 
    end
    
    paragraph_arr.join
  end

  def iterate_chapters#(toc)
    @num_chapters.times do |i|
      chapter_number = i + 1
      chapter_title = @contents[i]
      chapter_contents = File.read("./data/chp#{chapter_number}.txt")
      yield(chapter_number, chapter_title, chapter_contents)
    end

    @contents # is this logically consistent?
  end

  def iterate_paragraphs(chapter)
    all_paragraphs = []
    in_paragraphs(chapter).scan(/<p\sid="\d+">[a-zA-Z\s."\-\\!?,.';:]+<\/p>/).each do |paragraph| 
      yield(paragraph)
      all_paragraphs << paragraph
    end
  end

  def isolate_id_tag(content)
    tag = /id="\d+"/.match(content)
    
    return nil if tag.nil?

    digits_tag = /\d+/.match(tag[0])

    digits_tag[0]
  end

  def search(search_term)
    search_results = {}

    return search_results if (search_term == nil) || (search_term.empty?)

    iterate_chapters do |chapter_number, chapter_title, chapter_contents|
      search_results[chapter_number] = {
                                        :chapter_name => chapter_title,
                                        :matches => {}
                                       }
                                     
      iterate_paragraphs(chapter_contents) do |paragraph|
        if paragraph.include?(search_term)
          id_tag = isolate_id_tag(paragraph)
          search_results[chapter_number][:matches][id_tag] = paragraph
        end
      end
    end
    search_results
  end

end


before do
  @contents = File.readlines("./data/toc.txt")
  @num_chapters = @contents.size
end

get '/' do
  @title = 'The Adventures of Pretty Sure Holmes'

  erb :home
end

get '/chapters/:chapter_num' do 
  @chapter_number = params['chapter_num']
  @contents = File.readlines("./data/toc.txt")

  redirect "/" unless (1..@num_chapters).cover?(@chapter_number.to_i)

  @chapter_title = @contents[params['chapter_num'].to_i - 1]
  @title = "Chapter #{@chapter_number}: " + @chapter_title
  
  
  @content_body = File.read("./data/chp#{@chapter_number}.txt")

  erb :chapter
end

get '/search' do
  @search_results = search(params[:query])

  erb :search
end

not_found do |path|
  redirect "/"
end

