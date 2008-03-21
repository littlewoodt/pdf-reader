################################################################################
#
# Copyright (C) 2008 James Healy (jimmy@deefa.com)
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
################################################################################

class PDF::Reader
  class CMap

    def initialize(data)
      @map = {}
      in_char_mode = false
      in_range_mode = false

      data.each_line do |l|
        if l.include?("beginbfchar")
          in_char_mode = true 
        elsif l.include?("endbfchar")
          in_char_mode = false 
        elsif l.include?("beginbfrange")
          in_range_mode = true 
        elsif l.include?("endbfrange")
          in_range_mode = false 
        end
        if in_char_mode
          m, find, replace = *l.match(/<([0-9a-fA-F]+)> <([0-9a-fA-F]+)>/)
          @map["0x#{find}".hex] = "0x#{replace}".hex if find && replace
        elsif in_range_mode
          m, start_code, end_code, dst = *l.match(/<([0-9a-fA-F]+)> <([0-9a-fA-F]+)> <([0-9a-fA-F]+)>/)
          if start_code && end_code && dst
            start_code = "0x#{start_code}".hex
            end_code   = "0x#{end_code}".hex
            dst        = "0x#{dst}".hex
            (start_code..end_code).each do |val|
              @map[val] = dst 
              dst += 1
            end
          end
        end
      end
    end

    def decode(c)
      # TODO: implement the conversion
      Error.assert_equal(c.class, Fixnum)
      @map[c]
    end

  end
end
