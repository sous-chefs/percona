# frozen_string_literal: true

control 'percona_database' do
  impact 1.0
  title 'test creation and removal of databases'

  sql = mysql_session('root', '')

  describe sql.query('show databases') do
    its(:stdout) { should match(/databass/) }
    its(:stdout) { should_not match(/datatrout/) }
  end
end

control 'percona_user' do
  impact 1.0
  title 'test creation, granting and removal of users'

  sql = mysql_session('root', '')

  describe sql.query('select User,Host from mysql.user') do
    its(:stdout) { should match(/fozzie/) }
    its(:stdout) { should_not match(/kermit/) }
  end

  describe sql.query("SELECT authentication_string FROM mysql.user WHERE user='fozzie' AND host='mars'") do
    its(:stdout) { should include '*EF112B3D562CB63EA3275593C10501B59C4A390D' }
  end

  describe sql.query("SELECT authentication_string FROM mysql.user WHERE user='moozie' AND host='127.0.0.1'") do
    its(:stdout) { should include '*F798E7C0681068BAE3242AA2297D2360DBBDA62B' }
  end
end
