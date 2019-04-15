require_relative '../shared/select'

describe "CharacterSet::Pure#filter!", if: ruby_version_is_at_least('2.6') do
  it_behaves_like :sorted_set_select_bang, CharacterSet::Pure, :filter!
end
