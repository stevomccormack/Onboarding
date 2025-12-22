# .shared/variables/gem.ps1

# -------------------------------------------------------------------------------------------------
# Gem (Ruby Package Manager) Configuration & Packages
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Gem Package Commands
# -------------------------------------------------------------------------------------------------
# Install a gem:
#   gem install <package>
# Update a gem:
#   gem update <package>
# Uninstall a gem:
#   gem uninstall <package>
# List installed gems:
#   gem list
# -------------------------------------------------------------------------------------------------

$gemInstallUrl = 'https://rubyinstaller.org/'
$gemDocsUrl = 'https://guides.rubygems.org/'
$gemPackagesUrl = 'https://rubygems.org/'

$Gem = [pscustomobject]@{
    InstallUrl          = $gemInstallUrl               # Ruby installation (includes RubyGems)
    DocsUrl             = $gemDocsUrl                  # RubyGems documentation
    PackagesUrl         = $gemPackagesUrl              # Package registry
    
    # Gem Configuration Settings
    NoDocument          = $true                        # Skip documentation installation
    Quiet               = $false                       # Quiet output
    Verbose             = $false                       # Verbose output
    Force               = $false                       # Force installation
    
    Packages = @(
        # Web Frameworks
        @{ Id = 'rails';                  Enabled = $false; Name = 'Ruby on Rails';                CommandName = 'rails';         TestCommand = 'rails --version';                    Url = 'https://rubygems.org/gems/rails' }
        @{ Id = 'sinatra';                Enabled = $false; Name = 'Sinatra';                      CommandName = 'ruby';          TestCommand = 'ruby -e "require ''sinatra/version''; puts Sinatra::VERSION"'; Url = 'https://rubygems.org/gems/sinatra' }
        
        # Static Site Generators
        @{ Id = 'jekyll';                 Enabled = $false; Name = 'Jekyll';                       CommandName = 'jekyll';        TestCommand = 'jekyll --version';                   Url = 'https://rubygems.org/gems/jekyll' }
        @{ Id = 'middleman';              Enabled = $false; Name = 'Middleman';                    CommandName = 'middleman';     TestCommand = 'middleman version';                  Url = 'https://rubygems.org/gems/middleman' }
        
        # DevOps & Infrastructure
        @{ Id = 'chef';                   Enabled = $false; Name = 'Chef';                         CommandName = 'chef';          TestCommand = 'chef --version';                     Url = 'https://rubygems.org/gems/chef' }
        @{ Id = 'puppet';                 Enabled = $false; Name = 'Puppet';                       CommandName = 'puppet';        TestCommand = 'puppet --version';                   Url = 'https://rubygems.org/gems/puppet' }
        
        # Package Management
        @{ Id = 'bundler';                Enabled = $false; Name = 'Bundler';                      CommandName = 'bundle';        TestCommand = 'bundle --version';                   Url = 'https://rubygems.org/gems/bundler' }
        
        # Code Quality
        @{ Id = 'rubocop';                Enabled = $false; Name = 'RuboCop';                      CommandName = 'rubocop';       TestCommand = 'rubocop --version';                  Url = 'https://rubygems.org/gems/rubocop' }
        
        # Testing
        @{ Id = 'rspec';                  Enabled = $false; Name = 'RSpec';                        CommandName = 'rspec';         TestCommand = 'rspec --version';                    Url = 'https://rubygems.org/gems/rspec' }
    )
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Gem` Variable:"
    $Gem | Format-List
}
