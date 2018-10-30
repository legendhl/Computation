class Number < Struct.new(:value)
    def to_s
        value.to_s
    end
    def inspect
        "<#{self}>"
    end
    def evaluate(environment)
        self
    end
end

class Boolean < Struct.new(:value)
    def to_s
        value.to_s
    end
    def inspect
        "<#{self}>"
    end
    def evaluate(environment)
        self
    end
end

class Variable < Struct.new(:name)
    def to_s
        name.to_s
    end
    def inspect
        "<#{self}>"
    end
    def evaluate(environment)
        environment[name]
    end
end

class Add < Struct.new(:left, :right)
    def to_s
        "#{left} + #{right}"
    end
    def inspect
        "<#{self}>"
    end
    def evaluate(environment)
        Number.new(left.evaluate(environment).value + right.evaluate(environment).value)
    end
end

class Multiply < Struct.new(:left, :right)
    def to_s
        "#{left} * #{right}"
    end
    def inspect
        "<#{self}>"
    end
    def evaluate(environment)
        Number.new(left.evaluate(environment).value * right.evaluate(environment).value)
    end
end

class LessThan < Struct.new(:left, :right)
    def to_s
        "#{left} < #{right}"
    end
    def inspect
        "<#{self}>"
    end
    def evaluate(environment)
        Boolean.new(left.evaluate(environment).value < right.evaluate(environment).value)
    end
end

class Assign < Struct.new(:name, :expression)
    def to_s
        "#{name} = #{expression}"
    end
    def inspect
        "<#{self}>"
    end
    def evaluate(environment)
        environment.merge({ name => expression.evaluate(environment) })
    end
end

class If < Struct.new(:condition, :consequence, :alternative)
    def to_s
        "if #{condition} { #{consequence} } else { #{alternative} }"
    end
    def inspect
        "<#{self}>"
    end
    def evaluate(environment)
        case condition.evaluate(environment)
        when Boolean.new(true)
            consequence.evaluate(environment)
        when Boolean.new(false)
            alternative.evaluate(environment)
        end
    end
end

class Sequence < Struct.new(:first, :second)
    def to_s
        "#{first}; #{second}"
    end
    def inspect
        "<#{self}>"
    end
    def evaluate(environment)
        second.evaluate(first.evaluate(environment))
    end
end

class While < Struct.new(:condition, :body)
    def to_s
        "while (#{condition}) { #{body} }"
    end
    def inspect
        "<#{self}>"
    end
    def evaluate(environment)
        case condition.evaluate(environment)
        when Boolean.new(true)
            evaluate(body.evaluate(environment))
        when Boolean.new(false)
            environment
        end
    end
end

class Noop
    def to_s
        'do-nothing'
    end
    def inspect
        "#{self}"
    end
    def ==(other_statement)
        other_statement.instance_of?(Noop)
    end
    def evaluate(environment)
        environment
    end
end

environment = {x: Number.new(2)}
statement = Add.new(Variable.new(:x), Number.new(1))
puts environment, statement, statement.evaluate(environment)

environment = {x: Number.new(2), y: Number.new(5)}
statement = LessThan.new(Add.new(Variable.new(:x), Number.new(2)), Variable.new(:y))
puts environment, statement, statement.evaluate(environment)

environment = {x: Number.new(1), y: Number.new(4)}
statement = Assign.new(:x, Add.new(Variable.new(:x), Number.new(1)))
puts environment, statement, statement.evaluate(environment)

environment = {}
statement = Sequence.new(Assign.new(:x, Add.new(Number.new(1), Number.new(1))),
Assign.new(:y, Add.new(Variable.new(:x), Number.new(3))))
puts environment, statement, statement.evaluate(environment)

environment = {x: Boolean.new(1)}
statement = If.new(LessThan.new(Variable.new(:x), Number.new(2)), Assign.new(:y, Number.new(1)), Assign.new(:y, Number.new(2)))
puts environment, statement, statement.evaluate(environment)

environment = {x: Number.new(1), y: Number.new(4)}
statement = While.new(LessThan.new(Variable.new(:x), Number.new(5)),
Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3))))
puts environment, statement, statement.evaluate(environment)
