class formation_extra (
  Array[Struct[{ filename => String[1], source => String[1] }]] $stripped_skel_archives = [],
  String $google_calendar_id,
  String $google_api_key,
  String $timezone = "UTC",
  String $course,
) {

  ensure_resource('file', '/opt/puppetlabs/puppet/cache/puppet-archive', { 'ensure' => 'directory' })
  $stripped_skel_archives.each |$index, Hash $archive| {
    $filename = $archive['filename']
    archive { "stripped_skel_${index}":
      path            => "/opt/puppetlabs/puppet/cache/puppet-archive/${filename}",
      extract         => true,
      extract_path    => '/etc/skel.ipa',
      extract_command => 'tar xf %s --strip-components=1',
      source          => $archive['source'],
      require         => File['/etc/skel.ipa'],
      notify          => Exec['chown -R root:root /etc/skel.ipa'],
    }
  }

  file { '/usr/sbin/is_event_soon.py':
    path   => '/usr/sbin/is_event_soon.py',
    ensure => 'file',
    mode   => 'u+rx,go-rwx',
    source => 'https://raw.githubusercontent.com/calculquebec/CQORC/refs/heads/main/is_event_soon.py',
    owner  => 'root'
  }

  file { '/etc/cq_event_check.ini':
    path    => '/etc/cq_event_check.ini',
    ensure  => 'file',
    mode    => 'u+rwx,go-rwx',
    owner   => 'root',
    content => @("EOF"),
      # FILE MANAGED BY PUPPET, DO NOT EDIT DIRECTLY
      [DEFAULT]
      calendar_id = ${google_calendar_id}
      apikey = ${google_api_key}
      course = ${course}
      timezone = ${timezone}
      |EOF
  }
}
