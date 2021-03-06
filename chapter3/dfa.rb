require_relative 'fa_rule'

class DFARuleBook < Struct.new(:rules)
    def next_state(state, character)
        rule_for(state, character).follow
    end

    def rule_for(state, character)
        rules.detect { |rule| rule.applies_to?(state, character) }
    end
end

class DFA < Struct.new(:current_state, :accept_states, :rulebook)
    def accepting?
        accept_states.include?(current_state)
    end

    def read_character(character)
        self.current_state = rulebook.next_state(current_state, character)
    end

    def read_string(string)
        string.each_char { |c| read_character(c) }
    end
end

class DFADesign < Struct.new(:start_state, :accept_states, :rulebook)
    def to_dfa
        DFA.new(start_state, accept_states, rulebook)
    end

    def accepts?(string)
        to_dfa.tap { |dfa| dfa.read_string(string) }.accepting?
    end
end

# rulebook = DFARuleBook.new([
#     FARule.new(1, 'a', 2), FARule.new(1, 'b', 1),
#     FARule.new(2, 'a', 2), FARule.new(2, 'b', 3),
#     FARule.new(3, 'a', 3), FARule.new(3, 'b', 3),
# ])

# puts rulebook.next_state(1, 'a') # 2
# puts rulebook.next_state(1, 'b') # 1
# puts rulebook.next_state(2, 'b') # 3

# dfa = DFA.new(1, [3], rulebook)
# dfa.read_string('ab')
# puts dfa.accepting?

# dfa = DFA.new(1, [3], rulebook)
# dfa.read_string('aaa')
# puts dfa.accepting?

# dfaDesign = DFADesign.new(1, [3], rulebook)
# puts dfaDesign.accepts?('ab')
# puts dfaDesign.accepts?('aaa')