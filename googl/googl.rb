#!/usr/bin/ruby

def googl b
    require 'cgi'
    require 'timeout'
    require 'socket'
    require 'net/http'
    require 'json'

    def c *arguments
        l = 0
        arguments.each { |x|
            l = l + x & 4294967295
        }
        return l
    end

    def d l
        l = (l > 0 ? l : l + 4294967296).to_s
        m, o, n = l.dup, 0, false
        (0 .. (m.length - 1)).to_a.reverse.each { |p|
            q = m[p].to_i
            if n
                q *= 2
                o += (q / 10).floor + q % 10
            else
                o += q
            end
            n = !n
        }
        m, o = o % 10, 0
        if m != 0
            o = 10 - m
            if l.length % 2 == 1
                if o % 2 == 1
                    o += 9
                end
                o /= 2
            end
        end

        return o.to_s + l
    end

    def e l
        m = 5381
        l.split(//).each { |o|
            m = c(m << 5, m, o.ord)
        }
        return m
    end

    def f l
        m = 0
        l.split(//).each { |o|
            m = c(o.ord, m << 6, m << 16, -m)
        }
        return m
    end

    def get_params b
        i = e(b)
        i = i >> 2 & 1073741823
        i = i >> 4 & 67108800 | i & 63
        i = i >> 4 & 4193280 | i & 1023
        i = i >> 4 & 245760 | i & 16383
        h = f(b)
        k = (i >> 2 & 15) << 4 | h & 15
        k |= (i >> 6 & 15) << 12 | (h >> 8 & 15) << 8
        k |= (i >> 10 & 15) << 20 | (h >> 16 & 15) << 16
        k |= (i >> 14 & 15) << 28 | (h >> 24 & 15) << 24
        j = "7" + d(k)
        return {'user' => 'toolbar@google.com',
            'url' => b,
            'auth_token' => j
        }
    end

    par = get_params(b)

    JSON.parse Net::HTTP.post_form(URI.parse("http://goo.gl/api/url"), get_params(b)).body
end

if ARGV.length != 1
    puts "USAGE:\n\t#{$0} <link>"
    exit
end

if (res = googl((ARGV[0] =~ /^https?:\/\// ? ARGV[0] : 'http://' + ARGV[0])))['short_url']
    puts res['short_url']
else
    puts "Error: " + res['error_message']
end
