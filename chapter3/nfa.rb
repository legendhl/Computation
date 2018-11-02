require 'set'

class FARule < Struct.new(:state, :character, :next_state)
    def applies_to?(state, character)
        self.state == state && self.character == character
    end

    def follow
        next_state
    end

    def inspect
        "#<FARule #{state.inspect} --#{character}--> #{next_state.inspect}>"
    end
end

class NFARuleBook < Struct.new(:rules)
    def next_states(states, character)
        # next_states = states.map do |state|
        #     rule_for(state, character).map { |rule| rule.follow }
        # end
        # next_states.flatten.to_set
        (states.map { |state| rule_for(state, character).map { |rule| rule.follow } }).flatten.to_set
    end

    def rule_for(state, character)
        rules.select { |rule| rule.applies_to?(state, character) }
    end
end

rulebook = NFARuleBook.new([
    FARule.new(1, 'a', 1), FARule.new(1, 'b', 1), FARule.new(1, 'b', 2),
    FARule.new(2, 'a', 3), FARule.new(2, 'b', 3),
    FARule.new(3, 'a', 4), FARule.new(3, 'b', 4),
])

# puts rulebook.next_states(Set[1], 'b') # 1,2
# puts rulebook.next_states(Set[1,2], 'a') # 1,3
# puts rulebook.next_states(Set[1,3], 'b') # 1,2,4

class NFA < Struct.new(:current_states, :accept_states, :rulebook)
    def accepting?
        (current_states.map { |state| accept_states.include?(state) }).include?(true)
    end

    def read_character(character)
        self.current_states = rulebook.next_states(current_states, character)
    end

    def read_string(string)
        string.each_char { |c| read_character(c) }
    end
end

# nfa = NFA.new(Set[1], [3], rulebook)
# nfa.read_string('ab')
# puts nfa.accepting?

# nfa = NFA.new(Set[1], [3], rulebook)
# nfa.read_string('abbbb')
# puts nfa.accepting?

class NFADesign < Struct.new(:start_states, :accept_states, :rulebook)
    def to_nfa
        NFA.new(start_states, accept_states, rulebook)
    end

    def accepts?(string)
        to_nfa.tap { |nfa| nfa.read_string(string) }.accepting?
        # nfa = to_nfa
        # nfa.read_string(string)
        # nfa.accepting?
    end
end

nfaDesign = NFADesign.new(Set[1], [3], rulebook)
puts nfaDesign.accepts?('ab')
puts nfaDesign.accepts?('abbbb')