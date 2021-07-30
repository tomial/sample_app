require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test 'micropost interface' do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'

    # 无效提交
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: '' } }
    end

    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2' # 分页链接正确

    # 有效提交
    content = '测试'
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
    end

    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body

    # 删除一篇微博
    assert_select 'a', text: 'delete'
    first_micropost = Micropost.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end

    get user_path(users(:archer))
    assert_select 'a', { text: 'delete', count: 0a}
  end
end
