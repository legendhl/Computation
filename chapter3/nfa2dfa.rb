require_relative 'nfa'
require_relative 'dfa'

class NFASimulation < Struct.new(:nfa_design)
    def next_state(state, character)
        nfa_design.to_nfa(state).tap { |nfa| nfa.read_character(character) }.current_states
    end

    def rules_for(state)
        nfa_design.rulebook.alphabet.map { |character| FARule.new(state, character, next_state(state, character)) }
    end

    def discover_states_and_rules(states)
        rules = states.flat_map { |state| rules_for(state) }
        more_states = rules.map(&:follow).to_set
        if more_states.subset?(states)
            [states, rules]
        else
            discover_states_and_rules(states + more_states)
        end
    end

    def to_dfa_design
        start_state = nfa_design.to_nfa.current_states
        states, rules = discover_states_and_rules(Set[start_state])
        accept_states = states.select { |state| nfa_design.to_nfa(state).accepting? }
        DFADesign.new(start_state, accept_states, DFARuleBook.new(rules))
    end
end

# rulebook = NFARuleBook.new([
#     FARule.new(1, 'a', 1), FARule.new(1, 'a', 2),
#     FARule.new(1, nil, 2), FARule.new(2, 'b', 3),
#     FARule.new(3, 'b', 1), FARule.new(3, nil, 2),
# ])

# puts rulebook.alphabet
# puts rulebook.next_states(Set[1], nil) # 2,4
# puts rulebook.follow_free_moves(Set[1]) # 1,2,4

# nfa_design = NFADesign.new(1, [3], rulebook)
# puts nfa_design
# puts nfa_design.to_nfa.current_states
# puts nfa_design.to_nfa(Set[2]).current_states
# puts nfa_design.to_nfa(Set[3]).current_states

# nfa = nfa_design.to_nfa(Set[2,3])
# nfa.read_character('b')
# puts nfa.current_states

# simulation = NFASimulation.new(nfa_design)
# puts simulation
# puts simulation.next_state(Set[1,2], 'a')
# puts simulation.next_state(Set[1,2], 'b')
# puts simulation.next_state(Set[1,3,2], 'a')
# puts simulation.rules_for(Set[1,2])
# start_state = nfa_design.to_nfa.current_states
# puts start_state
# puts simulation.discover_states_and_rules(Set[start_state])
# puts nfa_design.to_nfa(Set[1,2]).accepting?
# puts nfa_design.to_nfa(Set[2,3]).accepting?

# dfa_desigin = simulation.to_dfa_design
# puts dfa_desigin.accepts?('aaa')
# puts dfa_desigin.accepts?('aab')
# puts dfa_desigin.accepts?('bbbabb')