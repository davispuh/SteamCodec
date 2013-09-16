module SteamCodec
    class ValueArray
        def initialize(valueHash = {})
            load(valueHash)
        end

        def load(valueHash)
            raise ArgumentError, "ValueHash must be instance of Hash" unless valueHash.is_a?(Hash)
            @ValueHash = {}
            valueHash.each do |id, file|
                @ValueHash[id.to_i] = file
            end
        end

        def [](id)
            @ValueHash[id]
        end

        def []=(id, file)
            @ValueHash[id] = file
        end

        def add(file)
            id = @ValueHash.keys.max + 1
            @ValueHash[id] = file
            id
        end

        def remove(id)
            @ValueHash.delete(id)
        end

        def to_a
            check = []
            @ValueHash.sort_by { |key, value| key.to_s.to_i }.each do |array|
                check << array.last
            end
            check
        end

        alias_method :all, :to_a
        alias_method :get, :[]
        alias_method :set, :[]=
    end
end
