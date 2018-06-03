class CharacterSet < SortedSet
  module SetMethods
    # this lets some Set methods work with a String arg in addition to Integer
    %w[add add? delete delete? include? member?].each do |mthd|
      define_method(mthd) do |arg|
        super(arg.is_a?(String) ? arg.codepoints.first : arg)
      end
    end
  end
end
