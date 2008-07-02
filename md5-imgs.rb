#!/usr/bin/ruby

# Copyright (c) 2008 Simone Dall'Angelo
#
# MIT License
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#

require 'digest/md5'

# If DELETE_DUPLICATES is false this script simultes deletion but nothing is written to the disk
DELETE_DUPLICATES = false

if ARGV[0] && File.exists?(ARGV[0])
  STORAGE_PATH = ARGV[0]
else
  puts 'Fatal error: path not existent or not given.'
  exit
end

# These are extensions parsed, others extensions are ignored
ACCEPTABLE_EXTS = ['.jpg', '.jpeg', '.gif', '.png', '.tiff']

# If EXTENDED_DESC is true when script found a duplicate it shows the two paths (useful to check duplicates)
EXTENDED_DESC = false

md5s        = Array.new
files       = Array.new
duplicates  = Array.new
skipped     = Array.new

puts "Evaluating #{STORAGE_PATH}..."
Dir.glob(STORAGE_PATH + '/*').each do |path|
  if ACCEPTABLE_EXTS.include?(File.extname(path))
    digest = Digest::MD5.hexdigest(File.read(path))
    if md5s.include?(digest)
      dup_index = md5s.index(digest)
      dup_md5 = md5s[dup_index]
      dup_path = files[dup_index]
      
      if EXTENDED_DESC
        file1 = File.basename(dup_path)
        file2 = File.basename(path)
        puts "Duplicate digest:"
        puts "\tFile 1: #{dup_path}"
        puts "\tFile 2: #{path}"
      else
        print "Duplicate: #{File.basename(path)} ..."
      end
      duplicates << path
      system("rm #{path}") if DELETE_DUPLICATES
      print " deleted!\n"
    else
      md5s << digest
      files << path
    end
  else
    skipped << path
  end
end

puts "Found #{files.size} files, generated #{md5s.size} digests, found #{duplicates.size} duplicates, ignored #{skipped.size} files/directory."