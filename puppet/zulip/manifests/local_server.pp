class zulip::local_server {
  class { 'zulip::base': }
  class { 'zulip::app_frontend': }

  package { "postgresql-9.1": ensure => installed }
  # This should be migrated over to app_frontend, once validated as functional
  # on app servers.
  package { "nodejs": ensure => installed }

  file { "/etc/nginx/sites-available/zulip-local":
    require => Package[nginx],
    ensure => file,
    owner  => "root",
    group  => "root",
    mode => 644,
    source => "puppet:///modules/zulip/nginx/sites-available/zulip-local",
  }
  file { '/etc/nginx/sites-enabled/zulip-local':
    ensure => 'link',
    target => '/etc/nginx/sites-available/zulip-local',
  }
  file { '/home/zulip/logs':
    ensure => 'directory',
    owner  => 'zulip',
    group  => 'zulip',
  }
  file { '/home/zulip/deployments':
    ensure => 'directory',
    owner  => 'zulip',
    group  => 'zulip',
  }
  file { '/home/zulip/deployments/current':
    ensure => 'link',
    target => '/home/zulip/zulip',
  }
  file { '/home/zulip/prod-static':
    ensure => 'link',
    target => '/home/zulip/deployments/current/prod-static/serve',
  }

  file { "/usr/share/postgresql/9.1/tsearch_data/zulip_english.stop":
    require => Package["postgresql-9.1"],
    ensure => file,
    owner => "root",
    group => "root",
    mode => 644,
    source => "puppet:///modules/zulip/postgresql/zulip_english.stop",
  }

}