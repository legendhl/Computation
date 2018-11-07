class Stack < Struct.new(:contents)
    def push(character)
        Stack.new([character] + contents)
    end

    def pop
        Stack.new(contents.drop(1))
    end
    
    def top
        contents[0]
    end
    
    def inspect
        "#<Stack (#{top})#{contents.drop(1).join}>"
    end
end