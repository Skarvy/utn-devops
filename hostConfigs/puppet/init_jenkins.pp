class jenkins {
    # get key
    exec { 'install_jenkins_key':
        command => '/usr/bin/wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add - ',
    }

    # update
    exec { 'apt-get update':
        command => '/usr/bin/apt-get update',
        require => File['/etc/apt/sources.list.d/jenkins.list'],
    }

    # source file
    file { '/etc/apt/sources.list.d/jenkins.list':
        content => "deb https://pkg.jenkins.io/debian-stable binary/\n",
        mode    => '0644',
        owner   => root,
        group   => root,
        require => Exec['install_jenkins_key'],
    }

    # jenkins package
    package { 'jenkins':
        ensure  => present,
        require => Exec['apt-get update'],
    }
	
	# Configuración por defecto para jenkins. La diferencia en este archivo 
	#solo es el cambio de puerto. Del 8080 al 8082
    file { '/etc/default/jenkins':
	    ensure  => present,
		force  => true,
        mode    => '0644',
        owner   => root,
        group   => root,
        require => Package['jenkins'],
		source => 'puppet:///modules/jenkins/jenkins_default',
    }
	#Archivo para el inicio del servicio de Jenkins. Mismo proposito que el anterior
	file { '/etc/init.d/jenkins':
	    ensure  => present,	
		force  => true,	
        mode    => '0755',
        owner   => root,
        group   => root,
        require => Package['jenkins'],
		source => 'puppet:///modules/jenkins/jenkins_init_d',
    }

    # jenkins service
    service { 'jenkins':
        ensure  => running,
        require => Package['jenkins'],
    }
}