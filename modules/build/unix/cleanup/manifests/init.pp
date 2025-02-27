class cleanup::init {
  $secgen_params = secgen_functions::get_parameters($::base64_inputs_file)
  $remove_history = str2bool($secgen_params['remove_history'][0])
  $root_password = $secgen_params['root_password'][0]
  $clobber_file_times = str2bool($secgen_params['clobber_file_times'][0])
  $disable_ssh = str2bool($secgen_params['disable_ssh'][0])

  Exec { path => ['/bin','/sbin','/usr/bin', '/usr/sbin'] }

  file_line { 'comment_out_legacy_login_config1':
    line   => '# NONEXISTENT',
    match  => 'NONEXISTENT.*',
    path => "/etc/login.defs",
  } ->
  file_line { 'comment_out_legacy_login_config2':
    line   => '# PREVENT_NO_AUTH',
    match  => 'PREVENT_NO_AUTH.*',
    path => "/etc/login.defs",
  }

  if $root_password {
    # Set root password
    ::accounts::user { 'root':
      ensure => present,
      password   => pw_hash($root_password, 'SHA-512', 'mysalt'),
    }
    ::accounts::user { 'vagrant':
      ensure => present,
      password   => pw_hash($root_password, 'SHA-512', 'mysalt'),
    }
  }

  # Disable ssh
  if $disable_ssh {
    service { 'ssh':
      enable => false,
    }
  }

  # Reset all system file access times to hide our tracks
  if $clobber_file_times {
    notice 'Clobbering file access times -- This may take a while...'
    exec { 'clobber_files':
      command => "find / -exec touch -d '17 May 2006 14:16' {} \\;",
    }
  }

  # removes bash history
  if $remove_history {
    exec { 'remove_history':
      command => "/bin/bash -c 'history -c && history -w'"
    }
  }
}
