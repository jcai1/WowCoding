##
# ===== sync.rb =====
# Based on the information in [config.yml], this script synchronizes
# WeakAura strings, (Lua) tables, and custom code files.
# Also generates Markdown description files.
#
# Written against ruby 2.3.1 / Windows
# I tried to keep it portable, but no guarantees.
#
# Also, don't run this against untrusted [config.yml] files!
##

require "yaml"
require "json"
require "open3"
require "set"

@config = YAML.load_file("config.yml")

@wa_config       = @config["weakauras"]
@sync_lua        = @wa_config["sync-lua"]
@string_filename = @wa_config["string file"]
@table_filename  = @wa_config["table file"]
@desc_filename   = @wa_config["description file"]
@verbose         = @wa_config["verbose sync"]
@weakauras       = @wa_config["auras"]

=begin
take newer of (string, table); one must exist
call it the "data"
take all wa.*.lua files newer than the data
compile them into a "code.json" file
call lua "inject-code-into-X"
call lua "extract-code-from-X", parse code.json
let time = Time.now
write them into wa.*.lua files
write the data in table and string formats
File.utime to set all written files to [time]
=end

class String
  def word_wrap(width = 80, ch = "\n")
    scan(/\S.{0,#{width-2}}\S(?=\s|$)|\S+/).join(ch)
  end
end

class Array
  def thread_each(&block)
    # may want to replace this with a fixed threadpool
    inject([]) { |threads, e|
      threads << Thread.new { yield(e) } 
    }.each(&:join)
  end
end

def process_wa(wa)
  source_dir = wa["source dir"]
  STDERR.puts "inspecting #{source_dir}" if @verbose

  sync_dir = File.join(source_dir, ".sync")
  unless File.directory?(sync_dir)
    Dir.mkdir(sync_dir)
    `attrib +h "#{sync_dir}"` if Gem.win_platform?
  end

  lock_file     = File.join(sync_dir, ".lock")
  lock_file_obj = File.open(lock_file, "w") # closed in [ensure]
  unless lock_file_obj.flock(File::LOCK_EX | File::LOCK_NB)
    raise "#{lock_file} already locked"
  end

  last_build_file = File.join(sync_dir, ".last_build")
  last_build = File.exist?(last_build_file) ? YAML.load_file(last_build_file) : {}
  something_to_do = last_build[:time].nil?

  string_file = File.join(source_dir, @string_filename)
  table_file  = File.join(source_dir, @table_filename)
  desc_file   = File.join(source_dir, @desc_filename)

  data_type, data_file, data_mtime = nil

  [["string", string_file], ["table", table_file]].each { |type, file|
    mtime = File.exist?(file) && File.mtime(file)
    if mtime && (data_mtime.nil? || mtime > data_mtime)
      data_type  = type
      data_file  = file
      data_mtime = mtime
    end
    something_to_do ||= mtime != last_build[:time]
  }

  if data_file.nil?
    raise "neither #{string_filename} nor #{table_file} exists"
  end
  STDERR.puts "using #{data_file} as data file" if @verbose

  code_hash = {}
  Dir.glob(File.join(source_dir, "wa.*.lua")) { |code_file|
    mtime = File.mtime(code_file)
    key   = File.basename(code_file, ".lua")
    if mtime > data_mtime
      STDERR.puts "code file #{code_file} is newer than data file" if @verbose
      something_to_do = true
      code_hash[key] = IO.read(code_file)
    end
    last_build[:code_files].delete(key) unless something_to_do
  }
  something_to_do ||= !last_build[:code_files].empty?

  something_to_do ||= File.exist?(desc_file) && File.mtime(desc_file) < last_build[:time]

  if something_to_do
    STDERR.puts "processing #{source_dir}"
  else
    STDERR.puts "nothing to do in #{source_dir}"
    return
  end

  code_tmp = File.join(sync_dir, ".code.json")
  IO.write(code_tmp, JSON.pretty_generate(code_hash))

  STDERR.puts "injecting code updates" if @verbose
  data_tmp = File.join(sync_dir, ".data")
  cmd = %Q{lua "#{@sync_lua}" inject-code-into-#{data_type} "#{data_file}" "#{code_tmp}" >"#{data_tmp}"}
  _, err, status = Open3.capture3(cmd)
  File.delete(code_tmp)
  raise "command failed: #{cmd}\nstderr:\n#{err}" unless status.success?

  STDERR.puts "extracting code" if @verbose
  code_hash = nil
  cmd = %Q{lua "#{@sync_lua}" extract-code-from-#{data_type} "#{data_tmp}"}
  code_json, err, status = Open3.capture3(cmd)
  raise "command failed: #{cmd}\nstderr:\n#{err}" unless status.success?
  code_hash = JSON.parse(code_json)

  # get time at filesystem mtime resolution
  time = Time.now
  IO.write(last_build_file, "")
  File.utime(time, time, last_build_file)
  time = File.mtime(last_build_file)
  File.utime(time, time, last_build_file)
  raise "filesystem mtime not idempotent" unless time == File.mtime(last_build_file)

  last_build[:time]       = time
  last_build[:code_files] = Set.new

  code_hash.each { |key, code_contents|
    code_file = File.join(source_dir, "#{key}.lua")
    STDERR.puts "writing code file #{code_file}" if @verbose
    IO.write(code_file, code_contents)
    File.utime(time, time, code_file)
    last_build[:code_files].add(key)
  }

  STDERR.puts "updating #{data_file}" if @verbose
  File.rename(data_tmp, data_file)
  File.utime(time, time, data_file)

  subcommand, other_file = (data_type == "string") ?
    ["string-to-table", table_file] : ["table-to-string", string_file]
  STDERR.puts "updating #{other_file}" if @verbose
  cmd = %Q{lua "#{@sync_lua}" #{subcommand} "#{data_file}" >"#{other_file}"}
  _, err, status = Open3.capture3(cmd)
  raise "command failed: #{cmd}\nstderr:\n#{err}" unless status.success?
  File.utime(time, time, other_file)

  import_string = IO.read(string_file)

  latest_header = nil
  versions_string = wa["versions"].map { |ver|
    date_string   = ver.key?("date") ? %Q| (#{ver["date"]})| : ""
    header        = %Q|v#{ver["id"]}#{date_string}|
    latest_header = header if latest_header.nil?
    <<~HEREDOC.rstrip!
      #### #{header}:

      #{ver["info"].rstrip.word_wrap}
    HEREDOC
  }.join("\n\n")

  IO.write(desc_file, <<~HEREDOC)
    ## #{wa["name"]}

    #{wa["description"].rstrip.word_wrap}

    **Classes**: #{wa["classes"].join(", ")}

    **Requested by**: #{wa["requested by"].join(", ")}

    ### Import String for #{latest_header}

        #{import_string}
         

    ### Changes

    #{versions_string}
  HEREDOC
  File.utime(time, time, desc_file)

  File.open(last_build_file, "w") { |f| f.write(last_build.to_yaml) }

  STDERR.puts "finished processing #{source_dir}" if @verbose
rescue StandardError => e
  STDERR.print <<~HEREDOC
    #{e.class} while processing #{source_dir}: #{e.message}
    #{e.backtrace.join("\n")}
  HEREDOC
ensure
  unless lock_file_obj.nil?
    STDERR.puts "closing and deleting #{lock_file}" if @verbose
    lock_file_obj.close
    File.delete(lock_file) rescue nil
  end
end

@weakauras.each(&method(:process_wa))

STDERR.puts "sync complete!"
