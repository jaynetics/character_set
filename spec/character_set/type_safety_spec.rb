# the core behavior of the methods below is tested by ruby-spec.
# this file just includes additional, paranoid type-safety tests,
# as trying to handle codepoints beyond the bounds would lead to a segfault.

shared_examples :character_set_typesafe_method do |variant, method|
  it 'raises ArgumentError for inapplicable values' do
    expect { variant[].send(method, -1) }.to raise_error(ArgumentError)
    expect { variant[].send(method, -(10**200)) }.to raise_error(ArgumentError)
    expect { variant[].send(method, 10**200) }.to raise_error(ArgumentError)
    expect { variant[].send(method, nil) }.to raise_error(ArgumentError)
    expect { variant[].send(method, :foo) }.to raise_error(ArgumentError)
    expect { variant[].send(method, []) }.to raise_error(ArgumentError)
    expect { variant[].send(method, Object.new) }.to raise_error(ArgumentError)
  end
end

describe "CharacterSet#add" do
  it_behaves_like :character_set_typesafe_method, CharacterSet, :add
end

describe "CharacterSet::Pure#add" do
  it_behaves_like :character_set_typesafe_method, CharacterSet::Pure, :add
end

describe "CharacterSet#add?" do
  it_behaves_like :character_set_typesafe_method, CharacterSet, :add?
end

describe "CharacterSet::Pure#add?" do
  it_behaves_like :character_set_typesafe_method, CharacterSet::Pure, :add?
end

describe "CharacterSet#delete" do
  it_behaves_like :character_set_typesafe_method, CharacterSet, :delete
end

describe "CharacterSet::Pure#delete" do
  it_behaves_like :character_set_typesafe_method, CharacterSet::Pure, :delete
end

describe "CharacterSet#delete?" do
  it_behaves_like :character_set_typesafe_method, CharacterSet, :delete?
end

describe "CharacterSet::Pure#delete?" do
  it_behaves_like :character_set_typesafe_method, CharacterSet::Pure, :delete?
end

describe "CharacterSet#include?" do
  it_behaves_like :character_set_typesafe_method, CharacterSet, :include?
end

describe "CharacterSet::Pure#include?" do
  it_behaves_like :character_set_typesafe_method, CharacterSet::Pure, :include?
end

describe "CharacterSet#member?" do
  it_behaves_like :character_set_typesafe_method, CharacterSet, :member?
end

describe "CharacterSet::Pure#member?" do
  it_behaves_like :character_set_typesafe_method, CharacterSet::Pure, :member?
end

shared_examples :character_set_typesafe_mass_method do |variant, method|
  it 'raises ArgumentError or TypeError for inapplicable values' do
    check = ->(err){ expect([ArgumentError, TypeError]).to include err.class }
    expect { variant[].send(method, [0, -1]) }.to raise_error(&check)
    expect { variant[].send(method, [0, -(10**200)]) }.to raise_error(&check)
    expect { variant[].send(method, [0, 10**200]) }.to raise_error(&check)
    expect { variant[].send(method, [0, nil]) }.to raise_error(&check)
    expect { variant[].send(method, [0, :foo]) }.to raise_error(&check)
    expect { variant[].send(method, [0, []]) }.to raise_error(&check)
    expect { variant[].send(method, [0, Object.new]) }.to raise_error(&check)
  end
end

describe 'CharacterSet#merge' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet, :merge
end

describe 'CharacterSet::Pure#merge' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet::Pure, :merge
end

describe 'CharacterSet#subtract' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet, :subtract
end

describe 'CharacterSet::Pure#subtract' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet::Pure, :subtract
end

describe 'CharacterSet#+' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet, :+
end

describe 'CharacterSet::Pure#+' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet::Pure, :+
end

describe 'CharacterSet#-' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet, :-
end

describe 'CharacterSet::Pure#-' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet::Pure, :-
end

describe 'CharacterSet#&' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet, :&
end

describe 'CharacterSet::Pure#&' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet::Pure, :&
end

describe 'CharacterSet#^' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet, '^'
end

describe 'CharacterSet::Pure#^' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet::Pure, '^'
end

describe 'CharacterSet#>' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet, :>
end

describe 'CharacterSet::Pure#>' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet::Pure, :>
end

describe 'CharacterSet#>=' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet, :>=
end

describe 'CharacterSet::Pure#>=' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet::Pure, :>=
end

describe 'CharacterSet#<' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet, :<
end

describe 'CharacterSet::Pure#<' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet::Pure, :<
end

describe 'CharacterSet#<=' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet, :<=
end

describe 'CharacterSet::Pure#<=' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet::Pure, :<=
end

describe 'CharacterSet#intersect?' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet, :intersect?
end

describe 'CharacterSet::Pure#intersect?' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet::Pure, :intersect?
end

describe 'CharacterSet#disjoint?' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet, :disjoint?
end

describe 'CharacterSet::Pure#disjoint?' do
  it_behaves_like :character_set_typesafe_mass_method, CharacterSet::Pure, :disjoint?
end
