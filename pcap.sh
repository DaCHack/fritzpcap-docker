#!/bin/bash

SIDFILE="/tmp/fritz.sid"

if [ -z "$FRITZIP" ] || [ -z "$FRITZPWD" ] || [ -z "$FRITZUSER" ] ; then echo "FRITZUSER, FRITZPWD, FRITZIP must all be set" ; exit 1; fi

echo "Logging in as $FRITZUSER into Fritz!Box $FRITZIP"

if [ ! -f $SIDFILE ]; then
  touch $SIDFILE
fi

SID=$(cat $SIDFILE)

# Request challenge token from Fritz!Box
CHALLENGE=$(curl -k -s $FRITZIP/login_sid.lua | grep -o "<Challenge>[a-z0-9]\{8\}" | cut -d'>' -f 2)

# Very proprietary way of AVM: create an authentication token by hashing the challenge token with the password
HASH=$(perl -MPOSIX -e '
    use Digest::MD5 "md5_hex";
    my $ch_Pw = "$ARGV[0]-$ARGV[1]";
    $ch_Pw =~ s/(.)/$1 . chr(0)/eg;
    my $md5 = lc(md5_hex($ch_Pw));
    print $md5;
  ' -- "$CHALLENGE" "$FRITZPWD")
  curl -k -s "$FRITZIP/login_sid.lua" -d "response=$CHALLENGE-$HASH" -d 'username='${FRITZUSER} | grep -o "<SID>[a-z0-9]\{16\}" | cut -d'>' -f 2 > $SIDFILE

SID=$(cat $SIDFILE)

# Check for successfull authentication
if [[ $SID =~ ^0+$ ]] ; then echo "Login failed. Did you create & use explicit Fritz!Box users?" ; exit 1 ; fi

echo "Login successful"

echo "Creating pipes"
rm -f pcap/*
#mkfifo pcap/eth0 pcap/eth2 pcap/eth3 pcap/ath0 pcap/ath1
mkfifo pcap/lan pcap/ath0

echo "Starting packet capture on the pipes: $(ls pcap | xargs echo)"
#wget --no-check-certificate -qO- $FRITZIP/cgi-bin/capture_notimeout?ifaceorminor=1-eth0\&snaplen=\&capture=Start\&sid=$SID > pcap/eth0 &
#wget --no-check-certificate -qO- $FRITZIP/cgi-bin/capture_notimeout?ifaceorminor=1-eth2\&snaplen=\&capture=Start\&sid=$SID > pcap/eth2 &
#wget --no-check-certificate -qO- $FRITZIP/cgi-bin/capture_notimeout?ifaceorminor=1-eth3\&snaplen=\&capture=Start\&sid=$SID > pcap/eth3 &
wget --no-check-certificate -qO- $FRITZIP/cgi-bin/capture_notimeout?ifaceorminor=4-133\&snaplen=\&capture=Start\&sid=$SID > pcap/ath0 &
wget --no-check-certificate -qO- $FRITZIP/cgi-bin/capture_notimeout?ifaceorminor=4-133\&snaplen=\&capture=Start\&sid=$SID > pcap/lan &
#wget --no-check-certificate -qO- $FRITZIP/cgi-bin/capture_notimeout?ifaceorminor=4-135\&snaplen=\&capture=Start\&sid=$SID > pcap/ath1 &

echo "Capturing... (barrier reached)"

wait $(jobs -p)
echo "All packet capture jobs have been interrupted"