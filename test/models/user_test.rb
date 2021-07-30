require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.new(name: 'Example User', email: 'example@test.com',
                     password: 'password', password_confirmation: 'password')
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'name should be present' do
    @user.name = '    '
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = '     '
    assert_not @user.valid?
  end

  test 'name should not be too long' do
    @user.name = 'a' * 51
    assert_not @user.valid?
  end

  test 'email should not be too long' do
    @user.email = "#{'a' * 244}@example.com"
    assert_not @user.valid?
  end

  test 'email validation should accept valid emails' do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test 'email validation should reject invalid addresses' do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address} should be invalid"
    end
  end

  test 'email addresses should be unique' do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'user email should be saved as lowercase' do
    mixed_case_email = 'fOo@TeSt.Com'
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test 'password should be present (notblank)' do
    @user.password = @user.password_confirmation = ' ' * 6
    assert_not @user.valid?
  end

  test 'password should have a minimum length' do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?
  end

  test 'authenticated? should return false for a user with nil digest' do
    assert_not @user.authenticated?(:remember, '')
  end

  test 'associated microposts should be destroyed' do
    @user.save
    @user.microposts.create!(content: 'lorem ipsum')
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test 'should follow and unfollow a user' do
    m = users(:michael)
    a = users(:archer)

    assert_not m.following?(a)
    m.follow a
    assert m.following?(a)
    assert a.followers.include?(m)
    m.unfollow a
    assert_not m.following?(a)
    # 不能关注自己
    m.follow m
    assert_not m.following?(m)
  end

  test 'feed should have the right posts' do
    michael = users(:michael)
    archer = users(:archer)
    lana = users(:lana)
    # 关注用户的微博
    lana.microposts.each do |micropost|
      assert michael.feed.include?(micropost)
    end

    # 自己的微博（有关注者）
    michael.microposts.each do |micropost|
      assert michael.feed.include?(micropost)
    end

    archer.microposts.each do |micropost|
      # 自己的微博（无关注者）
      assert archer.feed.include?(micropost)
      # 未关注用户的微博
      assert_not michael.feed.include?(micropost)
    end
  end
end
