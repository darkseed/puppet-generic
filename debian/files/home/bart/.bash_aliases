alias kickpuppet='sudo kill -USR1 $(sudo cat /var/run/puppet/puppetd.pid)'

allexec ()
{
        for host in lime-dom0.prot.db.kumina.nl kumquat-dom0.prot.db.kumina.nl pomelo-dom0.prot.db.kumina.nl management.prot.db.kumina.nl mailstore.prot.db.kumina.nl access.db.kumina.nl mailrelay.prot.db.kumina.nl database.prot.db.kumina.nl hosting.prot.db.kumina.nl backup.prot.db.kumina.nl mailman.prot.db.kumina.nl pbx1.prot.db.kumina.nl pbx2.prot.db.kumina.nl tangerine-dom0.prot.sit.kumina.nl backup.prot.sit.kumina.nl secondary.prot.sit.kumina.nl sandbox-bart.prot.db.kumina.nl management.prot.sit.kumina.nl builder.prot.sit.kumina.nl; do
                ssh -t $host $@
        done
}

alias allqs='for q in active bounce corrupt defer deferred flush hold incoming; do echo $q; sudo qshape $q; done'
