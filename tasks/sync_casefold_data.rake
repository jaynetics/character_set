desc 'Download unicode casefold data and write new C header file'
task :sync_casefold_data do
  src_path = './CaseFolding.txt'
  dst_path = "#{__dir__}/../ext/character_set/unicode_casefold_table.h"

  `wget http://www.unicode.org/Public/UNIDATA/CaseFolding.txt`

  mapping = File.foreach(src_path).each_with_object({}) do |line, hash|
    from, type, to = line.split(/\s*;\s*/).first(3)
    # type 'C' stands for 'common', excludes mappings to multiple chars
    hash[from] = to if type == 'C'
  end.sort

  content = File.read(dst_path + '.tmpl')
    .sub(/(CASEFOLD_COUNT )0/, "\\1#{mapping.count}")
    .sub('{}', ['{', mapping.map { |a, b| "{0x#{a},0x#{b}}," }, '}'].join("\n"))

  File.write(dst_path, content)
  File.unlink(src_path)
end
