module Lava
  abstract class Result(E, A)
    def self.ok(ok_value : A, error_type : E)
      Ok.new(ok_value, error_type)
    end

    def self.error(error_value : E, ok_type : A)
      Error.new(error_value, ok_type)
    end

    abstract def peek : A | E
    abstract def fold(error_handler : Proc(E, B), ok_handler : Proc(A, B)) : B forall B
    abstract def map(mapper : Proc(A, B)) : Result(E, B) forall B
    abstract def flat_map(mapper : Proc(A, Result(E,B))) : Result(E, B) forall B
  end

  private class Ok(E, A) < Result(E, A)
    def initialize(@value : A, @error_type : E.class)
    end

    def peek
      @value
    end

    def fold(error_handler : Proc(E, B), ok_handler : Proc(A, B)) forall B
      ok_handler.call(@value)
    end

    def map(mapper : Proc(A, B)) forall B
      Ok.new(mapper.call(@value), E)
    end

    def flat_map(mapper : Proc(A, Result(E,B))) forall B
      mapper.call(@value)
    end
  end

  private class Error(E, A) < Result(E, A)
    def initialize(@value : E, @ok_type : A.class)
    end

    def peek
      @value
    end

    def fold(error_handler : Proc(E, B), ok_handler : Proc(A, B)) forall B
      error_handler.call(@value)
    end

    def map(mapper : Proc(A, B)) forall B
      Result.error(@value, B)
    end

    def flat_map(mapper : Proc(A, Result(E, B))) forall B
      Result.error(@value, B)
    end
  end
end
