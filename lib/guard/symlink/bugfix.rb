# https://github.com/guard/listen/issues/426
require 'listen'
require 'listen/record'

module Listen
  class Record
    def dir_entries(rel_path)
      subtree =
        if [nil, '', '.'].include? rel_path.to_s
          tree
        else
          sub_dir_entries(rel_path)
        end

      result = {}
      subtree.each do |key, values|
        # only get data for file entries
        result[key] = values.key?(:mtime) ? values : {}
      end
      result
    end

    private

    def sub_dir_entries(rel_path)
      result = {}
      tree.each do |path, meta|
        next unless path.start_with?(rel_path)

        if path == rel_path
          result.merge!(meta)
        else
          sub_path = path.sub(%r{\A#{rel_path}/?}, '')
          result[sub_path] = meta
        end
      end
      result
    end
  end
end
