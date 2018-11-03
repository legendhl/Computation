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

    def follow_free_moves(states)
        more_states = next_states(states, nil)
        if more_states.subset?(states)
            states
        else
            states | follow_free_moves(more_states)
        end
    end
end

rulebook = NFARuleBook.new([
    FARule.new(1, nil, 2), FARule.new(1, nil, 4),
    FARule.new(2, 'a', 3), FARule.new(3, 'a', 2),
    FARule.new(4, 'a', 5), FARule.new(5, 'a', 6),
    FARule.new(6, 'a', 4),
])

# puts rulebook.next_states(Set[1], nil) # 2,4
# puts rulebook.follow_free_moves(Set[1]) # 1,2,4

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

    def current_states
        rulebook.follow_free_moves(super)
    end
end

# nfa = NFA.new(Set[1], [3], rulebook)
# nfa.read_string('ab')
# puts nfa.accepting?

# nfa = NFA.new(Set[1], [3], rulebook)
# nfa.read_string('abbbb')
# puts nfa.accepting?

class NFADesign < Struct.new(:start_state, :accept_states, :rulebook)
    def to_nfa
        NFA.new(Set[start_state], accept_states, rulebook)
    end

    def accepts?(string)
        to_nfa.tap { |nfa| nfa.read_string(string) }.accepting?
        # nfa = to_nfa
        # nfa.read_string(string)
        # nfa.accepting?
    end
end

nfa_design = NFADesign.new(1, [2,4], rulebook)
puts nfa_design.accepts?('aa') # true
puts nfa_design.accepts?('aaa') # true
puts nfa_design.accepts?('aaaaa') # false
puts nfa_design.accepts?('aaaaaa') # true
