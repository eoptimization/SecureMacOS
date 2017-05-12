# Class: SecureMacOS
# ===========================
#
# Full description of class securemacintosh here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'SecureMacOS':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
# Joseph Yousefpour joseph@enterprisetechs.com
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class securemacos {
if $::osfamily != 'Darwin' {
    fail("unsupported osfamily: ${::osfamily}")
  }

#Enables update check
exec { 'checkforupdate':
  command => '/usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -int 1',
  onlyif => '/usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled 0',

 }

#Patches need to be applied in a timely manner to reduce the risk of vulnerabilities being exploited
exec { 'Enable system data files and security update installs':
  command => '/usr/bin/defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool true && sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool true',
 }

#Turn off Bluetooth, if no paired devices exist
exec { 'checkBluetooth':
  command => '/usr/bin/defaults write /Library/Preferences/com.apple.Bluetooth \ControllerPowerState -int 0',
 }
#Ensure no users have screen saver timeout over 600 seconds
 exec { 'checkscreensaver':
   command => '/usr/bin/defaults -currentHost write com.apple.screensaver idleTime -int 600',

 }
#Ensure remote Apple events are disabled
exec { 'AppleEventsOff':
  command => '/usr/sbin/systemsetup -setremoteappleevents off',

  }

#Disable Screen Sharing
exec { 'screensharingoff':
  command => '/usr/bin/defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool true',
 }

#Ensure 'nmdb' 'smdb' 'AppleFileServer' not found in 'launchctl list'
exec { 'disablefilesharing':
 command => '/bin/launchctl unload -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist && launchctl unload -w /System/Library/LaunchDaemons/com.apple.smbd.plist',
 }
#Enable Gatekeeper
exec { 'EnableGatekeeper':
  command => '/usr/sbin/spctl --master-enable',
 }

#Enable Firewall
exec { 'Enable Firewall':
  command => '/usr/bin/defaults write /Library/Preferences/com.apple.alf globalstate -int 1',
 }
#Ensure a password is required to wake the computer from sleep or screen saver
exec { 'PasswordScreenSaver':
  command => '/usr/bin/defaults write com.apple.screensaver askForPassword -int 1',
 }
#Restrict Password Hints
exec { 'Disable_Password_Hint':
  command => '/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow \ RetriesUntilHint -int 0',
 }
#Disable Guest Account
exec { 'Disable_Guest_Account':
  command => '/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool NO',
  }
#Ensure file extensions are displayed
exec { 'FileExtensionDisplayed':
  command => '/usr/bin/defaults write NSGlobalDomain AppleShowAllExtensions -bool true',
  } 
#Ensure files are not automatically opened by Safari
exec { 'Disable_Auto_Open':
  command => '/usr/bin/defaults write com.apple.Safari AutoOpenSafeDownloads -boolean no',
  }
}
