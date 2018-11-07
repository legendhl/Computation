require_relative 'pda_configuration'

class PDARule < Struct.new(:state, :character, :next_state, :pop_character, :push_characters)
    # 机器状态、栈顶字符和下一个输入的字符都为期望值时才能应用规则
    def applies_to?(configuration, character)
        self.state == configuration.state && self.pop_character == configuration.stack.top && self.character == character
    end

    def follow(configuration)
        PDAConfiguration.new(next_state, next_stack(configuration))
    end

    def next_stack(configuration)
        stack = configuration.stack.pop
        push_characters.reverse.inject(stack) { |stack, character| stack.push(character) }
    end
end