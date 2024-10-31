class formation_extra (
  Array[Struct[{ filename => String[1], source => String[1] }]] $stripped_skel_archives = [],
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
}
