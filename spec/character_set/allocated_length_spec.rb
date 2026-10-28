describe 'CharacterSet#allocated_length' do
  it 'uses compact storage for ASCII members' do
    expect(CharacterSet[97].allocated_length).to be < 1024
  end
end
