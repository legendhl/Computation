require_relative 'nfa'

module Pattern
    def bracket(outer_precedence)
        if precedence < outer_precedence
            "(#{to_s})"
        else
            to_s
        end
    end

    def matches?(string)
        to_nfa_design.accepts?(string)
    end

    def inspect
        "/#{self}/"
    end
end

class Empty
    include Pattern
    
    def to_s
        ''
    end

    def precedence
        3
    end

    def to_nfa_design
        start_state = Object.new
        accept_states = [start_state]
        rule = FARule.new(start_state, nil, accept_states)
        rulebook = NFARuleBook.new([rule])
        NFADesign.new(start_state, accept_states, rulebook)
    end
end

class Literal < Struct.new(:character)
    include Pattern
    
    def to_s
        character
    end

    def precedence
        3
    end

    def to_nfa_design
        start_state = Object.new
        accept_state = Object.new
        rule = FARule.new(start_state, character, accept_state)
        rulebook = NFARuleBook.new([rule])
        NFADesign.new(start_state, [accept_state], rulebook)
    end
end

class Concatenate < Struct.new(:first, :second)
    include Pattern
    
    def to_s
        [first, second].map { |pattern| pattern.bracket(precedence) }.join
    end

    def precedence
        1
    end

    def to_nfa_design
        first_nfa_design = first.to_nfa_design
        second_nfa_design = second.to_nfa_design
        start_state = first_nfa_design.start_state
        accept_states = second_nfa_design.accept_states
        rules = first_nfa_design.rulebook.rules + second_nfa_design.rulebook.rules
        extra_rules = first_nfa_design.accept_states.map { |state| FARule.new(state, nil, second_nfa_design.start_state) }
        rulebook = NFARuleBook.new(rules + extra_rules)
        NFADesign.new(start_state, accept_states, rulebook)
    end
end

class Choose < Struct.new(:first, :second)
    include Pattern
    
    def to_s
        [first, second].map { |pattern| pattern.bracket(precedence) }.join('|')
    end

    def precedence
        0
    end

    def to_nfa_design
        first_nfa_design = first.to_nfa_design
        second_nfa_design = second.to_nfa_design
        start_state = Object.new
        accept_states = first_nfa_design.accept_states + second_nfa_design.accept_states
        rules = first_nfa_design.rulebook.rules + second_nfa_design.rulebook.rules
        extra_rules = [first_nfa_design, second_nfa_design].map { |nfa_design| FARule.new(start_state, nil, nfa_design.start_state)}
        rulebook = NFARuleBook.new(rules + extra_rules)
        NFADesign.new(start_state, accept_states, rulebook)
    end
end

class Repeat < Struct.new(:pattern)
    include Pattern
    
    def to_s
        pattern.bracket(precedence) + '*'
    end

    def precedence
        2
    end

    def to_nfa_design
        nfa_design = pattern.to_nfa_design
        start_state = Object.new
        accept_state = start_state
        rules = nfa_design.rulebook.rules
        extra_rules = [FARule.new(start_state, nil, accept_state), FARule.new(start_state, nil, nfa_design.start_state)]
        extra_rules += nfa_design.accept_states.map { |state| FARule.new(state, nil, accept_state) }
        rulebook = NFARuleBook.new(rules + extra_rules)
        NFADesign.new(start_state, [accept_state], rulebook)
    end
end

# pattern = Repeat.new(Choose.new(Concatenate.new(Literal.new('a'), Literal.new('b')), Literal.new('a')))
# puts pattern

# puts Empty.new.matches?('')
# puts Literal.new('a').matches?('a')
# puts Concatenate.new(Literal.new('a'), Literal.new('b')).matches?('ab')
# choose_pattern = Choose.new(Concatenate.new(Literal.new('a'), Literal.new('b')), Literal.new('a'))
# puts choose_pattern.matches?('ab')
# puts choose_pattern.matches?('a')
# puts choose_pattern.matches?('aba')
# puts pattern.matches?('')
# puts pattern.matches?('a')
# puts pattern.matches?('ab')
# puts pattern.matches?('abaaa')
# puts pattern.matches?('abaaab')
# puts pattern.matches?('abab')
# puts pattern.matches?('ababaabb')
# puts pattern.matches?('bb')
# puts pattern.matches?('ba')