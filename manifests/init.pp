class logstash (
  $version     = '1.4.2',
  $destination = '/opt',
  $redis_host = 'localhost',
  $elasticsearch_host = 'localhost',
  $components = []) {

  $filename  = "logstash-${version}" 
  $tar_file  = "${filename}.tar.gz"
  $url       = "https://download.elasticsearch.org/logstash/logstash/${tar_file}"

  exec { "wget ${filename}":
    command => "wget -q ${url} -O ${destination}/${tar_file}",
    path => ["/usr/bin", "/bin"],
  }

  exec { "untar ${filename}":
    command => "tar -xf ${destination}/${tar_file} -C ${destination}",
    path => ["/usr/bin", "/bin"],
    subscribe => Exec["wget ${filename}"],
    refreshonly => true,
  }

  file { '/etc/logstash-redis.conf':
    ensure  => file,
    content => template('logstash/logstash-redis.conf.erb'),
  }
    
  file { '/etc/init/logstash.conf':
    ensure  => file,
    content => template('logstash/logstash.conf.erb'),
    require => [Exec["untar ${filename}"], File["/etc/logstash-redis.conf"]],
  }

  service { 'logstash':
    ensure   => running,
    provider => 'upstart',
    require  => File['/etc/init/logstash.conf'],
  }
}