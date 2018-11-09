require_relative 'stack'
require_relative 'pda_configuration'
require_relative 'npda'

class NPDADesign < Struct.new(:start_state, :bottom_character, :accept_states, :rulebook)
    def to_npda
        NPDA.new(Set[PDAConfiguration.new(start_state, Stack.new([bottom_character]))], accept_states, rulebook)
    end

    def accepts?(string)
        to_npda.tap { |npda| npda.read_string(string) }.accepting?
    end
end