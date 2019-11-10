# Introducing the kjlite gem

## Usage

    require 'kjlite'

    bible = KjLite::Bible.new
    puts bible.books('Genesis').chapters(1).verses('1', '2')


Output

<pre>
1:001:001 In the beginning God created the heaven and the earth.

1:001:002 And the earth was without form, and void; and darkness was
           upon the face of the deep. And the Spirit of God moved upon
           the face of the waters.


</pre>

## Resources

* kjlite https://rubygems.org/gems/kjlite

bible kj kjlite gem gutenberg
