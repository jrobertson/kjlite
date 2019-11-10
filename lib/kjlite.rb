#!/usr/bin/env ruby

# file: kjlite.rb

require 'abbrev'
require 'novowels'
require 'open-uri'


module KjLite

  class Verse

    attr_reader :book_id, :chapter_id, :number

    def initialize(book_name, chapter_id, number, verse, debug: false)
      @book_name, @chapter_id, @debug = book_name, chapter_id, debug
      @number, @verse = number, verse
    end

    def inspect()
      "#<KjLite::Verse @book_name=#{@book_name} " + 
        "@chapter_id=#{@chapter_id} @number=#{@number}>"
    end

    def text()
      @verse[/^\d+:\d+:\d+\s+(.*)/m,1].gsub(/[\r\n]|\s\s/,'')
    end

    def title()
      "%s %s:%s" % [@book_name, @chapter_id, @number]
    end

    def to_s()
      @verse
    end

  end

  class Chapter

    attr_reader :id, :book_id, :number, :title

    def initialize(allverses, id, book_id, book_name, debug: false)
      @verses, @id, @book_id, @debug = allverses, id, book_id, debug
      @book_name = book_name
    end

    def verse(n)
      verses(n).text
    end

    def verses(*list)

      puts 'inside verses' if @debug
      
      list = list.first.to_a if list.first.is_a? Range

      if list.empty? then
        return @verses.map.with_index {|x,i| Verse.new @book_name, @id, i+1, x}
      elsif list.length < 2
        Verse.new @book_name, @id, list.first, @verses[list.first.to_i-1]
      else
        list.flatten.map do |n| 
          Verse.new @book_name, @id, n, @verses[n.to_i-1]
        end
      end

    end

    def inspect()
      "#<KjLite::Chapter @id=#{@id} @book_id=#{@book_id} @number=#{@id}>"
    end

    def title()
      "%s %s" % [@book_name, @id]
    end

    def to_s()
      title()
    end

  end

  class Book

    attr_reader :id, :name, :permalink
 
    def initialize(id, name, chapters, debug: false)

      @id, @name, @debug = id, name, debug
      @permalink = name.downcase.gsub(/\s/,'-')
      puts 'chapters.length : ' + chapters.length.inspect if @debug
      @chapters = chapters.map.with_index do |x,i|
        Chapter.new x, i+1, id, name, debug: @debug
      end

    end

    def chapter(n)
      chapters n
    end

    def chapters(*args)

      puts 'args: ' + args.inspect if @debug     

      if args.empty? then
        return @chapters
      elsif args.length < 2
        @chapters[args.first.to_i-1]
      else
        args.flatten.map {|n| @chapters[n-1] }.compact
      end
      
    end

    def inspect()
      "#<KjLite::Book @name=#{@name.inspect} @chapters=#{@chapters.inspect}>"
    end

    def to_s()
      @chapters
    end

  end

  class Bible

    attr_reader :to_h, :to_s, :booklist

    def initialize(url='http://www.gutenberg.org/cache/epub/30/pg30.txt',
                  debug: false)
      
      filename, @debug = 'kjbible.txt', debug

      if File.exists?(filename) then
        s = File.read(filename)
      else
        s = open(url).read
        File.write filename, s
      end

      s2 = s.split(/.*(?=^Book 01)/,3).last; 0
      a = s2.split(/.*(?=^Book \d+)/); 0

      h = a.inject({}) do |r,x|

        title, body = x.match(/^Book \d+\s+([^\r]+)\s+(.*)/m).captures

        a2 = body.split(/.*(?=\d+\:\d+\:\d+)/)
        a3 = a2.group_by {|x| x[/^\d+:\d+/]}.to_a.map(&:last)
        r.merge(title => a3[1..-1])  

      end

      @h = h.group_by {|key, _| key[/\d*\s*(.*)/,1]}; 0

      @h.each do |key, value|
        @h[key] = value.length < 2 ? value.last.last : value.map(&:last)
      end

      @to_h, @to_s, @booklist = @h, s, h.keys

    end

    def books(ref=nil)           
      
      return @booklist.map {|x| books(x) } unless ref

      index = ref.to_s[/^\d+$/] ? (ref.to_i - 1) : find_book(ref.downcase)
      puts 'index: ' + index.inspect if @debug
      title = @booklist[index]
      r = @h[title.sub(/^\d+\s+/,'')]

      puts 'r: '  + r.class.inspect if @debug

      if r.length > 3 then
        Book.new index+1, title, r, debug: @debug
      else
        i = ref[/\d+/].to_i - 1
        a = r.map.with_index {|x,i| Book.new index+1, title, r[i], debug: @debug}
        a[i]
      end
    end

    def inspect()
      "#<KjLite::Bible @booklist=#{@booklist}>"
    end

    def random_book()
      books booklist.sample
    end

    def random_chapter()
      random_book.chapters.sample
    end

    def random_verse()
      random_chapter.verses.sample
    end

    private

    def find_book(ref)

      h = @booklist.inject({}) do |r,rawx|

        x = rawx.downcase
        a3 = [
          x,
          x.sub(/(\d)\s/,'\1'),
          x.sub(/(\d)\s/,'\1-'),
          NoVowels.compact(x),
          NoVowels.compact(x.sub(/(\d)\s/,'\1')),
          NoVowels.compact(x.sub(/(\d)\s/,'\1-')),
        ]
        puts 'a3: ' + a3.inspect if @debug
        a3b = a3.uniq.abbrev.keys.reject {|x| x[/^\s*\d+$/] or x.length < 2}
        r.merge(rawx => a3b)

      end
      puts 'h: '  + h.inspect if @debug
      r = h.find {|key, val| val.grep(/#{ref}/).any? }
      r = h.find {|key, vl| vl.grep(/#{ref.sub(/\d+\s*/,'')}/).any? } unless r
      puts 'r: ' + r.inspect if @debug
      @booklist.index r.first

    end

  end

end

