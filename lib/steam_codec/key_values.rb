require 'json'
require 'insensitive_hash/minimal'

module SteamCodec
    # About KeyValues => https://developer.valvesoftware.com/wiki/KeyValues
    # Valve's implementation => https://github.com/ValveSoftware/source-sdk-2013/blob/master/mp/src/tier1/KeyValues.cpp
    # SteamKit's implementation => https://github.com/SteamRE/SteamKit/blob/master/SteamKit2/SteamKit2/Types/KeyValue.cs
    class KeyValues < InsensitiveHash
        class Parser
            def self.proccess(data, last = true)
                token = /"[^"]*"/
                data = data.gsub(/(?<=^|[\s{}])(\s*)([^"{}\s\n\r]+)(\s*)(?=[\s{}]|\z)/, '\1"\2"\3')
                if last
                    data.gsub!(/(#{token}:\s*#{token}|})(?=\s*")/, '\1,')
                    data.gsub!(/(#{token})(?=\s*{|[ \t\f]+")/, '\1:')
                else
                    data.gsub!(/(#{token}:\s*#{token}|})(?=\s*"|\s*\z)/, '\1,')
                    data.gsub!(/(#{token})(?=\s*{|[ \t\f]+"|\s*\z)/, '\1:')
                end
                data
            end

            def self.isEscaped(data, index, char = '\\')
                return false if index == 0
                escaped = false
                (index - 1).downto(0) do |num|
                    if data[num] == char
                        escaped = !escaped
                    else
                        break
                    end
                end
                escaped
            end

            def self.getQuoteList(data)
                indexes = []
                quoted = false
                length = data.length
                length.times do |index|
                    if data[index] == '"'
                        escaped = false
                        escaped = self.isEscaped(data, index) if quoted
                        if not escaped
                            indexes << index
                            quoted = !quoted
                        end
                    end
                end
                raise RuntimeError, "Unmatched quotes" if quoted
                indexes
            end

            def self.toJSON(data)
                raise ArgumentError, "data must be String" unless data.is_a?(String)
                str = ''
                previous = 0
                data.gsub!(/^#(include|base).*$/, '') # include and base not supported so just ignore
                quoteList = self.getQuoteList(data)
                quoteList.each_index  do |index|
                    quoted = index % 2 == 1
                    part = data[previous...quoteList[index]]
                    previous = quoteList[index] + 1
                    next if part.empty? and not quoted
                    if quoted
                        str += '"' + part.gsub(/\n/,'\n') + '"'
                        lastIndex = data.length
                        lastIndex = quoteList[index + 1] if index + 1 < quoteList.length
                        nextPart = data[previous...lastIndex].gsub(/\\\\.*$/,'') # remove comments
                        nextPart = self.proccess(nextPart, true)
                        case nextPart
                        when /\A(\s*{|[ \t]+\z)/
                            str += ':'
                        when /\A\s+\z/
                            str += ','
                        end
                    else
                        part = part.gsub(/\\\\[^\n]*$/,'') # remove comments
                        str += self.proccess(part, index + 1 >= quoteList.length)
                    end
                end
                lastIndex = data.length
                part = data[previous...lastIndex]
                str += self.proccess(part, true) if part
                '{' + str + '}'
            end
        end

        def self.loadFromJSON(json)
            JSON.parse(json, {:object_class => self})
        rescue JSON::ParserError
            nil
        end

        def self.loadFromFile(file)
            raise ArgumentError, "file must respond to :read" unless file.respond_to?(:read)
            json = self::Parser::toJSON(file.read)
            self.loadFromJSON(json)
        end

        def self.load(data)
            json = self::Parser::toJSON(data)
            self.loadFromJSON(json)
        end

        def get(path = '')
            fields = path.gsub(/^\/|\/$/, '').split('/')
            current = self
            fields.each do |name|
                return nil if not current.key?(name)
                current = current[name]
            end
            current
        end

        def asArray(name, seperator = '_')
            data = []
            counter = 0
            cname = name+seperator+counter.to_s
            data << self[cname] if key?(cname)
            counter += 1
            cname = name+seperator+counter.to_s
            while key?(cname) do
                data << self[cname]
                counter += 1
                cname = name+seperator+counter.to_s
            end
            data
        end

        def method_missing(name, *args, &block) # :nodoc:
            return self[name] if args.empty? and block.nil? and key?(name)
            super
        end

        def respond_to_missing?(name, include_private = false) # :nodoc:
            return true if key?(name)
            super
        end
    end
end
