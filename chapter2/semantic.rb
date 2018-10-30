class Number < Struct.new(:value)
    def to_s
        value.to_s
    end
    def inspect
        "<#{self}>"
    end
    def reducible?
        false
    end
end

class Boolean < Struct.new(:value)
    def to_s
        value.to_s
    end
    def inspect
        "<#{self}>"
    end
    def reducible?
        false
    end
end

class Variable < Struct.new(:name)
    def to_s
        name.to_s
    end
    def inspect
        "<#{self}>"
    end
    def reducible?
        true
    end
    def reduce(environment)
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
    def reducible?
        true
    end
    def reduce(environment)
        if left.reducible?
            Add.new(left.reduce(environment), right)
        elsif right.reducible?
            Add.new(left, right.reduce(environment))
        else
            Number.new(left.value + right.value)
        end
    end
end

class Multiply < Struct.new(:left, :right)
    def to_s
        "#{left} * #{right}"
    end
    def inspect
        "<#{self}>"
    end
    def reducible?
        true
    end
    def reduce(environment)
        if left.reducible?
            Multiply.new(left.reduce(environment), right)
        elsif right.reducible?
            Multiply.new(left, right.reduce(environment))
        else
            Number.new(left.value * right.value)
        end
    end
end

class LessThan < Struct.new(:left, :right)
    def to_s
        "#{left} < #{right}"
    end
    def inspect
        "<#{self}>"
    end
    def reducible?
        true
    end
    def reduce(environment)
        if left.reducible?
            LessThan.new(left.reduce(environment), right)
        elsif right.reducible?
            LessThan.new(left, right.reduce(environment))
        else
            Boolean.new(left.value < right.value)
        end
    end
end

class Assign < Struct.new(:name, :expression)
    def to_s
        "#{name} = #{expression}"
    end
    def inspect
        "<#{self}>"
    end
    def reducible?
        true
    end
    def reduce(environment)
        if expression.reducible?
            [Assign.new(name, expression.reduce(environment)), environment]
        else
            [Noop.new, environment.merge({name => expression})]
        end
    end
end

class If < Struct.new(:condition, :consequence, :alternative)
    def to_s
        "if #{condition} { #{consequence} } else { #{alternative} }"
    end
    def inspect
        "<#{self}>"
    end
    def reducible?
        true
    end
    def reduce(environment)
        if condition.reducible?
            [If.new(condition.reduce(environment), consequence, alternative), environment]
        else
            case condition
            when Boolean.new(true)
                [consequence, environment]
            when Boolean.new(false)
                [alternative, environment]
            end
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
    def reducible?
        true
    end
    def reduce(environment)
        if first.reducible?
            reduced_statement, reduced_environment = first.reduce(environment)
            [Sequence.new(reduced_statement, second), environment.merge(reduced_environment)]
        else
            [second, environment]
        end
    end
end

class While < Struct.new(:condition, :body)
    def to_s
        "while (#{condition}) { #{body} }"
    end
    def inspect
        "<#{self}>"
    end
    def reducible?
        true
    end
    def reduce(environment)
        [If.new(condition, Sequence.new(body, self), Noop.new), environment]
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
    def reducible?
        false
    end
end

class Machine < Struct.new(:statement, :environment)
    def step
        self.statement, self.environment = statement.reduce(environment)
    end

    def run
        while statement.reducible?
            puts "#{statement}, #{environment}"
            step
        end
        puts "#{statement}, #{environment}"
    end
end

# expression = Add.new(Multiply.new(Variable.new(:x), Number.new(1)),
# Multiply.new(Number.new(3), Variable.new(:y)))

# environment = {x: Number.new(1), y: Number.new(4)}
# statement = Assign.new(:x, Add.new(Variable.new(:x), Number.new(1)))

# environment = {}
# statement = Sequence.new(Assign.new(:x, Add.new(Number.new(1), Number.new(1))),
# Assign.new(:y, Add.new(Variable.new(:x), Number.new(3))))

# environment = {x: Boolean.new(1)}
# statement = If.new(LessThan.new(Variable.new(:x), Number.new(2)), Assign.new(:y, Number.new(1)), Assign.new(:y, Number.new(2)))

environment = {x: Number.new(1), y: Number.new(4)}
statement = While.new(LessThan.new(Variable.new(:x), Number.new(5)),
Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3))))

Machine.new(statement, environment).run
puts(environment)