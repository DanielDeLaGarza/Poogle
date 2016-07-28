class DoogleController < ApplicationController
  def home
  end

  def search
    input = params[:word_entry][:word]
    @word = Word.find_by(content: input)

    #if word is already in database
    if(@word != nil)

      @definitions = format_data(@word.definitions)
      @sprites = format_data(@word.sprites)
      @validation_text = ''

    #if word is not already in database
    else
      @word = Word.new()
      @word.content = params[:word_entry][:word]

      if(@word.valid?)
        @data = get_word_definitions_from_api(@word.content)
        @definitions = @data['definitions']
        @sprites = @data['sprites']

        if (@definitions != nil && @definitions.length > 0 )
          @word.save
          save_definitions(@word, @definitions)
          if(@sprites != nil && @sprites.length > 0)
            save_sprites(@word, @sprites)
          end

        else
          @validation_text = "#{@word.content} is not a Pokemon. are you sure you spelled it right?"
        end

      #ivalid word handling
      else
        @validation_text = get_validation_text(@word.content)
        @definitions = []
        @sprites = []
      end
    end

    respond_to do |format|
      format.js
    end
  end

  #_PRIVATE__METHODS____________________________________________________________________
  private
    def get_validation_text(word)
      if(word == nil || word == "")
        @validation_text = "Please type a Pokemon to search."
      else
        if(word =~ /\d/)
          @validation_text = "Pokemon names may not include digits!"
        end
        if(word =~ /\s/)
          @validation_text = "#{@validation_text} Pokemon names may not include spaces!"
        end
        @validation_text = "#{@validation_text} Please only use letters and hyphens."
      end
      return @validation_text
    end

    def get_word_definitions_from_api(word)
      data = {}

      pokedex = Poke::API::Loader.new("pokemon")
      dictionary = Poke::API::Loader.new("description")
      gallery = Poke::API::Loader.new("sprite")

      begin
        definitions = []
        pokemon = pokedex.find(word)

        pokemon['descriptions']. each do |description|
          d = dictionary.find(description['resource_uri'].split('/')[4])
          des = d['description'].gsub("\n", '')
          definitions.push(des.gsub("\f", ''))
        end
        data['definitions'] = definitions

      rescue
        data['definitions'] = []
        data['sprites'] = []
        return data
      end

      begin
        sprites = []
        pokemon = pokedex.find(word)

        pokemon['sprites']. each do |sprite|
          s = gallery.find(sprite['resource_uri'].split('/')[4])['image']
          sprites.push("http://pokeapi.co#{s}")
        end
        data['sprites'] = sprites

      rescue
        data['sprites'] = []
      end

      return data
    end


    def format_data(definitions)
      arr = []
      definitions.each do |definition|
        arr.push(definition.content)
      end
      return arr
    end

    def save_definitions(word, definitions)
      definitions.each do |definition|
        word.definitions.create(content: definition)
      end
    end

  def save_sprites(word, sprites)
    sprites.each do |sprite|
      word.sprites.create(content: sprite)
    end
  end
end