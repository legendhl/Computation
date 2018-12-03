require_relative 'tape'
require_relative 'tm_rule'
require_relative 'tm_configuration'
require_relative 'dtm_rulebook'
require_relative 'dtm'

tape = Tape.new(['1','0','1'], '1', [], '_')
p tape
p tape.middle
p tape.move_head_left
p tape.write('0')
p tape.move_head_right
p tape.move_head_right.write('0')

rule = TMRule.new(1, '0', 2, '1', :right)
p rule
p rule.applies_to?(TMConfiguration.new(1, Tape.new([], '0', [], '_')))
p rule.applies_to?(TMConfiguration.new(1, Tape.new([], '1', [], '_')))
p rule.applies_to?(TMConfiguration.new(2, Tape.new([], '0', [], '_')))

p rule.follow(TMConfiguration.new(1, Tape.new([], '0', [], '_')))

rulebook = DTMRulebook.new([
    TMRule.new(1, '0', 2, '1', :right),
    TMRule.new(1, '1', 1, '0', :left),
    TMRule.new(1, '_', 2, '1', :right),
    TMRule.new(2, '0', 2, '0', :right),
    TMRule.new(2, '1', 2, '1', :right),
    TMRule.new(2, '_', 3, '_', :left)
])

p rulebook
configuration = TMConfiguration.new(1, tape)
p configuration
configuration = rulebook.next_configuration(configuration)
p configuration
configuration = rulebook.next_configuration(configuration)
p configuration
configuration = rulebook.next_configuration(configuration)
p configuration

dtm = DTM.new(TMConfiguration.new(1, tape), [3], rulebook)
p dtm
p dtm.current_configuration
p dtm.accepting?
p dtm.run
p dtm.current_configuration
p dtm.accepting?