#!/usr/bin/env ruby
#encoding: utf-8
#frozen_string_literal: true

###
# Script for generating test-cases for my pathname-Implementation in nim.
#
# author:: Raimund Hübel <raimund.huebel@googlemail.de>
###


require 'pathname'


PATH_ITEMS = [
    'a',
    'bb',
    'ccc',
    '.',
    '..',
    '../..',
    ' ',
    '  ',
].freeze


PATH_SEPERATORS = [
    '/',
    '//',
].freeze


PATH_ROOTS = [
    '',
    '/',
    '//',
].freeze

PATH_FILES = [
    'a',
    'bb',
    'ccc',
    ' ',
    '  ',
].freeze

PATH_EXTENSIONS = [
    '',
    '.x',
    '.x ',
    '. x ',
    '. x',
    '.yz',
    '.yz ',
    '. yz ',
    '. yz',
    '.x.y',
    '.x.y ',
    '. x.y ',
    '. x.y',
    '.',
    '. ',
    ' . ',
    ' .',
    '..x',
    '..x ',
    '.. x ',
    '.. x',
].freeze

def path_combinations(path_items, path_seperators, path_roots, path_files, path_extensions, max_length)
    base_combinations = path_combinations_impl(path_items, path_seperators, path_files, path_extensions, max_length, 0)
    path_roots.map do |path_root|
        base_combinations.map do |base_combination|
            path_root + base_combination
        end
    end.flatten(1)
end

def path_combinations_impl(path_items, path_seperators, path_files, path_extensions, max_length, curr_length)
    if curr_length + 1 >= max_length
        path_files.map do |path_file|
            path_extensions.map do |path_extension|
                path_file + path_extension
            end
        end.flatten(1)
    else
        base_combinations = path_combinations_impl(path_items, path_seperators, path_files, path_extensions, max_length, curr_length+1)
        result = []
        path_items.each do |path_item|
            result << path_item
            path_seperators.each do |path_seperator|
                result << path_item + path_seperator
                base_combinations.each do |base_combination|
                    result << path_item + path_seperator + base_combination
                end
            end
        end
        return result
    end
end


path_variants = (
      ['', '/', '//', '///'             ] \
    + ['.', '/.', '//.', '///.'         ] \
    + ['..', '/..', '//..', '///..'     ] \
    + ['...', '/...', '//...', '///...' ] \
    + ['.z', '/.z', '//.z', '///.z'            , '. ', '/. ', '//. ', '///. '             ] \
    + ['..y', '/..y', '//..y', '///..y'        , '.. ', '/.. ', '//.. ', '///.. '         ] \
    + ['...x', '/...x', '//...x', '///...x'    , '... ', '/... ', '//... ', '///... '     ] \
    + ['a.', '/a.', '//a.', '///a.'            , ' .', '/ .', '// .', '/// .'             ] \
    + ['b..', '/b..', '//b..', '///b..'        , ' ..', '/ ..', '// ..', '/// ..'         ] \
    + ['c...', '/c...', '//c...', '///c...'    , ' ...', '/ ...', '// ...', '/// ...'     ] \
    + ['a.x', '/a.x', '//a.x', '///a.x'        , ' .x', '/ .x', '// .x', '/// .x'         ] \
    + ['b..y', '/b..y', '//b..y', '///b..y'    , ' ..y', '/ ..y', '// ..y', '/// ..y'     ] \
    + ['c...z', '/c...z', '//c...z', '///c...z', ' ...z', '/ ...z', '// ...z', '/// ...z' ] \
    + PATH_EXTENSIONS.map { |ext| ''    + ext } \
    + PATH_EXTENSIONS.map { |ext| '/'   + ext } \
    + PATH_EXTENSIONS.map { |ext| '//'  + ext } \
    + PATH_EXTENSIONS.map { |ext| '///' + ext } \
    + PATH_EXTENSIONS.map { |ext| 'a'    + ext } \
    + PATH_EXTENSIONS.map { |ext| 'a/'   + ext } \
    + PATH_EXTENSIONS.map { |ext| 'a//'  + ext } \
    + PATH_EXTENSIONS.map { |ext| 'a///' + ext } \
    + path_combinations(PATH_ITEMS, PATH_SEPERATORS, PATH_ROOTS, PATH_FILES, PATH_EXTENSIONS, 3)
).uniq

path_entry_items = path_variants.map do |path_variant|
    pathname = Pathname.new(path_variant)

    dirname = pathname.dirname.to_s

    # Bugfix: Root-Slashes von Originalem Pfadnamen wiederherstellen, da Ruby diese wegfrisst.
    # Beispiel: org: ///, ruby: /, wiederhegestellt: ///
    # Dies sollte ich melden, da dies ein verstoss gegen das Prinzip der kleinsten Überraschung ist.
    #dirname[0] = "//"  if  path_variant.start_with?("//") #DEPRECATED
    dirname[/\A\/+/] = path_variant[/\A\/+/]  if  path_variant.start_with?("/")


    [ path_variant.inspect,
      pathname.absolute?.inspect,
      pathname.basename.to_s.inspect,
      dirname.inspect,
      pathname.extname.to_s.inspect,
      pathname.parent.to_s.inspect,
      pathname.cleanpath.to_s.inspect,
    ]
end

path_entry_item_lengths = []
path_entry_items.each do |path_entry_item|
    path_entry_item.each_with_index do |item, idx|
        path_entry_item_lengths[idx] = [path_entry_item_lengths[idx] || 0, item.length].max
    end
end


STDERR.puts "Count Pathname-Check-Entries: #{path_variants.length}"

puts "["
path_entry_items.map do |path_entry_item|
    print "    {"
    print ' "path": '
    print path_entry_item[0].ljust(path_entry_item_lengths[0])
    print ', "isAbsolute": '
    print path_entry_item[1].ljust(path_entry_item_lengths[1])
    print ', "basename": '
    print path_entry_item[2].ljust(path_entry_item_lengths[2])
    print ', "dirname": '
    print path_entry_item[3].ljust(path_entry_item_lengths[3])
    print ', "extname": '
    print path_entry_item[4].ljust(path_entry_item_lengths[4])
    print ', "parent": '
    print path_entry_item[5].ljust(path_entry_item_lengths[5])
    print ', "cleanpath": '
    print path_entry_item[6].ljust(path_entry_item_lengths[6])
    puts " },"
end
puts "]"
