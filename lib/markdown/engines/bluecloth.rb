module Markdown
  module Engine

    def bluecloth_to_html( content )
      BlueCloth.new( content ).to_html
    end
    
  end # module Engine
end # module Markdown            