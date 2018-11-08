require_relative 'dpda'

class DPDADesign < Struct.new(:current_configuration, :accept_states, :rulebook)
    def to_dpda
        DPDA.new(current_configuration, accept_states, rulebook)
    end

    def accepts?(string)
        to_dpda.tap { |dpda| dpda.read_string(string) }.accepting?
    end
end