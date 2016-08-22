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

config = YAML.load_file("config.yml")

wa_config       = config["weakauras"]
sync_lua        = wa_config["sync-lua"]
wa_root_dir     = wa_config["root dir"]
string_filename = wa_config["string file"]
table_filename  = wa_config["table file"]
desc_filename   = wa_config["description file"]
verbose         = wa_config["verbose sync"]
weakauras       = wa_config["auras"]

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

# TODO: lock file

class String
  def word_wrap(width = 80, ch = "\n")
    scan(/\S.{0,#{width-2}}\S(?=\s|$)|\S+/).join(ch)
  end
end

weakauras.each {|wa|
  begin
    source_dir = File.join(wa_root_dir, wa["source dir"])
    STDERR.puts "processing #{source_dir}"

    sync_dir = File.join(source_dir, ".sync")
    unless File.directory? sync_dir
      Dir.mkdir(sync_dir)
      `attrib +h "#{sync_dir}"` if Gem.win_platform?
    end

    string_file = File.join(source_dir, string_filename)
    table_file  = File.join(source_dir, table_filename)
    desc_file  = File.join(source_dir, desc_filename)

    IO.write(desc_file, <<~HEREDOC)
      ## #{wa["name"]}

      #{wa["description"].strip!.word_wrap}

      **Classes**: #{wa["classes"].join(", ")}

      **Requested by**: #{wa["requested by"].join(", ")}

      ### Changes

      #### ...
    HEREDOC

    data_type, data_file, data_mtime = nil

    [["string", string_file], ["table", table_file]].each { |type, file|
      if File.exist? file
        mtime = File.mtime(file)
        if data_mtime.nil? || mtime > data_mtime
          data_type  = type
          data_file  = file
          data_mtime = mtime
        end
      end
    }

    if data_file.nil?
      raise "neither #{string_filename} nor #{table_file} exists"
    end
    STDERR.puts "determined the newest file is #{data_file}" if verbose

    code_hash = {}
    Dir.glob(File.join(source_dir, "wa.*.lua")) { |code_file|
      if File.mtime(code_file) > data_mtime
        STDERR.puts "code file #{code_file} is newer than data file" if verbose
        key = File.basename(code_file, ".lua")
        code_hash[key] = IO.read(code_file)
      end
    }

    code_tmp = File.join(sync_dir, ".code.json")
    IO.write(code_tmp, JSON.pretty_generate(code_hash))

    STDERR.puts "injecting code updates" if verbose
    data_tmp = File.join(sync_dir, ".data")
    cmd = %Q{lua "#{sync_lua}" inject-code-into-#{data_type} "#{data_file}" "#{code_tmp}" >"#{data_tmp}"}
    _, err, status = Open3.capture3(cmd)
    File.delete(code_tmp)
    raise "command failed: #{cmd}\nstderr:\n#{err}" unless status.success?

    STDERR.puts "extracting code" if verbose
    code_hash = nil
    cmd = %Q{lua "#{sync_lua}" extract-code-from-#{data_type} "#{data_tmp}"}
    code_json, err, status = Open3.capture3(cmd)
    raise "command failed: #{cmd}\nstderr:\n#{err}" unless status.success?
    code_hash = JSON.parse(code_json)

    time = Time.now

    code_hash.each {|key, code_contents|
      code_file = File.join(source_dir, "#{key}.lua")
      STDERR.puts "writing code file #{code_file}" if verbose
      IO.write(code_file, code_contents)
      File.utime(time, time, code_file)
    }

    STDERR.puts "updating #{data_file}" if verbose
    File.rename(data_tmp, data_file)
    File.utime(time, time, data_file)

    subcommand, other_file = (data_type == "string") ?
      ["string-to-table", table_file] : ["table-to-string", string_file]
    STDERR.puts "updating #{other_file}" if verbose
    cmd = %Q{lua "#{sync_lua}" #{subcommand} "#{data_file}" >"#{other_file}"}
    _, err, status = Open3.capture3(cmd)
    raise "command failed: #{cmd}\nstderr:\n#{err}" unless status.success?
    File.utime(time, time, other_file)

    STDERR.puts "finished processing #{source_dir}" if verbose

  rescue StandardError => e
    puts "error: #{e.class} while processing WeakAura: #{e.message}"
  end
}

STDERR.puts "sync complete!"
