require 'cgi'

#run rake hype:parser
#install rake gem

namespace :hype do
  desc "HTML parsing"
  task :parser do
    full_path = File.expand_path "~/epcdept/"
    log full_path
    # drop(2) to remove . and .. folder
    Dir.entries(full_path).drop(2).each do |entry|
      path = File.join(full_path, entry)
      list_files(path) if Dir.exist? path
    end
  end

  def list_files(dir)
    @list = Dir.entries(dir).drop(2)
    traverse_dir(dir)
    return 0
  end

  def traverse_dir(dir)
    match_files(File.join(dir, @list[0])) unless Dir.glob("#{dir}/*.js").empty?

    @list.each do |entry|
      path = File.join(dir, entry)
      if Dir.exist? path
        log "#{entry}"
        list_files(File.join(path))
      end
    end
    log "end of Directory"
    return 0
  end

  def match_files(path)
    print_output(path) do
      detect_file_size(path)
      traverse_for_links(path)
    end
  end

  def print_output(path, &block)
    puts path
    print_list
    block.call if block_given?
    print_linked_files
    print_unlinked_files
  end

  def traverse_for_links(path)
    html_file =  File.new(path).read.gsub!(escape,"\n")
    @links = html_file.scan(regex).map{ |file| CGI.unescape(file[0]) }
  end

  def detect_file_size(path)
    dir = File.dirname(path)
    size = @list.map{ |file| [file, file_size(dir,file)]}
    log "printing list with size"
    puts size.inspect
  end

  def file_size(dir, file)
    size = File.stat(File.join(dir,file)).size
    case
    when size < kb then "#{size} bytes"
    when size > kb || size < mb then "#{size/kb} KB"
    when size > mb then "#{size/mb} MB"
    else size
    end
  end

  def print_list
    log "printing list"
    puts @list.inspect
  end

  def print_linked_files
    log "printing linked files"
    puts @links.inspect
  end

  def print_unlinked_files
    log "files not linked"
    @unlinked = @list - @links
    puts @unlinked.inspect
  end

  def regex ; /\"(\S+\w+\W+(png|pdf|gif|js|htc))\"/ ; end

 def log(val) ; puts "#{"#"*20} #{val} #{"#"*20} " ; end

  def kb ; 1024 ; end

  def mb ; kb**2 ; end

  def escape ; /{|}|,/ ; end


end
