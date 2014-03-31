require 'spec_helper'

describe UTF8Cleaner::Middleware do
  let :env do
    {
      'PATH_INFO' => 'foo/%FFbar%2e%2fbaz%26%3B',
      'QUERY_STRING' => 'foo=bar%FF',
      'HTTP_REFERER' => 'http://example.com/blog+Result:+%ED%E5+%ED%E0%F8%EB%EE%F1%FC+%F4%EE%F0%EC%FB+%E4%EB%FF+%EE%F2%EF%F0%E0%E2%EA%E8',
      'REQUEST_URI' => '%C3%89%E2%9C%93'
    }
  end

  let :new_env do
    UTF8Cleaner::Middleware.new(nil).send(:sanitize_env, env)
  end

  describe "removes invalid UTF-8 sequences" do
    it { new_env['QUERY_STRING'].should == 'foo=bar' }
    it { new_env['HTTP_REFERER'].should == 'http://example.com/blog+Result:+++++' }
  end

  describe "leaves all valid characters untouched" do
    it { new_env['PATH_INFO'].should == 'foo/bar%2e%2fbaz%26%3B' }
    it { new_env['REQUEST_URI'].should == '%C3%89%E2%9C%93' }
  end
  context 'POST' do
    let :env do
      {
        'rack.input' => StringIO.new("foo=bar%ED"),
        'REQUEST_METHOD' => 'POST'
      }
    end
    describe "removes invalid UTF-8 sequences from post" do
      it { new_env['rack.input'].string.should == 'foo=bar' }
    end
  end

end
