require_relative '../shared/include'

describe "CharacterSet#===", if: ruby_version_is_at_least('2.5') do
  it_behaves_like :sorted_set_include, CharacterSet, :===
end
