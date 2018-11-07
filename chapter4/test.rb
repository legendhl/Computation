require_relative 'stack'
require_relative 'pda_rule'
require_relative 'dpda_rulebook'
require_relative 'dpda'

# stack = Stack.new(['a','b','c','d','e'])
# puts stack ##<Stack (a)bcde>
# puts stack.pop ##<Stack (b)cde>
# puts stack.pop.pop.top # c
# puts stack.push('x').push('y').top # y
# puts stack.push('x').push('y').pop.top # x

# rule = PDARule.new(1, '(', 2, '$', ['b','$'])
# puts rule
# configuration = PDAConfiguration.new(1, Stack.new(['$']))
# puts rule.applies_to?(configuration, '(')
# puts rule.follow(configuration)

rulebook = DPDARulebook.new([PDARule.new(1,'(',2,'$',['b','$']), PDARule.new(2,'(',2,'b',['b','b']), 
PDARule.new(2,')',2,'b',[]), PDARule.new(2,nil,1,'$',['$'])])

configuration = PDAConfiguration.new(1, Stack.new(['$']))
configuration = rulebook.next_configuration(configuration, '(')
puts configuration
configuration = rulebook.next_configuration(configuration, '(')
puts configuration
configuration = rulebook.next_configuration(configuration, ')')
puts configuration
configuration = rulebook.next_configuration(configuration, ')')
puts configuration