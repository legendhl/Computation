class DPDARulebook < Struct.new(:rules)
    def next_configuration(configuration, character)
        rule_for(configuration, character).follow(configuration)
    end

    def rule_for(configuration, character)
        rules.detect { |rule| rule.applies_to?(configuration, character) }
    end
end