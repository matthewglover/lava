require "./spec_helper"

describe Lava::Result do
  ex = Exception.new("Boom!")
  int_to_str = ->(a : Int32){ a.to_s }
  err_to_str = ->(e : Exception){ "Something's gone wrong: #{e.message}" }

  describe "#peek" do
    it "Ok(E, A) #peek = A" do
      ok = Lava::Result.ok(10, Exception)
      ok.peek.should eq 10
    end

    it "Error(E, A) #peek = E" do
      error = Lava::Result.error(ex, Int32)
      error.peek.should eq ex
    end
  end

  describe "#fold" do
    it "Ok(E, A) #fold Proc(E, B), Proc(A, B) = B" do
      ok = Lava::Result.ok(10, Exception)
      actual = ok.fold(err_to_str, int_to_str)
      actual.should eq "10"
    end

    it "Error(A, E) #fold Proc(E, B), Proc(A, B) = B" do
      error = Lava::Result.error(ex, Int32)
      actual = error.fold(err_to_str, int_to_str)
      actual.should eq "Something's gone wrong: Boom!"
    end
  end

  describe "#map" do
    it "Ok(E, A) #map Proc(A, B) = Ok(E, B)" do
      ok = Lava::Result.ok(10, Exception)
      actual = ok.map(int_to_str)
      actual.peek.should eq "10"
    end

    it "Error(E, A) #map Proc(A, B) = Error(E, B)" do
      error = Lava::Result.error(ex, Int32)
      actual = error.map(int_to_str)
      actual.peek.should eq ex
    end
  end

  describe "#flat_map" do
    it "Ok(E, A) #flat_map Proc(A, Ok(E, B)) = Ok(E, B)" do
      int_to_ok_str = ->(a : Int32){ Lava::Result.ok(a.to_s, Exception) }
      ok = Lava::Result.ok(10, Exception)
      actual = ok.flat_map(int_to_ok_str)
      actual.peek.should eq "10"
    end

    it "Error(E, A) #flat_map Proc(A, Ok(E, B)) = Error(E, B)" do
      int_to_ok_str = ->(a : Int32){ Lava::Result.ok(a.to_s, Exception) }
      error = Lava::Result.error(ex, Int32)

      actual = error.flat_map(int_to_ok_str)

      actual.should be_a Lava::Result(Exception, String)
      actual.peek.should eq ex
    end

    it "Ok(E, A) #flat_map Proc(A, Error(E, B)) = Error(E, B)" do
      int_to_error_str = ->(a : Int32){ Lava::Result.error(ex, String) }
      ok = Lava::Result.ok(10, Exception)

      actual = ok.flat_map(int_to_error_str)

      actual.should be_a Lava::Result(Exception, String)
      actual.peek.should eq ex
    end
  end
end
