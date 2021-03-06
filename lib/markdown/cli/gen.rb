module Markdown

class Gen

  include TextUtils::Filter   # include filters such as comments_percent_style, etc. (see textutils gem)

  attr_reader :logger
  attr_reader :opts
    
  def initialize( logger, opts )
    @logger = logger
    @opts   = opts
  end

    def create_doc( fn )
      dirname  = File.dirname(  fn )
      basename = File.basename( fn, '.*' )
      extname  = File.extname(  fn )

      logger.debug "dirname=#{dirname}, basename=#{basename}, extname=#{extname}"

      if opts.output_path == '.'
        # expand output path in current dir
        outpath = File.expand_path( dirname ) 
      else
        # expand output path in user supplied dir and make sure output path exists
        outpath = File.expand_path( opts.output_path ) 
        FileUtils.makedirs( outpath ) unless File.directory? outpath 
      end
      logger.debug "outpath=#{outpath}"
      
      # todo: add a -c option to commandline? to let you set cwd?


      # change working dir to sourcefile dir (that is, dirname); push working folder/dir
      newcwd  = File.expand_path( dirname )
      oldcwd  = File.expand_path( Dir.pwd )
    
      unless newcwd == oldcwd
        logger.debug "oldcwd=>#{oldcwd}<, newcwd=>#{newcwd}<"
        Dir.chdir( newcwd )
      end  

      inname  = "#{basename}#{extname}"
      outname = "#{basename}.html"
      
      logger.debug "inname=#{inname}, outname=#{outname}"
      
      puts "*** #{inname} (#{dirname}) => #{outname} (#{(opts.output_path == '.') ? dirname : opts.output_path})..."
      
      content = File.read( inname )
      
      # step 1) run (optional) preprocessing text filters
      Markdown.filters.each do |filter|
        mn = filter.tr( '-', '_' ).to_sym  # construct method name (mn)
        content = send( mn, content )   # call filter e.g.  include_helper_hack( content )  
      end

      # step 2) convert light-weight markup to hypertext
      content = Markdown.new( content ).to_html


## todo: add Markdown.lib_options inspect/dump to banner
            
      banner =<<EOS
<!-- ======================================================================
      generated by #{Markdown.banner}
                on #{Time.now} with Markdown engine '#{Markdown.lib}'
     ====================================================================== -->
EOS
      
      out = File.new( File.join( outpath, outname ), "w+" )
####      out << banner
      out << content
      out.flush
      out.close

      ## pop/restore working folder/dir
      unless newcwd == oldcwd
        logger.debug "oldcwd=>#{oldcwd}<, newcwd=>#{newcwd}<"
        Dir.chdir( oldcwd )
      end  
            
    end # method create_doc


    
end # class Gen
end # module Markdown